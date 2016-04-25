//
//  ZYXBSDSocketController.m
//  ZYXLowLevelNetwork
//
//  Created by 卓酉鑫 on 16/4/25.
//  Copyright © 2016年 卓酉鑫. All rights reserved.
//

#import "ZYXBSDSocketController.h"
#import <arpa/inet.h>
#import <netdb.h>

@implementation ZYXBSDSocketController
{
    int socketFileDescriptor;
}

- (void)loadCurrentStatus:(NSURL *)url
{
    if ([self.delegate respondsToSelector:@selector(networkingResultsDidStart)])
    {
        [self.delegate networkingResultsDidStart];
    }
    
    socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0);
    if (socketFileDescriptor == -1)
    {
        if ([self.delegate respondsToSelector:@selector(networkingResultDidFail:)])
        {
            [self.delegate networkingResultDidFail:@"Unable to allocate networking resources."];
        }
        
        return;
    }
    
    struct hostent *remoteHostEnt = gethostbyname([[url host] UTF8String]);
    if (remoteHostEnt == NULL)
    {
        if ([self.delegate respondsToSelector:@selector(networkingResultDidFail:)])
        {
            [self.delegate networkingResultDidFail:@"Unable to resolve the hostname of the warehouse server."];
        }
        
        return;
    }
    
    struct in_addr *remoteInAddr = (struct in_addr *)remoteHostEnt->h_addr_list[0];
    
    struct sockaddr_in socketParameters;
    socketParameters.sin_family = AF_INET;
    socketParameters.sin_addr = *remoteInAddr;
    socketParameters.sin_port = htons([[url port] intValue]);
    
    if (connect(socketFileDescriptor, (struct sockaddr *)&socketParameters, sizeof(socketParameters)) == -1)
    {
        NSLog(@"Failed to connect to %@", url);
        
        if ([self.delegate respondsToSelector:@selector(networkingResultDidFail:)])
        {
            [self.delegate networkingResultDidFail:@"Unable to connect to the warehouse server."];
            return;
        }
    }
    
    NSLog(@"Successfuly connected to %@", url);
    
    NSMutableData *data = [[NSMutableData alloc] init];
    BOOL waitingForData = YES;
    
    while (waitingForData)
    {
        const char *buffer[1024];
        int length = sizeof(buffer);
        
        ssize_t result = recv(socketFileDescriptor, &buffer, length, 0);
        if (result > 0)
        {
            [data appendBytes:buffer length:result];
        }
        else
        {
            waitingForData = NO;
        }
    }
    
    close(socketFileDescriptor);
    
    NSString *resultsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received string: '%@'", resultsString);
    
    ZYXNetworkingResult *result = [self parseResultString:resultsString];
    
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
            [self.delegate networkingResultDidFail:@"Unable to parse the response from the warehouse server."];
        }
    }
}

@end
