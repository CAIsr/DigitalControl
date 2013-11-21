
//
//  CommController.m
//  Digital Control
//
//  Created by Adam Lin on 12/04/13.
//  Copyright (c) 2013 Adam Lin. All rights reserved.
//

#import "CommController.h"
#import "CommSocketClient.h"

@implementation CommController
@synthesize messageArray, protocolArray,initFullArray, initCallBackDic, messageStatus;
@synthesize code,command,message, value;
@synthesize reloadImages;

-(void) checkMessage{
    //NSString *invalue = @"NULL";
    int		i = 0;
    
    if(code == [NSString stringWithFormat:@"%d", OK])
    {  
       getSystemLogMessage = @"initialization completed.";
    }
    else if(code == [NSString stringWithFormat:@"%d", KO]){
        //getSystemLogMessage = @"KO! unable to trigger functions!";
        getSystemLogMessage = command;
    }
    else if(code == [NSString stringWithFormat:@"%d", WRONG_COMMAND]){
        getSystemLogMessage = @"wrong command! check parameters!";
    }
    else if(code == [NSString stringWithFormat:@"%d", BAD_PARAMETERS])
    {
        //getSystemLogMessage = @"BAD PARAMETERS. check parameters!";
        getSystemLogMessage = command;
       /* while ([protocolArray objectAtIndex:i] != NULL)
        {
            NSLog(@"%@ | ", [protocolArray objectAtIndex:i]);
            i++;
        }
        NSLog(@"\n");*/
    }
    else if(code == [NSString stringWithFormat:@"%d", WAIT_RESPONSE])
    {
        getSystemLogMessage = command;
    }
    else if(code == [NSString stringWithFormat:@"%d", COMPLETE])
    {
        getSystemLogMessage = command;
        if ([command isEqualToString: @"capture done"]){
            [initImageBrowser reloadImageBrowser];
        }
    }
    else if([code intValue] == VALUE)
    {
        if(value){
            getValueFromCamera = value;
            getSystemLogMessage = value;
        }
    }
    else if([code intValue] == EXEC)
    {
        i = 0;
        getSystemLogMessage = command;
        while ([protocolArray objectAtIndex:i] != NULL)
        {
           // NSLog(@"%@ | ", [protocolArray objectAtIndex:i]);
            i++;
        }
        getSystemLogMessage = message;
    }

    if (code == 0){
        getSystemLogMessage = @"UNKNOWN COMMAND";
    }
    getSystemCode = code;
}

- (void) parsingMessage: (NSString *)camera_Message{
    NSString *getMessage = camera_Message;
    messageArray = [[getMessage componentsSeparatedByString:@"|"] mutableCopy];
    if(messageArray == NULL)
        return;
    [self arrangeMessage];
}
- (void) parsingMessageData: (NSString *)camera_Message{
    NSString *getMessage = camera_Message;
    NSLog(@"%@",getMessage);
}

- (void) arrangeMessage{
    NSMutableArray *tmpMessageArray = messageArray;
    
    if(tmpMessageArray == NULL || [tmpMessageArray count] <=2) //response message should > 2 objects
        return;
    if([tmpMessageArray objectAtIndex:0])
    {
        code = [tmpMessageArray objectAtIndex:0];
        [tmpMessageArray removeObjectAtIndex:0];
    }
    if([tmpMessageArray objectAtIndex:0])
    {
        command = [messageArray objectAtIndex:0];
        [tmpMessageArray removeObjectAtIndex:0];
    }
    if([tmpMessageArray objectAtIndex:0])
    {
        message = [tmpMessageArray objectAtIndex:0];
        [tmpMessageArray removeObjectAtIndex:0];
    }
    if([code intValue] == VALUE) {
        if([tmpMessageArray count]){
            if([tmpMessageArray objectAtIndex:0])
            {
                value = [tmpMessageArray objectAtIndex:0];
                [tmpMessageArray removeObjectAtIndex:0];
                getMessageFromCamera = message;
            }
        }
    }
    protocolArray = tmpMessageArray;
}

-(void) initFirstLoadMessage: (NSString *)full_call_back_message
                            : (int)checkpoint {
    
    messageArray = [[full_call_back_message componentsSeparatedByString:@"\n"] mutableCopy];

    if(checkpoint){
        initFullArray = [[NSMutableArray alloc]initWithCapacity:[messageArray count]];
        
        NSString *tempString;
        NSUInteger i;
        NSString  *t_command, *t_name, *t_type, *t_currentValue, *t_read;
        NSMutableArray *t_param;

        for( tempString in messageArray)
        {
            i = [messageArray indexOfObject:tempString];
            if(i >= [messageArray count]-1){
                break;
            }
            NSMutableArray *tempArrayRoot;
            tempArrayRoot = [[[messageArray objectAtIndex:i] componentsSeparatedByString:@"=>"] mutableCopy];
            t_command = [tempArrayRoot objectAtIndex:0];
            
            [tempArrayRoot removeObjectAtIndex:0];
            tempArrayRoot = [[[tempArrayRoot objectAtIndex:0] componentsSeparatedByString:@"#"] mutableCopy];
            
            if([[tempArrayRoot objectAtIndex:1] isNotEqualTo:@""]){
                t_name = [tempArrayRoot objectAtIndex:0];
                t_read = [tempArrayRoot objectAtIndex:1];
                t_type = [tempArrayRoot objectAtIndex:2];
                t_currentValue = [tempArrayRoot objectAtIndex:3];
            
                tempArrayRoot = [[[tempArrayRoot objectAtIndex:4] componentsSeparatedByString:@"|"] mutableCopy];
                t_param = [tempArrayRoot mutableCopy];
            }
            else{
                [tempArrayRoot removeObjectAtIndex:0]; // double check with other cameras
                t_name = @"";
                t_read = @"0";
                t_type = @"";
                t_currentValue = @"";
                t_param = [tempArrayRoot mutableCopy];
            }
            // Apply to dictionay //
            initCallBackDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:t_command, t_name, t_read, t_currentValue, t_type, t_param ,nil] forKeys:[NSArray arrayWithObjects:@"Command", @"Name", @"Read", @"CurrentValue", @"Type", @"Param", nil]];
            
          [initFullArray addObject:initCallBackDic];
        }
        finalCallBackFirstMessage = initFullArray;
    }
}
@end
