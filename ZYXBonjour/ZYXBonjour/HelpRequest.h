//
//  HelpRequest.h
//  ZYXBonjourServer
//
//  Created by 卓酉鑫 on 16/5/12.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelpRequest : NSObject <NSCoding>

@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSString *location;

@end
