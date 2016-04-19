//
//  ZYXAuthenticateOperation.h
//  ZYXMobileBanking
//
//  Created by 卓酉鑫 on 16/4/19.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYXBaseOperation.h"

@interface ZYXAuthenticateOperation : ZYXBaseOperation

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *passphrased;
@property (nonatomic, assign) BOOL registerDevice;

@end
