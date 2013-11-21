//
//  cameraTypeController.m
//  Digital Control
//
//  Created by Adam Lin on 5/06/13.
//  Copyright (c) 2013 Adam Lin. All rights reserved.
//

#import "cameraTypeController.h"

@implementation cameraTypeController

@synthesize cameraType;
@synthesize callExpMode, callApertureMode, callExposureComp, callHDR, callISO, callProMode, callQuality, callShutterSpeed, callWhiteBalance, callAutoISO;
@synthesize callLiveView, callCapture, callFocus, callLiveViewFPS;
@synthesize callBattery, callFocusArea, callModel;

-(void)dumpNewCameraValue: (NSArray *) checkCameraPrama{
    if ([checkCameraPrama count] != 0) {
        for (int i = 0 ;i < [checkCameraPrama count]; i++) {
            if ([[[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"] isEqualToString:@"Nikon Corporation"]) {
                cameraType = [[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"];
                
                [self changCommMessageCode:"exposuremetermode" :"expprogram"
                                          :"f-number" :"exposurecompensation" :"shutterspeed" :"iso"
                                          :"whitebalance" :"hdrhighdynamic" :"imagequality":"autoiso"];
                
                [self changFireMessageCode:"capture" :"auto_focus" :"liveview" :"liveviewfps"];
                [self changModelOthers: "cameramodel" :"batterylevel" :"autofocusarea"];
                return;
            }
            
            if ([[[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"] isEqualToString:@"Canon"]) {
                cameraType = [[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"];
                // fill in all value for canon pramater...........
                [self changCommMessageCode:"exposuremetermode" :"expprogram"
                                          :"f-number" :"exposurecompensation" :"shutterspeed" :"iso"
                                          :"whitebalance" :"hdrhighdynamic" :"imagequality":"autoiso"];
                
                [self changFireMessageCode:"capture" :"auto_focus" :"liveview" :"liveviewfps"];
                [self changModelOthers: "cameramodel" :"batterylevel" :"autofocusarea"];
                return;
            }
            if ([[[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"] isEqualToString:@"Sony"]) {
                cameraType = [[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"];
                return;
            }
            if ([[[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"] isEqualToString:@"Casio"]) {
                cameraType = [[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"];
                return;
            }
            if ([[[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"] isEqualToString:@"Fuji"]) {
                cameraType = [[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"];
                return;
            }
            if ([[[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"] isEqualToString:@"Kodak"]) {
                cameraType = [[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"];
                return;
            }
            if ([[[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"] isEqualToString:@"Fuji"]) {
                cameraType = [[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"];
                return;
            }
            if ([[[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"] isEqualToString:@"Olympus"]) {  
                cameraType = [[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"];
                return;
            }
            if ([[[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"] isEqualToString:@"Pentax"]) {
                cameraType = [[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"];
                return;
            }
            if ([[[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"] isEqualToString:@"Ricoh"]) {
                cameraType = [[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"];
                return;
            }
            if ([[[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"] isEqualToString:@"Apple iPhone"]) {
                cameraType = [[checkCameraPrama objectAtIndex:(long)i] objectForKey:@"CurrentValue"];
                // fill in all value for canon pramater...........
                [self changCommMessageCode:"" :""
                                          :"" :"" :"" :""
                                          :"" :"" :"":""];
                
                [self changFireMessageCode:"" :"" :"" :""];
                [self changModelOthers: "cameramodel" :"" :""];
                return;
            }
        }
    }
    return;
}

//assign all callback value for camera used
-(void)changCommMessageCode:(char *)expMode: (char *)proMode: (char *)apertureMode: (char *)exposureComp: (char *)shutterSpeed: (char *)ISO: (char *)whilteBalance: (char *)HDR: (char *)quality: (char *)autoISO{
    callExpMode = expMode;
    callProMode = proMode;
    callApertureMode = apertureMode;
    callExposureComp = exposureComp;
    callShutterSpeed = shutterSpeed;
    callISO = ISO;
    callWhiteBalance = whilteBalance;
    callHDR = HDR;
    callQuality = quality;
    callAutoISO = autoISO;
}

-(void)changFireMessageCode:(char *)capture: (char *)focus: (char *)liveView: (char *)liveViewFPS{
    callLiveView = liveView;
    callCapture = capture;
    callFocus = focus;
    callLiveViewFPS = liveViewFPS;
}
-(void)changModelOthers: (char *)model: (char *)battery: (char *)autofocusarea{
    callBattery = battery;
    callModel = model;
    callFocusArea = autofocusarea;
}

@end
