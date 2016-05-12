//
//  BonjourBrowser.m
//  ZYXBonjourClient
//
//  Created by 卓酉鑫 on 16/5/12.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "BonjourBrowser.h"
#import "Utils.h"

@interface BonjourBrowser ()
{
    NSNetServiceBrowser *_browser;
    NSMutableArray *services;
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSMutableData *receiveData;
    NSMutableData *sendData;
    NSNumber *bytesRead;
    NSNumber *bytesWritten;
}

@end

@implementation BonjourBrowser

static BonjourBrowser *_instance = nil;

+ (BonjourBrowser *)sharedBrowser
{
    if (_instance == nil)
    {
        _instance = [[self alloc] init];
    }
    
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        services = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)browseForHelp
{
    if (_browser == nil)
    {
        _browser = [[NSNetServiceBrowser alloc] init];
    }
    
    _browser.delegate = self;
    [_browser searchForServicesOfType:@"_associateHelp._tcp" inDomain:@""];
    
    [Utils postNotification:kBrowseStartNotification];
}

- (NSArray *)availableServices
{
    return (NSArray *)services;
}

- (void)connectToService:(NSNetService *)service
{
    service.delegate = self;
    [service resolveWithTimeout:5.0];
    
    [Utils postNotification:kConnectStartNotification];
    
    [_browser stop];
}

- (void)sendHelpRequest:(HelpRequest *)request
{
    if (sendData == nil)
    {
        sendData = [[NSMutableData alloc] init];
    }
    
    NSData *requestData = [NSKeyedArchiver archivedDataWithRootObject:request];
    
    [sendData appendData:requestData];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

#pragma mark - NSNetServiceBrowserDelegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    if (![services containsObject:service])
    {
        [services addObject:service];
    }
    
    if (moreComing == NO)
    {
        [Utils postNotification:kBrowseSuccessNotification];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    [Utils postNotification:kBrowseErrorNotification];
    [browser stop];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    _browser = nil;
    [Utils postNotification:kSearchStoppedNotification];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"服务移除");
    [services removeObject:service];
    if (moreComing == NO)
    {
        [Utils postNotification:kServiceRemovedNotification];
    }
}

#pragma mark - NSNetServiceDelegate
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    [Utils postNotification:kConnectErrorNotification];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSInputStream *tmpIS;
    NSOutputStream *tmpOS;
    BOOL error = NO;
    
    if (![sender getInputStream:&tmpIS outputStream:&tmpOS])
    {
        error = YES;
    }
    
    if (tmpIS != NULL)
    {
        inputStream = tmpIS;
        inputStream.delegate = self;
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        if (inputStream.streamStatus == NSStreamStatusNotOpen)
        {
            [inputStream open];
        }
    }
    else
    {
        error = YES;
    }
    
    if (tmpOS != NULL)
    {
        outputStream = tmpOS;
        outputStream.delegate = self;
        
        if (outputStream.streamStatus == NSStreamStatusNotOpen)
        {
            [outputStream open];
        }
    }
    else
    {
        error = YES;
    }
    
    if (error == NO)
    {
        [Utils postNotification:kConnectSuccessNotification];
    }
    else
    {
        [Utils postNotification:kConnectErrorNotification];
    }
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventHasSpaceAvailable: {
            NSLog(@"开始与服务端通信");
            if (aStream == outputStream) {
                if ([sendData length] > 0) {
                    uint8_t *readBytes =
                    (uint8_t *)[sendData mutableBytes];
                    
                    // keep track of pointer position
                    readBytes += [bytesWritten integerValue];
                    NSInteger data_len = [sendData length];
                    NSLog(@"data_len = %ld, byteswritten = %ld", data_len, [bytesWritten integerValue]);
                    NSInteger len =
                    ((data_len - [bytesWritten integerValue] >= 1024) ?
                     1024 : (data_len - [bytesWritten integerValue]));
                    NSLog(@"len = %lu", (unsigned long)len);
                    uint8_t buffer[len];
                    memcpy(buffer, readBytes, len);
                    len = [(NSOutputStream*)aStream
                           write:(const uint8_t *)buffer
                           maxLength:len];
                    
                    bytesWritten =
                    [NSNumber
                     numberWithInteger:([bytesWritten integerValue]+len)];
                    
                    if ([sendData length] == [bytesWritten integerValue]) {
                        NSLog(@"数据获取完毕");
                        sendData = nil;
                        bytesWritten = [NSNumber numberWithInteger:0];
                        [outputStream
                         removeFromRunLoop:[NSRunLoop currentRunLoop]
                         forMode:NSDefaultRunLoopMode];
                    }
                    
                    if ([bytesWritten intValue] == -1) {
                        NSLog(@"Error writing data.");
                    }
                }
            }
            break;
        }
        case NSStreamEventOpenCompleted:
            // you could optionally set a BOOL here
            // indicating that the different streams
            // are ready to read or write
            break;
        case NSStreamEventHasBytesAvailable:
            if (aStream == inputStream) {
                NSLog(@"获取到数据");
                if (receiveData == nil) {
                    receiveData = [[NSMutableData alloc] init];
                }
                uint8_t buffer[1024];
                NSInteger len = 0;
                len = [(NSInputStream *)aStream read:buffer
                                           maxLength:1024];
                
                if(len) {
                    [receiveData appendBytes:(const void *)buffer
                                      length:len];
                    
                    bytesRead = [NSNumber
                                 numberWithInteger:([bytesRead integerValue]+len)];
                    
                    if (![inputStream hasBytesAvailable]) {
                        
                        // you could optionally keep the 'transaction'
                        // state stored so that you could determine
                        // which object you are expecting.
                        HelpResponse *response;
                        @try {
                            response =
                            [NSKeyedUnarchiver
                             unarchiveObjectWithData:receiveData];
                            
                            NSDictionary *info =
                            [NSDictionary
                             dictionaryWithObject:response
                             forKey:kNotificationResultSet];
                            
                            [[NSNotificationCenter defaultCenter]
                             postNotificationName:kHelpResponseNotification
                             object:nil
                             userInfo:info];
                            
                        }
                        @catch (NSException *exception) {
                            NSLog(@"Exception unarchiving data.");
                            NSLog(@"Possible missing / corrupt data.");
                        }
                        @finally {
                            // clean up
                            receiveData = nil;
                            bytesRead = nil;
                        }
                    }
                } else {
                    NSLog(@"No data found in buffer.");
                }
            }
            break;
            
        case NSStreamEventEndEncountered: {
            NSLog(@"End of stream reached");
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
            break;
            
        case NSStreamEventErrorOccurred:
            if (aStream == inputStream) {
                NSLog(@"Input stream error: %@", [aStream streamError]);
            } else {
                NSLog(@"Output stream error: %@", [aStream streamError]);
            }
            break;
            
        default:
            break;
    }

}



@end
