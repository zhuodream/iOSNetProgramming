//
//  ViewController.m
//  ZYXLowLevelNetwork
//
//  Created by 卓酉鑫 on 16/4/25.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ViewController.h"
#import "ZYXBSDSocketController.h"
#import "ZYXCFNetworkController.h"
#import "ZYXNSStreamController.h"

#define kWarehouseFeedHost @"warehouse.example.com"
#define kWarehouseFeedPort 1102

@interface ViewController ()

@property (nonatomic, strong) ZYXNetworkingResult *mostRecentResults;
@property (nonatomic, strong) NSNumberFormatter *formatter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formatter = [[NSNumberFormatter alloc] init];
    [self.formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [self.formatter setMinimumFractionDigits:1];
    [self.formatter setMaximumFractionDigits:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshButtonTapped:(id)sender
{
    switch (self.networkingTypeSelector.selectedSegmentIndex)
    {
        case 0:
        {
            ZYXBSDSocketController *bsdSocketController = [[ZYXBSDSocketController alloc] initWithURLString:kWarehouseFeedHost port:kWarehouseFeedPort];
            bsdSocketController.delegate = self;
            [bsdSocketController start];
            break;
        }
            // CFNetwork
        case 1: {
            ZYXCFNetworkController *cfNetworkController = [[ZYXCFNetworkController alloc] initWithURLString:kWarehouseFeedHost port:kWarehouseFeedPort];
            cfNetworkController.delegate = self;
            
            [cfNetworkController start];
            break;
        }
            
            // NSStream
        case 2: {
            ZYXNSStreamController *nsStreamController = [[ZYXNSStreamController alloc] initWithURLString:kWarehouseFeedHost port:kWarehouseFeedPort];
            nsStreamController.delegate = self;
            
            [nsStreamController start];
            break;
        }
            
        default:
            break;
    }

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"resultCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.row)
    {
        case 0:
            cell.textLabel.text = @"Room Temperature";
            if (self.mostRecentResults.temperatureRoom != nil)
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@°F", [self.formatter stringFromNumber:self.mostRecentResults.temperatureRoom]];
            }
            else
            {
                cell.detailTextLabel.text = nil;
            }
            break;
        case 1:
            cell.textLabel.text = @"Outlet Temperature";
            
            if (self.mostRecentResults.temperatureOutlet != nil)
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@°F", [self.formatter stringFromNumber:self.mostRecentResults.temperatureOutlet]];
            }
            else
            {
                cell.detailTextLabel.text = nil;
            }
            break;
        case 2:
            cell.textLabel.text = @"Coil Tenperature";
            
            if (self.mostRecentResults.temperatureCoil != nil)
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@°F", [self.formatter stringFromNumber:self.mostRecentResults.temperatureCoil]];
            }
            else
            {
                cell.detailTextLabel.text = nil;
            }
            break;
        case 3:
            cell.textLabel.text = @"Compressor";
            
            if (self.mostRecentResults != nil)
            {
                cell.detailTextLabel.text = (self.mostRecentResults.statusCompressorOn ? @"On" : @"Off");
            }
            else
            {
                cell.detailTextLabel.text = nil;
            }
            break;
        case 4:
            cell.textLabel.text = @"Air Switch";
            
            if (self.mostRecentResults != nil) {
                cell.detailTextLabel.text = (self.mostRecentResults.statusAirSwitchOn ? @"On" : @"Off");
            } else {
                cell.detailTextLabel.text = nil;
            }
            
            break;
            
        case 5:
            cell.textLabel.text = @"Auxilary Heat";
            
            if (self.mostRecentResults != nil) {
                cell.detailTextLabel.text = (self.mostRecentResults.statusAuxilaryHeatOn ? @"On" : @"Off");
            } else {
                cell.detailTextLabel.text = nil;
            }
            
            break;
            
        case 6:
            cell.textLabel.text = @"Front Door";
            
            if (self.mostRecentResults != nil) {
                cell.detailTextLabel.text = (self.mostRecentResults.statusFrontDoorOpen ? @"Open" : @"Closed");
            } else {
                cell.detailTextLabel.text = nil;
            }
            
            break;
            
        case 7:
            cell.textLabel.text = @"System Status";
            
            if (self.mostRecentResults != nil) {
                cell.detailTextLabel.text = (self.mostRecentResults.statusSystemStandby ? @"Standby" : @"Ready");
            } else {
                cell.detailTextLabel.text = nil;
            }
            
            break;
            
        case 8:
            cell.textLabel.text = @"Alarm";
            
            if (self.mostRecentResults != nil) {
                cell.detailTextLabel.text = (self.mostRecentResults.statusAlarmActive ? @"Active" : @"Normal");
            } else {
                cell.detailTextLabel.text = nil;
            }
            
            break;
    
        default:
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
            break;
    }
    
    return cell;
}

#pragma mark - ZYXNetworkingResultsDelegate

- (void)networkingResultsDidStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
}

- (void)networkingResultsDidLoad:(ZYXNetworkingResult *)result
{
    self.mostRecentResults = result;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        self.refreshButton.enabled = YES;
        [self.tableView reloadData];
    });
}

- (void)networkingResultDidFail:(NSString *)errorMessgae
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        self.refreshButton.enabled = YES;
        
        [[[UIAlertView alloc] initWithTitle:@"Error" message:errorMessgae delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    });
}


@end
