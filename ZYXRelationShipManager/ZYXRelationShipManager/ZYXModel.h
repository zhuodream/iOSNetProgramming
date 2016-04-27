//
//  ZYXModel.h
//  ZYXRelationShipManager
//
//  Created by 卓酉鑫 on 16/4/26.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZYXContact.h"

@interface ZYXModel : NSObject

+ (ZYXModel *)sharedModel;

- (NSArray *)contacts;

- (void)scheduleNotificationWithFireDate:(NSDate *)fireDate timeZone:(NSTimeZone *)timeZone repeatInterval:(NSCalendarUnit)repeatInterval alertBody:(NSString *)alertBody alertAction:(NSString *)alertAction launchImage:(NSString *)launchImage soundName:(NSString *)soundName badgeNumber:(NSInteger)badgeNumber andUserInfo:(NSDictionary *)userInfo;

- (void)scheduleContaceFollowUpForContact:(ZYXContact *)contact onDate:(NSDate *)date withBody:(NSString *)body andAction:(NSString *)action;

- (NSArray *)notificationsForContact:(ZYXContact *)contact;

- (void)cancelNotificationsForContact:(ZYXContact *)contact;

@end
