//
//  ViewController.m
//  ZYXGameKit
//
//  Created by 卓酉鑫 on 16/5/11.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "GALobbyViewController.h"
#import "GAAuctionViewController.h"

@interface GALobbyViewController ()
{
    UIAlertView *_alertView;
    NSMutableArray *confirmedPeers;
    int remainingAcks;
    UIBarButtonItem *startButton;
    
    GAPeer *inviter;
}

- (void)startTapped:(id)sender;
- (void)openAuctionScreenAsParticipant;
- (void)openAuctionScreenAsHostWithItem:(NSString *)itemName;

@end

@implementation GALobbyViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.title = NSLocalizedString(@"Participants", @"Participant");
        startButton = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleDone target:self action:@selector(startTapped:)];
        self.navigationItem.rightBarButtonItem = startButton;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    startButton.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    remainingAcks = 0;
    confirmedPeers = [[NSMutableArray alloc] init];
    [[GANetworkingManager sharedManager] setupSession];
    [[GANetworkingManager sharedManager] startAcceptingInvitation];
    startButton.enabled = NO;
    
    for (GAPeer *s in [GANetworkingManager sharedManager].peerList)
    {
        NSInteger loc = [[GANetworkingManager sharedManager].peerList indexOfObject:s];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:loc inSection:0]];
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[GANetworkingManager sharedManager] stopAcceptingInvitation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI Response
- (void)startTapped:(id)sender
{
    UIAlertView *itemNameAlert = [[UIAlertView alloc] initWithTitle:nil message:@"What item will you be auctioning" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Start Auction", nil];
    itemNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    itemNameAlert.tag = 999;
    [itemNameAlert show];
    
    [[GANetworkingManager sharedManager] stopAcceptingInvitation];
}

- (void)openAuctionScreenAsParticipant
{
    GAAuctionViewController *auctionVC = [[GAAuctionViewController alloc] init];
    auctionVC.isHost = NO;
    auctionVC.host = inviter;
    
    [GANetworkingManager sharedManager].auctionDelegate = auctionVC;
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:auctionVC] animated:YES completion:nil];
}

- (void)openAuctionScreenAsHostWithItem:(NSString *)itemName
{
    GAAuctionViewController *auctionVC = [[GAAuctionViewController alloc] init];
    auctionVC.isHost = YES;
    auctionVC.host = [GANetworkingManager sharedManager].devicePeer;
    auctionVC.itemName = itemName;
    auctionVC.peerList = [GANetworkingManager sharedManager].peerList;
    
    [GANetworkingManager sharedManager].auctionDelegate = auctionVC;
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    GAPeer *devicePeer = [[GANetworkingManager sharedManager] devicePeer];
    
    [dataDic setObject:devicePeer.peerID forKey:@"ownerPeerID"];
    [dataDic setObject:itemName forKey:@"itemName"];
    [dataDic setObject:[NSNumber numberWithInteger:[confirmedPeers count]] forKey:@"numberOfParticipants"];
    
    if ([confirmedPeers count] > 0)
    {
        GAPeer *peer = [confirmedPeers objectAtIndex:0];
        [dataDic setObject:peer.peerID forKey:@"participant1PeerID"];
    }
    
    if ([confirmedPeers count] > 1)
    {
        GAPeer *peer = [confirmedPeers objectAtIndex:1];
        [dataDic setObject:peer.peerID forKey:@"participant2PeerID"];
    }
    
    if ([confirmedPeers count] > 2)
    {
        GAPeer *peer = [confirmedPeers objectAtIndex:2];
        [dataDic setObject:peer.peerID forKey:@"participant3PeerID"];
    }
    
    if ([confirmedPeers count] > 3)
    {
        GAPeer *peer = [confirmedPeers objectAtIndex:3];
        [dataDic setObject:peer.peerID forKey:@"participant4PeerID"];
    }
    
    if ([confirmedPeers count] > 4)
    {
        GAPeer *peer = [confirmedPeers objectAtIndex:4];
        [dataDic setObject:peer.peerID forKey:@"participant5PeerID"];
    }
    
    if ([confirmedPeers count] > 5)
    {
        GAPeer *peer = [confirmedPeers objectAtIndex:5];
        [dataDic setObject:peer.peerID forKey:@"participant6PeerID"];
    }
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dataDic forKey:@"AuctionStarted"];
    [archiver finishEncoding];
    
    [[GANetworkingManager sharedManager] sendPacket:data ofType:GAPacketTypeAuctionStart];
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:auctionVC] animated:YES completion:nil];
}

#pragma  mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[GANetworkingManager sharedManager] peerList].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    GAPeer *peer = [[[GANetworkingManager sharedManager] peerList] objectAtIndex:indexPath.row];
    cell.textLabel.text = [[GANetworkingManager sharedManager] displayNameForPeer:peer];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    GAPeer *peer = [[GANetworkingManager sharedManager].peerList objectAtIndex:indexPath.row];
    
    if ([confirmedPeers count] >= 6)
    {
        UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"Too Many Participants" message:@"You can't send any more invitations because you have reached the maximum of 6 participants." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [msg show];
        return;
    }
    else if (([confirmedPeers count] + remainingAcks) >= 6)
    {
        UIAlertView	*msg = [[UIAlertView alloc]
                            initWithTitle:@"Too Many Invitations"
                            message:[NSString stringWithFormat:@"You can't send any more invitations because you have invited the maximum of 6 participants (%lu confirmed & %i pending).", (unsigned long)[confirmedPeers count], remainingAcks]
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
        [msg show];
        return;
    }
    
    if (cell.accessoryView == nil)
    {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        
        cell.accessoryView = spinner;
        
        remainingAcks++;
        startButton.enabled = NO;
        NSLog(@"连接周围的人");
        [[GANetworkingManager sharedManager] connect:peer];
    }
}

#pragma mark - GANetworkingManagerLobbyDelegate

- (void)peerListDidChange:(GANetworkingManager *)manager
{
    [self.tableView reloadData];
}

- (void)connectionSuccessful:(GANetworkingManager *)session withPeer:(GAPeer *)peer
{
    if (peer != nil)
    {
        NSInteger loc = [session.peerList indexOfObject:peer];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:loc inSection:0]];
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        remainingAcks--;
        [confirmedPeers addObject:peer];
        
        if (remainingAcks == 0 && [confirmedPeers count] > 0)
        {
            startButton.enabled = YES;
        }
    }
}

- (void)didReceiveInvitation:(GANetworkingManager *)manager fromPeer:(GAPeer *)peer
{
    NSString *peerName = [manager displayNameForPeer:peer];
    if (peerName == nil || peerName.length <= 0)
    {
        peerName = @"Unknown";
    }
    
    NSString *str = [NSString stringWithFormat:@"Invitation from %@", peerName];
    if (_alertView.visible)
    {
        [_alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    
    inviter = peer;
    
    _alertView = [[UIAlertView alloc] initWithTitle:str message:[NSString stringWithFormat:@"Do you want to join %@'s auction", peerName] delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:nil];
    [_alertView addButtonWithTitle:@"Join"];
    _alertView.tag = 200;
    [_alertView show];
}

- (void)cancelInvitationFromPeer:(GAPeer *)peer
{
    NSString *name = [[GANetworkingManager sharedManager] displayNameForPeer:peer];
    if (_alertView.title != nil && [_alertView.title length] != 0)
    {
        NSRange notFound = [_alertView.title rangeOfString:name];
        
        if (_alertView != nil && _alertView.visible && notFound.location != NSNotFound)
        {
            [_alertView dismissWithClickedButtonIndex:0 animated:NO];
            
            _alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ Has Disappeared", name] message:[NSString stringWithFormat:@"The invitation from %@ was automatically canceled because the device can no longer be found", name] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [_alertView show];
        }
    }
}

- (void)invitationDidFail:(GANetworkingManager *)session fromPeer:(GAPeer *)peer
{
    NSString *peerName = [session displayNameForPeer:peer];
    if (peerName == nil || peerName.length <= 0)
    {
        peerName = @"Unknown";
    }
    
    NSString *str;
    if (_alertView.visible)
    {
        [_alertView dismissWithClickedButtonIndex:0 animated:NO];
        str = [NSString stringWithFormat:@"%@ cancelled your invitation.", peerName];
    }
    else
    {
        str = [NSString stringWithFormat:@"%@ declined your invitation.", peerName];
    }
    
    _alertView = [[UIAlertView alloc] initWithTitle:str message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [_alertView show];
    
    NSInteger loc = -1;
    for (GAPeer *p in session.peerList)
    {
        if ([[session displayNameForPeer:p] isEqualToString:[session displayNameForPeer:peer]])
        {
            loc = [session.peerList indexOfObject:p];
            break;
        }
    }
    
    if (loc >= 0)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:loc inSection:0]];
        
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellEditingStyleNone;
        remainingAcks--;
        
        if (remainingAcks == 0 && [confirmedPeers count] > 0)
        {
            startButton.enabled = YES;
        }
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 200)
    {
        if (buttonIndex == 1)
        {
            startButton.enabled = NO;
            [[GANetworkingManager sharedManager] didAcceptInvitationFromPeer:inviter];
            [self openAuctionScreenAsParticipant];
        }
        else
        {
            [[GANetworkingManager sharedManager] didDeclineInvitationFromPeer:inviter];
        }
    }
    else if (alertView.tag == 999)
    {
        [self openAuctionScreenAsHostWithItem:[alertView textFieldAtIndex:0].text];
    }
}



@end
