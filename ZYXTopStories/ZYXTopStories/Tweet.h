//
//  Tweet.h
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *fromUser;
@property (nonatomic, strong) NSString *fromUserDisplay;
@property (nonatomic, strong) NSString *profileImageURL;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) UIImage *profileImage;

- (id)initWithDictionary:(NSDictionary *)tweetData;

@end
