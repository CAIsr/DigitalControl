
#import "ImageController.h"
#import "ControllerBrowsing.h"
#import "ControllerImporting.h"


/* the controller */
@implementation ImageController(Importing)


#pragma mark -
#pragma mark pictureTaker callback

- (void)pictureTakerDidEnd:(IKPictureTaker *)pictureTaker returnCode:(NSInteger)returnCode contextInfo:(void  *)contextInfo
{
    static int snapCount = 0;
    
    if(returnCode == NSOKButton){
        NSImage *image = [pictureTaker outputImage];
        NSString *outputPath = [NSString stringWithFormat:@"/tmp/snap%d.tiff", ++snapCount];
        
        [[image TIFFRepresentation] writeToFile:outputPath atomically:YES];
         
        //add it to our datasource
        [self addImageWithPath:outputPath];

        //reflect changes
        [imageBrowser reloadData];
    }
}


#pragma mark -
#pragma mark actions

- (IBAction) importImage:(id)sender
{
    IKPictureTaker *sharedPictureTaker = [IKPictureTaker pictureTaker];
    
    [sharedPictureTaker setValue:[NSNumber numberWithBool:YES] forKey:IKPictureTakerShowEffectsKey];
    [sharedPictureTaker beginPictureTakerSheetForWindow:[self window] withDelegate:self didEndSelector:@selector(pictureTakerDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

@end
