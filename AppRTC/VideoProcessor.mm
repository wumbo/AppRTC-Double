//
//  VideoProcessor.m
//  AppRTC
//
//  Created by Simon Crequer on 11/08/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VideoProcessor.h"
#import <RTCI420Frame.h>
#import <opencv2/opencv.hpp>

#import "ARTCVideoChatViewController.h"

using namespace cv;


@interface VideoProcessor ()

@property ARTCVideoChatViewController *observer;

@end

@implementation VideoProcessor

-(void) setSize:(CGSize)size {
    
}

-(void) renderFrame:(RTCI420Frame *)frame {
    // Convert the frame into an OpenCV matrix, then convert from YUV to RGB
    Mat mYUV((int)frame.height + (int)frame.chromaHeight, (int)frame.width, CV_8UC1, (void*) frame.yPlane);
    Mat mRGB((int)frame.height, (int)frame.width, CV_8UC1);
    cvtColor(mYUV, mRGB, CV_YUV2GRAY_I420);
    
    // Convert OpenCV matrix to UIImage and update the view
    UIImage *image = [self UIImageFromCVMat:mRGB];
    if (self.observer) {
        [self.observer showImage:image];
    }
}

/*
 * Converts an OpenCV matrix to a UIImage. If the matrix has one channel, the image will be grayscale,
 * otherwise it will be RGB
 */
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

// TODO: Use real observer pattern or something else
-(void) addObserver:(id) observer {
    self.observer = observer;
}

@end
