//
//  ContactsTableViewController.m
//  ZYXRelationShipManager
//
//  Created by 卓酉鑫 on 16/4/26.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "ZYXModel.h"
#import "ZYXContact.h"
#import "ContactsDetailTableViewController.h"

#import "AddContactTableViewController.h"

@interface ContactsTableViewController ()

@property (nonatomic, strong) NSArray *contacts;

- (void)addContact:(id)sender;

@end

@implementation ContactsTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        _contacts = [[NSArray alloc] init];
    }
    
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Contacts";
    
    self.contacts = [[ZYXModel sharedModel] contacts];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.contacts = [[ZYXModel sharedModel] contacts];
    [self.tableView reloadData];
}

#pragma mark - UI Response
- (void)addContact:(id)sender
{
    AddContactTableViewController *addVC = [[AddContactTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:addVC];
    [self.navigationController presentViewController:nc animated:YES completion:nil];
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
    return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    ZYXContact *contact = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", contact.lastName, contact.firstName];
    cell.detailTextLabel.text = contact.emailAddress;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZYXContact *contact = [self.contacts objectAtIndex:indexPath.row];
    ContactsDetailTableViewController *detailVC = [[ContactsDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailVC.contact = contact;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}


@end
