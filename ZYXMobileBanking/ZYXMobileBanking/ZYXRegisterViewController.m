//
//  ZYXRegisterViewController.m
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXRegisterViewController.h"
#import "ZYXModel.h"

@interface ZYXRegisterViewController ()

@property (nonatomic, strong) UITextField *pinField;

- (void)loginStartHandler:(NSNotification *)notification;
- (void)loginSuccessHandler:(NSNotification *)notification;
- (void)loginErrorHandler:(NSNotification *)notification;

@end

@implementation ZYXRegisterViewController

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
    
    self.title = @"Login";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStartHandler:)
                                                 name:kRegisteredLoginStartNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSuccessHandler:)
                                                 name:kRegisteredLoginSuccessNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginErrorHandler:)
                                                 name:kRegisteredLoginFailedNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *inputCell = @"inputCell";
    static NSString *buttonCell = @"buttonCell";
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:inputCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inputCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"PIN: ";
            if (self.pinField == nil)
            {
                self.pinField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 49)];
                self.pinField.autocorrectionType = UITextAutocorrectionTypeNo;
                self.pinField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                self.pinField.keyboardType = UIKeyboardTypeNumberPad;
                [self.pinField becomeFirstResponder];
            }
            
            cell.accessoryView = self.pinField;
        }
    }
    else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:buttonCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonCell];
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Login";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[ZYXModel sharedModel] authenticateWithCertificateAndPin:self.pinField.text];
}

#pragma mark - Notification Handlers

- (void)loginStartHandler:(NSNotification*)notification {
    // you could do something here like update the UI. this example relies on the activity indicator
}

- (void)loginSuccessHandler:(NSNotification*)notification {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginErrorHandler:(NSNotification*)notification {
    NSLog(@"收到失败通知");
    [[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                message:@"Unable to authenticate. Please try again."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
