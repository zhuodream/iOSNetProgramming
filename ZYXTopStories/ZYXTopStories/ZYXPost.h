//
//  ZYXPost.h
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYXPost : NSObject

@property (nonatomic, strong) NSString *title;              //rss
@property (nonatomic, strong) NSString *postDescription;    //rss
@property (nonatomic, strong) NSString *content;            //html
@property (nonatomic, strong) NSString *author;             //html
@property (nonatomic, strong) NSString *section;            //html
@property (nonatomic, strong) NSString *contentURL;         //rss
@property (nonatomic, strong) NSDate *pubDate;              //rss
@property (nonatomic, strong) NSMutableArray *keywords;     //html
@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, assign) BOOL contentFetched;
@property (nonatomic, assign) BOOL tweetsLoading;

- (NSDictionary *)dictionaryRepresentation;

@end
