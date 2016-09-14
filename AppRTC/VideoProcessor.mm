//
//  VideoProcessor.m
//  AppRTC
//
//  Created by Simon Crequer on 11/08/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import <opencv2/opencv.hpp>

#import <Foundation/Foundation.h>

#import "VideoProcessor.h"
#import <RTCI420Frame.h>

#import "ARTCVideoChatViewController.h"

#define SKIP_FRAMES 0


@interface VideoProcessor ()

@property ARTCVideoChatViewController *observer;
@property int frameSkipper;

@end

@implementation VideoProcessor

-(id) init {
    if (self = [super init]) {
        self.frameSkipper = 0;
    }
    return self;
}

-(void) setSize:(CGSize)size {
    
}

-(void) renderFrame:(RTCI420Frame *)frame {
    NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(processFrame:)
                                                   object:frame];
    [myThread start];
}

-(void) processFrame:(RTCI420Frame *)frame {
    if (self.frameSkipper == SKIP_FRAMES) {
        // Convert the frame into an OpenCV matrix, then convert from YUV to RGB
        cv::Mat mYUV((int)frame.height + (int)frame.chromaHeight, (int)frame.width, CV_8UC1, (void*) frame.yPlane);
        cv::Mat mRGB((int)frame.height, (int)frame.width, CV_8UC1);
        cvtColor(mYUV, mRGB, CV_YUV2RGB_I420);
        
        [self detectMarkers:&mRGB];
        
        // Convert OpenCV matrix to UIImage and update the view
        UIImage *image = [self UIImageFromCVMat:mRGB];
        if (self.observer) {
            [self.observer showImage:image];
        }
        
        self.frameSkipper = 0;
    } else {
        self.frameSkipper++;
    }
}

-(void) detectMarkers:(cv::Mat *)image {
    int rows = image->rows;
    int cols = image->cols;
    
    int yMaxR = 0;
    int yMinR = rows;
    int xMaxR = 0;
    int xMinR = cols;
    int yMaxY = 0;
    int yMinY = rows;
    int xMaxY = 0;
    int xMinY = cols;
    int yMaxB = 0;
    int yMinB = rows;
    int xMaxB = 0;
    int xMinB = cols;
    int yMaxW = 0;
    int yMinW = rows;
    int xMaxW = 0;
    int xMinW = cols;
    
    for (int y = 0; y < rows; y++) {
        for (int x = 0; x < cols; x++) {
            cv::Vec3b intensity = image->at<cv::Vec3b>(y, x);
            uchar red = intensity.val[0];
            uchar green = intensity.val[1];
            uchar blue = intensity.val[2];
    
            if (red > 240 && green > 50 && green < 170 && blue > 180) {
                if (y > yMaxR) yMaxR = y;
                if (y < yMinR) yMinR = y;
                if (x > xMaxR) xMaxR = x;
                if (x < xMinR) xMinR = x;
            }
            if (red > 170 && green > 240 && blue > 60 && blue < 150) {
                if (y > yMaxY) yMaxY = y;
                if (y < yMinY) yMinY = y;
                if (x > xMaxY) xMaxY = x;
                if (x < xMinY) xMinY = x;
            }
            if (red > 60 && red < 190 && green > 130 && blue > 230) {
                if (y > yMaxB) yMaxB = y;
                if (y < yMinB) yMinB = y;
                if (x > xMaxB) xMaxB = x;
                if (x < xMinB) xMinB = x;
            }
            if (red > 230 && green > 230 && blue > 230) {
                if (y > yMaxW) yMaxW = y;
                if (y < yMinW) yMinW = y;
                if (x > xMaxW) xMaxW = x;
                if (x < xMinW) xMinW = x;
            }
        }
    }

    cv::rectangle(*image, cv::Point(xMinR, yMinR), cv::Point(xMaxR, yMaxR), cv::Scalar(0, 127, 31));
    cv::rectangle(*image, cv::Point(xMinY, yMinY), cv::Point(xMaxY, yMaxY), cv::Scalar(63, 0, 127));
    cv::rectangle(*image, cv::Point(xMinB, yMinB), cv::Point(xMaxB, yMaxB), cv::Scalar(127, 31, 0));
    cv::rectangle(*image, cv::Point(xMinW, yMinW), cv::Point(xMaxW, yMaxW), cv::Scalar(0, 0, 0));
    cv::putText(*image,
                "Pink",
                cv::Point((xMinR + xMaxR)/2 - 30, (yMinR + yMaxR)/2 + 7),
                cv::FONT_HERSHEY_COMPLEX_SMALL,
                1.0,
                cv::Scalar(0,0,0),
                1,
                CV_AA);
    cv::putText(*image,
                "Yellow",
                cv::Point((xMinY + xMaxY)/2 - 34, (yMinY + yMaxY)/2 + 7),
                cv::FONT_HERSHEY_COMPLEX_SMALL,
                1.0,
                cv::Scalar(0,0,0),
                1,
                CV_AA);
    cv::putText(*image,
                "Blue",
                cv::Point((xMinB + xMaxB)/2 - 30, (yMinB + yMaxB)/2 + 7),
                cv::FONT_HERSHEY_COMPLEX_SMALL,
                1.0,
                cv::Scalar(0,0,0),
                1,
                CV_AA);
    cv::putText(*image,
                "White",
                cv::Point((xMinW + xMaxW)/2 - 32, (yMinW + yMaxW)/2 + 7),
                cv::FONT_HERSHEY_COMPLEX_SMALL,
                1.0,
                cv::Scalar(0,0,0),
                1,
                CV_AA);
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
