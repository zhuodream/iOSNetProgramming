//
//  Utils.h
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSString *)urlEncode:(NSString *)rawString;

+ (NSString *)prettyStringFromDate:(NSDate *)date;

+ (NSDate *)publicationDateFromString:(NSString *)pubDate;

+ (NSDate *)tweetDateFromString:(NSString *)tweetDate;

+ (NSData *)postXMLDataFromDictionary:(NSDictionary *)dictionary;

@end
