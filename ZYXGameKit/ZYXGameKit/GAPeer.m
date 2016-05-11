//
//  GAPeer.m
//  ZYXGameKit
//
//  Created by 卓酉鑫 on 16/5/11.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "GAPeer.h"

@implementation GAPeer

- (id)initWithPeerID:(NSString *)peerID
{
    self = [super init];
    
    if (self != nil)
    {
        self.peerID = peerID;
        self.state = GKPeerStateDisconnected;
        self.tag = -1;
    }
    
    return self;
}

@end
