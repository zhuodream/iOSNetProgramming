//
//  ZYXDashboardViewController.m
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXDashboardViewController.h"
#import "ZYXModel.h"
#import "ZYXNormalViewController.h"
#import "ZYXRegisterViewController.h"

@interface ZYXDashboardViewController ()

@property (nonatomic, strong) NSArray *dashboardActions;

@end

@implementation ZYXDashboardViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Acme Bank";
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([ZYXModel sharedModel].token == nil)
    {
        if ([ZYXModel sharedModel].isDeviceRegistered == NO)
        {
            ZYXNormalViewController *vc = [[ZYXNormalViewController alloc] initWithStyle:UITableViewStyleGrouped];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nc animated:YES completion:nil];
        }
        else
        {
            NSLog(@"证书验证操作");
            ZYXRegisterViewController *vc = [[ZYXRegisterViewController alloc] initWithStyle:UITableViewStyleGrouped];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:nc animated:YES completion:nil];
        }
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Accounts";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            cell.textLabel.text = @"Transfer Funds";
            break;
        case 2:
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = @"Logout";
            break;
        default:
            break;
    }
    
    // Configure the cell...
    
    return cell;
}


@end
