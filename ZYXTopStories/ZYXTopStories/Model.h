//
//  Model.h
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYXPost.h"

typedef NS_ENUM(NSInteger, PayloadShareType)
{
    PayloadShareTypeJSON = 0,
    PayloadShareTypeXML,
};

#define kTopStoriesStartNotification    @"TopStoresOperationStart"
#define kTopStoriesSuccessNotification  @"TopStoresOperationSucess"
#define kTopStoriesErrorNotification    @"TopStoresOperationError"

#define kPostContentStartNotification   @"PostContentOperationStart"
#define kPostContentSuccessNotification @"PostContentsOperationSuccess"
#define kPostContentErrorNotification   @"PostContentOperationError"

#define kTweetsStartNotification                @"TweetsOperationStart"
#define kTweetsSuccessNotification              @"TweetsOperationSuccess"
#define kTweetsErrorNotification                @"TweetsOperationError"

#define kShareArticleStartNotification          @"ShareArticleOperationStart"
#define kShareArticleSuccessNotification        @"ShareArticleOperationSuccess"
#define kShareArticleErrorNotification          @"ShareArticleOperationError"

#define kTweetProfileImageSuccessNotification   @"TweetProfileImageOperationSuccess"

@interface Model : NSObject

@property (nonatomic, strong) NSMutableArray *posts;

+ (Model *)sharedModel;

- (void)enqueueOperation:(NSOperation *)op;

- (void)fecthTopStories;

- (void)fetchContentForPost:(ZYXPost *)post;

- (void)fetchTweetsForPost:(ZYXPost *)post;

- (void)sharePostsWithType:(PayloadShareType)type;

@end
