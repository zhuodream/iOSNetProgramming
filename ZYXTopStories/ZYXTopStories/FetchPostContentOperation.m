//
//  FetchPostContentOperation.m
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "FetchPostContentOperation.h"
#import "Model.h"
#import "HTMLParser.h"

#define kURLPrefix @"http://localhost/chapter4/"

@interface FetchPostContentOperation ()

- (void)processContentData:(NSData *)content;

@end

@implementation FetchPostContentOperation

- (void)main
{
    [self postNotification:kPostContentStartNotification];
    [self startNetworkActivityIndicator];
    
    //NSURL *url = [NSURL URLWithString:self.post.contentURL];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kURLPrefix, self.post.contentURL]];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    if (data != nil)
    {
        [self processContentData:data];
        self.post.contentFetched = YES;
        
        [self postNotification:kPostContentSuccessNotification];
    }
    else
    {
        [self postNotification:kPostContentErrorNotification];
    }
    
    [self stopNetworkActivityIndicator];
}

#pragma mark - Private Method
- (void)processContentData:(NSData *)content
{
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithData:content error:&error];
    
    if (error)
    {
        return;
    }
    
    HTMLNode *head = [parser head];
    NSArray *metaTags = [head findChildTags:@"meta"];
    
    for (HTMLNode *meta in metaTags)
    {
        NSString *name = [meta getAttributeNamed:@"name"];
        
        if ([name isEqualToString:@"keywords"])
        {
            NSString *keywordContent = [meta getAttributeNamed:@"content"];
            NSMutableArray *keywords = (NSMutableArray *)[keywordContent componentsSeparatedByString:@","];
            if ([keywords count] > 0)
            {
                self.post.keywords = keywords;
            }
        }
        else if ([name isEqualToString:@"author"])
        {
            NSString *author = [meta getAttributeNamed:@"content"];
            if (author.length > 0)
            {
                self.post.author = author;
            }
        }
        else if ([name isEqualToString:@"section"])
        {
            NSString *section = [meta getAttributeNamed:@"content"];
            if (section.length > 0)
            {
                self.post.section = section;
            }
        }
    }
    
    HTMLNode *body = [parser body];
    NSArray *paragraphTags = [body findChildTags:@"p"];
    
    NSMutableString *storyContent = [[NSMutableString alloc] init];
    for (HTMLNode *para in paragraphTags)
    {
        NSString *class = [para getAttributeNamed:@"class"];
        NSRange storyParaTest = [[class lowercaseString] rangeOfString:@"cnn_storypgraphtxt"];
        if ((storyParaTest.location != NSNotFound) && (class != nil))
        {
            [storyContent appendString:[para rawContents]];
        }
    }
    
    self.post.content = storyContent;
}

@end
