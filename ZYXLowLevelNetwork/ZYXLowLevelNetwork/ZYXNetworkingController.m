//
//  ZYXNetworkingController.m
//  ZYXLowLevelNetwork
//
//  Created by 卓酉鑫 on 16/4/25.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXNetworkingController.h"

@interface ZYXNetworkingController ()

@property (nonatomic, readwrite) NSString *urlString;
@property (nonatomic, readwrite, assign) NSInteger portNumber;

@end

@implementation ZYXNetworkingController

- (instancetype)initWithURLString:(NSString *)urlString port:(NSInteger)portNumber
{
    self = [super init];
    if (self)
    {
        self.urlString = urlString;
        self.portNumber = portNumber;
    }
    
    return self;
}

- (void)start
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telnet://%@:%li", self.urlString, (long)self.portNumber]];
    
    NSThread *backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadCurrentStatus:) object:url];
    
    [backgroundThread start];
}

- (void)loadCurrentStatus:(NSURL *)url
{
    NSLog(@"Warning: this loadCurrentStatus: implementation doesn't do anything, please use a subclass.");
}

- (ZYXNetworkingResult *)parseResultString:(NSString *)resultString
{
    ZYXNetworkingResult *results = [[ZYXNetworkingResult alloc] init];
    
    NSArray *components = [resultString componentsSeparatedByString:@","];
    
    if (components.count < 9)
    {
        return nil;
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    NSNumberFormatter *formatterWithPlusSign = [[NSNumberFormatter alloc] init];
    [formatterWithPlusSign setPositiveFormat:@"+"];
    
    results.temperatureRoom = [formatter numberFromString:components[0]];
    results.temperatureOutlet = [formatter numberFromString:components[1]];
    results.temperatureCoil = [formatterWithPlusSign numberFromString:components[2]];
    results.statusCompressorOn = [[formatter numberFromString:components[3]] boolValue];
    results.statusAirSwitchOn = [[formatter numberFromString:components[4]] boolValue];
    results.statusAuxilaryHeatOn = [[formatter numberFromString:components[5]] boolValue];
    results.statusFrontDoorOpen = [[formatter numberFromString:components[6]] boolValue];
    results.statusSystemStandby = [[formatter numberFromString:components[7]] boolValue];
    results.statusAlarmActive = [[formatter numberFromString:components[8]] boolValue];
    
    return results;
}

@end
