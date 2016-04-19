//
//  ZYXNormalViewController.m
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXNormalViewController.h"
#import "ZYXModel.h"

@interface ZYXNormalViewController ()

@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UISwitch *rememberMeSwitch;

- (void)loginStartHandler:(NSNotification *)notification;
- (void)loginSuccessHandler:(NSNotification *)notification;
- (void)loginErrorHandler:(NSNotification *)notification;

@end

@implementation ZYXNormalViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStartHandler:) name:kNormalLoginStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessHandler:) name:kNormalLoginSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginErrorHandler:) name:kNormalLoginFailedNotification object:nil];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        return 2;
    }
    else
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
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = @"Username: ";
                if (self.usernameField == nil)
                {
                    self.usernameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
                    self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
                    self.usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                    [self.usernameField becomeFirstResponder];
                }
                cell.accessoryView = self.usernameField;
                break;
            case 1:
            default:
                cell.textLabel.text = @"Password: ";
                if (self.passwordField == nil)
                {
                    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
                    self.passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
                    self.passwordField.secureTextEntry = YES;
                    self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                cell.accessoryView = self.passwordField;
                break;
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
        
        cell.textLabel.text = @"Login";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if (indexPath.section == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:buttonCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inputCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        cell.textLabel.text = @"Remember Me";
        
        if (self.rememberMeSwitch == nil)
        {
            self.rememberMeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        }
        cell.accessoryView = self.rememberMeSwitch;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0) {
        if (self.usernameField.text.length == 0 || self.passwordField.text.length == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Validation Error"
                                        message:@"Username or Password is empty. Enter credentials and try again."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            return;
        }
        
        if (self.rememberMeSwitch.on == YES) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Choose Numeric PIN"
                                                         message:@""
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"OK", nil];
            
            av.alertViewStyle = UIAlertViewStyleSecureTextInput;
            av.tag = 1;
            [av show];
            return;
        }
        // attempt authentication
        [[ZYXModel sharedModel] authenticateWithUsername:self.usernameField.text
                                          andPassword:self.passwordField.text
                                       registerDevice:self.rememberMeSwitch.on
                                         withPasscode:@""];
        
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        // attempt authentication
        if (buttonIndex == 1) {
            UITextField *pinField = [alertView textFieldAtIndex:0];
            [[ZYXModel sharedModel] authenticateWithUsername:self.usernameField.text
                                              andPassword:self.passwordField.text
                                           registerDevice:self.rememberMeSwitch.on
                                             withPasscode:pinField.text];
        }
    }
}

#pragma mark - Notification Handlers

- (void)loginStartHandler:(NSNotification*)notification {
    // you could do something here like update the UI. this example relies on the activity indicator
}

- (void)loginSuccessHandler:(NSNotification*)notification {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginErrorHandler:(NSNotification*)notification {
    NSLog(@"收到通知");
    [[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                message:@"Invalid username or password. Please try again."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}


@end
