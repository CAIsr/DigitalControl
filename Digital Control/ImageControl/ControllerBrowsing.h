#import <Quartz/Quartz.h>
#import <Cocoa/Cocoa.h>
#import "ImageController.h"

@interface ImageController(Browsing)

- (void) setupBrowsing;
- (void) addImageWithPath:(NSString *) path;

@end
