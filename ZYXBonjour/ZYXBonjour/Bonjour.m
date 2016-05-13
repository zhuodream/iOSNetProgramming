//
//  Bonjour.m
//  ZYXBonjourServer
//
//  Created by 卓酉鑫 on 16/5/12.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "Bonjour.h"
#import "Utils.h"
#import <netinet/in.h>
#import <sys/socket.h>

@interface Bonjour ()
{
    NSNetService *service;
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    
    NSMutableData *receiveData;
    NSMutableData *sendData;
    
    NSNumber *bytesRead;
    NSNumber *bytesWritten;
    
    uint16_t port;
    CFSocketRef ipv4socket;
    CFSocketRef ipv6socket;
}

- (BOOL)setupListeningSocket;
- (void)stopListening;
- (void)handleNewConnectionWithInputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr;

@end

@implementation Bonjour

static Bonjour *_instance = nil;

+ (Bonjour *)sharedPublisher
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
        
    }
    
    return self;
}

- (BOOL)publishServiceWithName:(NSString *)name
{
    if (![self setupListeningSocket])
    {
        return NO;
    }
    
    service = [[NSNetService alloc] initWithDomain:@"" type:@"_associateHelp._tcp." name:name port:port];
    
    if (service == nil)
    {
        return NO;
    }
    
    service.delegate = self;
    
    [Utils postNotification:kPublishBonjourStartNotification];
    
    [service publish];
    
    return YES;
}

- (void)stopService
{
    [service stop];
}

- (void)sendHelpResponse:(HelpResponse *)response
{
    if (sendData == nil)
    {
        sendData = [[NSMutableData alloc] init];
    }
    
    NSData *responseData = [NSKeyedArchiver archivedDataWithRootObject:response];
    
    [sendData appendData:responseData];
    
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    if (response.response == YES)
    {
        [self stopService];
    }
}

#pragma mark - NetServiceDelegate
- (void)netServiceDidPublish:(NSNetService *)sender
{
    [Utils postNotification:kPublishBonjourSuccessNotification];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    [Utils postNotification:kStopBonkourSuccessNotification];
}

- (void)netServiceDidStop:(NSNetService *)sender
{
    NSLog(@"服务已经停止");
    port = 0;
    CFRelease(ipv4socket);
    CFRelease(ipv6socket);
    [Utils postNotification:kStopBonkourSuccessNotification];
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode)
    {
        case NSStreamEventHasBytesAvailable:
            if (aStream == inputStream)
            {
                if (receiveData == nil)
                {
                    receiveData = [[NSMutableData alloc] init];
                }
                
                uint8_t buffer[1024];
                NSInteger len = 0;
                len = [(NSInputStream *)aStream read:buffer maxLength:1024];
                
                if (len)
                {
                    [receiveData appendBytes:(const void *)buffer length:len];
                    bytesRead = [NSNumber numberWithInteger:([bytesRead integerValue] + len)];
                    
                    if (![inputStream hasBytesAvailable])
                    {
                        HelpRequest *request;
                        @try {
                            request = [NSKeyedUnarchiver unarchiveObjectWithData:receiveData];
                            NSDictionary *info = [NSDictionary dictionaryWithObject:request forKey:kNotificationResultSet];
                            NSLog(@"info = %@", info);
                            [[NSNotificationCenter defaultCenter] postNotificationName:kHelpRequestedNotification object:nil userInfo:info];
                        } @catch (NSException *exception) {
                            NSString *msg = @"Exception while archiving request data.";
                            NSLog(@"%@", msg);
                        } @finally {
                            receiveData = nil;
                            bytesRead = nil;
                        }
                    }
                }
                else
                {
                    NSLog(@"No data found in buffer");
                }
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            if (aStream == outputStream)
            {
                NSLog(@"输出数据");
                if ([sendData length] > 0)
                {
                    uint8_t *readBytes = (uint8_t *)[sendData mutableBytes];
                    
                    readBytes += [bytesWritten intValue];
                    NSUInteger data_len = [sendData length];
                    NSUInteger len = ((data_len - [bytesWritten unsignedIntegerValue] >= 1024) ? 1024 : (data_len - [bytesWritten unsignedIntegerValue]));
                    
                    uint8_t buffer[len];
                    (void)memcpy(buffer, readBytes, len);
                    
                    len = [(NSOutputStream *)aStream write:(const uint8_t *)buffer maxLength:len];
                    
                    bytesWritten = [NSNumber numberWithInteger:([bytesWritten integerValue] + len)];
                    
                    if ([sendData length] == [bytesWritten integerValue])
                    {
                        sendData = nil;
                        bytesWritten = [NSNumber numberWithInteger:0];
                        [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                    }
                    
                    if ([bytesWritten integerValue] == -1)
                    {
                        NSLog(@"error writing data.");
                    }
                }
            }
        case NSStreamEventOpenCompleted:
            if (aStream == inputStream)
            {
                NSLog(@"Input Stream Opened");
            }
            else
            {
                NSLog(@"Output Stream Opened");
            }
            break;
        case NSStreamEventEndEncountered:
        {
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
        }
        case NSStreamEventErrorOccurred:
            if (aStream == inputStream)
            {
                NSLog(@"Input error: %@", [aStream streamError]);
            }
            else
            {
                NSLog(@"Output error: %@", [aStream streamError]);
            }
            break;
        default:
            if (aStream == inputStream) {
                NSLog(@"Input default error: %@", [aStream streamError]);
            } else {
                NSLog(@"Output default error: %@", [aStream streamError]);
            }
            break;
    }
}

#pragma mark - Private Methods

- (BOOL)setupListeningSocket
{
    CFSocketContext socketCtxt = {0, (__bridge void *)self, NULL, NULL, NULL};
    
    ipv4socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&BonjourServerAcceptCallBack, &socketCtxt);
    
    ipv6socket = CFSocketCreate(kCFAllocatorDefault, PF_INET6, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&BonjourServerAcceptCallBack, &socketCtxt);
    
    if (ipv4socket == NULL || ipv6socket == NULL)
    {
        if (ipv4socket)
        {
            CFRelease(ipv4socket);
        }
        if (ipv6socket)
        {
            CFRelease(ipv6socket);
        }
        ipv4socket = NULL;
        ipv6socket = NULL;
        return NO;
    }
    
    int yes = 1;
    setsockopt(CFSocketGetNative(ipv4socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
    setsockopt(CFSocketGetNative(ipv6socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
    
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(port);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
    
    if (kCFSocketSuccess != CFSocketSetAddress(ipv4socket, (__bridge CFDataRef)address4))
    {
        NSLog(@"Error setting ipv4 socket address");
        if (ipv4socket)
        {
            CFRelease(ipv4socket);
        }
        if (ipv6socket)
        {
            CFRelease(ipv6socket);
        }
        ipv4socket = NULL;
        ipv6socket = NULL;
        return NO;
    }
    
    if (port == 0)
    {
        NSData *addr = (__bridge_transfer NSData *)CFSocketCopyAddress(ipv4socket);
        memcpy(&addr4, [addr bytes], [addr length]);
        port = ntohs(addr4.sin_port);
    }
    
    struct sockaddr_in6 addr6;
    memset(&addr6, 0, sizeof(addr6));
    addr6.sin6_len = sizeof(addr6);
    addr6.sin6_family = AF_INET6;
    addr6.sin6_port = htons(port);
    memcpy(&(addr6.sin6_addr), &in6addr_any, sizeof(addr6.sin6_addr));
    NSData *address6 = [NSData dataWithBytes:&addr6 length:sizeof(addr6)];
    
    if (kCFSocketSuccess != CFSocketSetAddress(ipv6socket, (__bridge CFDataRef)address6))
    {
        NSLog(@"Error setting ipv6 socket address");
        if (ipv4socket)
        {
            CFRelease(ipv4socket);
        }
        if (ipv6socket)
        {
            CFRelease(ipv6socket);
        }
        ipv4socket = NULL;
        ipv6socket = NULL;
        
        return NO;
    }
    
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();
    CFRunLoopSourceRef src4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, ipv4socket, 0);
    
    CFRunLoopAddSource(cfrl, src4, kCFRunLoopCommonModes);
    CFRelease(src4);
    
    CFRunLoopSourceRef src6 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, ipv6socket, 0);
    
    CFRunLoopAddSource(cfrl, src6, kCFRunLoopCommonModes);
    CFRelease(src6);
    
    return YES;
}

- (void)stopListening
{
    CFSocketInvalidate(ipv4socket);
    CFRelease(ipv4socket);
    
    CFSocketInvalidate(ipv6socket);
    CFRelease(ipv6socket);
}

- (void)handleNewConnectionWithInputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr
{
    inputStream = istr;
    outputStream = ostr;
    
    inputStream.delegate = self;
    outputStream.delegate = self;
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    if (inputStream.streamStatus == NSStreamStatusNotOpen)
    {
        [inputStream open];
    }
    if (outputStream.streamStatus == NSStreamStatusNotOpen)
    {
        [outputStream open];
    }
}

static void BonjourServerAcceptCallBack (CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    Bonjour *server = (__bridge Bonjour *)info;
    if (type == kCFSocketAcceptCallBack)
    {
        CFSocketNativeHandle socketHandle = *(CFSocketNativeHandle *)data;
        
        CFReadStreamRef readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, socketHandle, &readStream, &writeStream);
        
        if (readStream && writeStream)
        {
            CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            
            NSInputStream *is = (__bridge_transfer NSInputStream*)readStream;
            NSOutputStream *os = (__bridge_transfer NSOutputStream*)writeStream;
            
            [server handleNewConnectionWithInputStream:is outputStream:os];
        }
        else
        {
            close(socketHandle);
        }
//        
//        if (readStream)
//        {
//            CFRelease(readStream);
//        }
//        
//        if (writeStream)
//        {
//            CFRelease(writeStream);
//        }
    }
}


@end
