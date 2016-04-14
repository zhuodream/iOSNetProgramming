//
//  FetchPostContentOperation.h
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "BaseOperation.h"
#import "ZYXPost.h"

@interface FetchPostContentOperation : BaseOperation

@property (nonatomic, strong) ZYXPost *post;

@end
