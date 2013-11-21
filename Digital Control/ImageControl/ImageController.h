//
//  ImageController.h
//  Digital Control
//
//  Created by Adam Lin on 22/04/13.
//  Copyright (c) 2013 Adam Lin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

NSString *imagefilePath;

@interface ImageController : NSWindowController
{
    IBOutlet IKImageBrowserView * imageBrowser;
    IBOutlet IKImageView * imageView;
    IBOutlet NSPathControl * displayPath;

    NSMutableArray *images;
    NSMutableArray *filteredOutImages;
	NSMutableIndexSet *filteredOutIndexes;
}
- (IBAction) switchToolMode:(id)sender;
- (IBAction) openPath:(id)sender;
- (void) reloadImageBrowser;
@end

ImageController *initImageBrowser;


