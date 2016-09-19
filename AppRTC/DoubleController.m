//
//  WebSocketConnection.m
//  AppRTC
//
//  Created by Simon Crequer on 11/07/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import "DoubleController.h"
#import <UIKit/UIKit.h>

@interface DoubleController ()

@property SIOSocket *socket;

@end

@implementation DoubleController

- (id) init {
    if (self = [super init]) {
        [DRDouble sharedDouble].delegate = self;
        NSLog(@"SDK Version: %@", kDoubleBasicSDKVersion);
        
        self.controlState = [[ControlState alloc] init];
        
        [SIOSocket socketWithHost: @"http://csse-s402g2.canterbury.ac.nz:8443" response: ^(SIOSocket *socket) {
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
        
        if ([command isEqualToString:@"start"]) {
            self.controlState.forward = ACTIVE;
        } else if ([command isEqualToString:@"stop"]) {
            self.controlState.forward = INACTIVE;
        }
    } else if ((command = [control valueForKey:@"backward"])) {
        NSLog(@"backward");
        NSLog(@"%@", command);
        
        if ([command isEqualToString:@"start"]) {
            self.controlState.backward = ACTIVE;
        } else if ([command isEqualToString:@"stop"]) {
            self.controlState.backward = INACTIVE;
        }
    } else if ((command = [control valueForKey:@"left"])) {
        NSLog(@"left");
        NSLog(@"%@", command);
        
        if ([command isEqualToString:@"start"]) {
            self.controlState.left = ACTIVE;
        } else if ([command isEqualToString:@"stop"]) {
            self.controlState.left = INACTIVE;
        }
    } else if ((command = [control valueForKey:@"right"])) {
        NSLog(@"right");
        NSLog(@"%@", command);
        
        if ([command isEqualToString:@"start"]) {
            self.controlState.right = ACTIVE;
        } else if ([command isEqualToString:@"stop"]) {
            self.controlState.right = INACTIVE;
        }
    } else if ((command = [control valueForKey:@"kickstand"])) {
        NSLog(@"kickstand");
        NSLog(@"%@", command);
        
        if ([command isEqualToString:@"deploy"]) {
            [[DRDouble sharedDouble] deployKickstands];
        } else if ([command isEqualToString:@"retract"]) {
            [[DRDouble sharedDouble] retractKickstands];
        }
    }  else if ((command =[control valueForKey:@"turn"])) {
        NSLog(@"turn");
        NSLog(@"%@", command);
        
        [[DRDouble sharedDouble] turnByDegrees:[command floatValue]];
    } else {
        NSLog(@"%@", control);
    }
}

#pragma mark - DRDoubleDelegate

- (void)doubleDriveShouldUpdate:(DRDouble *)theDouble {
    float drive = (self.controlState.forward == ACTIVE) ? kDRDriveDirectionForward : ((self.controlState.backward == ACTIVE) ? kDRDriveDirectionBackward : kDRDriveDirectionStop);
    float turn = (self.controlState.right == ACTIVE) ? 1.0 : ((self.controlState.left == ACTIVE) ? -1.0 : 0.0);
    [theDouble drive:drive turn:turn];
}

@end
