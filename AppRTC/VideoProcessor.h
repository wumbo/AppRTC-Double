//
//  VideoProcessor.h
//  AppRTC
//
//  Created by Simon Crequer on 11/08/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCVideoRenderer.h"

@interface VideoProcessor : NSObject <RTCVideoRenderer>

-(void) addObserver:(id) observer;

@end
