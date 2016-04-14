//
//  PostViewContentViewController.h
//  ZYXTopStories
//
//  Created by 卓酉鑫 on 16/4/14.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYXPost.h"

@interface PostViewContentViewController : UIViewController<UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) ZYXPost *post;

@end
