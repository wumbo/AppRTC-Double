//
//  VideoProcessor.m
//  AppRTC
//
//  Created by Simon Crequer on 11/08/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import "VideoProcessor.h"

/**
 * Need to include the interface for this class as for some reason RTCI420Frame.h
 * doesn't include the actual interface. This makes the code compile because the
 * compiler knows the properties exist.
 */
@interface RTCI420Frame : NSObject

@property(nonatomic, readonly) NSUInteger width;
@property(nonatomic, readonly) NSUInteger height;
@property(nonatomic, readonly) NSUInteger chromaWidth;
@property(nonatomic, readonly) NSUInteger chromaHeight;
@property(nonatomic, readonly) NSUInteger chromaSize;
// These can return NULL if the object is not backed by a buffer.
@property(nonatomic, readonly) const uint8_t* yPlane;
@property(nonatomic, readonly) const uint8_t* uPlane;
@property(nonatomic, readonly) const uint8_t* vPlane;
@property(nonatomic, readonly) NSInteger yPitch;
@property(nonatomic, readonly) NSInteger uPitch;
@property(nonatomic, readonly) NSInteger vPitch;

- (BOOL)makeExclusive;
#ifndef DOXYGEN_SHOULD_SKIP_THIS
// Disallow init and don't add to documentation
- (id)init __attribute__((
    unavailable("init is not a supported initializer for this class.")));
#endif /* DOXYGEN_SHOULD_SKIP_THIS */

@end


@implementation VideoProcessor

-(void) setSize:(CGSize)size {
    
}

-(void) renderFrame:(RTCI420Frame *)frame {
    NSLog(@"Received frame");
    NSLog(@"%lu", (unsigned long)frame.yPlane);
    NSLog(@"%lu", (unsigned long)frame.uPlane);
    NSLog(@"%lu", (unsigned long)frame.vPlane);
    NSLog(@"%lu", (unsigned long)frame.yPitch);
    NSLog(@"%lu", (unsigned long)frame.uPitch);
    NSLog(@"%lu", (unsigned long)frame.vPitch);
}

@end
