#import <Quartz/Quartz.h>
#import "ControllerEditing.h"


@implementation ImageController(Editing)

- (void) setupEditing
{
    [imageView setCurrentToolMode: IKToolModeMove];
    [imageView setDoubleClickOpensImageEditPanel: YES];
    [imageView setDelegate: self];
}

@end
