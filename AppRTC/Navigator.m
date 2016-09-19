//
//  Navigator.m
//  AppRTC
//
//  Created by Simon Crequer on 19/09/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import "Navigator.h"

@implementation Navigator

-(id) initWithVideoProcessor: (VideoProcessor *)videoProcessor doubleController:(DoubleController *)doubleController {
    if (self = [super init]) {
        self.videoProcessor = videoProcessor;
        self.doubleController = doubleController;
    }
    
    return self;
}

-(void) navigate {
    while (1) {
        if (self.videoProcessor.detectedMarkerCount == 0) {
            self.doubleController.controlState.left = ACTIVE;
        } else {
            self.doubleController.controlState.left = INACTIVE;
        }
    }
}

@end
