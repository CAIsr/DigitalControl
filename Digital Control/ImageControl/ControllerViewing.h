
#import <Quartz/Quartz.h>
#import <Cocoa/Cocoa.h>
#import "ImageController.h"

@interface ImageController(Viewing)

- (void) setupViewing;
- (void) imageBrowserSelectionDidChange: (IKImageBrowserView *) aBrowser;

@end
