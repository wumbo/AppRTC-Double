//
//  VideoProcessor.m
//  AppRTC
//
//  Created by Simon Crequer on 11/08/16.
//  Copyright © 2016 ISBX. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/aruco.hpp>

#import <Foundation/Foundation.h>

#import "VideoProcessor.h"
#import <RTCI420Frame.h>

#import "ARTCVideoChatViewController.h"

#define SKIP_FRAMES 0

using namespace cv;


@interface VideoProcessor ()

@property ARTCVideoChatViewController *observer;
@property int frameSkipper;

@property Ptr<aruco::DetectorParameters> detectorParams;
@property Ptr<aruco::Dictionary> dictionary;

@property int totalFrames;
@property int successfulFrames;

@end

@implementation VideoProcessor

-(id) init {
    if (self = [super init]) {
        self.frameSkipper = 0;
        self.detectedMarkerCount = 0;
        self.totalFrames = 0;
        self.successfulFrames = 0;
        
        self.detectorParams = aruco::DetectorParameters::create();
        self.detectorParams->doCornerRefinement = true;
        self.dictionary = aruco::getPredefinedDictionary(cv::aruco::DICT_4X4_50);
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
    std::vector<int> markerIds;
    std::vector<std::vector<Point2f>> markerCorners, rejectedCandidates;
    aruco::detectMarkers(*image, _dictionary, markerCorners, markerIds, self.detectorParams, rejectedCandidates);
    cv::aruco::drawDetectedMarkers(*image, markerCorners, markerIds);
    //std::vector<Vec3d> rvecs, tvecs;
    //aruco::estimatePoseSingleMarkers(corners, 0.05, cameraMatrix, distCoeffs, rvecs, tvecs);
    
    self.detectedMarkerCount = (int)markerIds.size();
    NSLog(@"Marker IDs");
    for (int i = 0; i < markerIds.size(); i++) {
        NSLog(@"%d", markerIds[i]);
    }
    
    self.totalFrames ++;
    if (markerIds.size() > 0) {
        self.successfulFrames++;
    }
    NSLog(@"Success rate: %f %%", 100 * ((float)self.successfulFrames)/self.totalFrames);
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
