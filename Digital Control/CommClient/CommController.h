//
//  CommController.h
//  Digital Control
//
//  Created by Adam Lin on 12/04/13.
//  Copyright (c) 2013 Adam Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageController.h"

NSMutableArray *finalCallBackFirstMessage;
NSString *getValueFromCamera;
NSString *getMessageFromCamera;
NSString *getSystemLogMessage;
NSString *getSystemCode;

@interface CommController : NSObject{
    NSMutableArray     *messageArray;
    NSMutableArray     *protocolArray;
    NSMutableArray     *initFullArray;
    NSDictionary       *initCallBackDic;
    ImageController    *reloadImages;

    NSString    *code;
    NSString    *command;
    NSString    *message;
    NSString    *value;
}
@property(nonatomic, retain) NSMutableArray *messageArray;
@property(nonatomic, retain) NSMutableArray *protocolArray;
@property(retain) NSMutableArray *initFullArray;
@property(nonatomic, retain) NSDictionary *initCallBackDic;
@property(nonatomic, retain) NSString    *code;
@property(nonatomic, retain) NSString    *command;
@property(nonatomic, retain) NSString    *message;
@property(nonatomic, retain) NSString    *value;

@property(nonatomic, retain) ImageController *reloadImages;

-(void) parsingMessage: (NSString *)camera_Message;
-(void) parsingMessageData: (NSString *)camera_Message;
-(void) arrangeMessage;
-(void) checkMessage;
-(void) initFirstLoadMessage: (NSString *)full_call_back_message
                            : (int)checkpoint;


typedef enum _codeMessage{
        OK              = 1,
        KO              = 2,
        WRONG_COMMAND	= 4,
        BAD_PARAMETERS	= 8,
        WAIT_RESPONSE	= 16,
        COMPLETE        = 32,
        EXEC            = 64,
        INFO            = 128,
        VALUE           = 256
} codeMessage;

@property (readonly, nonatomic) codeMessage messageStatus;

@end
