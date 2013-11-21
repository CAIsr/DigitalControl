//
//  cameraTypeController.h
//  Digital Control
//
//  Created by Adam Lin on 5/06/13.
//  Copyright (c) 2013 Adam Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommController.h"

@interface cameraTypeController : NSObject{
    NSString *cameraType;
    
    char *callExpMode;
    char *callProMode;
    char *callApertureMode;
    char *callExposureComp;
    char *callShutterSpeed;
    char *callISO;
    char *callWhiteBalance;
    char *callHDR;
    char *callQuality;
    char *callLiveViewFPS;
    char *callAutoISO;
    
    char *callCapture;
    char *callFocus;
    char *callLiveView;
    
    char *callModel;
    char *callBattery;
    char *callFocusArea;
}
@property (nonatomic, retain) NSString *cameraType;
@property char *callExpMode;
@property char *callProMode;
@property char *callApertureMode;
@property char *callExposureComp;
@property char *callShutterSpeed;
@property char *callISO;
@property char *callWhiteBalance;
@property char *callHDR;
@property char *callQuality;
@property char *callLiveViewFPS;
@property char *callAutoISO;

@property char *callCapture;
@property char *callFocus;
@property char *callLiveView;

@property char *callModel;
@property char *callBattery;
@property char *callFocusArea;

-(void)dumpNewCameraValue: (NSArray *) checkCameraPrama;
@end
