//
//  ViewController.m
//  TestReachability
//
//  Created by 卓酉鑫 on 16/4/18.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"

@interface ViewController ()

@property (nonatomic, strong) Reachability *reachability;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus reach = [self.reachability currentReachabilityStatus];
    if ( reach == NotReachable)
    {
        NSLog(@"没有网络连接");
    }
    else if (reach == ReachableViaWWAN)
    {
        NSLog(@"蜂窝移动");
    }
    else if (reach == ReachableViaWiFi)
    {
        NSLog(@"无线网络");
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
    [self.reachability startNotifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)networkChanged:(NSNotification *)notification
{
    NSLog(@"网络变化");
    Reachability *reachability = [notification object];
    if ([reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        NSLog(@"无线网络");
    }
    else if ([reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        NSLog(@"蜂窝网络");
    }
    else if ([reachability currentReachabilityStatus] == NotReachable)
    {
        NSLog(@"无网络");
    }
}

@end
