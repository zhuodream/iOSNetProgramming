//
//  HelpRequest.m
//  ZYXBonjourServer
//
//  Created by 卓酉鑫 on 16/5/12.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "HelpRequest.h"

@implementation HelpRequest

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.question forKey:@"question"];
    [aCoder encodeObject:self.location forKey:@"location"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.question = [aDecoder decodeObjectForKey:@"question"];
    self.location = [aDecoder decodeObjectForKey:@"location"];
    
    return self;
}

@end
