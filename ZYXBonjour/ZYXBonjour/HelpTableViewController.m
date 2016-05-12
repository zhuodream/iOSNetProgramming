//
//  HelpTableViewController.m
//  ZYXBonjourServer
//
//  Created by 卓酉鑫 on 16/5/12.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "HelpTableViewController.h"
#import "Bonjour.h"

@interface HelpTableViewController ()
{
    UITextField *serviceNameField;
    NSIndexPath *availabilityCellPath;
    BOOL available;
}

- (void)handleBonjourPublishStart:(NSNotification *)notification;
- (void)handleBonjourPublishSuccess:(NSNotification *)notification;
- (void)handleBonjourPublishError:(NSNotification *)notification;
- (void)handleBonjourStopSuccess:(NSNotification *)notification;

@end

@implementation HelpTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        available = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Associate Help";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBonjourPublishStart:) name:kPublishBonjourStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBonjourPublishSuccess:) name:kPublishBonjourSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBonjourPublishError:) name:kPublishBonjourErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBonjourStopSuccess:) name:kStopBonkourSuccessNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *inputIdentifier = @"InputCell";
    UITableViewCell *inputCell = [tableView dequeueReusableCellWithIdentifier:inputIdentifier];
    
    static NSString *ActionIdentifier = @"ActionCell";
    
    UITableViewCell *actionCell = [tableView dequeueReusableCellWithIdentifier:ActionIdentifier];
    
    if (indexPath.section == 0)
    {
        if (inputCell == nil)
        {
            inputCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inputIdentifier];
        }
        
        inputCell.textLabel.text = @"Department";
        inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (serviceNameField == nil)
        {
            serviceNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 2, 160, 40)];
            
            serviceNameField.placeholder = @"Department Name";
            serviceNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        }
        
        inputCell.accessoryView = serviceNameField;
        
        return inputCell;
    }
    else if (indexPath.section == 1)
    {
        if (actionCell == nil)
        {
            actionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ActionIdentifier];
            actionCell.textLabel.textAlignment = NSTextAlignmentCenter;
            actionCell.textLabel.textColor = [UIColor blueColor];
        }
        
        if (indexPath.row == 0)
        {
            availabilityCellPath = indexPath;
            if (available == YES)
            {
                actionCell.textLabel.text = @"No Longer Availabel";
            }
            else
            {
                actionCell.textLabel.text = @"I'm Availabel";
            }
        }
        
        return actionCell;
    }
    
    return nil;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            if (available == YES)
            {
                NSLog(@"停止服务");
                [[Bonjour sharedPublisher] stopService];
                available = NO;
            }
            else
            {
                if (serviceNameField.text == nil)
                {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Department name is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    return;
                }
                
                BOOL serviceRslt = [[Bonjour sharedPublisher] publishServiceWithName:serviceNameField.text];
                
                if (serviceRslt == NO)
                {
                    NSString *errorMsg = @"Unable to publish your services at this time. Please try again.";
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
            }
        }
    }
}

#pragma mark - Bonjour Notifications
- (void)handleBonjourPublishStart:(NSNotification *)notification
{
    NSLog(@"Started publishing");
}

- (void)handleBonjourPublishSuccess:(NSNotification *)notification
{
    available = YES;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:availabilityCellPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)handleBonjourPublishError:(NSNotification *)notification
{
    NSLog(@"Error publishing");
}

- (void)handleBonjourStopSuccess:(NSNotification *)notification
{
    available = NO;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:availabilityCellPath] withRowAnimation:UITableViewRowAnimationNone];
}
@end
