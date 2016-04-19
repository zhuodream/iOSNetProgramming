//
//  ZYXBaseOperation.h
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "ZYXModel.h"


#define kResourceBaseURL    @"http://192.168.1.90/chapter6"

@interface ZYXBaseOperation : NSOperation <NSCopying>

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSMutableData *responseData;

- (void)enqueueOperation;
- (void)postNotification:(NSString *)notificationName withStatusCode:(NSString *)statusCode andResultSet:(id)resultSet;
- (BOOL)requestWasSuccessful:(NSHTTPURLResponse *)response error:(NSError *)error;
- (NSMutableURLRequest *)buildRequestWithURL:(NSString *)url httpMethod:(NSString *)method payload:(NSMutableDictionary *)payload timeout:(NSTimeInterval)timeout signingOption:(ZYXRequestSigningOption)signingOption;

//override in each subclass
+ (BOOL)operationInProcess;
+ (NSURLProtectionSpace *)certificateAuthenticationProtectionSpace;

@end
