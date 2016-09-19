//
//  ControlState.m
//  AppRTC
//
//  Created by Simon Crequer on 19/09/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import "ControlState.h"

@implementation ControlState

- (id) init {
    if (self = [super init]) {
        self.forward = INACTIVE;
        self.backward = INACTIVE;
        self.left = INACTIVE;
        self.right = INACTIVE;
    }
    
    return self;
}

@end
