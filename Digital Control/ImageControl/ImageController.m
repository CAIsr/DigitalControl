//
//  ImageController.m
//  Digital Control
//
//  Created by Adam Lin on 22/04/13.
//  Copyright (c) 2013 Adam Lin. All rights reserved.
//

#import "ImageController.h"
#import "ControllerBrowsing.h"
#import "ControllerViewing.h"
#import "ControllerEditing.h"

@implementation ImageController

#pragma mark -
#pragma mark awakeFromNib

- (void) awakeFromNib
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *PathStoredValue = [prefs stringForKey:@"ImageSavePath"];
    if([PathStoredValue isNotEqualTo: @"/tmp/"]){
        imagefilePath = PathStoredValue;
        [displayPath setURL:(NSURL *)PathStoredValue];
    }
    else{
        imagefilePath = @"/tmp/";
    }
    [self setupBrowsing];
    [self setupViewing];
    [self setupEditing];
    
    [imageBrowser setAllowsEmptySelection: NO];
    [imageBrowser setSelectionIndexes: [NSIndexSet indexSetWithIndex: 0] byExtendingSelection:NO];
    initImageBrowser = self;
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

- (IBAction)openPath:(id)sender {
    int i;
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanCreateDirectories:YES];

    if([openDlg runModal])
    {
        NSArray *files = [openDlg filenames];
        for( i = 0; i < [files count]; i++ )
        {
            NSString *fileName = [files objectAtIndex:i];
            [displayPath setURL:(NSURL *)fileName];
            imagefilePath = fileName;
        }
    }
    [self setupBrowsing];
}

- (void) reloadImageBrowser{
    [self setupBrowsing];
}

- (IBAction)switchToolMode:(id)sender {
    
    NSInteger newTool;
    
    if ([sender isKindOfClass: [NSSegmentedControl class]])
        newTool = [sender selectedSegment];
    else
        newTool = [sender tag];
    
    switch (newTool)
    {
        case 0:
            [imageView setCurrentToolMode: IKToolModeMove];
            break;
        case 1:
            [imageView setCurrentToolMode: IKToolModeSelect];
            break;
        case 2:
            [imageView setCurrentToolMode: IKToolModeCrop];
            break;
        case 3:
            [imageView setCurrentToolMode: IKToolModeRotate];
            break;
        case 4:
            [imageView setCurrentToolMode: IKToolModeAnnotate];
            break;
    }

}
@end
