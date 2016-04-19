//
//  Utils.h
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (void)identity:(SecIdentityRef *)identity andCertificate:(SecCertificateRef *)certificate fromPKS12Data:(NSData *)cerData withPassphrase:(NSString *)passphrase;

@end
