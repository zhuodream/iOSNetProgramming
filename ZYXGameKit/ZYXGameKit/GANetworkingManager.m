//
//  GANetworkingManager.m
//  ZYXGameKit
//
//  Created by 卓酉鑫 on 16/5/11.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "GANetworkingManager.h"
#import "AppDelegate.h"

@interface GANetworkingManager ()
{
    GKSession *_session;
}

- (void)destroySession;

@end

@implementation GANetworkingManager

+ (GANetworkingManager *)sharedManager
{
    static GANetworkingManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _peerList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - GKSession
- (void)setupSession
{
    if (_session != nil)
    {
        [[GANetworkingManager sharedManager] destroySession];
    }
    
    _session = [[GKSession alloc] initWithSessionID:kGameKitSessionID displayName:nil sessionMode:GKSessionModePeer];
    
    _session.delegate = self;
    [_session setDataReceiveHandler:self withContext:nil];
    
    [_lobbyDelegate peerListDidChange:self];
}

- (void)stopAcceptingInvitation
{
    _session.available = NO;
}

- (void)startAcceptingInvitation
{
    _session.available = YES;
}

- (GAPeer*)devicePeer {
    return [[GAPeer alloc] initWithPeerID:_session.peerID];
}

- (void)connect:(GAPeer *)peerID
{
    if (peerID == nil)
    {
        return;
    }
    
    [_session connectToPeer:peerID.peerID withTimeout:10.0];
    peerID.state = GKPeerStateConnecting;
}

- (void)didAcceptInvitationFromPeer:(GAPeer *)peer
{
    if (peer == nil)
    {
        return;
    }
    
    NSError *error = nil;
    if (![_session acceptConnectionFromPeer:peer.peerID error:&error])
    {
        NSLog(@"error in accept = %@", [error localizedDescription]);
    }
}

- (void)didDeclineInvitationFromPeer:(GAPeer *)peer
{
    if (peer == nil)
    {
        return;
    }
    
    if (peer.state != GKPeerStateDisconnected)
    {
        [_session denyConnectionFromPeer:peer.peerID];
        peer.state = GKPlayerStateDisconnected;
    }
}

- (NSString *)displayNameForPeer:(GAPeer *)peer
{
    return [_session displayNameForPeer:peer.peerID];
}

- (void)sendPacket:(NSData *)data ofType:(GAPacketType)type
{
    NSMutableData *newPacket = [NSMutableData dataWithCapacity:([data length] + sizeof(uint32_t))];
    uint32_t swappedType = CFSwapInt32HostToBig((uint32_t)type);
    [newPacket appendBytes:&swappedType length:sizeof(uint32_t)];
    [newPacket appendData:data];
    
    NSError *error;
    if (![_session sendDataToAllPeers:newPacket withDataMode:GKSendDataReliable error:&error])
    {
        NSLog(@"Error sending packet: %@", [error localizedDescription]);
    }
}

- (void)disconnectFromAllPeers
{
    [_auctionDelegate managerWillDisConnect:self];
    for (GAPeer *peer in _peerList)
    {
        if (peer.state != GKPeerStateDisconnected)
        {
            if (peer.state == GKPeerStateConnecting)
            {
                [_session cancelConnectToPeer:peer.peerID];
            }
            
            peer.state = GKPeerStateDisconnected;
        }
    }
    
    [_session disconnectFromAllPeers];
}

- (void)disconnectFromPeer:(GAPeer *)peer
{
    if (peer == nil)
    {
        return;
    }
    
    if (peer.state != GKPeerStateDisconnected)
    {
        if (peer.state == GKPeerStateConnecting)
        {
            [_session cancelConnectToPeer:peer.peerID];
        }
        
        peer.state = GKPeerStateDisconnected;
    }
    
    [_session disconnectPeerFromAllPeers:peer.peerID];
}

- (void)destroySession
{
    [self disconnectFromAllPeers];
    
    _session.delegate = nil;
    
    [_session setDataReceiveHandler:nil withContext:nil];
    [_peerList removeAllObjects];
}

#pragma mark -GKSessionDelegate

- (GAPeer *)peerFromPeerID:(NSString *)peerID
{
    for (GAPeer *p in _peerList)
    {
        if (p.peerID == peerID)
        {
            return p;
        }
    }
    
    return nil;
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"didRecieve = %@", peerID);
    GAPeer *peer = [self peerFromPeerID:peerID];
    
    if (peer == nil)
    {
        return;
    }
    
    if (peer.state == GKPeerStateDisconnected)
    {
        peer.state = GKPeerStateConnecting;
        
        [_lobbyDelegate didReceiveInvitation:self fromPeer:peer];
    }
    else
    {
        [session denyConnectionFromPeer:peerID];
    }
}

- (void)withdrawInvitationToPeer:(GAPeer *)peer
{
    if (peer == nil)
    {
        return;
    }
    
    [_session cancelConnectToPeer:peer.peerID];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"connectionWithPeerFailed=%@",[error localizedDescription]);
    
    GAPeer* peer = [self peerFromPeerID:peerID];
    if (peer == nil) {
        return;
    }
    
    if (peer.state != GKPeerStateDisconnected) {
        
        // tell the UI that the invitation failed
        [_lobbyDelegate invitationDidFail:self fromPeer:peer];
        
        // mark this peer as disconnected
        peer.state = GKPeerStateDisconnected;
    }
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    GAPeer* peer = [self peerFromPeerID:peerID];
    NSLog(@"state changed = %@", peerID);
    switch (state) {
        case GKPeerStateAvailable:
            // this peer became available
            
            //peer.state = GKPeerStateAvailable;
            
            // if this is the first time we've seen this peer, add to our peer list
            if (![_peerList containsObject:peer] || peer == nil) {
                [_peerList addObject:[[GAPeer alloc] initWithPeerID:peerID]];
            }
            
            // tell the UI to update
            [_lobbyDelegate peerListDidChange:self];
            
            break;
            
        case GKPeerStateUnavailable:
            // this peer became unavailable
            
            [_peerList removeObject:peer];
            
            // tell the UI to cancel any pending invitations and update
            [_lobbyDelegate cancelInvitationFromPeer:peer];
            [_lobbyDelegate peerListDidChange:self];
            
            break;
            
        case GKPeerStateConnected:
            // this peer accepted our connection
            
            peer.state = GKPeerStateConnected;
            
            // tell the UI we connected
            [_lobbyDelegate connectionSuccessful:self withPeer:peer];
            
            break;
            
        case GKPeerStateDisconnected:
            // this peer disconnected from the session
            
            [self disconnectFromPeer:peer];
            [_peerList removeObject:peer];
            
            // tell the UI to update
            [_lobbyDelegate peerListDidChange:self];
            
            break;
            
        default:
            break;
    }
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"失败");
}

- (void)receiveData:(NSData*)data fromPeer:(NSString*)peerID inSession:(GKSession*)session context:(void*)context {
    GAPacketType header;
    uint32_t swappedHeader;
    
    if ([data length] >= sizeof(uint32_t)) {
        [data getBytes:&swappedHeader length:sizeof(uint32_t)];
        header = (GAPacketType)CFSwapInt32BigToHost(swappedHeader);
        NSRange payloadRange = {sizeof(uint32_t), [data length]-sizeof(uint32_t)};
        NSData* payload = [data subdataWithRange:payloadRange];
        
        // tell the auction that we received a packet
        [_auctionDelegate manager:self didReceivePacket:payload ofType:header];
    }
}
@end
