//
//  AppDelegate.h
//  Digital Control
//
//  Created by Adam Lin on 13/03/13.
//  Copyright (c) 2013 Adam Lin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Quartz/Quartz.h>
#import <IOKit/hid/IOHIDManager.h>
#import "CommSocketClient.h"
#import "CommController.h"
#import "PreferencesController.h"
#import "initCameraValue.h"
#import "cameraTypeController.h"
#import "USBDetection.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    NSWindow *window;
    NSWindow *preferenceWindow;
    
    NSTextField *apertureLabel;
    NSTextField *exposureLabel;
    NSTextField *shutterLabel;
    
    NSTextField *displayShutterSpeed;
    NSTextField *displayExposure;
    NSButton *displayPanelArrow;
    NSTextField *displayAperture;
    NSComboBox *displayISODropDown;
    NSComboBox *displayExposureMode;
    NSComboBox *displayWhiteBalanceDropDown;
    NSComboBox *displayImageQualityDropDown;
    NSComboBox *displayProgramModeDropDown;
    
    NSTextField *displayISO;
    NSTextField *displayProgramMode;
    NSImageView *jpLiveView;
    NSImageView *jpLiveView2;
    NSImageView *jpGrid;
    
    NSSlider *apertureSliderValue;
    NSSlider *exposureSliderValue;
    NSSlider *shutterSpeedSliderValue;
    
    NSArray *gApertureValue;
    NSArray *gExposureValue;
    NSArray *gShutterSpeedValue;
    NSArray *gISOValue;
    NSArray *gExposureModeValue;
    NSArray *gWhiteBalanceValue;
    NSArray *gImageQualityValue;
    NSArray *gProgramModeValue;
    NSArray *gHDRModeValue;
    
    NSTextField *detectCamera;
    NSTextField *diskSpace;
    NSTextField *cameraName;
    NSTextField *connection;
    NSView *displayDrawer;
    
    NSTextField *status;
    NSString *log;
    NSMutableAttributedString *logColor;
    NSButton *btCapture;
    NSComboBox *nCaptureTime;
    NSMutableArray *fulldetails;
    NSString *fullvalues;
    NSString *fullmessages;
    NSString *fullcurrentvalue;
    NSData *fullLiveViewData;
    NSTextField *systemLog;
    
    CommSocketClient *socket;
    CommSocketClient *socket_data;
    NSLevelIndicator *batteryLevel;
    
    // focus area buttons slection
    NSButton *btFocusCentre;
    NSButton *btFocusCentreRight;
    NSButton *btFocusCentreLeft;
    NSButton *btFocusTop;
    NSButton *btFocusTopRight;
    NSButton *btFocusTopLeft;
    NSButton *btFocusBottom;
    NSButton *btFocusBottomRight;
    NSButton *btFocusBottomLeft;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSWindow *preferenceWindow;
@property (nonatomic, retain) IBOutlet NSWindow *cameraValueWindow;

//slider values
@property (nonatomic, retain) IBOutlet NSSlider *apertureSliderValue;
@property (nonatomic, retain) IBOutlet NSSlider *exposureSliderValue;
@property (nonatomic, retain) IBOutlet NSSlider *shutterSpeedSliderValue;
@property (nonatomic, retain) IBOutlet NSSlider *FPSSliderValue;
@property (nonatomic, retain) IBOutlet NSTextField *apertureLabel;
@property (nonatomic, retain) IBOutlet NSTextField *exposureLabel;
@property (nonatomic, retain) IBOutlet NSTextField *shutterLabel;
@property (nonatomic, retain) IBOutlet NSTextField *FPSLabel;

//button label values
@property (nonatomic, retain) IBOutlet NSTextField *displayShutterSpeed;
@property (nonatomic, retain) IBOutlet NSTextField *displayExposure;
@property (nonatomic, retain) IBOutlet NSButton *displayPanelArrow;
@property (nonatomic, retain) IBOutlet NSTextField *displayAperture;
@property (nonatomic, retain) IBOutlet NSTextField *displayISO;
@property (nonatomic, retain) IBOutlet NSTextField *displayProgramMode;

//dropdown valuesdisplay
@property (nonatomic, retain) IBOutlet NSComboBox *displayISODropDown;
@property (nonatomic, retain) IBOutlet NSComboBox *displayExposureMode;
@property (nonatomic, retain) IBOutlet NSComboBox *displayWhiteBalanceDropDown;
@property (nonatomic, retain) IBOutlet NSComboBox *displayImageQualityDropDown;
@property (nonatomic, retain) IBOutlet NSComboBox *displayProgramModeDropDown;
@property (nonatomic, retain) IBOutlet NSComboBox *nCaptureTime;
@property (nonatomic, retain) IBOutlet NSComboBox *displayHDRMode;

//live view image
@property (nonatomic, retain) IBOutlet NSImageView *jpLiveView;
@property (nonatomic, retain) IBOutlet NSImageView *jpLiveView2;
@property (nonatomic, retain) IBOutlet NSImageView *jpGrid;
@property (nonatomic, retain) NSImage *newimage;

@property (nonatomic, retain) IBOutlet NSTextField *diskSpace;
@property (nonatomic, retain) IBOutlet NSTextField *bnLiveView;

@property (nonatomic, retain) CommSocketClient *socket;
@property (nonatomic, retain) CommSocketClient *socket_data;
@property (nonatomic, retain) cameraTypeController *checkCameraType;
@property (nonatomic, retain) NSMutableArray *fulldetails;
@property (nonatomic, retain) NSString *fullvalues;
@property (nonatomic, retain) NSString *fullmessages;
@property (nonatomic, retain) NSString *fullcurrentvalue;
@property (nonatomic, retain) NSData *fullLiveViewData;

// Top feilds
@property (nonatomic, retain) IBOutlet NSTextField *cameraName;
@property (nonatomic, retain) IBOutlet NSTextField *connection;

// Side Panel
@property (nonatomic, retain) IBOutlet NSTextField *status;

// Battery Level
@property (nonatomic, retain) IBOutlet NSLevelIndicator *batteryLevel;

// Systemlog
@property (nonatomic, retain) IBOutlet NSTextField *systemLog;

// RejectButton
@property (nonatomic, retain) IBOutlet NSButton *ejectButton;

//KeyDown to capture
@property (nonatomic, retain) IBOutlet NSButton *keyDownCapture;

// IBAction to triger functions
- (IBAction)sliderAperture:(id)sender;
- (IBAction)sliderExposure:(id)sender;
- (IBAction)sliderShutter:(id)sender;
- (IBAction)sliderFPS:(id)sender;
- (IBAction)btCapture:(id)sender;
- (IBAction)btFocus:(id)sender;
- (IBAction)dropDownISO:(id)sender;
- (IBAction)dropDownWhiteBalance:(id)sender;
- (IBAction)dropDownImageQuality:(id)sender;
- (IBAction)dropDownProgramMode:(id)sender;
- (IBAction)dropDownExposureMode:(id)sender;
- (IBAction)rejectCamera:(id)sender;
- (IBAction)ISOAuto:(id)sender;
- (IBAction)HDRmode:(id)sender;
- (IBAction)cameraValueChanged:(id)sender;
- (IBAction)moreCameraValue:(id)sender;

//Focus Area Controller - change foucs point
@property (nonatomic, retain) IBOutlet NSButton *btFocusCentre;
@property (nonatomic, retain) IBOutlet NSButton *btFocusCentreRight;
@property (nonatomic, retain) IBOutlet NSButton *btFocusCentreLeft;
@property (nonatomic, retain) IBOutlet NSButton *btFocusTop;
@property (nonatomic, retain) IBOutlet NSButton *btFocusTopRight;
@property (nonatomic, retain) IBOutlet NSButton *btFocusTopLeft;
@property (nonatomic, retain) IBOutlet NSButton *btFocusBottom;
@property (nonatomic, retain) IBOutlet NSButton *btFocusBottomRight;
@property (nonatomic, retain) IBOutlet NSButton *btFocusBottomLeft;

- (IBAction)focusCentre:(id)sender;
- (IBAction)focusCentreRight:(id)sender;
- (IBAction)focusCentreLeft:(id)sender;
- (IBAction)focusTop:(id)sender;
- (IBAction)focusBottom:(id)sender;
- (IBAction)focusTopRight:(id)sender;
- (IBAction)focusTopLeft:(id)sender;
- (IBAction)focusBottomRight:(id)sender;
- (IBAction)focusBottomLeft:(id)sender;


//preferences
- (IBAction)openPreferences:(id)sender;


// USB device callback function
static void Handle_DeviceMatchingCallback(void *inContext,
                                          IOReturn inResult,
                                          void *inSender,
                                          IOHIDDeviceRef inIOHIDDeviceRef);

static void Handle_DeviceRemovalCallback(void *inContext,
                                         IOReturn inResult,
                                         void *inSender,
                                         IOHIDDeviceRef inIOHIDDeviceRef);

static long USBDeviceCount(IOHIDManagerRef HIDManager);

@end