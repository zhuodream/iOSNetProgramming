//
//  Tweet.m
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "Tweet.h"
#import "FetchTweetProfileImageOperation.h"
#import "Utils.h"

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)tweetData
{
    self = [super init];
    if (self)
    {
        self.identifier = [tweetData objectForKey:@"id_str"];
        self.fromUser = [tweetData objectForKey:@"from_user"];
        self.fromUserDisplay = [tweetData objectForKey:@"from_user_name"];
        self.profileImageURL = [tweetData objectForKey:@"profile_image_url"];
        self.text = [tweetData objectForKey:@"text"];
        self.createdDate = [Utils tweetDateFromString:[tweetData objectForKey:@"created_at"]];
    }
    
    FetchTweetProfileImageOperation *op = [[FetchTweetProfileImageOperation alloc] init];
    op.tweet = self;
    op.queuePriority = NSOperationQueuePriorityVeryHigh;
    [op enqueueOperation];
    
    return self;
}

@end
