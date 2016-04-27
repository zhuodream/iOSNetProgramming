//
//  AppDelegate.m
//  ZYXRelationShipManager
//
//  Created by 卓酉鑫 on 16/4/26.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "AppDelegate.h"
#import "ZYXModel.h"
#import "ContactsTableViewController.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "ContactsDetailTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification != nil)
    {
        NSDictionary *userInfo = localNotification.userInfo;
        
        NSString *action = [userInfo objectForKey:@"action"];
        ZYXContact *contact = [[ZYXModel sharedModel] contactWithEmailAddress:[userInfo objectForKey:@"emailAddress"]];
        if ([action isEqualToString:@"Call"])
        {
            NSString *phone = [NSString stringWithFormat:@"tel:%@", contact.phoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
        }
        else if ([action isEqualToString:@"Email"])
        {
            NSString *email = [NSString stringWithFormat:@"mailto:%@", contact.emailAddress];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
        }
    }
    
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ContactsTableViewController *contactsVC = [[ContactsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:contactsVC];
    
    self.window.rootViewController = self.navigationController;
    
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
    [[ZYXModel sharedModel] saveContext];
}

//接收到本地通知，该选项只有在已打开应用的情况下回走
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *userInfo = notification.userInfo;
        
        NSString *action = [userInfo objectForKey:@"action"];
        ZYXContact *contact = [[ZYXModel sharedModel] contactWithEmailAddress:[userInfo objectForKey:@"emailAddress"]];
        
        [UIAlertView alertViewWithTitle:@"Reminder" message:notification.alertBody cancelButtonTitle:@"Cancel" otherButtonTitles:[NSArray arrayWithObjects:@"View Contact", action, nil] onDismiss:^(int buttonIndex) {
            if (buttonIndex == 0)
            {
                ContactsDetailTableViewController *contactVC = [[ContactsDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                contactVC.contact = contact;
                contactVC.presentedModally = YES;
                
                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:contactVC];
                [self.navigationController presentViewController:nc animated:YES completion:nil];
            }
            else if (buttonIndex == 1)
            {
                if ([action isEqualToString:@"Call"])
                {
                    NSString *phone = [NSString stringWithFormat:@"tel:%@", contact.phoneNumber];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
                }
                else if ([action isEqualToString:@"Email"])
                {
                    NSString *email = [NSString stringWithFormat:@"mailto:%@", contact.emailAddress];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
                }
            }
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            
        } onCancel:^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }];
    });
    
    NSLog(@"收到通知");
    
}

@end
