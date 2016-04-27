//
//  AddContactTableViewController.m
//  ZYXRelationShipManager
//
//  Created by 卓酉鑫 on 16/4/26.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "AddContactTableViewController.h"
#import "ZYXModel.h"

#define kFieldTitleWidth 165

@interface AddContactTableViewController ()

@property (nonatomic, strong) UITextField *firstNameField;
@property (nonatomic, strong) UITextField *lastNameField;
@property (nonatomic, strong) UITextField *companyField;
@property (nonatomic, strong) UITextField *emailAddressField;
@property (nonatomic, strong) UITextField *phoneNumberField;
@property (nonatomic, strong) UITextView *noteField;

- (void)cancel:(id)sender;
- (void)saveContact:(id)sender;

@end

@implementation AddContactTableViewController

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
    
    self.title = @"Add Contact";
    
    UIBarButtonItem *cancleButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    self.navigationItem.leftBarButtonItem = cancleButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveContact:)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveContact:(id)sender {
    
    // save our contact
    BOOL contactAdded = [[ZYXModel sharedModel] addContactWithFirstName:_firstNameField.text
                                                            lastName:_lastNameField.text
                                                             company:_companyField.text
                                                        emailAddress:_emailAddressField.text
                                                         phoneNumber:_phoneNumberField.text
                                                             andNote:_noteField.text];
    if (contactAdded == YES) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Unable to add contact. Confirm email address doesn't already exist."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // notes section
    if (indexPath.section == 2) {
        return 100;
    }
    
    // all other cells are standard height
    return 44;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return @"Notes";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                if (_firstNameField == nil) {
                    _firstNameField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                   2,
                                                                                   cell.contentView.frame.size.width - kFieldTitleWidth,
                                                                                   40)];
                    _firstNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                cell.textLabel.text = @"First Name";
                cell.accessoryView = _firstNameField;
            } else if (indexPath.row == 1) {
                if (_lastNameField == nil) {
                    _lastNameField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                  2,
                                                                                  cell.contentView.frame.size.width - kFieldTitleWidth,
                                                                                  40)];
                    _lastNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                cell.textLabel.text = @"Last Name";
                cell.accessoryView = _lastNameField;
            } else {
                if (_companyField == nil) {
                    _companyField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                 2,
                                                                                 cell.contentView.frame.size.width - kFieldTitleWidth,
                                                                                 40)];
                    _companyField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                cell.textLabel.text = @"Company";
                cell.accessoryView = _companyField;
            }
            
            break;
            
        case 1:
            if (indexPath.row == 0) {
                if (_phoneNumberField == nil) {
                    _phoneNumberField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                     2,
                                                                                     cell.contentView.frame.size.width - 165,
                                                                                     40)];
                    _phoneNumberField.keyboardType = UIKeyboardTypePhonePad;
                    _phoneNumberField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                cell.textLabel.text = @"Phone Number";
                cell.accessoryView = _phoneNumberField;
            } else {
                if (_emailAddressField == nil) {
                    _emailAddressField = [[UITextField alloc] initWithFrame:CGRectMake(kFieldTitleWidth,
                                                                                      2,
                                                                                      cell.contentView.frame.size.width - kFieldTitleWidth,
                                                                                      40)];
                    _emailAddressField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }
                
                cell.textLabel.text = @"Email Address";
                cell.accessoryView = _emailAddressField;
            }
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}

@end
