//
//  Navigator.h
//  AppRTC
//
//  Created by Simon Crequer on 19/09/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DoubleControlSDK/DoubleControlSDK.h"
#import "VideoProcessor.h"
#import "DoubleController.h"
#import "ControlState.h"

@interface Follower : NSObject

@property (weak, atomic) VideoProcessor *videoProcessor;
@property (weak, atomic) DoubleController *doubleController;

@property (atomic) bool ended;

@property int timeSinceLastDetection;

-(id) initWithVideoProcessor: (VideoProcessor *) videoProcessor doubleController: (DoubleController *) doubleController;
-(void) follow;

@end
