//
//  ContactsTableViewController.h
//  ZYXRelationShipManager
//
//  Created by 卓酉鑫 on 16/4/26.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYXContact.h"

@interface ContactsTableViewController : UITableViewController<UIActionSheetDelegate>

@property(nonatomic,strong) ZYXContact *contact;
@property(nonatomic,assign) BOOL presentedModally;

@end
