//
//  AppDelegate.m
//  Digital Control
//
//  Created by Adam Lin on 13/03/13.
//  Copyright (c) 2013 Adam Lin. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window, preferenceWindow, cameraValueWindow;
@synthesize apertureSliderValue, exposureSliderValue, shutterSpeedSliderValue, FPSSliderValue;
@synthesize apertureLabel, exposureLabel, shutterLabel, FPSLabel;
@synthesize displayShutterSpeed, displayExposure, displayPanelArrow, displayAperture;
@synthesize displayISO, displayProgramMode;
@synthesize displayISODropDown, displayWhiteBalanceDropDown, displayExposureMode, displayImageQualityDropDown, displayProgramModeDropDown, displayHDRMode;
@synthesize nCaptureTime;
@synthesize jpGrid, jpLiveView, jpLiveView2, newimage;
@synthesize diskSpace;
@synthesize bnLiveView;
@synthesize socket, socket_data, checkCameraType;
@synthesize fulldetails, fullvalues, fullmessages, fullLiveViewData, fullcurrentvalue;
//Top feilds
@synthesize cameraName,connection;
//Slide Panel
@synthesize status,batteryLevel;
@synthesize systemLog, ejectButton,keyDownCapture;
//button for focus area action
@synthesize btFocusCentre,btFocusCentreRight,btFocusCentreLeft,btFocusTop,btFocusTopRight,btFocusTopLeft,btFocusBottom,btFocusBottomRight,btFocusBottomLeft;
//tray value
@synthesize vertical_number, horizontal_number, save_tray, rotating_number;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{       
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *FPSStoredValue = [prefs stringForKey:@"FPSValueString"];
    if(FPSStoredValue != NULL){
        [FPSSliderValue setStringValue:FPSStoredValue];
    }
    
    // ----------   Set All Information from Camera    -----------------//
    setFullPathInfo(NULL, NULL, NULL, NULL,NULL, NULL, (__bridge void*)self);
    setAllCameraValue(NULL, NULL, NULL, (__bridge void*)self);
    
    checkCameraType = [[cameraTypeController alloc]init];
    
    // ---------    PreView Image Information   --------------//
    [self getDiskSpacePrivate];
    
    // ---------    Finally display    ---------------------------//
    [preferenceWindow setIsVisible:NO];
    [window makeKeyWindow];
    
    [nCaptureTime selectItemAtIndex:0]; // set default value of capture time when application started!
    [self initAllValue]; // start all thread to connect with sockets
    
    // set few images while init application
    NSImage *grid_img = [NSImage imageNamed:@"camera_grid10.png"];
    [grid_img setSize:(NSSize){385,260}];
    [jpGrid setImage:grid_img];
    [jpLiveView2 setImage:[NSImage imageNamed:@"blackImage.png"]];
    [self getUSBlistener];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[FPSSliderValue objectValue] forKey:@"FPSValueString"];
    [prefs setObject:imagefilePath forKey:@"ImageSavePath"];
    return YES;
}

-(void)trigerCameraFunction:(char *)exet_message: (char *)comm_message: (char *)dis_message: (const char *)triger_message{
    if([socket sockRef]){
        int sock = CFSocketGetNative([socket sockRef]);
        char *final_message;
        asprintf(&final_message, "%s|%s|%s|%s|\n", exet_message, comm_message, dis_message, triger_message);
        
        write(sock, final_message, strlen(final_message));
        free(final_message);
    }
}

- (IBAction)sliderAperture:(id)sender {
    float current = lrintf([apertureSliderValue floatValue]);
    NSString *output = [[NSString alloc]initWithFormat:@"%@", [gApertureValue objectAtIndex:current]];
    if([socket sockRef]){
        [apertureLabel setStringValue:[output capitalizedString]];
        if([output isNotEqualTo:@"(null)"]){    // if no camera connected. need to check to see if slider is working!
            [displayAperture setStringValue:[[gApertureValue objectAtIndex:current] capitalizedString]];
                    
            /*          trigger event when mouse up         */
            NSEvent *event = [[NSApplication sharedApplication]currentEvent];
            BOOL endingDrag = event.type == NSLeftMouseUp;
            if(endingDrag){
                [self trigerCameraFunction:"64" :[checkCameraType callApertureMode]: "Aperture Value" :[output UTF8String]];
            }
        }
    }
}

- (IBAction)sliderExposure:(id)sender {
    float current = lrintf([exposureSliderValue floatValue]);
    int ntemOutPut = [[[NSString alloc]initWithFormat:@"%@", [gExposureValue objectAtIndex:current]] intValue]/1000;
    if([socket sockRef]){
        NSString *nOutput = [NSString stringWithFormat:@"%i EV", ntemOutPut];
        [exposureLabel setStringValue:nOutput];
        [displayExposure setStringValue:[NSString stringWithFormat:@"%i",ntemOutPut]];
        
        /*          trigger event when mouse up         */
        NSEvent *event = [[NSApplication sharedApplication]currentEvent];
        BOOL endingDrag = event.type == NSLeftMouseUp;
        
        if(endingDrag){
            [self trigerCameraFunction:"64" :[checkCameraType callExposureComp]: "Exposure Value"
                                      :[[[NSString alloc]initWithFormat:@"%@", [gExposureValue objectAtIndex:current]] UTF8String]];
        }
    }
}

- (IBAction)sliderShutter:(id)sender {
    float current = lrintf([shutterSpeedSliderValue floatValue]);
    if([socket sockRef]){
        NSString *output = [gShutterSpeedValue objectAtIndex:current];
        NSRange r;
        r.location = 0;
        r.length = [output length]-1;
        double num = [[output substringWithRange:r] doubleValue];
        double n_num = ceil(1/num);
        double p_num = ceil(num);
        
        if(num < 1){
            NSString *output_int = [[NSString alloc]initWithFormat:@"1/%.0fsec",n_num];
            [shutterLabel setStringValue:output_int];
            [displayShutterSpeed setStringValue:[output_int stringByReplacingOccurrencesOfString:@"sec" withString:@""]];
        }
        else if ( num >= 1){
            NSString *output_int2 = [[NSString alloc]initWithFormat:@"%.0fsec",p_num];
            [shutterLabel setStringValue:output_int2];
            [displayShutterSpeed setStringValue:[output_int2 stringByReplacingOccurrencesOfString:@"sec" withString:@""]];
        }
        if ( num > 30){
            [shutterLabel setStringValue:@"Bulb"];
            [displayShutterSpeed setStringValue:@"Bulb"];
        }
        /*          trigger event when mouse up         */
        NSString *output2 = [[NSString alloc]initWithFormat:@"%@", [gShutterSpeedValue objectAtIndex:current]];
        
        NSEvent *event = [[NSApplication sharedApplication]currentEvent];
        BOOL endingDrag = event.type == NSLeftMouseUp;
        
        if(endingDrag){
            [self trigerCameraFunction:"64" :[checkCameraType callShutterSpeed] : "Shutter Speed" :[output2 UTF8String]];
        }
    }
}

- (IBAction)sliderFPS:(id)sender {
    float current = lrintf([FPSSliderValue floatValue]);
    NSString *output = [[NSString alloc]initWithFormat:@"%.0f/sec", current];
    NSString *tempOutput = [[NSString alloc]initWithFormat:@"%.0f", current];
    [FPSLabel setStringValue:output];
    if([socket sockRef]){
        if([tempOutput isNotEqualTo:@"(null)"]){
            /*          trigger event when mouse up         */
            NSEvent *event = [[NSApplication sharedApplication]currentEvent];
            BOOL endingDrag = event.type == NSLeftMouseUp;
            
            if(endingDrag){
                [self trigerCameraFunction:"64" :[checkCameraType callLiveViewFPS] : "FPS Value" :[tempOutput UTF8String]];
            }
        }
    }
}

- (IBAction)btCapture:(id)sender {
    if([socket sockRef]){        
        int sock = CFSocketGetNative([socket sockRef]);
        NSInteger time_message = [nCaptureTime indexOfSelectedItem];
        char *first_message = "64|capture|asking capture|";
        char *middle_message = "|";
        const char *other_message = [imagefilePath UTF8String];
        char *final_message;
        asprintf(&final_message, "%s%li%s%s/|\n", first_message, ++time_message, middle_message, other_message);
        write(sock, final_message, strlen(final_message));
        free(final_message);
    }
}

- (IBAction)btFocus:(id)sender {
    if([socket sockRef]){
        [self trigerCameraFunction:"64" :[checkCameraType callFocus] : "Focusing" :NULL];
    }
}
- (IBAction)dropDownISO:(id)sender {
    NSComboBox *boxValue = (NSComboBox *)sender;
    NSString *stValue = [boxValue objectValueOfSelectedItem];
    /*          trigger event          */
    if(stValue != NULL && [socket sockRef] != NULL){
        [self trigerCameraFunction:"64" :[checkCameraType callISO] : "Setting ISO" :[stValue UTF8String]];
        [displayISO setStringValue:stValue];
    }
}

- (IBAction)dropDownWhiteBalance:(id)sender {
    NSComboBox *boxValue = (NSComboBox *)sender;
    NSString *stValue = [boxValue objectValueOfSelectedItem];
    /*          trigger event          */
    if(stValue != NULL && [socket sockRef] != NULL){
        [self trigerCameraFunction:"64" :[checkCameraType callWhiteBalance] : "Setting White Balance" :[stValue UTF8String]];
        [displayWhiteBalanceDropDown setStringValue:stValue];
    }
}

- (IBAction)dropDownImageQuality:(id)sender {
    NSComboBox *boxValue = (NSComboBox *)sender;
    NSString *stValue = [boxValue objectValueOfSelectedItem];
    /*          trigger event          */
    if(stValue != NULL && [socket sockRef] != NULL){
        [self trigerCameraFunction:"64" :[checkCameraType callQuality] : "Setting Image Quality" :[stValue UTF8String]];
        [displayImageQualityDropDown setStringValue:stValue];
    }
}

- (IBAction)dropDownProgramMode:(id)sender {
    NSComboBox *boxValue = (NSComboBox *)sender;
    NSString *stValue = [boxValue objectValueOfSelectedItem];
    
    /*          trigger event          */
    if(stValue != NULL && [socket sockRef] != NULL){
        [self trigerCameraFunction:"64" :[checkCameraType callProMode] : "Setting Program Mode" :[stValue UTF8String]];
        [displayProgramMode setStringValue:stValue];
    }
}

- (IBAction)rejectCamera:(id)sender {
    if ([[connection stringValue] isEqualToString:@"connected"]) {
        if([socket sockRef] != NULL){
            [self trigerCameraFunction:"64" :"eject" : "ejectCamera" :NULL];
            [cameraName setStringValue:@"not found"];
            [connection setStringValue:@"disconnect"];
            [ejectButton setImage:[NSImage imageNamed:@"connect.png"]];
            [ejectButton setAlternateImage:[NSImage imageNamed:@"connect.png"]];
            [systemLog setStringValue:@"camera ejected!"];
            //[socket stopClient];
            //[socket_data stopClient];
        }
    }
    // fix for reconnection
    else if ([[connection stringValue] isEqualToString:@"disconnect"]) {
        [self trigerCameraFunction:"64" :"connect" : "connectCamera" :NULL];
        [ejectButton setImage:[NSImage imageNamed:@"eject.png"]];
        [connection setStringValue:@"connected"];
    }
}

- (IBAction)ISOAuto:(id)sender {
    
    NSButton *button = sender;
    if ([button state] == NSOnState){
        if([socket sockRef] != NULL){
            [self trigerCameraFunction:"64" :[checkCameraType callAutoISO] : "setting Auto ISO" :"On"];
            [displayISODropDown setEnabled:NO];
        }
    }
    else{
        if([socket sockRef] != NULL){
            [self trigerCameraFunction:"64" :[checkCameraType callAutoISO] : "setting Auto ISO" :"Off"];
            [displayISODropDown setEnabled:YES];
        }
    }
}

- (IBAction)HDRmode:(id)sender {
    NSComboBox *boxValue = (NSComboBox *)sender;
    NSString *stValue = [boxValue objectValueOfSelectedItem];
    /*          trigger event          */
    if(stValue != NULL && [socket sockRef] != NULL){
        [self trigerCameraFunction:"64" :[checkCameraType callHDR] : "HDR High Dynamic" :[stValue UTF8String]];
        [displayHDRMode setStringValue:stValue];
    }
}

- (IBAction)moreCameraValue:(id)sender {
    [cameraValueWindow setIsVisible:YES];
}

- (IBAction)openPreferences:(id)sender {
    [preferenceWindow setIsVisible:YES];
}

- (IBAction)dropDownExposureMode:(id)sender {
    NSComboBox *boxValue = (NSComboBox *)sender;
    NSString *stValue = [boxValue objectValueOfSelectedItem];
    
    /*          trigger event          */
    if(stValue != NULL && [socket sockRef] != NULL){
        [self trigerCameraFunction:"64" :[checkCameraType callExpMode] : "Exposuremet Mode" :[stValue UTF8String]];
    }
}
- (void)getDiskSpacePrivate{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        float freeSpace  = [[dictionary objectForKey: NSFileSystemFreeSize] floatValue];
        NSString *availableSpace = [NSString stringWithFormat:@"%.02f GB",freeSpace/1000000000];
        diskSpace.stringValue = availableSpace;
    }
}

- (void)initAllValueFromCamera{
    [checkCameraType dumpNewCameraValue:fulldetails];
    NSDictionary *tempValue;
    NSString *tempString;
    NSMutableArray *tempParam;
    NSString *getCurrentValue;

    for (int i = 0; i < [fulldetails count]; i++){
        tempValue = [fulldetails objectAtIndex:i];
        tempString = [tempValue objectForKey:@"Command"];
        if([tempString isEqualTo:[NSString stringWithFormat:@"%s",[checkCameraType callExpMode]]]){
            tempParam = [tempValue objectForKey:@"Param"];
            gExposureModeValue = tempParam;
            [displayExposureMode addItemsWithObjectValues:gExposureModeValue];
            [displayExposureMode removeItemAtIndex:[gExposureModeValue count]-1];
            
            getCurrentValue = [tempValue objectForKey:@"CurrentValue"];
            [displayExposureMode setStringValue:getCurrentValue];
        }
        
        if([tempString isEqualTo:[NSString stringWithFormat:@"%s",[checkCameraType callWhiteBalance]]]){
            tempParam = [tempValue objectForKey:@"Param"];
            gWhiteBalanceValue = tempParam;
            [displayWhiteBalanceDropDown addItemsWithObjectValues:gWhiteBalanceValue];
            [displayWhiteBalanceDropDown removeItemAtIndex:[gWhiteBalanceValue count]-1];
            getCurrentValue = [tempValue objectForKey:@"CurrentValue"];
            [displayWhiteBalanceDropDown setStringValue:getCurrentValue];
        }
        
        if([tempString isEqualTo:[NSString stringWithFormat:@"%s",[checkCameraType callQuality]]]){
            tempParam = [tempValue objectForKey:@"Param"];
            gImageQualityValue = tempParam;
            [displayImageQualityDropDown addItemsWithObjectValues:gImageQualityValue];
            [displayImageQualityDropDown removeItemAtIndex:[gImageQualityValue count]-1];
            getCurrentValue = [tempValue objectForKey:@"CurrentValue"];
            [displayImageQualityDropDown setStringValue:getCurrentValue];
        }
        
        if([tempString isEqualTo:[NSString stringWithFormat:@"%s",[checkCameraType callHDR]]]){
            tempParam = [tempValue objectForKey:@"Param"];
            gHDRModeValue = tempParam;
            [displayHDRMode addItemsWithObjectValues:gHDRModeValue];
            [displayHDRMode removeItemAtIndex:[gHDRModeValue count]-1];
            getCurrentValue = [tempValue objectForKey:@"CurrentValue"];
            [displayHDRMode setStringValue:getCurrentValue];
        }
        
        if([tempString isEqualTo:[NSString stringWithFormat:@"%s",[checkCameraType callProMode]]]){
            tempParam = [tempValue objectForKey:@"Param"];
            gProgramModeValue = tempParam;
            [displayProgramModeDropDown addItemsWithObjectValues:gProgramModeValue];
            [displayProgramModeDropDown removeItemAtIndex:[gProgramModeValue count]-1];
            getCurrentValue = [tempValue objectForKey:@"CurrentValue"];
            [displayProgramModeDropDown setStringValue:getCurrentValue];
        }
        
        if ([tempString isEqualTo:[NSString stringWithFormat:@"%s",[checkCameraType callISO]]]) {
            tempParam = [tempValue objectForKey:@"Param"];
            gISOValue = tempParam;
            [displayISODropDown addItemsWithObjectValues:gISOValue];
            [displayISODropDown removeItemAtIndex:[gISOValue count]-1];
            getCurrentValue = [tempValue objectForKey:@"CurrentValue"];
            [displayISODropDown setStringValue:getCurrentValue];
            [displayISO setStringValue:getCurrentValue];
        }

        if([tempString isEqualTo:[NSString stringWithFormat:@"%s",[checkCameraType callExposureComp]]]){
            tempParam = [tempValue objectForKey:@"Param"];
            gExposureValue = tempParam;
            [exposureSliderValue setNumberOfTickMarks:[gExposureValue count]];
            [exposureSliderValue setMinValue:0];
            [exposureSliderValue setMaxValue:[gExposureValue count]-2];
            [exposureSliderValue setAllowsTickMarkValuesOnly:YES];
            [exposureSliderValue setIntValue:(int)[gExposureValue count]/2];  
        }
        if([tempString isEqualTo:[NSString stringWithFormat:@"%s",[checkCameraType callShutterSpeed]]]){
            tempParam = [tempValue objectForKey:@"Param"];
            gShutterSpeedValue = tempParam;
            [shutterSpeedSliderValue setNumberOfTickMarks:[gShutterSpeedValue count]];
            [shutterSpeedSliderValue setMinValue:0];
            [shutterSpeedSliderValue setMaxValue:[gShutterSpeedValue count]-2];
            [shutterSpeedSliderValue setAllowsTickMarkValuesOnly:YES];
            [shutterSpeedSliderValue setIntValue:(int)[gShutterSpeedValue count]/2];
            
            getCurrentValue = [tempValue objectForKey:@"CurrentValue"];            
            [self modifyInitMessage:getCurrentValue :NULL];
        }
        if([tempString isEqualTo:[NSString stringWithFormat:@"%s",[checkCameraType callApertureMode]]]){
            tempParam = [tempValue objectForKey:@"Param"];
            gApertureValue= tempParam;
            [apertureSliderValue setNumberOfTickMarks:[gApertureValue count]];
            [apertureSliderValue setMinValue:0];
            [apertureSliderValue setMaxValue:[gApertureValue count]-2];
            [apertureSliderValue setAllowsTickMarkValuesOnly:YES];
            [apertureSliderValue setIntValue:(int)[gApertureValue count]/2];
            
            getCurrentValue = [tempValue objectForKey:@"CurrentValue"];
            [displayAperture setStringValue:[getCurrentValue capitalizedString]];
        }
        if([tempString isEqualTo:[NSString stringWithFormat:@"%s",[checkCameraType callModel]]]){
            getCurrentValue = [tempValue objectForKey:@"CurrentValue"];
            [cameraName setStringValue:getCurrentValue];
            [connection setStringValue:@"connected"];
        }
        if([tempString isEqualTo:[NSString stringWithFormat:@"%s",[checkCameraType callBattery]]]){
            getCurrentValue = [tempValue objectForKey:@"CurrentValue"];
            [self modifyInitMessage:NULL:getCurrentValue];
        }
    }
}

-(void) lookForResponse: (NSString *)logMessage
                       : (NSString *)code{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    if(getSystemLogMessage != NULL && code != NULL){
        log = [NSString stringWithFormat:@"%@ > code: %@\n%@\n---------------------------------\n%@\n",dateString, code, logMessage, log];
        if ([code isEqualToString:@"2"]) {
            logColor = [[NSMutableAttributedString alloc]initWithString:log];
            [logColor addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0,[logColor length])];
        }
        [systemLog setStringValue:log];
    }
    if( [code isEqualToString:@"16"]){
        [btCapture setEnabled:NO];
        
    }
    else if([code isEqualToString:@"32"]){
        [btCapture setEnabled:YES];
    }
}

-(void) liveViewImages: (NSData *) data{
     @autoreleasepool {
        NSImage *img = [[NSImage alloc] initWithData:data];
        [img setSize:(NSSize){385,260}]; // test later !!
        [jpLiveView2 setImage: img];
        newimage = img;
     }
}

//purpose for Mac 10.7 or earlier versions
-(void) preservedLiveViewImage {
    usleep(10000);
    NSImage *oldImg = newimage;
    [jpLiveView setImage:oldImg];
}


void setFullPathInfo(NSMutableArray *fullpathInfo, NSString *fullMessage, NSString *fullValue, NSData *fullLiveData, NSString *systemLogText,NSString *code, void *obj)
{
    static AppDelegate *app = NULL;
    
    if (obj != NULL)
        app = (__bridge AppDelegate *)obj;
    
    if (fullLiveData != NULL)
    {
        [app liveViewImages:fullLiveData];
        [app preservedLiveViewImage]; //for Mac 10.7 or earlier versions
        //app.fullLiveViewData = fullLiveData;
    }
    else if (fullLiveData == NULL){
        app.fulldetails = fullpathInfo;
        app.fullvalues = fullValue;
        app.fullmessages = fullMessage;
        app.fullLiveViewData = fullLiveData;
        [app initAllValueFromCamera];
        [app lookForResponse:systemLogText:code];
        //[app saveTrayValue:code];
    }
}

//set camera value from MORE.....
void setAllCameraValue(NSString *comCom, NSString *comName, NSString *comValue, void *obj){
    
    static AppDelegate *app = NULL;
    
    if (obj != NULL)
        app = (__bridge AppDelegate *)obj;
    
    if([comCom isNotEqualTo:nil] && [comName isNotEqualTo:nil] && [comValue isNotEqualTo:nil]){
        if([app.socket sockRef] != NULL){
            int sock = CFSocketGetNative([app.socket sockRef]);
            char *first_message = "64";
            const char *second_message = [comCom UTF8String];
            const char *other_message = [comName UTF8String];
            const char *value_message = [comValue UTF8String];
            char *final_message;
            asprintf(&final_message, "%s|%s|%s|%s|\n", first_message, second_message, other_message, value_message);
            write(sock, final_message, strlen(final_message));
            free(final_message);
        }
    }
}

- (IBAction)cameraValueChanged:(id)sender {
    setAllCameraValue(NULL, NULL, NULL, NULL);
}

-(void) modifyInitMessage:(NSString *)shutterMessage: (NSString *)batteryMessage{
      
    if([NSString stringWithFormat:@"%s",[checkCameraType callShutterSpeed]]){
        double num = [shutterMessage doubleValue];
        double n_num = ceil(1/num);
        double p_num = ceil(num);
        
        if(num < 1){
            NSString *output_int = [[NSString alloc]initWithFormat:@"1/%.0fsec",n_num];
            [displayShutterSpeed setStringValue:[output_int stringByReplacingOccurrencesOfString:@"sec" withString:@""]];
        }
        else if ( num >= 1 && num <=30){
            NSString *output_int2 = [[NSString alloc]initWithFormat:@"%.0fsec",p_num];
            [displayShutterSpeed setStringValue:[output_int2 stringByReplacingOccurrencesOfString:@"sec" withString:@""]];
        }
        if ( num > 30){
            [displayShutterSpeed setStringValue:@"Bulb"];
        }
    }    
    if([NSString stringWithFormat:@"%s",[checkCameraType callBattery]]){
        [batteryLevel setMinValue:0];
        [batteryLevel setMaxValue:5];
        [batteryLevel setWarningValue:1];
        if ([batteryMessage isEqualToString:@"20%"]) {
            [batteryLevel setDoubleValue:1];
        }
        if ([batteryMessage isEqualToString:@"40%"]) {
            [batteryLevel setDoubleValue:2];
        }
        if ([batteryMessage isEqualToString:@"60%"]) {
            [batteryLevel setDoubleValue:3];
        }
        if ([batteryMessage isEqualToString:@"80%"]) {
            [batteryLevel setDoubleValue:4];
        }
        if ([batteryMessage isEqualToString:@"100%"]) {
            [batteryLevel setDoubleValue:5];
        }
    }
}

- (IBAction)liveViewSwitch:(id)sender {
    if([socket sockRef]){
        [self trigerCameraFunction:"64" :[checkCameraType callLiveView] : "liveview Inaction" : NULL];
    }
    
    if (bnLiveView.isHidden == NO)
    {
        [bnLiveView setHidden:YES];
    }
    else if(bnLiveView.isHidden == YES)
    {
        [bnLiveView setHidden:NO];
        [jpLiveView2 setImage:nil];
    }
}

// -------------------  Threads to connect with sockets  ------------------- //

-(void) startNewThread{
   // [NSThread detachNewThreadSelector:@selector(initAllValue) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(startTheBackgroundJob) toTarget:self withObject:nil];
}

- (void)initAllValue{
    NSString *urlString = [NSString stringWithFormat: @"/tmp/camera_control.sock"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *typeStream = [NSString stringWithFormat:@"comm"];
    socket = [CommSocketClient initAndStartClient:url:typeStream];
    
    if([socket sockRef] != NULL){
        getSystemLogMessage = @"connect sock completed";
        [systemLog setStringValue:getSystemLogMessage];
        [status setStringValue:@"connect sock completed"];
        [self startNewThread];
    }
    if([socket sockRef] == NULL){
        getSystemLogMessage = @"Can not connect sock!";
        [systemLog setStringValue:getSystemLogMessage];
        [status setStringValue:@"can not connect sock"];
        [connection setStringValue:@"disconnect"];
    }
   // CFRunLoopRun();
}

-(void) startTheBackgroundJob {
    NSString *urlString = [NSString stringWithFormat: @"/tmp/camera_control_data.sock"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *typeStream = [NSString stringWithFormat:@"data"];
    socket_data = [CommSocketClient initAndStartClient:url:typeStream];
    CFRunLoopRun();
}


// -------------------  Focus Area Selection  ------------------- //

-(void)focusAreaSelection: (NSString *) selectedFocus{
    if([socket sockRef]){
        [self trigerCameraFunction:"64" :[checkCameraType callFocusArea]: "Auto Focus Area" :[selectedFocus UTF8String]];
        [self trigerCameraFunction:"64" :[checkCameraType callFocus] : "Focusing" :NULL];
    }
}
-(void)setFocusImageToNil: (NSImage *) focusImages{
    [btFocusCentre setImage:focusImages];
    [btFocusCentreRight setImage:focusImages];
    [btFocusCentreLeft setImage:focusImages];
    [btFocusTop setImage:focusImages];
    [btFocusTopRight setImage:focusImages];
    [btFocusTopLeft setImage:focusImages];
    [btFocusBottom setImage:focusImages];
    [btFocusBottomLeft setImage:focusImages];
    [btFocusBottomRight setImage:focusImages];
}

-(void)focusPointImageTrigger: (NSButton *)imageButton: (NSString *)imageAreaSelected{
    [self setFocusImageToNil:nil];
    NSImage *grid_img = [NSImage imageNamed:@"grid_cross_org.png"];
    [imageButton setImage:grid_img];
    [self focusAreaSelection:imageAreaSelected];
}

- (IBAction)focusCentre:(id)sender {
    [self focusPointImageTrigger: btFocusCentre :@"Centre"];
}

- (IBAction)focusCentreRight:(id)sender {
    [self focusPointImageTrigger: btFocusCentreRight :@"Right"];
}

- (IBAction)focusCentreLeft:(id)sender {
    [self focusPointImageTrigger: btFocusCentreLeft :@"Left"];
}

- (IBAction)focusTop:(id)sender {
    [self focusPointImageTrigger: btFocusTop :@"Top"];
}

- (IBAction)focusBottom:(id)sender {
    [self focusPointImageTrigger: btFocusBottom :@"Bottom"];
}

- (IBAction)focusTopRight:(id)sender {
    [self focusPointImageTrigger: btFocusTopRight :@"Top-Right"];
}

- (IBAction)focusTopLeft:(id)sender {
    [self focusPointImageTrigger: btFocusTopLeft :@"Top-Left"];
}

- (IBAction)focusBottomRight:(id)sender {
    [self focusPointImageTrigger: btFocusBottomRight :@"Bootom-Right"];
}

- (IBAction)focusBottomLeft:(id)sender {
    [self focusPointImageTrigger: btFocusBottomLeft :@"Bottom-Left"];
}


- (IBAction)saveTrayValue:(NSString *)code{
    int v_number, h_number, f_number;
    int final_number = 1;
    
    v_number = [[vertical_number stringValue] intValue];
    h_number = [[horizontal_number stringValue] intValue];
    f_number = v_number * h_number;
    save_tray = [NSString stringWithFormat:@"%d", f_number];
    if([code isEqualToString:@"16"]){
        if (final_number > v_number) {
            final_number = 1;
        }
        [rotating_number setIntValue:final_number];
        final_number ++;
    }
}

-(void)getUSBlistener{
    USBDetection *detected = [[USBDetection alloc]init];
    [detected initUsbNotification];
    [[detected returnValue]intValue];    
}

@end