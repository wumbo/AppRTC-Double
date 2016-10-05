//
//  WebSocketConnection.h
//  AppRTC
//
//  Created by Simon Crequer on 11/07/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SIOSocket/SIOSocket.h>
#import "DoubleControlSDK/DoubleControlSDK.h"
#import "ControlState.h"
#import "VideoProcessor.h"

@interface DoubleController : NSObject <DRDoubleDelegate>
@property ControlState *controlState;

- (id) initWithVideoProcessor: (VideoProcessor *)videoProcessor;

@end
