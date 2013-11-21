#import <Quartz/Quartz.h>
#import "ControllerViewing.h"

@implementation ImageController(Viewing)

- (void) setupViewing
{
    [imageView setAutoresizes: YES];
    [imageView setImageWithURL: NULL];
}

- (void) imageBrowserSelectionDidChange: (IKImageBrowserView *) aBrowser
{
    NSIndexSet * sel = [aBrowser selectionIndexes];
    if (sel && [sel count])
    {
        NSUInteger firstIndex = [sel firstIndex];
        if (NSNotFound != firstIndex) 
        {
            id item = [[aBrowser dataSource] imageBrowser: aBrowser itemAtIndex: firstIndex];
            
            id imageRepresentation = [item imageRepresentation];
            
            if(imageRepresentation !=NULL)
                [imageView setImageWithURL: [NSURL fileURLWithPath: imageRepresentation]];
        }
    }
    
}

@end
