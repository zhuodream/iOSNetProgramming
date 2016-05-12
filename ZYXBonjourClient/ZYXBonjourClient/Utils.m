//
//  Utils.m
//  ZYXBonjourServer
//
//  Created by 卓酉鑫 on 16/5/12.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (void)postNotification:(NSString *)notificationName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:nil];
    });
}

@end
