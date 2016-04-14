//
//  FetchTopStoriesOperation.m
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "FetchTopStoriesOperation.h"
#import "Model.h"
#import "ZYXPost.h"
#import "FetchPostContentOperation.h"

//#define kURL @"http://rss.cnn.com/rss/cnm_topstories.rss"
#define kURL @"http://localhost/cnn_topstories.rss"

@implementation FetchTopStoriesOperation

- (void)main
{
    [self postNotification:kTopStoriesStartNotification];
    [self startNetworkActivityIndicator];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]
                                initWithURL:[NSURL URLWithString:kURL]
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                timeoutInterval:30.0];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    NSLog(@"response = %@", response);
    if (data != nil)
    {
        TopStoriesParser *parser = [[TopStoriesParser alloc] initWithFeedData:data];
        parser.delegate = self;
        [parser parseTopStoriesFeed];
    }
    else
    {
        [self postNotification:kTopStoriesErrorNotification];
    }
    
    [self stopNetworkActivityIndicator];
}

#pragma mark - TopStoriesDelegate
- (void)topStoriesParsedWithResult:(NSMutableArray *)posts
{
    [Model sharedModel].posts = posts;
    NSLog(@"count ====== %ld", [Model sharedModel].posts.count);
    for (ZYXPost *post in posts)
    {
        FetchPostContentOperation *op = [[FetchPostContentOperation alloc] init];
        op.post = post;
        op.queuePriority = NSOperationQueuePriorityLow;
        [op enqueueOperation];
    }
    
    [self postNotification:kTopStoriesSuccessNotification];
}

@end
