//
//  USBDetection.h
//  Digital Control
//
//  Created by Adam Lin on 11/06/13.
//  Copyright (c) 2013 Adam Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface USBDetection : NSObject{
        NSString *returnValue;
        NSString *cameraName;
        NSString *cameraConnection;
}
@property (nonatomic, retain) NSString *returnValue;
@property (nonatomic, retain) NSString *cameraName;;
@property (nonatomic, retain) NSString *cameraConnection;
-(void) initUsbNotification;
-(NSArray *) deviceAttributes;
-(void)detectedVendorAndProductID;
@end