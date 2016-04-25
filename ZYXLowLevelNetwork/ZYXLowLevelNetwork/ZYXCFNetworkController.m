//
//  ZYXCFNetworkController.m
//  ZYXLowLevelNetwork
//
//  Created by 卓酉鑫 on 16/4/25.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXCFNetworkController.h"


#define kBufferSize 1024

@interface ZYXCFNetworkController ()

- (void)didReceiveData:(NSData *)data;
- (void)didFinishReceivingData;

@end

@implementation ZYXCFNetworkController
{
    CFSocketRef socket;
    NSMutableData *receivedData;
}

void socketCallback(CFReadStreamRef stream, CFStreamEventType event, void *myPtr)
{
    ZYXCFNetworkController *controller = (__bridge ZYXCFNetworkController *)myPtr;
    
    switch (event)
    {
        case kCFStreamEventHasBytesAvailable:
            while (CFReadStreamHasBytesAvailable(stream))
            {
                UInt8 buffer[kBufferSize];
                long numBytesRead = CFReadStreamRead(stream, buffer, kBufferSize);
                
                [controller didReceiveData:[NSData dataWithBytes:buffer length:numBytesRead]];
            }
            break;
        case kCFStreamEventErrorOccurred:
            {
                CFErrorRef error = CFReadStreamCopyError(stream);
            
                if (error != NULL)
                {
                    if (CFErrorGetCode(error) != 0)
                    {
                       NSLog(@"Failed while reading stream; error '%@' (code %ld)", (__bridge NSString*)CFErrorGetDomain(error), CFErrorGetCode(error));
                    }
                    CFRelease(error);
                }
                
                if ([controller.delegate respondsToSelector:@selector(networkingResultDidFail:)]) {
                    [controller.delegate networkingResultDidFail:@"An unexpected error occurred while reading from the warehouse server."];
                }
                break;
            }
        case kCFStreamEventEndEncountered:
            [controller didFinishReceivingData];
            
            // clean up the stream
            CFReadStreamClose(stream);
            
            // stop processing callback methods
            CFReadStreamUnscheduleFromRunLoop(stream,
                                              CFRunLoopGetCurrent(),
                                              kCFRunLoopCommonModes);
            // end the thread's run loop
            CFRunLoopStop(CFRunLoopGetCurrent());
            break;
        default:
            break;
    }
    
}

- (void)loadCurrentStatus:(NSURL *)url
{
    if ([self.delegate respondsToSelector:@selector(networkingResultsDidStart)])
    {
        [self.delegate networkingResultsDidStart];
    }
    
    CFStreamClientContext ctx = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    CFOptionFlags registeredEvents = (kCFStreamEventHasBytesAvailable | kCFStreamEventEndEncountered | kCFStreamEventErrorOccurred);
    
    CFReadStreamRef readStream;
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)[url host], [[url port] unsignedIntValue], &readStream, NULL);

    if (CFReadStreamSetClient(readStream, registeredEvents, socketCallback, &ctx))
    {
        CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
    else
    {
        NSLog(@"Failed to assign callback method");
        
        if ([self.delegate respondsToSelector:@selector(networkingResultDidFail:)])
        {
            [self.delegate networkingResultDidFail:@"Unable to respond to data from the warehouse server."];
        }
        return;
    }
    
    if (CFReadStreamOpen(readStream) == NO)
    {
        NSLog(@"Failed to open read stream.");
        
        if ([self.delegate respondsToSelector:@selector(networkingResultDidFail:)])
        {
            [self.delegate networkingResultDidFail:@"Unable to read data from the warehouse server."];
        }
        
        return;
    }
    
    CFErrorRef error = CFReadStreamCopyError(readStream);
    if (error != NULL)
    {
        if (CFErrorGetCode(error) != 0)
        {
            NSLog(@"Failed to connect stream; error '%@' (code %ld)", (__bridge NSString *)CFErrorGetDomain(error), CFErrorGetCode(error));
        }
        
        CFRelease(error);
        
        if ([self.delegate respondsToSelector:@selector(networkingResultDidFail:)])
        {
            [self.delegate networkingResultDidFail:@"Unable to connect to the warehouse server."];
        }
        
        return;
    }
    
    NSLog(@"Successfully connected to %@", url);
    
    CFRunLoopRun();
}

- (void)didReceiveData:(NSData *)data
{
    if (receivedData == nil)
    {
        receivedData = [[NSMutableData alloc] init];
    }
    
    [receivedData appendData:data];
}

- (void)didFinishReceivingData
{
    NSString *resultString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"Received string: '%@'", resultString);
    
    ZYXNetworkingResult *result = [self parseResultString:resultString];
    
    if (result != nil)
    {
        if ([self.delegate respondsToSelector:@selector(networkingResultsDidLoad:)])
        {
            [self.delegate networkingResultsDidLoad:result];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(networkingResultDidFail:)])
        {
            [self.delegate networkingResultDidFail:@"Unable to parse the respons from the warehouse server."];
        }
    }
}
@end
