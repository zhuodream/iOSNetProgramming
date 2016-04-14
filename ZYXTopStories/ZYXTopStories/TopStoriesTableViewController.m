//
//  TopStoriesTableViewController.m
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "TopStoriesTableViewController.h"
#import "Model.h"
#import "Utils.h"
#import "PostViewContentViewController.h"

@interface TopStoriesTableViewController ()

- (void)handleTopStoriesStart:(id)notification;
- (void)handleTopStoriesSuccess:(id)notification;
- (void)handleTopStoriesError:(id)notification;

@end

@implementation TopStoriesTableViewController

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
    
    self.title = @"CNN Top Stories";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTopStoriesStart:) name:kTopStoriesStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTopStoriesSuccess:) name:kTopStoriesSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTopStoriesError:) name:kTopStoriesErrorNotification object:nil];
    
    [[Model sharedModel] fecthTopStories];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[Model sharedModel] posts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    ZYXPost *post = [[Model sharedModel].posts objectAtIndex:indexPath.row];
    cell.textLabel.text = post.title;
    cell.detailTextLabel.text = [Utils prettyStringFromDate:post.pubDate];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZYXPost *post = [[Model sharedModel].posts objectAtIndex:indexPath.row];
    PostViewContentViewController *pvc = [[PostViewContentViewController alloc] init];
    pvc.post = post;
    
    [self.navigationController pushViewController:pvc animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma  mark - Notification Handlers
- (void)handleTopStoriesStart:(id)notification
{
    
}

- (void)handleTopStoriesSuccess:(id)notification
{
    [self.tableView reloadData];
}

- (void)handleTopStoriesError:(id)notification
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to download the top stories feed fromC CNN" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

@end
