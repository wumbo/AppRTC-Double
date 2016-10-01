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

        self.timeSinceLastDetection = 0;
    }
    
    return self;
}

-(void) navigate {

    int direction[4] = {1, 1, 0, 1};

    int targetMarker = 1;

    while (1) {

        if (self.videoProcessor.detectedMarkerCount == 0 || self.videoProcessor.currentMarkerId != targetMarker) {
            if (self.timeSinceLastDetection > 10) {

                if (direction[targetMarker-1] == 1) {
                    self.doubleController.controlState.right = ACTIVE;
                } else {
                    self.doubleController.controlState.left = ACTIVE;
                }
            }

            self.timeSinceLastDetection++;

        } else {

            if (direction[targetMarker-1] == 1) {
                self.doubleController.controlState.right = INACTIVE;
            } else {
                self.doubleController.controlState.left = ACTIVE;
            }

            self.timeSinceLastDetection = 0;

            self.doubleController.controlState.forward = ACTIVE;
            [NSThread sleepForTimeInterval:5.2f];
            self.doubleController.controlState.forward = INACTIVE;

            targetMarker++;
        }

        [NSThread sleepForTimeInterval:0.1f];
    }
}

@end
