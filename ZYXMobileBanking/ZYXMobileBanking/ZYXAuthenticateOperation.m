//
//  ZYXAuthenticateOperation.m
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXAuthenticateOperation.h"
#import <UIKit/UIKit.h>

#define kEndPoint @"?method=user/authenticate/basic"
#define kHTTPMethod @"POST"
#define kOperationTimeOut 30.0

@interface ZYXAuthenticateOperation () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation ZYXAuthenticateOperation
{
    BOOL _isExecuting;
    BOOL _isFinished;
}

static BOOL kZXYOperationInProcess = NO;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _isExecuting = NO;
        _isFinished = NO;
    }
    
    return self;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)start
{
    //在主线程上执行登录方法
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNormalLoginStartNotification object:nil];
    });
    
    //创建认证请求
    NSString *url;
    url = [kResourceBaseURL stringByAppendingString:kEndPoint];
    
    if (_registerDevice == YES)
    {
        url = [url stringByAppendingFormat:@"&register=true&pin=%@", self.passphrased];
    }
    NSLog(@"url = %@", url);
    NSMutableURLRequest *request = [self buildRequestWithURL:url httpMethod:kHTTPMethod payload:nil timeout:kOperationTimeOut signingOption:ZYXRequestSigningOptionNone];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)finish
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.connection = nil;
    [self willChangeValueForKey:@"isEcecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

+ (BOOL)operationInProcess
{
    return kZXYOperationInProcess;
}

#pragma mark - Copy
- (id)copyWithZone:(NSZone *)zone
{
    ZYXAuthenticateOperation *copy = [super copyWithZone:zone];
    copy.username = self.username;
    copy.password = self.password;
    return copy;
}

#pragma mark - NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [[NSMutableData alloc] init];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"response = %@", [httpResponse allHeaderFields]);
    self.statusCode = httpResponse.statusCode;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.statusCode == 200)
    {
        NSError *error = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&error];
        
        NSString *token = [response objectForKey:@"token"];
        
        [ZYXModel sharedModel].token = token;
        
        if (self.registerDevice)
        {
            NSString *certString = [response objectForKey:@"certificate"];
            NSLog(@"certString = %@", certString);
            NSData *certData = [[NSData alloc] initWithBase64EncodedString:certString options:0];
            NSLog(@"data = %@", certData);
            
            
        }
        
        [[ZYXModel sharedModel] fetchAccounts];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNormalLoginSuccessNotification object:nil];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNormalLoginFailedNotification object:nil];
        });
    }
    
    [self finish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"加载失败");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNormalLoginFailedNotification object:nil];
    });
    
    [self finish];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"请求认证");
    //to be vertified by http basic
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic)
    {
        if (challenge.previousFailureCount == 0)
        {
            NSURLCredential *creds = [[NSURLCredential alloc] initWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceForSession];
            
            [challenge.sender useCredential:creds forAuthenticationChallenge:challenge];
        }
        else
        {
            [challenge.sender cancelAuthenticationChallenge:challenge];
            //don't need this, the connection will call connection:didFailWithError
            /*
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNormalLoginFailedNotification object:nil];
            });*/
        }
    }
}

@end
