//
//  initCameraValue.m
//  Digital Control
//
//  Created by Adam Lin on 26/05/13.
//  Copyright (c) 2013 Adam Lin. All rights reserved.
//

#import "initCameraValue.h"

@implementation initCameraValue
@synthesize cameraTableView, cameraAllValue, selectedCameraValueInit, selectedCommValueInit, selectedCameraValueName, selectedCameraValueRead;
@synthesize initCameraWindow, txtComm,readOrWrite;
@synthesize valueLog;

static NSMutableArray *backFirstMessageLoad;


- (void) refreshValue{
    [self reconstructValues];
    list = backFirstMessageLoad;
    [cameraTableView reloadData];
}

- (IBAction)btRefresh:(id)sender {
    [self refreshValue];
    //[self tempArrayToLoadFiles];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [list count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
   
    NSDictionary *tempValue;
    [cameraAllValue removeAllItems];
    [readOrWrite setImage:NULL];
    
    NSString *identifier = [tableColumn identifier];
    tempValue = [list objectAtIndex:row];
    
    NSString *thecommand = [tempValue objectForKey:@"Command"];
    NSString *readonly = [tempValue objectForKey:@"Read"];
    //NSString *thevalue = [tempValue objectForKey:@"CurrentValue"];
    NSString *thename = [tempValue objectForKey:@"Name"];
    NSArray  *paramvalue = [tempValue objectForKey:@"Param"];
      
    if([identifier isEqualToString:@"comm"]){
        return thecommand;
    }
    if([identifier isEqualToString:@"name"]){
        return thename;
    }
    if([identifier isEqualToString:@"read"]){
        if([readonly isEqualToString:@"0"]){
            NSImage *readWriteImage = [NSImage imageNamed:@"write"];
            [readWriteImage setName:@"0"];
            return readWriteImage;
        }
        if ([readonly isEqualToString:@"1"]){
            NSImage *readWriteImage = [NSImage imageNamed:@"read"];
            [readWriteImage setName:@"1"];
            return readWriteImage;
        }
    }
    if([identifier isEqualToString:@"value"]){
        NSString *selected = @" --- SELECT ---";
            [cameraAllValue addItemsWithObjectValues:paramvalue];
            [cameraAllValue removeItemAtIndex:[paramvalue count]-1];

            if([readonly isEqualToString:@"0"]){
                [cameraAllValue setBackgroundColor:[NSColor redColor]];
                return selected;
            }
            if ([readonly isEqualToString:@"1"]){
                [cameraAllValue setBackgroundColor:[NSColor grayColor]];
                return selected;
            }
    }
    if([identifier isEqualToString:@"readable"]){
        return readonly;
    }
    
    return NULL;
}
-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{    
    NSTableColumn *column = [cameraTableView tableColumnWithIdentifier:@"comm"];
    selectedCommValueInit = [[column dataCellForRow:row] stringValue];

    NSTableColumn *column2 = [cameraTableView tableColumnWithIdentifier:@"name"];
    selectedCameraValueName = [[column2 dataCellForRow:row] stringValue];
    
    NSTableColumn *column3 = [cameraTableView tableColumnWithIdentifier:@"readable"];
    selectedCameraValueRead = [[column3 dataCellForRow:row] stringValue];
    
    selectedCameraValueInit = object;

    if(object != NULL){
        setAllCameraValue(selectedCommValueInit, selectedCameraValueName, selectedCameraValueInit, nil);
        [self selectedValueChanged:selectedCameraValueName:selectedCameraValueInit];
    }
}

- (IBAction)closeWindowOK:(id)sender {
    [initCameraWindow close];
}

-(void)selectedValueChanged: (NSString *)vName:(NSString *)vValue{
    if([selectedCameraValueRead isEqualToString:@"0"]){
        if(log != NULL){
            log = [NSString stringWithFormat:@"%@",log];
            log = [NSString stringWithFormat:@"%@ has been set to %@\n%@\n", vName, vValue, log];
        }else{
            log = [NSString stringWithFormat:@"%@ has been set to %@\n",vName, vValue];
        }
    }else{
        if(log != NULL){
            log = [NSString stringWithFormat:@"%@\n",log];
            log = [NSString stringWithFormat:@"READ ONLY: %@ can't be changed\n%@\n", vName, log];
        }else
        log = [NSString stringWithFormat:@"READ ONLY: %@ can't be changed\n", vName];
    }
    [valueLog setStringValue:log];
}

-(void)reconstructValues{
    //[self tempArrayToLoadFiles];    // load init message from text file
    backFirstMessageLoad = finalCallBackFirstMessage;
    
    NSMutableArray *tempBackFirstMessageLoad = [[NSMutableArray alloc] init];;
    for (int i = 0 ;i < [backFirstMessageLoad count]; i++) {
        if ([[[backFirstMessageLoad objectAtIndex:(long)i] objectForKey:@"Param"]count] > 1) {
            [tempBackFirstMessageLoad addObject:[backFirstMessageLoad objectAtIndex:i]];
        }
    }
    backFirstMessageLoad = tempBackFirstMessageLoad;
}

-(void)tempArrayToLoadFiles{
    
    /* solution to read dump file from txt */
    NSString* path = [[NSBundle mainBundle] pathForResource:@"dump_param_new" ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path
    encoding:NSUTF8StringEncoding
    error:NULL];
    
    NSDictionary *initCallBackDic;
    NSMutableArray *messageArray = [[content componentsSeparatedByString:@"\n"] mutableCopy];
    NSMutableArray *initFullArray = [[NSMutableArray alloc]initWithCapacity:[messageArray count]];
    
    NSString *tempString;
    NSUInteger i = 2;
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
            t_read = 0;
            t_type = @"";
            t_param = [tempArrayRoot mutableCopy];
        }
        // Apply to dictionay //
        initCallBackDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:t_command, t_name, t_read, t_currentValue, t_type, t_param ,nil] forKeys:[NSArray arrayWithObjects:@"Command", @"Name", @"Read", @"CurrentValue", @"Type", @"Param", nil]];
        
        [initFullArray addObject:initCallBackDic];
    }
    backFirstMessageLoad = initFullArray;
    NSLog(@"%@", backFirstMessageLoad);
}
@end
    