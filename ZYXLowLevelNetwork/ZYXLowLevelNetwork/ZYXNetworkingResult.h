//
//  ZYXNetworkingResult.h
//  ZYXLowLevelNetwork
//
//  Created by 卓酉鑫 on 16/4/25.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYXNetworkingResult : NSObject

@property (nonatomic, strong) NSNumber *temperatureRoom;
@property (nonatomic, strong) NSNumber *temperatureOutlet;
@property (nonatomic, strong) NSNumber *temperatureCoil;

@property (nonatomic, assign) BOOL statusCompressorOn;
@property (nonatomic, assign) BOOL statusAirSwitchOn;
@property (nonatomic, assign) BOOL statusAuxilaryHeatOn;
@property (nonatomic, assign) BOOL statusFrontDoorOpen;
@property (nonatomic, assign) BOOL statusSystemStandby;
@property (nonatomic, assign) BOOL statusAlarmActive;

@end
