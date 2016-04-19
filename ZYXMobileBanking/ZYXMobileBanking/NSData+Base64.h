//
//  NSData+Base64.h
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 base64方法在iOS7之后，系统已经提供了可用的加密和解密方法
 
 */
@interface NSData (Base64)

+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
- (id)initWithBase64EncodedString:(NSString *)string;

- (NSString *)base64Encoding;
- (NSString *)base64EncodingWithLineLength:(NSUInteger)lineLength;

@end
