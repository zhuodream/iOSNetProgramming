//
//  Bonjour.h
//  ZYXBonjourServer
//
//  Created by 卓酉鑫 on 16/5/12.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HelpRequest.h"
#import "HelpResponse.h"

#define kNotificationResultSet      @"NotificationObject"
#define kPublishBonjourStartNotification    @"PublishSatrtNotification"
#define kPublishBonjourErrorNotification    @"PublishErrorNotification"
#define kPublishBonjourSuccessNotification  @"PublishSuccessNotification"
#define kStopBonkourSuccessNotification     @"StopSuccessNotification"
#define kHelpRequestedNotification          @"HelpRequestedNotification"

@interface Bonjour : NSObject <NSNetServiceDelegate, NSStreamDelegate>

+ (Bonjour *)sharedPublisher;

- (BOOL)publishServiceWithName:(NSString *)name;

- (void)stopService;

- (void)sendHelpResponse:(HelpResponse *)response;

@end
