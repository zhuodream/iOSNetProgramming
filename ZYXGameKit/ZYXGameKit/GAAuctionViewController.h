//
//  GAAuctionViewController.h
//  ZYXGameKit
//
//  Created by 卓酉鑫 on 16/5/11.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GANetworkingManager.h"

@interface GAAuctionViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, GANetworkingManagerAuctionDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *peerList;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) GAPeer *host;
@property (nonatomic, assign) BOOL isHost;

@end
