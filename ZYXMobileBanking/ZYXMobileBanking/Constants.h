//
//  Constants.h
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

typedef NS_ENUM(NSInteger, ZYXRequestSigningOption)
{
    ZYXRequestSigningOptionNone = 0,
    ZYXRequestSigningOptionQuerystring,
    ZYXRequestSigningOptionPayload,
    ZYXRequestSigningOptionHeader
};

#define kZYXStatusCode  @"ZYX-StatusCode"
#define kZYXResultSet   @"ZYX-ResultSet"

#define kAESEncryptionKey   @"b36013521d0f5dbea0e4ac1fd7af804a"
#define kDESEncryptionKey   @"b36013521d0f5dbea0e4ac1f"
#define kMACKey             @"065a62448fb75fce3764dcbe68f9908d"

#define kAccountOperationSuccessful @"AccountOperationSuccessful"
#define kAccountOperationError      @"AccountOperationError"

#define kNormalLoginStartNotification   @"NormalLoginStart"
#define kNormalLoginSuccessNotification @"NormalLoginSuccess"
#define kNormalLoginFailedNotification  @"NormalLoginFail"

#define kRegisteredLoginStartNotification   @"RegisteredLoginStart"
#define kRegisteredLoginSuccessNotification @"RegisteredLoginSuccess"
#define kRegisteredLoginFailedNotification  @"RegisteredLoginFailed"

#define kFundsTransferStartNotification     @"FundsTransferStart"
#define kFundsTransferSuccessNotification   @"FundsTransferSuccess"
#define kFundsTransferFailedNotification    @"FundsTransferFailed"

#endif /* Constants_h */
