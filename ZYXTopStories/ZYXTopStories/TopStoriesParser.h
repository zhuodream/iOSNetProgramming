//
//  TopStoriesParser.h
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TopStoriesDelegate <NSObject>

@required
- (void)topStoriesParsedWithResult:(NSMutableArray *)posts;

@end

@interface TopStoriesParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSData *feedData;
@property (nonatomic, strong) NSMutableArray *posts;

@property (nonatomic, weak) id<TopStoriesDelegate> delegate;

- (instancetype)initWithFeedData:(NSData *)data;
- (void)parseTopStoriesFeed;

@end
