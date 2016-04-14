//
//  Utils.m
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "Utils.h"
#import <libxml/xmlwriter.h>

@implementation Utils

+ (NSString *)urlEncode:(NSString *)rawString
{
    NSMutableString *newEncoded = [[rawString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] mutableCopy];
    NSMutableString *encoded = [[rawString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    [encoded replaceOccurrencesOfString:@"$" withString:@"%24" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@"@" withString:@"%40" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@"\t" withString:@"%09" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@"#" withString:@"%23" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@"<" withString:@"%3C" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@">" withString:@"%3E" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@"\"" withString:@"%22" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    [encoded replaceOccurrencesOfString:@"\n" withString:@"%0A" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [encoded length])];
    NSLog(@"old encode = %@", encoded);
    
    NSLog(@"new encode = %@", newEncoded);
    return encoded;
}

+ (NSString *)prettyStringFromDate:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEEE, MMMM dd, yyyy"];
    
    return [df stringFromDate:date];
}

+ (NSDate *)publicationDateFromString:(NSString *)pubDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    return [df dateFromString:pubDate];
}

+ (NSDate *)tweetDateFromString:(NSString *)tweetDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZZ"];
    
    return [df dateFromString:tweetDate];
}

+ (NSData *)postXMLDataFromDictionary:(NSDictionary *)dictionary
{
    xmlTextWriterPtr _writer;
    xmlBufferPtr _buffer;
    xmlChar *_elementName;
    xmlChar *_elementValue;
    
    _buffer = xmlBufferCreate();
    _writer = xmlNewTextWriterMemory(_buffer, 0);
    
    xmlTextWriterStartDocument(_writer, "1.0", "UTF-8", NULL);
    xmlTextWriterStartElement(_writer, BAD_CAST "articles");
    
    NSArray *posts = [dictionary objectForKey:@"articles"];
    for (NSDictionary *post in posts)
    {
        xmlTextWriterStartElement(_writer, BAD_CAST "article");
        NSArray *keys = [post allKeys];
        for (NSString *key in keys)
        {
            _elementName = (xmlChar *)[key UTF8String];
            _elementValue = (xmlChar *)[[post objectForKey:key] UTF8String];
            
            xmlTextWriterStartElement(_writer, _elementName);
            xmlTextWriterWriteString(_writer, _elementValue);
            xmlTextWriterEndElement(_writer); //</_elementName>
        }
        
        xmlTextWriterEndElement(_writer); //</article>
    }
    
    xmlTextWriterEndElement(_writer);// </articles>
    xmlTextWriterEndDocument(_writer);
    xmlFreeTextWriter(_writer);
    
    //convert buffer to NSData and cleanup
    NSData *_xmlData = [NSData dataWithBytes:(_buffer->content) length:(_buffer->use)];
    
    xmlBufferFree(_buffer);
    
    return _xmlData;
}



@end
