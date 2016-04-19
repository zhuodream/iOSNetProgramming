//
//  Utils.m
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "Utils.h"
#import <Security/SecRandom.h>

@implementation Utils

+ (void)identity:(SecIdentityRef *)identity andCertificate:(SecCertificateRef *)certificate fromPKS12Data:(NSData *)cerData withPassphrase:(NSString *)passphrase
{
    // adapted from https://developer.apple.com/library/IOs/#documentation/Security/Conceptual/CertKeyTrustProgGuide/iPhone_Tasks/iPhone_Tasks.html#//apple_ref/doc/uid/TP40001358-CH208-SW13
    
    // bridge our import data to foundation objects
    CFStringRef importPassphrase = (__bridge CFStringRef)passphrase;
    CFDataRef importData = (__bridge CFDataRef)cerData;
    
    //create dictionary of options for the PKCS12 import
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { importPassphrase };
    
    CFDictionaryRef importOptions = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    //create array to store our import results
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus pkcs12ImportStatus = SecPKCS12Import(importData, importOptions, &items);
    
    if (pkcs12ImportStatus == errSecSuccess)
    {
        CFDictionaryRef identityAndTrust = CFArrayGetValueAtIndex(items, 0);
        const void *tempIdentity = NULL;
        
        tempIdentity = CFDictionaryGetValue(identityAndTrust, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
        
        //从identity中提取证书信息
        SecCertificateRef tempCertificate = NULL;
        OSStatus certificateStatus = errSecSuccess;
        certificateStatus = SecIdentityCopyCertificate(*identity, &tempCertificate);
        *certificate = (SecCertificateRef)tempCertificate;
    }
    
    if (importOptions)
    {
        CFRelease(importOptions);
    }
    
//    if (items)
//    {
//        CFRelease(items);
//    }
}

@end
