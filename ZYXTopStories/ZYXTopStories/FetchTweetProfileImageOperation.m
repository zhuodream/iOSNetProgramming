//
//  FetchTweetProfileImageOperation.m
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "FetchTweetProfileImageOperation.h"
#import "Model.h"
#import "Tweet.h"

@implementation FetchTweetProfileImageOperation

- (void)main
{
    [self startNetworkActivityIndicator];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.tweet.profileImageURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    if (data != nil)
    {
        UIImage *profileImage = [UIImage imageWithData:data];
        self.tweet.profileImage = profileImage;
        [self postNotification:kTweetProfileImageSuccessNotification];
    }
    
    [self stopNetworkActivityIndicator];
}

@end
