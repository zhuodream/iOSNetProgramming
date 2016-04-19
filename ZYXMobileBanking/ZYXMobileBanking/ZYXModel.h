//
//  ZYXModel.h
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface ZYXModel : NSObject

@property (nonatomic, strong) NSMutableArray *accounts;
@property (nonatomic, strong) NSString *token;

+ (ZYXModel *)sharedModel;
- (void)enqueueOperation:(NSOperation *)op;
- (void)enqueuePendingOperation:(NSOperation *)op;

- (void)authenticateWithUsername:(NSString *)username andPassword:(NSString *)password registerDevice:(BOOL)registerDevice withPasscode:(NSString *)passcode;
- (void)authenticateWithCertificateAndPin:(NSString *)pin;
- (void)signOut;
- (void)fetchAccounts;
- (void)registerDevice;
- (BOOL)isDeviceRegistered;

- (void)transferFundsFromAccount:(NSString *)fromAccount toAccount:(NSString *)toAccount effectiveDate:(NSDate *)transferDate withAmount:(double)amount andNotes:(NSString *)notes;

- (NSArray *)vaildProtectionSpaces;
- (NSURLProtectionSpace *)clientCerficateProtectionSpace;

@end
