//
//  BaseOperation.m
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "BaseOperation.h"
#import "Model.h"
#import <UIKit/UIKit.h>

@implementation BaseOperation

static NSString *activityIndicatorLock = @"activityIndicatorLock";
static NSInteger activityIndicatorCount = 0;

- (void)enqueueOperation
{
    [[Model sharedModel] enqueueOperation:self];
}

- (void)postNotification:(NSString *)notificationName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:nil];
    });
}

- (void)startNetworkActivityIndicator
{
    @synchronized (activityIndicatorLock)
    {
        if (activityIndicatorCount == 0)
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
        activityIndicatorCount++;
    }
}

- (void)stopNetworkActivityIndicator
{
    @synchronized (activityIndicatorLock)
    {
        activityIndicatorCount--;
        if (activityIndicatorCount < 1)
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            activityIndicatorCount = 0;
        }
    }
}

@end
