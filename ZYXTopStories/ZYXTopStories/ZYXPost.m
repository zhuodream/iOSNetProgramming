//
//  ZYXPost.m
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXPost.h"
#import "Utils.h"

@implementation ZYXPost

- (NSDictionary *)dictionaryRepresentation
{
    NSString *pubDateString = [NSString stringWithFormat:@"%@", self.pubDate];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[Utils urlEncode:self.title], @"title",
            [Utils urlEncode:self.postDescription],@"description",
            [Utils urlEncode:self.author], @"author",
            [Utils urlEncode:self.section], @"section",
            [Utils urlEncode:self.contentURL], @"contentURL",
            [Utils urlEncode:pubDateString], @"pubDate",nil];
}

@end
