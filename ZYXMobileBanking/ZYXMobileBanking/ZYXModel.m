//
//  ZYXModel.m
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXModel.h"
#import "ZYXAuthenticateOperation.h"
#import "ZYXCertificateAuthenticateOperation.h"

@interface ZYXModel ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableArray *pendingOperations;

@end

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

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}

- (void)enqueueOperation:(NSOperation *)op
{
    if (self.queue == nil)
    {
        self.queue = [[NSOperationQueue alloc] init];
        [self.queue setMaxConcurrentOperationCount:5];
    }
    
    [self.queue addOperation:op];
}

- (void)enqueuePendingOperation:(NSOperation *)op
{
    if (self.pendingOperations == nil)
    {
        self.pendingOperations = [[NSMutableArray alloc] init];
    }
    
    [self.pendingOperations addObject:op];
}

- (void)authenticateWithUsername:(NSString *)username andPassword:(NSString *)password registerDevice:(BOOL)registerDevice withPasscode:(NSString *)passcode
{
    ZYXAuthenticateOperation *operation = [[ZYXAuthenticateOperation alloc] init];
    operation.username = username;
    operation.password = password;
    operation.registerDevice = registerDevice;
    operation.passphrased = passcode;
    [operation enqueueOperation];
}

- (void)authenticateWithCertificateAndPin:(NSString *)pin
{
    ZYXCertificateAuthenticateOperation *operation = [[ZYXCertificateAuthenticateOperation alloc] init];
    operation.pin = pin;
    [operation enqueueOperation];
}

- (NSArray *)validProtectionSpaces
{
    // valid supported protection spaces
    NSURLProtectionSpace *defaultSpace = [[NSURLProtectionSpace alloc] initWithHost:@"192.168.1.152"
                                                                               port:443
                                                                           protocol:NSURLProtectionSpaceHTTPS
                                                                              realm:@"mobile"
                                                               authenticationMethod:NSURLAuthenticationMethodDefault];
    
    NSURLProtectionSpace *trustSpace = [[NSURLProtectionSpace alloc] initWithHost:@"192.168.1.152"
                                                                             port:443
                                                                         protocol:NSURLProtectionSpaceHTTPS
                                                                            realm:nil
                                                             authenticationMethod:NSURLAuthenticationMethodServerTrust];
    
    NSURLProtectionSpace *certSpace = [[NSURLProtectionSpace alloc] initWithHost:@"192.168.1.152"
                                                                            port:443
                                                                        protocol:NSURLProtectionSpaceHTTPS
                                                                           realm:nil
                                                            authenticationMethod:NSURLAuthenticationMethodClientCertificate];
    
    return [NSArray arrayWithObjects:defaultSpace, trustSpace, certSpace, nil];
}

- (void)fetchAccounts
{
    
}

- (void)signOut
{
    self.token = nil;
}

- (void)registerDevice
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"registeredDevice"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isDeviceRegistered
{
    BOOL registered = [[NSUserDefaults standardUserDefaults] boolForKey:@"registeredDevice"];
    if (registered == YES)
    {
        return YES;
    }
    
    return NO;
}

- (NSURLProtectionSpace *)clientCerficateProtectionSpace
{
    NSURLProtectionSpace *certSpace = [[NSURLProtectionSpace alloc] initWithHost:@"localhost" port:443 protocol:NSURLProtectionSpaceHTTPS realm:nil authenticationMethod:NSURLAuthenticationMethodClientCertificate];
    
    return certSpace;
}


@end
