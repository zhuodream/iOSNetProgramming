//
//  Reachability.h
//  TestReachability
//
//  Created by 卓酉鑫 on 16/4/18.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef enum : NSInteger{
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
}NetworkStatus;

extern NSString *kReachabilityChangedNotification;

@interface Reachability : NSObject

+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;

+ (instancetype)reachabilityForInternetConnection;

+ (instancetype)reachabilityForLocalWifi;

- (BOOL)startNotifier;

- (void)stopNotifier;

- (NetworkStatus)currentReachabilityStatus;

- (BOOL)connectionRequired;

@end
