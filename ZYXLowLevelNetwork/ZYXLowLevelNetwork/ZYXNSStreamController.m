//
//  ZYXNSStreamController.m
//  ZYXLowLevelNetwork
//
//  Created by 卓酉鑫 on 16/4/25.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXNSStreamController.h"

@implementation ZYXNSStreamController
{
    NSMutableData *receuvedData;
}

- (void)loadCurrentStatus:(NSURL *)url
{
    if ([self.delegate respondsToSelector:@selector(networkingResultsDidStart)])
    {
        [self.delegate networkingResultsDidStart];
    }
    
    NSInputStream *readStream;
    [NSStream getStreamsToHostWithName:[url host] port:[[url port] integerValue] inputStream:&readStream outputStream:nil];
    
    [readStream setDelegate:self];
    [readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [readStream open];
    [[NSRunLoop currentRunLoop] run];
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode)
    {
        case NSStreamEventHasBytesAvailable:
            if (receuvedData == nil)
            {
                receuvedData = [[NSMutableData alloc] init];
            }
            uint8_t buf[1024];
            NSInteger numBytesRead = [(NSInputStream *)aStream read:buf maxLength:1024];
            
            if (numBytesRead > 0)
            {
                [receuvedData appendBytes:(const void *)buf length:numBytesRead];
            }
            else if (numBytesRead == 0)
            {
                NSLog(@"End of stream reached");
            }
            else
            {
                NSLog(@"Read error occurred");
            }
            
            break;
        case NSStreamEventErrorOccurred:
        {
            NSError *error = [aStream streamError];
            NSLog(@"Failed while reading stream; error '%@' (code %ld)", error.localizedDescription, error.code);
            if ([self.delegate respondsToSelector:@selector(networkingResultDidFail:)])
            {
                [self.delegate networkingResultDidFail:@"An unexpected error occurred while reading from the warehouse server."];
            }
            
            [self cleanUpStream:aStream];
            break;
        }
        default:
            break;
    }
}

- (void)cleanUpStream:(NSStream *)stream
{
    [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [stream close];
    
    stream = nil;
}

@end
