//
//  BaseOperation.h
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseOperation : NSOperation

- (void)enqueueOperation;

- (void)postNotification:(NSString *)notificationName;

- (void)startNetworkActivityIndicator;

- (void)stopNetworkActivityIndicator;

@end
