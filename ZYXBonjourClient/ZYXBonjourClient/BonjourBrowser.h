//
//  BonjourBrowser.h
//  ZYXBonjourClient
//
//  Created by 卓酉鑫 on 16/5/12.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HelpRequest.h"
#import "HelpResponse.h"

#define kNotificationResultSet   @"NotificationObject"
#define kBrowseStartNotification   @"BonjourBrowseStartNotification"
#define kBrowseErrorNotification   @"BonjourBrowseErrorNotification"
#define kBrowseSuccessNotification  @"BonjourBrowseSuccessNotification"

#define kConnectStartNotification   @"BonjourConnectStartNotification"
#define kConnectErrorNotification   @"BonjourConnectErrorNotification"
#define kConnectSuccessNotification @"BonjourConnectSuccessNotification"

#define kServiceRemovedNotification @"BonjourServiceRemovedNotification"
#define kSearchStoppedNotification  @"BonjourSearchStoppedNotification"

#define kHelpRequestedNotification  @"HelpRequestedNotification"
#define kHelpResponseNotification   @"HelpResponseNotification"

@interface BonjourBrowser : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate, NSStreamDelegate>

+ (BonjourBrowser *)sharedBrowser;

- (NSArray *)availableServices;

- (void)connectToService:(NSNetService *)service;

- (void)sendHelpRequest:(HelpRequest *)request;
- (void)browseForHelp;

@end
