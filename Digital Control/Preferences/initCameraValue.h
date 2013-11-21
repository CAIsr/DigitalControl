//
//  initCameraValue.h
//  Digital Control
//
//  Created by Adam Lin on 26/05/13.
//  Copyright (c) 2013 Adam Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "CommSocketClient.h"
#import "CommController.h"

void setAllCameraValue(NSString *comCom, NSString *comName, NSString *comValue, void *obj);

@interface initCameraValue : NSObject <NSTableViewDataSource>{
    IBOutlet NSTableView    *cameraTableView;
             NSMutableArray *list;
             NSString       *selectedCommValueInit;
             NSString       *selectedCameraValueInit;
             NSString       *selectedCameraValueName;
             NSString       *selectedCameraValueRead;
             NSString       *log;
}
@property (nonatomic, retain) IBOutlet NSWindow *initCameraWindow;
@property (nonatomic, retain) IBOutlet NSTableView *cameraTableView;
@property (nonatomic, retain) IBOutlet NSComboBoxCell *cameraAllValue;


@property (nonatomic, retain) IBOutlet NSImageCell *readOrWrite;
@property (nonatomic, retain) IBOutlet NSTextFieldCell *txtComm;
@property (nonatomic, retain) IBOutlet NSTextFieldCell *currentValue;
@property (nonatomic, retain) IBOutlet NSTextField *valueLog;


@property (nonatomic, retain) NSString *selectedCommValueInit;
@property (nonatomic, retain) NSString *selectedCameraValueInit;
@property (nonatomic, retain) NSString *selectedCameraValueName;
@property (nonatomic, retain) NSString *selectedCameraValueRead;

- (IBAction)btRefresh:(id)sender;
- (IBAction)closeWindowOK:(id)sender;
- (void) refreshValue;

@end
