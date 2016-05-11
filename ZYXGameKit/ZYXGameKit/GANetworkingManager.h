//
//  GANetworkingManager.h
//  ZYXGameKit
//
//  Created by 卓酉鑫 on 16/5/11.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "GAPeer.h"
#import "GANetworkingPackets.h"

@class GANetworkingManager;

@protocol GANetworkingManagerLobbyDelegate <NSObject>

- (void)peerListDidChange:(GANetworkingManager *)manager;
- (void)didReceiveInvitation:(GANetworkingManager *)manager fromPeer:(GAPeer *)peer;
- (void)cancelInvitationFromPeer:(GAPeer *)peer;
- (void)invitationDidFail:(GANetworkingManager *)session fromPeer:(GAPeer *)peer;
- (void)connectionSuccessful:(GANetworkingManager *)session withPeer:(GAPeer *)peer;

@end

@protocol GANetworkingManagerAuctionDelegate <NSObject>

- (void)managerWillDisConnect:(GANetworkingManager *)manager;
- (void)manager:(GANetworkingManager *)manager didReceivePacket:(NSData *)data ofType:(GAPacketType)packetType;

@end

@interface GANetworkingManager : NSObject <GKSessionDelegate>

@property (nonatomic, strong) NSMutableArray *peerList;
@property (nonatomic, strong) id<GANetworkingManagerLobbyDelegate> lobbyDelegate;
@property (nonatomic, strong) id<GANetworkingManagerAuctionDelegate> auctionDelegate;

+ (GANetworkingManager *)sharedManager;

- (void)setupSession;
- (void)stopAcceptingInvitation;
- (void)startAcceptingInvitation;

- (GAPeer *)devicePeer;
- (GAPeer *)peerFromPeerID:(NSString *)peerID;
- (NSString *)displayNameForPeer:(GAPeer *)peer;

- (void)connect:(GAPeer *)peerID;
- (void)didAcceptInvitationFromPeer:(GAPeer *)peer;
- (void)didDeclineInvitationFromPeer:(GAPeer *)peer;
- (void)withdrawInvitationToPeer:(GAPeer *)peer;
- (void)disconnectFromAllPeers;
- (void)disconnectFromPeer:(GAPeer *)peer;

- (void)sendPacket:(NSData *)data ofType:(GAPacketType)type;

@end
