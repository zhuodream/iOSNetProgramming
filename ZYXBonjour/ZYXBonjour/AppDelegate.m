//
//  AppDelegate.m
//  ZYXBonjour
//
//  Created by 卓酉鑫 on 16/5/12.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "AppDelegate.h"
#import "HelpTableViewController.h"
#import "Bonjour.h"

@interface AppDelegate () <UIAlertViewDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(helpRequestHandler:) name:kHelpRequestedNotification object:nil];
    
    HelpTableViewController *helpVC = [[HelpTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:helpVC];
    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Notification Handlers
- (void)helpRequestHandler:(NSNotification *)notification
{
    HelpRequest *request = (HelpRequest *)[[notification userInfo] objectForKey:kNotificationResultSet];
    
    NSString *helpString = [NSString stringWithFormat:@"Help requested in %@ with: %@.", request.location, request.question];
    
    UIAlertView *helpAlert = [[UIAlertView alloc] initWithTitle:@"Help Request" message:helpString delegate:self cancelButtonTitle:@"I'm Unavailable" otherButtonTitles:@"I'll help", nil];
    helpAlert.tag = 1;
    [helpAlert show];
}

#pragma mark - UIALertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case 1:
        {
            HelpResponse *response = [[HelpResponse alloc] init];
            
            if (buttonIndex == 0)
            {
                NSLog(@"点击response");
                response.response = NO;
            }
            else if (buttonIndex == 1)
            {
                NSLog(@"1111");
                response.response = YES;
            }
            
            [[Bonjour sharedPublisher] sendHelpResponse:response];
            break;
        }
        default:
            break;
    }
}

@end
