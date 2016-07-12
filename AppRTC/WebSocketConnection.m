//
//  WebSocketConnection.m
//  AppRTC
//
//  Created by Simon Crequer on 11/07/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import "WebSocketConnection.h"

@implementation WebSocketConnection

- (id) init {
    if (self = [super init]) {
        [SIOSocket socketWithHost: @"http://csse-s402g2.canterbury.ac.nz:3000" response: ^(SIOSocket *socket) {
            self.socket = socket;
            __weak typeof(self) weakSelf = self;
            self.socket.onConnect = ^() {
                SIOParameterArray *args = [[SIOParameterArray alloc] initWithObjects:@{@"serial": @"25"}, nil];
                [weakSelf.socket emit:@"info" args:args];
                NSLog(@"---------- Sending info");
                
                [weakSelf.socket on:@"control" callback:^(SIOParameterArray *args) {
                    [weakSelf control: (NSDictionary *)args.firstObject];
                }];
            };
        }];
    }
    return self;
}

- (void) control: (NSDictionary *) control {
    NSString *command; // start or stop
    
    if ((command = [control valueForKey:@"forward"])) {
        NSLog(@"forward");
        NSLog(@"%@", command);
    } else if ((command = [control valueForKey:@"backward"])) {
        NSLog(@"backward");
        NSLog(@"%@", command);
    } else if ((command = [control valueForKey:@"left"])) {
        NSLog(@"left");
        NSLog(@"%@", command);
    } else if ((command = [control valueForKey:@"right"])) {
        NSLog(@"right");
        NSLog(@"%@", command);
    }
}

@end
