//
//  HelpResponse.m
//  ZYXBonjourServer
//
//  Created by 卓酉鑫 on 16/5/12.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "HelpResponse.h"

@implementation HelpResponse

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.response forKey:@"response"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.response = [aDecoder decodeBoolForKey:@"response"];
    return self;
}

@end
