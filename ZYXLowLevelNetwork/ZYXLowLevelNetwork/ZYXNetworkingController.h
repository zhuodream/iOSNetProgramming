//
//  ZYXNetworkingController.h
//  ZYXLowLevelNetwork
//
//  Created by 卓酉鑫 on 16/4/25.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYXNetworkingResult.h"

@protocol ZYXNetworkingDelegate <NSObject>

- (void)networkingResultsDidStart;
- (void)networkingResultsDidLoad:(ZYXNetworkingResult *)result;
- (void)networkingResultDidFail:(NSString *)errorMessgae;

@end

@interface ZYXNetworkingController : NSObject

@property (nonatomic, readonly) NSString *urlString;
@property (nonatomic, readonly, assign) NSInteger portNumber;
@property (nonatomic, weak) id<ZYXNetworkingDelegate> delegate;

- (instancetype)initWithURLString:(NSString *)urlString port:(NSInteger)portNumber;
- (void)start;
- (void)loadCurrentStatus:(NSURL *)url;
- (ZYXNetworkingResult *)parseResultString:(NSString *)resultString;

@end
