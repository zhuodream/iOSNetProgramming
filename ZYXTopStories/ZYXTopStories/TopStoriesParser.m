//
//  TopStoriesParser.m
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "TopStoriesParser.h"
#import "ZYXPost.h"
#import "Utils.h"

@interface TopStoriesParser ()

@property (nonatomic, strong) ZYXPost *post;
@property (nonatomic, strong) NSMutableString *currentValue;
@property (nonatomic, assign) BOOL parsingItem;

@end

@implementation TopStoriesParser

- (instancetype)initWithFeedData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        self.feedData = data;
    }
    
    return self;
}

- (void)parseTopStoriesFeed
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.feedData];
    parser.delegate = self;
    [parser parse];
}

#pragma mark - MSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.posts = [[NSMutableArray alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if ([self.delegate respondsToSelector:@selector(topStoriesParsedWithResult:)])
    {
        [self.delegate topStoriesParsedWithResult:self.posts];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    if ([elementName isEqualToString:@"item"])
    {
        self.post = [[ZYXPost alloc] init];
        _parsingItem = YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSString *tmpValue = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.currentValue == nil)
    {
        self.currentValue = [[NSMutableString alloc] initWithString:tmpValue];
    }
    else
    {
        [self.currentValue appendString:tmpValue];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"item"])
    {
        [self.posts addObject:self.post];
        self.post = nil;
        self.parsingItem = NO;
    }
    
    if (_parsingItem == YES)
    {
        if ([elementName isEqualToString:@"title"])
        {
            self.post.title = self.currentValue;
        }
        else if ([elementName isEqualToString:@"description"])
        {
            self.post.postDescription = self.currentValue;
        }
        else if ([elementName isEqualToString:@"pubDate"])
        {
            self.post.pubDate = [Utils publicationDateFromString:self.currentValue];
        }
        else if ([elementName isEqualToString:@"feedburner:origLink"])
        {
            self.post.contentURL = self.currentValue;
        }
    }
    
    self.currentValue = nil;
}
@end
