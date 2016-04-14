//
//  Model.m
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "Model.h"
#import "FetchTopStoriesOperation.h"
#import "FetchPostContentOperation.h"
#import "FetchPostTweetsOperation.h"
#import "ShareArticlesOperationXML.h"
#import "ShareArticlesOperationJSON.h"

@interface Model ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation Model

static Model *instance = nil;

- (id)init
{
    self = [super init];
    return self;
}

+ (Model *)sharedModel
{
    if (instance == nil)
    {
        instance = [[self alloc] init];
    }
    
    return instance;
}

#pragma mark - Queue Management
- (void)enqueueOperation:(NSOperation *)op
{
    if (self.queue == nil)
    {
        self.queue = [[NSOperationQueue alloc] init];
        [self.queue setMaxConcurrentOperationCount:5];
    }
    
    [self.queue addOperation:op];
}

#pragma mark - Post Management
- (void)fecthTopStories
{
    FetchTopStoriesOperation *op = [[FetchTopStoriesOperation alloc] init];
    op.queuePriority = NSOperationQueuePriorityVeryHigh;
    [op enqueueOperation];
}

- (void)fetchContentForPost:(ZYXPost *)post
{
    FetchPostContentOperation *op = [[FetchPostContentOperation alloc] init];
    op.post = post;
    op.queuePriority = NSOperationQueuePriorityVeryHigh;
    [op enqueueOperation];
}

- (void)fetchTweetsForPost:(ZYXPost *)post
{
    FetchPostTweetsOperation *op = [[FetchPostTweetsOperation alloc] init];
    op.post = post;
    [op enqueueOperation];
}

- (void)sharePostsWithType:(PayloadShareType)type {
    
    if (type == PayloadShareTypeJSON) {
        ShareArticlesOperationJSON *op = [[ShareArticlesOperationJSON alloc] init];
        op.posts = _posts;
        op.shareType = type;
        [op enqueueOperation];
    } else {
        ShareArticlesOperationXML *op = [[ShareArticlesOperationXML alloc] init];
        op.posts = _posts;
        op.shareType = type;
        [op enqueueOperation];
    }
    
}

@end
