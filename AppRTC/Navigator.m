//
//  Navigator.m
//  AppRTC
//
//  Created by Simon Crequer on 5/10/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import "Navigator.h"

#define FOV (47.0 * M_PI / 180.0)

typedef enum {
    LEFT,
    RIGHT,
    NONE
} dir_t;

// These could be read from a file rather than hard coded.
int numMarkers = 7;
int ids[] = {1, 2, 3, 4, 5, 6, 7};
dir_t dirs[] = {RIGHT, RIGHT, LEFT, RIGHT, LEFT, RIGHT, RIGHT};
dir_t hint[] = {RIGHT, LEFT, RIGHT, LEFT, RIGHT, NONE, NONE};

@interface Navigator ()

@property bool turning;
@property bool forward;
@property bool waiting;

@property int currentMarker;

@property int lastXPosition;

@end

@implementation Navigator

-(id) initWithVideoProcessor: (VideoProcessor *)videoProcessor doubleController:(DoubleController *)doubleController {
    if (self = [super init]) {
        self.videoProcessor = videoProcessor;
        self.doubleController = doubleController;
        
        self.timeSinceLastDetection = 0;
        
        self.turning = true;
        self.forward = false;
        self.waiting = false;
        
        self.currentMarker = 0;
        
        self.ended = false;
        
        self.doubleController.controlState.right = ACTIVE;
    }
    
    return self;
}

-(void) navigate {
    while (1) {
    
        if (self.ended) {
            NSLog(@"YO");
            self.doubleController.controlState.forward = INACTIVE;
            self.doubleController.controlState.backward = INACTIVE;
            self.doubleController.controlState.left = INACTIVE;
            self.doubleController.controlState.right = INACTIVE;
            break;
        }
        
        if (self.videoProcessor.detectedMarkerCount == 0 || self.videoProcessor.currentMarkerId != ids[self.currentMarker]) {
            self.timeSinceLastDetection++;
        } else {
            self.timeSinceLastDetection = 0;
            self.lastXPosition = self.videoProcessor.markerXPosition;
        }
        
        if (self.turning) {
            if (self.timeSinceLastDetection == 0) {
                self.doubleController.controlState.right = INACTIVE;
                self.doubleController.controlState.left = INACTIVE;
                
                [NSThread sleepForTimeInterval:1.0f];
                
                if (self.videoProcessor.detectedMarkerCount == 0 || self.videoProcessor.currentMarkerId != ids[self.currentMarker]) {
                    if (dirs[self.currentMarker] == RIGHT) {
                        self.doubleController.controlState.left = ACTIVE;
                    } else {
                        self.doubleController.controlState.right = ACTIVE;
                    }
                    continue;
                }
                
                self.lastXPosition = self.videoProcessor.markerXPosition;
                
                float x = self.lastXPosition - 240;
                float theta;
                if (x < 0) {
                    theta = - atan((x / 480.0) * tan(FOV / 2.0)) * 180.0 / M_PI;
                } else if (x > 0) {
                    theta = atan((-x / 480.0) * tan(FOV / 2.0)) * 180.0 / M_PI;
                } else {
                    theta = 0;
                }
                
                if (hint[self.currentMarker] == LEFT) {
                    theta += 8;
                } else if (self.currentMarker == 1 || self.currentMarker == 3 || self.currentMarker == 5) {
                    theta -= 8;
                }
                
                NSLog(@"%d, %f", _lastXPosition, theta);
                [[DRDouble sharedDouble] turnByDegrees: theta];
                [NSThread sleepForTimeInterval:0.5f];
                
                self.turning = false;
                
                self.doubleController.controlState.forward = ACTIVE;
                self.forward = true;
            }
        }
        
        if (self.forward) {
            if (self.timeSinceLastDetection > 6) {
                self.doubleController.controlState.forward = INACTIVE;
                self.forward = false;
                self.waiting = true;
            }
            else if (self.videoProcessor.markerSize > 120 && self.videoProcessor.currentMarkerId == ids[self.currentMarker]) {
                self.doubleController.controlState.forward = INACTIVE;
                self.forward = false;
                
                self.currentMarker++;
                
                if (self.currentMarker == numMarkers) {
                    break;
                }
                
                [NSThread sleepForTimeInterval:0.5f];
                
                if (dirs[self.currentMarker] == LEFT) {
                    self.doubleController.controlState.left = ACTIVE;
                } else {
                    self.doubleController.controlState.right = ACTIVE;
                }
                self.turning = true;
            }
        }
        
        if (self.waiting) {
            if (self.timeSinceLastDetection > 15) {
                self.doubleController.controlState.forward = INACTIVE;
                self.waiting = false;
                
                self.currentMarker++;
                
                if (self.currentMarker == numMarkers) {
                    NSLog(@"WUT");
                    break;
                }
                
                [NSThread sleepForTimeInterval:0.5f];
                
                if (dirs[self.currentMarker] == LEFT) {
                    self.doubleController.controlState.left = ACTIVE;
                } else {
                    self.doubleController.controlState.right = ACTIVE;
                }
                self.turning = true;
            }
            if (self.timeSinceLastDetection < 6) {
                [NSThread sleepForTimeInterval:1.0f];
                
                if (self.videoProcessor.detectedMarkerCount == 0 || self.videoProcessor.currentMarkerId != ids[self.currentMarker]) {
                    if (dirs[self.currentMarker] == RIGHT) {
                        self.doubleController.controlState.left = ACTIVE;
                    } else {
                        self.doubleController.controlState.right = ACTIVE;
                    }
                    self.waiting = false;
                    self.turning = true;
                    continue;
                }
                
                self.lastXPosition = self.videoProcessor.markerXPosition;

                float x = self.videoProcessor.markerXPosition - 240;
                float theta;
                if (x < 0) {
                    theta = - atan((x / 480.0) * tan(FOV / 2.0)) * 180.0 / M_PI;
                } else if (x > 0) {
                    theta = atan((-x / 480.0) * tan(FOV / 2.0)) * 180.0 / M_PI;
                } else {
                    theta = 0;
                }
                
                if (hint[self.currentMarker] == LEFT) {
                    theta += 8;
                } else if (self.currentMarker == 1 || self.currentMarker == 3 || self.currentMarker == 5) {
                    theta -= 8;
                }
                
                NSLog(@"%f", theta);
                [[DRDouble sharedDouble] turnByDegrees: theta];
                [NSThread sleepForTimeInterval:0.5f];
                
                self.waiting = false;
                
                self.doubleController.controlState.forward = ACTIVE;
                self.forward = true;
            }
        }
        
        [NSThread sleepForTimeInterval:0.1f];
        
    }
    NSLog(@"Exiting loop");
    
}

@end
