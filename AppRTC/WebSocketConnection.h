//
//  WebSocketConnection.h
//  AppRTC
//
//  Created by Simon Crequer on 11/07/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SIOSocket/SIOSocket.h>

@interface WebSocketConnection : NSObject

@property SIOSocket *socket;

- (id) init;

@end
