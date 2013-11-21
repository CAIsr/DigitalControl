//
//  USBDetection.m
//  Digital Control
//
//  Created by Adam Lin on 11/06/13.
//  Copyright (c) 2013 Adam Lin. All rights reserved.
//

#import "USBDetection.h"

#import <CoreFoundation/CoreFoundation.h>
#import <IOKit/usb/IOUSBLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/IOMessage.h>
@implementation USBDetection


typedef struct MyPrivateData {
    io_object_t				notification;
    IOUSBDeviceInterface	**deviceInterface;
    CFStringRef				deviceName;
    UInt32					locationID;
} MyPrivateData;

static IONotificationPortRef	gNotifyPort;
static io_iterator_t			gAddedIter;
static CFRunLoopRef				gRunLoop;

@synthesize returnValue, cameraConnection, cameraName;
long gVanderID, gProductID;

-(void) initUsbNotification {
    [self detectedVendorAndProductID];
    CFMutableDictionaryRef 	matchingDict;
    CFRunLoopSourceRef		runLoopSource;
    CFNumberRef				numberRef;
    kern_return_t			kr;
    long					usbVendor = gVanderID; //0x04b0
    long					usbProduct = gProductID; //0x042e
    sig_t					oldHandler;
    
    NSLog(@"%li : %li", usbProduct, usbVendor);
    
    // Set up a signal handler so we can clean up when we're interrupted from the command line
    // Otherwise we stay in our run loop forever.
    oldHandler = signal(SIGINT, SignalHandler);
    if (oldHandler == SIG_ERR) {
        fprintf(stderr, "Could not establish new signal handler.");
	}
    
    matchingDict = IOServiceMatching(kIOUSBDeviceClassName);	// Interested in instances of class
    // IOUSBDevice and its subclasses
    if (matchingDict == NULL) {
        fprintf(stderr, "IOServiceMatching returned NULL.\n");
        return;
    }
    
    
    // Create a CFNumber for the idVendor and set the value in the dictionary
    numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbVendor);
    CFDictionarySetValue(matchingDict,
                         CFSTR(kUSBVendorID),
                         numberRef);
    CFRelease(numberRef);
    
    // Create a CFNumber for the idProduct and set the value in the dictionary
    numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbProduct);
    CFDictionarySetValue(matchingDict,
                         CFSTR(kUSBProductID),
                         numberRef);
    CFRelease(numberRef);
    numberRef = NULL;
    
    // Create a notification port and add its run loop event source to our run loop
    // This is how async notifications get set up.
    
    gNotifyPort = IONotificationPortCreate(kIOMasterPortDefault);
    runLoopSource = IONotificationPortGetRunLoopSource(gNotifyPort);
    
    gRunLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(gRunLoop, runLoopSource, kCFRunLoopDefaultMode);
    
    // Now set up a notification to be called when a device is first matched by I/O Kit.
    kr = IOServiceAddMatchingNotification(gNotifyPort,					// notifyPort
                                          kIOFirstMatchNotification,	// notificationType
                                          matchingDict,					// matching
                                          DeviceAdded,					// callback
                                          NULL,
                                          &gAddedIter					// notification
                                          );
    
    // Iterate once to get already-present devices and arm the notification
    DeviceAdded((__bridge void *)(self), gAddedIter);
    // Start the run loop. Now we'll receive notifications.
    //CFRunLoopRun();
    return;
}

void DeviceNotification(void *refCon, io_service_t service, natural_t messageType, void *messageArgument)
{
    kern_return_t	kr;
    MyPrivateData	*privateDataRef = (MyPrivateData *) refCon;
    
    if (messageType == kIOMessageServiceIsTerminated) {
        fprintf(stderr, "Device removed.\n");
        
        // Dump our private data to stderr just to see what it looks like.
        fprintf(stderr, "privateDataRef->deviceName: ");
		CFShow(privateDataRef->deviceName);
		fprintf(stderr, "privateDataRef->locationID: 0x%x.\n", privateDataRef->locationID);
        
        // Free the data we're no longer using now that the device is going away
        CFRelease(privateDataRef->deviceName);
        
        if (privateDataRef->deviceInterface) {
            kr = (*privateDataRef->deviceInterface)->Release(privateDataRef->deviceInterface);
        }
        
        kr = IOObjectRelease(privateDataRef->notification);
        
        free(privateDataRef);
    }
}

void DeviceAdded(void *refCon, io_iterator_t iterator)
{
    kern_return_t		kr;
    io_service_t		usbDevice = 0;
    IOCFPlugInInterface	**plugInInterface = NULL;
    SInt32				score;
    HRESULT 			res;
    static USBDetection *retVal;
    
    if (refCon != NULL){
        retVal = (__bridge USBDetection *)refCon;
    }
    
    while ((usbDevice = IOIteratorNext(iterator))) {
        retVal->returnValue = [[NSString alloc]initWithFormat:@"%i",usbDevice];
        io_name_t		deviceName;
        CFStringRef		deviceNameAsCFString;
        MyPrivateData	*privateDataRef = NULL;
        UInt32			locationID;
        
        printf("Device added.\n");
        
        // Add some app-specific information about this device.
        // Create a buffer to hold the data.
        privateDataRef = malloc(sizeof(MyPrivateData));
        bzero(privateDataRef, sizeof(MyPrivateData));
        
        // Get the USB device's name.
        kr = IORegistryEntryGetName(usbDevice, deviceName);
		if (KERN_SUCCESS != kr) {
            deviceName[0] = '\0';
        }
        
        deviceNameAsCFString = CFStringCreateWithCString(kCFAllocatorDefault, deviceName,
                                                         kCFStringEncodingASCII);
        
        // Dump our data to stderr just to see what it looks like.
        fprintf(stderr, "deviceName: ");
        CFShow(deviceNameAsCFString);
        refCon = (void *)deviceNameAsCFString;
        
        // Save the device's name to our private data.
        privateDataRef->deviceName = deviceNameAsCFString;
        
        kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID,
                                               &plugInInterface, &score);
        
        if ((kIOReturnSuccess != kr) || !plugInInterface) {
            fprintf(stderr, "IOCreatePlugInInterfaceForService returned 0x%08x.\n", kr);
            continue;
        }
        
        // Use the plugin interface to retrieve the device interface.
        res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
                                                 (LPVOID*) &privateDataRef->deviceInterface);
        
        // Now done with the plugin interface.
        (*plugInInterface)->Release(plugInInterface);
        
        if (res || privateDataRef->deviceInterface == NULL) {
            fprintf(stderr, "QueryInterface returned %d.\n", (int) res);
            continue;
        }
        
        kr = (*privateDataRef->deviceInterface)->GetLocationID(privateDataRef->deviceInterface, &locationID);
        if (KERN_SUCCESS != kr) {
            fprintf(stderr, "GetLocationID returned 0x%08x.\n", kr);
            continue;
        }
        else {
            fprintf(stderr, "Location ID: 0x%x\n\n", locationID);
        }
        
        privateDataRef->locationID = locationID;
        
        // Register for an interest notification of this device being removed. Use a reference to our
        // private data as the refCon which will be passed to the notification callback.
        kr = IOServiceAddInterestNotification(gNotifyPort,						// notifyPort
											  usbDevice,						// service
											  kIOGeneralInterest,				// interestType
											  DeviceNotification,				// callback
											  privateDataRef,					// refCon
											  &(privateDataRef->notification)	// notification
											  );
        
        if (KERN_SUCCESS != kr) {
            printf("IOServiceAddInterestNotification returned 0x%08x.\n", kr);
        }
        
        // Done with this USB device; release the reference added by IOIteratorNext
        kr = IOObjectRelease(usbDevice);
    }
}
void SignalHandler(int sigraised)
{
    fprintf(stderr, "\nInterrupted.\n");
    exit(0);
}

-(NSArray *) deviceAttributes
{
    mach_port_t masterPort;
    CFMutableDictionaryRef matchingDict;
    NSMutableArray * devicesAttributes = [NSMutableArray array];
    kern_return_t kr;
    
    //Create a master port for communication with the I/O Kit
    kr = IOMasterPort (MACH_PORT_NULL, &masterPort);
    if (kr || !masterPort)
    {
        NSLog (@"Error: Couldn't create a master I/O Kit port(%08x)", kr);
        return devicesAttributes;
    }

    //Set up matching dictionary for class IOUSBDevice and its subclasses
    matchingDict = IOServiceMatching (kIOUSBDeviceClassName);
    if (!matchingDict)
    {
        NSLog (@"Error: Couldn't create a USB matching dictionary");
        mach_port_deallocate(mach_task_self(), masterPort);
        return devicesAttributes;
    }
    io_iterator_t iterator;
    IOServiceGetMatchingServices (kIOMasterPortDefault, matchingDict, &iterator);
    io_service_t usbDevice;
    
    //Iterate for USB devices
    
    while ((usbDevice = IOIteratorNext (iterator)))
    {
        IOCFPlugInInterface**plugInInterface = NULL;
        SInt32 theScore;
        //Create an intermediate plug-in
        
        kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &theScore);
        if ((kIOReturnSuccess != kr) || !plugInInterface)
            printf("Unable to create a plug-in (%08x)\n", kr);
        
        IOUSBDeviceInterface182 **dev = NULL;

        //Create the device interface
        
        HRESULT result = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID)&dev);
        
        if (result || !dev)
            printf("Couldn't create a device interface (%08x)\n", (int) result);
        
        UInt16 vendorId;
        UInt16 productId;
        UInt16 releaseId;

        //Get configuration Ids of the device
        
        (*dev)->GetDeviceVendor(dev, &vendorId);
        (*dev)->GetDeviceProduct(dev, &productId);
        (*dev)->GetDeviceReleaseNumber(dev, &releaseId);

        UInt8 stringIndex;
        (*dev)->USBGetProductStringIndex(dev, &stringIndex);
        IOUSBConfigurationDescriptorPtr descriptor;
        (*dev)->GetConfigurationDescriptorPtr(dev, stringIndex, &descriptor);

        //Get Device name
        
        io_name_t deviceName;
        kr = IORegistryEntryGetName (usbDevice, deviceName);
        if (kr != KERN_SUCCESS)
        {  
            NSLog (@"fail 0x%8x", kr);
            deviceName[0] = '\0';
        }
        NSString * name = [NSString stringWithCString:deviceName encoding:NSASCIIStringEncoding];

        //data will be initialized only for USB storage devices.
        
        //bsdName can be converted to mounted path of the device and vice-versa using DiskArbitration framework, hence we can identify the device through it's mounted path
        
        CFTypeRef data = IORegistryEntrySearchCFProperty(usbDevice, kIOServicePlane, CFSTR("BSD Name"), kCFAllocatorDefault, kIORegistryIterateRecursively);
        
        NSString *bsdName = [(__bridge NSString*)data substringToIndex:5];

        NSString* attributeString = @"";
        
        if(bsdName)
            attributeString = [NSString stringWithFormat:@"%@=>0x0%x|0x0%x", name, vendorId, productId];
        else
            attributeString = [NSString stringWithFormat:@"%@=>0x0%x|0x0%x", name, vendorId, productId];

        [devicesAttributes addObject:attributeString];

        IOObjectRelease(usbDevice);
        (*plugInInterface)->Release(plugInInterface);
        (*dev)->Release(dev);
    }
    
    //Finished with master port
    
    mach_port_deallocate(mach_task_self(), masterPort);
    masterPort = 0;

    return devicesAttributes;
}
-(void)detectedVendorAndProductID{    
    NSArray *cameraID = [self deviceAttributes];
    
    NSString  *t_name, *t_vander, *t_product;
    NSString *tempString;
    NSUInteger i;
    
    for( tempString in cameraID)
    {
        i = [cameraID indexOfObject:tempString];
        
        NSMutableArray *tempArrayRoot;
        tempArrayRoot = [[[cameraID objectAtIndex:i] componentsSeparatedByString:@"=>"] mutableCopy];
        if([[tempArrayRoot objectAtIndex:0] isEqualToString:@"NIKON DSC D800E"]){
            t_name = [tempArrayRoot objectAtIndex:0];
            
            [tempArrayRoot removeObjectAtIndex:0];
            tempArrayRoot = [[[tempArrayRoot objectAtIndex:0] componentsSeparatedByString:@"|"] mutableCopy];
            
            if([[tempArrayRoot objectAtIndex:1] isNotEqualTo:@""]){
                t_vander = [tempArrayRoot objectAtIndex:0];
                t_product = [tempArrayRoot objectAtIndex:1];
            }
        }
    }
    
    gVanderID = [t_vander longLongValue];
    gProductID = [t_product longLongValue];
}

-(void)checkCameraName: (NSString *)detectedName{
    NSArray *words = [detectedName componentsSeparatedByString:@" "];
    NSMutableArray *mutableWords = [NSMutableArray new];
    for (NSString *word in words){
        if ([word length] > 0 && [word characterAtIndex:0] == 'NIKON'){
            NSString * editedWord = [word substringFromIndex:1];
            [mutableWords addObject:editedWord];
        }
    }
}

@end