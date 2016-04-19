//
//  ZYXCertificateAuthenticateOperation.m
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/20.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXCertificateAuthenticateOperation.h"
#import <UIKit/UIKit.h>

#define kEndpoint @"?method=user/authenticate/certificate"
#define kHttpMethod @"POST"
#define kOperationTimeout 30.0

@interface ZYXCertificateAuthenticateOperation () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation ZYXCertificateAuthenticateOperation
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
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRegisteredLoginStartNotification object:nil];
    });
    
    NSString *url = [kResourceBaseURL stringByAppendingFormat:@"%@&pin=%@", kEndpoint, self.pin];
    
    NSMutableURLRequest *request = [self buildRequestWithURL:url httpMethod:kHttpMethod payload:nil timeout:kOperationTimeout signingOption:ZYXRequestSigningOptionNone];
    
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

- (BOOL)operationInProcess
{
    return kZXYOperationInProcess;
}

#pragma mark - Copy
- (id)copyWithZone:(NSZone *)zone
{
    ZYXCertificateAuthenticateOperation *copy = [super copyWithZone:zone];
    copy.pin = self.pin;
    
    return copy;
}

#pragma mark - NSURLConnection Delegate
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
        
        [[ZYXModel sharedModel] fetchAccounts];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kRegisteredLoginSuccessNotification object:nil];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kRegisteredLoginFailedNotification object:nil];
        });
    }
    
    [self finish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRegisteredLoginFailedNotification object:nil];
    });
    
    [self finish];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
    // validate that the authentication challenge came from a whitelisted protection space
    if (![[[ZYXModel sharedModel] validProtectionSpaces] containsObject:challenge.protectionSpace]) {
        // dispatch alert view message to the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Unsecure Connection"
                                        message:@"We're unable to establish a secure connection. Please check your network connection and try again."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        });
        
        // cancel authentication
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
    
    // user the clients certificate
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate) {
        
        // proceed with authentication
        if (challenge.previousFailureCount == 0) {
            
            // retrieve the default credential specifically for client certificate challenges
            NSURLCredential *credential = [[NSURLCredentialStorage sharedCredentialStorage]
                                           defaultCredentialForProtectionSpace:[[ZYXModel sharedModel] clientCerficateProtectionSpace]];
            if (credential) {
                [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
            }
            
            // authentication has previously failed. depending on authentication configuration, too
            // many attempts here could lead to a poor user experience via locked accounts
        } else {
            
            // cancel the authentication attempt
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            
            // alert the user that their credentials are invalid
            // this would typically be handled in a cleaner manner such as updating the styled login view
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Invalid Certificate"
                                            message:@"The certificate used is not valid. Please login using your username and password."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            });
            
        }
    }
    
    // if nothing catches this challenge, attempt to connect without credentials
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];

}

@end
