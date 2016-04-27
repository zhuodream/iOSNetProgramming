//
//  ZYXModel.m
//  ZYXRelationShipManager
//
//  Created by 卓酉鑫 on 16/4/26.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXModel.h"

@implementation ZYXModel

+ (ZYXModel *)sharedModel
{
    static ZYXModel *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)scheduleNotificationWithFireDate:(NSDate *)fireDate timeZone:(NSTimeZone *)timeZone repeatInterval:(NSCalendarUnit)repeatInterval alertBody:(NSString *)alertBody alertAction:(NSString *)alertAction launchImage:(NSString *)launchImage soundName:(NSString *)soundName badgeNumber:(NSInteger)badgeNumber andUserInfo:(NSDictionary *)userInfo
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = fireDate;
    notification.timeZone = timeZone;
    notification.repeatInterval = repeatInterval;
    notification.alertBody = alertBody;
    notification.alertLaunchImage = launchImage;
    notification.soundName = soundName;
    notification.applicationIconBadgeNumber = badgeNumber;
    notification.userInfo = userInfo;
    
    if (alertAction == nil)
    {
        notification.hasAction = NO;
    }
    else
    {
        notification.alertAction = alertAction;
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    });
}

- (void)scheduleContaceFollowUpForContact:(ZYXContact *)contact onDate:(NSDate *)date withBody:(NSString *)body andAction:(NSString *)action
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:contact.emailAddress, @"emailAddress", contact.phoneNumber, @"phoneNumber", @"contaceProfile", @"type", action, @"action", nil];
    
    [self scheduleNotificationWithFireDate:date timeZone:[NSTimeZone systemTimeZone] repeatInterval:0 alertBody:body alertAction:action launchImage:@"" soundName:nil badgeNumber:1 andUserInfo:userInfo];
}

- (NSArray *)notificationsForContact:(ZYXContact *)contact
{
    NSMutableArray *contactNotifications = [[NSMutableArray alloc] init];
    NSArray *scheduledNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *notification in scheduledNotifications)
    {
        if ([notification.userInfo objectForKey:@"emailAddress"])
        {
            [contactNotifications addObject:notification];
        }
    }
    
    return contactNotifications;
}

- (void)cancelNotificationsForContact:(ZYXContact *)contact
{
    NSArray *notificatons = [self notificationsForContact:contact];
    for (UILocalNotification *notification in notificatons)
    {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}

@end
