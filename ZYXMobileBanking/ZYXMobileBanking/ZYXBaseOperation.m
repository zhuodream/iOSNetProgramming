//
//  ZYXBaseOperation.m
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYXBaseOperation.h"
#import "ZYXModel.h"

@implementation ZYXBaseOperation

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}

- (void)enqueueOperation
{
    [[ZYXModel sharedModel] enqueueOperation:self];
}

- (void)postNotification:(NSString *)notificationName withStatusCode:(NSString *)statusCode andResultSet:(id)resultSet
{
    statusCode = (statusCode != nil) ? statusCode : @"";
    resultSet = (resultSet != nil) ? resultSet : @"";
    
    //build response
    NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:statusCode, kZYXStatusCode, resultSet, kZYXResultSet, nil];
    
    //在主线程中通知
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:response];
    });
}

- (BOOL)requestWasSuccessful:(NSHTTPURLResponse *)response error:(NSError *)error
{
    NSInteger statusCode = response.statusCode;
    
    //handle the one off cass for httpcode 401(unauthorized)
    if (error != nil && error.code == NSURLErrorUserCancelledAuthentication)
    {
        statusCode = 401;
        
        //clear the token
        [[ZYXModel sharedModel] signOut];
    }
    
    switch (statusCode)
    {
        case 200:
        case 201:
        case 202:
        case 204:
            // successful response
            return YES;
            break;
            
        case 500:
        case 501:
        case 502:
        case 503:
        case 504:
        case 505:
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Service Down"
                                            message:@"Acme Bank's mobile service is down for maintenance."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            });
            return NO;
        default:
            // check if the connect timed out and alert accordingly
            if (error != nil && error.code == NSURLErrorTimedOut) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Service Down"
                                                message:@"Your request timed out. Please try again later."
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                });
            }
            return NO;
            break;
    }
    
    // inform user via simple alert view that an unexpected case occurred
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"Unexpected Error"
                                    message:@"Acme Bank's services are down."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    });
    return NO;
}

- (NSMutableURLRequest *)buildRequestWithURL:(NSString *)url httpMethod:(NSString *)method payload:(NSMutableDictionary *)payload timeout:(NSTimeInterval)timeout signingOption:(ZYXRequestSigningOption)signingOption
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeout];
    
    switch (signingOption)
    {
        case ZYXRequestSigningOptionQuerystring:
            // here we would check for a ? and add one if needed prior to adding our token
            break;
        case ZYXRequestSigningOptionPayload:
            [payload setObject:[ZYXModel sharedModel].token forKey:@"auth-token"];
            break;
        case ZYXRequestSigningOptionHeader:
            [request setValue:[ZYXModel sharedModel].token forHTTPHeaderField:@"auth-token"];
        case ZYXRequestSigningOptionNone:
        default:
            break;
    }
    
    [request setHTTPMethod:method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if (payload != nil)
    {
        NSError *error = nil;
        NSData *requestBody = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:&error];
        
        [request setHTTPBody:requestBody];
    }
    
    return request;
}

+ (BOOL)operationInProcess
{
    return NO;
}

+ (NSURLProtectionSpace *)certificateAuthenticationProtectionSpace
{
    NSURLProtectionSpace *space = [[NSURLProtectionSpace alloc] initWithHost:@"67.205.6.121"
                                                                        port:443
                                                                    protocol:NSURLProtectionSpaceHTTPS
                                                                       realm:@"mobilebanking"
                                                        authenticationMethod:NSURLAuthenticationMethodClientCertificate];
    return space;
}

#pragma mark - Copying
- (id)copyWithZone:(NSZone *)zone
{
    ZYXBaseOperation *copy = [[[self class] allocWithZone:zone] init];
    return copy;
}

@end
