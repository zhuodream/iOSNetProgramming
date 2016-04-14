//
//  FetchTweetProfileImageOperation.h
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "BaseOperation.h"
@class Tweet;

@interface FetchTweetProfileImageOperation : BaseOperation

@property (nonatomic, strong) Tweet *tweet;

@end
