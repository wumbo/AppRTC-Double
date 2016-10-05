//
//  Navigator.m
//  AppRTC
//
//  Created by Simon Crequer on 19/09/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import "Follower.h"

#define FOV (47.0 * M_PI / 180.0)

@interface Follower ()

@property bool turning;
@property bool forward;
@property bool forwardAndTurning;
@property bool staying;
@property bool stayingAndTurning;
@property bool waiting;

@property int lastXPosition;

@end

@implementation Follower

-(id) initWithVideoProcessor: (VideoProcessor *)videoProcessor doubleController:(DoubleController *)doubleController {
    if (self = [super init]) {
        self.videoProcessor = videoProcessor;
        self.doubleController = doubleController;

        self.timeSinceLastDetection = 0;
        
        self.turning = true;
        self.forward = false;
        self.forwardAndTurning = false;
        self.staying = false;
        self.stayingAndTurning = false;
        self.waiting = false;
        
        self.ended = false;
        
        self.doubleController.controlState.right = ACTIVE;
    }
    
    return self;
}

-(void) follow {
    while (1) {
        
        if (self.ended) {
            self.doubleController.controlState.forward = INACTIVE;
            self.doubleController.controlState.backward = INACTIVE;
            self.doubleController.controlState.left = INACTIVE;
            self.doubleController.controlState.right = INACTIVE;
            return;
        }

        if (self.videoProcessor.detectedMarkerCount == 0 || self.videoProcessor.currentMarkerId != 14) {
            self.timeSinceLastDetection++;
        } else {
            self.timeSinceLastDetection = 0;
            self.lastXPosition = self.videoProcessor.markerXPosition;
        }
        
        if (self.turning) {
            if (self.timeSinceLastDetection == 0) {
                self.doubleController.controlState.right = INACTIVE;
                self.doubleController.controlState.left = INACTIVE;
                
                [NSThread sleepForTimeInterval:0.5f];
                float x = self.lastXPosition - 240;
                float theta;
                if (x < 0) {
                    theta = - atan((x / 480.0) * tan(FOV / 2.0)) * 180.0 / M_PI;
                } else if (x > 0) {
                    theta = atan((-x / 480.0) * tan(FOV / 2.0)) * 180.0 / M_PI;
                } else {
                    theta = 0;
                }
                [[DRDouble sharedDouble] turnByDegrees: theta];
                [NSThread sleepForTimeInterval:0.5f];
                
                self.turning = false;
                
                if (self.videoProcessor.markerSize > 150) {
                    self.doubleController.controlState.forward = ACTIVE;
                    self.forward = true;
                } else {
                    self.staying = true;
                }
            }
        }
        
        else if (self.forward) {
            if (self.timeSinceLastDetection > 6) {
                self.doubleController.controlState.forward = INACTIVE;
                self.forward = false;
                self.waiting = true;
            }
            
            else if (self.timeSinceLastDetection > 0) {
                // We don't want to turn if we're looking at the wrong marker
            }
            
            else {
            
                if (self.videoProcessor.markerXPosition > 300  && self.videoProcessor.currentMarkerId == 14) {
                    self.doubleController.controlState.right = ACTIVE;
                    self.forward = false;
                    self.forwardAndTurning = true;
                }
                
                else if (self.videoProcessor.markerXPosition < 180 && self.videoProcessor.currentMarkerId == 14) {
                    self.doubleController.controlState.left = ACTIVE;
                    self.forward = false;
                    self.forwardAndTurning = true;
                }
                
                else if (self.videoProcessor.markerSize > 150 && self.videoProcessor.currentMarkerId == 14) {
                    self.doubleController.controlState.forward = INACTIVE;
                    self.forward = false;
                    self.staying = true;
                }
                
            }
        }
        
        else if (self.forwardAndTurning) {
            if (self.timeSinceLastDetection > 6) {
                self.doubleController.controlState.forward = INACTIVE;
                self.doubleController.controlState.left = INACTIVE;
                self.doubleController.controlState.right = INACTIVE;
                self.forwardAndTurning = false;
                self.waiting = true;
            }
            
            else {
            
                if (self.videoProcessor.markerXPosition < 380 && self.videoProcessor.markerXPosition > 100) {
                    self.doubleController.controlState.right = INACTIVE;
                    self.doubleController.controlState.left = INACTIVE;
                    self.forwardAndTurning = false;
                    self.forward = true;
                }
                
                else if (self.videoProcessor.markerSize > 150) {
                    self.doubleController.controlState.forward = INACTIVE;
                    self.forwardAndTurning = false;
                    self.stayingAndTurning = true;
                }
            }
        }
        
        else if (self.staying) {
            if (self.timeSinceLastDetection > 6) {
                self.staying = false;
                self.waiting = true;
            }
            
            else if (self.timeSinceLastDetection > 0) {
                // We don't want to turn if we're looking at the wrong marker
            }
            
            else {
                
                if (self.videoProcessor.markerXPosition > 300) {
                    self.doubleController.controlState.right = ACTIVE;
                    self.staying = false;
                    self.stayingAndTurning = true;
                }
                
                else if (self.videoProcessor.markerXPosition < 180) {
                    self.doubleController.controlState.left = ACTIVE;
                    self.staying = false;
                    self.stayingAndTurning = true;
                }
                
                else if (self.videoProcessor.markerSize < 150) {
                    self.doubleController.controlState.forward = ACTIVE;
                    self.staying = false;
                    self.forward = true;
                }
                
            }
        }
        
        else if (self.stayingAndTurning) {
            if (self.timeSinceLastDetection > 6) {
                self.doubleController.controlState.left = INACTIVE;
                self.doubleController.controlState.right = INACTIVE;
                self.stayingAndTurning = false;
                self.waiting = true;
            }
            
            else {
                
                if (self.videoProcessor.markerXPosition < 380 && self.videoProcessor.markerXPosition > 100) {
                    self.doubleController.controlState.right = INACTIVE;
                    self.doubleController.controlState.left = INACTIVE;
                    self.stayingAndTurning = false;
                    self.staying = true;
                }
                
                else if (self.videoProcessor.markerSize < 150) {
                    self.doubleController.controlState.forward = ACTIVE;
                    self.stayingAndTurning = false;
                    self.forwardAndTurning = true;
                }
            }
        }
        
        else if (self.waiting) {
            if (self.timeSinceLastDetection > 25) {
                if (self.lastXPosition > 240) {
                    self.doubleController.controlState.right = ACTIVE;
                } else {
                    self.doubleController.controlState.left = ACTIVE;
                }
                self.waiting = false;
                self.turning = true;
            }
            if (self.timeSinceLastDetection < 6) {
                float x = self.videoProcessor.markerXPosition - 240;
                float theta;
                if (x < 0) {
                    theta = - atan((x / 480.0) * tan(FOV / 2.0)) * 180.0 / M_PI;
                } else if (x > 0) {
                    theta = atan((-x / 480.0) * tan(FOV / 2.0)) * 180.0 / M_PI;
                } else {
                    theta = 0;
                }
                [[DRDouble sharedDouble] turnByDegrees: theta];
                [NSThread sleepForTimeInterval:0.5f];
                
                self.waiting = false;
                
                if (self.videoProcessor.markerSize > 150) {
                    self.doubleController.controlState.forward = ACTIVE;
                    self.forward = true;
                } else {
                    self.staying = true;
                }
            }
        }

        [NSThread sleepForTimeInterval:0.1f];
    }
}

@end
