//
//  ViewController.h
//  ZYXLowLevelNetwork
//
//  Created by 卓酉鑫 on 16/4/25.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYXNetworkingController.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ZYXNetworkingDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *networkingTypeSelector;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)refreshButtonTapped:(id)sender;


@end

