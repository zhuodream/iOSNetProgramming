//
//  AddReminderTableViewController.h
//  ZYXRelationShipManager
//
//  Created by 卓酉鑫 on 16/4/27.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYXContact.h"

@interface AddReminderTableViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) ZYXContact *contact;

@end
