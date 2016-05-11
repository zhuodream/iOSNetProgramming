//
//  GAPeer.h
//  ZYXGameKit
//
//  Created by 卓酉鑫 on 16/5/11.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GAPeer : NSObject

@property (nonatomic, strong) NSString *peerID;
@property (nonatomic, assign) GKPeerConnectionState state;
@property (nonatomic, assign) NSInteger tag;

- (id)initWithPeerID:(NSString *)peerID;

@end
