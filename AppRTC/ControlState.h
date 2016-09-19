//
//  ControlState.h
//  AppRTC
//
//  Created by Simon Crequer on 19/09/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Used to indicate whether a specific direction is active or not (start/stop)
 */
typedef enum {
    INACTIVE = 0,
    ACTIVE = 1
} active_t;

@interface ControlState : NSObject

@property active_t forward;
@property active_t backward;
@property active_t left;
@property active_t right;

@end
