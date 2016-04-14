//
//  FetchPostTweetsOperation.m
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "FetchPostTweetsOperation.h"
#import "Model.h"
#import "Utils.h"
#import "Tweet.h"

@implementation FetchPostTweetsOperation

- (void)main
{
    [self postNotification:kTweetsStartNotification];
    [self startNetworkActivityIndicator];
    self.post.tweetsLoading = YES;
    
    NSMutableString *query = [[NSMutableString alloc] init];
    
    for (int i = 0; i < [self.post.keywords count]; ++i)
    {
        if (i != 0)
        {
            [query appendString:@","];
        }
        
        [query appendString:[self.post.keywords objectAtIndex:i]];
    }
    
    NSString *searchEndpoint = @"http://search.twitter.com/search.json";
    NSString *queryString = [NSString stringWithFormat:@"q=%@rpp=15", [Utils urlEncode:query]];
    
    NSString *url = [NSString stringWithFormat:@"%@?%@", searchEndpoint, queryString];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    NSHTTPURLResponse *response = nil;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    if (data != nil)
    {
        NSError *error = nil;
        NSDictionary *searchResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSMutableArray *tweets = [[NSMutableArray alloc] init];
        
        NSArray *results = [searchResults objectForKey:@"results"];
        for (NSDictionary *tweetData in results)
        {
            Tweet *tweet = [[Tweet alloc] initWithDictionary:tweetData];
            [tweets addObject:tweet];
        }
        
        self.post.tweetsLoading = NO;
        
        if ([tweets count] > 0)
        {
            self.post.tweets = tweets;
            [self postNotification:kTweetsSuccessNotification];
        }
        else
        {
            [self postNotification:kTweetsErrorNotification];
        }
    }
    else
    {
        self.post.tweetsLoading = NO;
        [self postNotification:kTweetsErrorNotification];
    }
    
    [self stopNetworkActivityIndicator];
}

@end
