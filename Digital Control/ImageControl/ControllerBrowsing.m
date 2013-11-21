#import "ImageController.h"
#import "ControllerBrowsing.h"


/* a simple C function that open an NSOpenPanel and return an array of selected filepath */
static NSArray *openFiles()
{ 
    NSOpenPanel *panel;

    panel = [NSOpenPanel openPanel];
    
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    
	int i = [panel runModalForTypes:nil];
	if(i == NSOKButton){
		return [panel filenames];
    }
    
    return nil;
}    

/* Our datasource object : represents one item in the browser */
@interface MyImageObject : NSObject{
    NSString *path; 
}
@end

@implementation MyImageObject


- (void) setPath:(NSString *) aPath
{
    if(path != aPath){
        path = aPath;
    }
}

#pragma mark -
#pragma mark item data source protocol

- (NSString *)  imageRepresentationType
{
	return IKImageBrowserPathRepresentationType;
}

- (id)  imageRepresentation
{
	return path;
}

- (NSString *) imageUID
{
    return path;
}

- (id) imageTitle
{
	return [path lastPathComponent];
}

@end



/* the controller */
@implementation ImageController(Browsing)


#pragma mark -
#pragma mark import images from file system

/* 
 code that parse a repository and add all entries to our datasource array,
*/

- (void) addImageWithPath:(NSString *) path
{   
    MyImageObject *item;
    
    NSString *filename = [path lastPathComponent];

	/* skip '.*' */ 
	if([filename length] > 0){
		char *ch = (char*) [filename UTF8String];
		
		if(ch)
			if(ch[0] == '.')
				return;
	}
	
	item = [[MyImageObject alloc] init];	
	[item setPath:path];
	[images addObject:item];
	//[item release];
}

- (void) addImagesFromDirectory:(NSString *) path
{
    int i, n, rev;
    BOOL dir;
	
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir];
    
    if(dir){
        NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        
        n = (int)[content count];
        rev = n - 1;
        
        for(i=1; i<n; i++){
			[self addImageWithPath:[path stringByAppendingPathComponent:[content objectAtIndex:rev]]];
            rev = rev - 1;
        }
        
    }
    else
        [self addImageWithPath:path];
	
	[imageBrowser reloadData];
}



#pragma mark -
#pragma mark setupBrowsing


- (void) setupBrowsing
{
	//allocate our datasource array: will contain instances of MyImageObject
    images = [[NSMutableArray alloc] init];
    
	[self addImagesFromDirectory:imagefilePath];
}


#pragma mark -
#pragma mark actions

/* "add" button was clicked */
- (IBAction) addImageButtonClicked:(id) sender
{   
    NSArray *path = openFiles();
    
    if(!path){ 
        NSLog(@"No path selected, return..."); 
        return; 
    }
        
	int i, n;
	
	n = (int)[path count];
    
	for(i=0; i<n; i++){
		[self addImagesFromDirectory:[path objectAtIndex:i]];
    }
}

- (IBAction) zoomSliderDidChange:(id)sender
{
    [imageBrowser setZoomValue:[sender floatValue]];
}

#pragma mark -
#pragma mark  drag'n drop

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	return [self draggingUpdated:sender];
}


- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	if ([sender draggingSource] == imageBrowser) 
		return NSDragOperationMove;
	
    return NSDragOperationCopy;
}


- (BOOL) performDragOperation:(id <NSDraggingInfo>)sender
{
    NSData *data = nil;
    NSString *errorDescription;
    
	// if we are dragging from the browser itself, ignore it
	if ([sender draggingSource] == imageBrowser) 
		return NO;
	
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    
    if ([[pasteboard types] containsObject:NSFilenamesPboardType]) 
        data = [pasteboard dataForType:NSFilenamesPboardType];
	
    if(data){
        NSArray *filenames = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:kCFPropertyListImmutable format:nil errorDescription:&errorDescription];		
		
        int i, n;
        n = (int)[filenames count];
        for(i=0; i<n; i++){
			MyImageObject *item = [[MyImageObject alloc] init];
			[item setPath:[filenames objectAtIndex:i]];	
			[images insertObject:item atIndex:[imageBrowser indexAtLocationOfDroppedItem]];
			//[item release];
        }
		
		[imageBrowser reloadData];
    }
	
	return YES;
}

#pragma mark -
#pragma mark IKImageBrowserDataSource

/* implement image-browser's datasource protocol 
   Our datasource representation is a simple mutable array
*/

- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) view
{
    return [images count];
}

- (id) imageBrowser:(IKImageBrowserView *) view itemAtIndex:(NSUInteger) index
{
    return [images objectAtIndex:index];
}


#pragma mark -
#pragma mark optional datasource methods : reordering / removing

- (void) imageBrowser:(IKImageBrowserView *) aBrowser removeItemsAtIndexes: (NSIndexSet *) indexes
{
	[images removeObjectsAtIndexes:indexes];
	[imageBrowser reloadData];
}

- (BOOL) imageBrowser:(IKImageBrowserView *) aBrowser moveItemsAtIndexes: (NSIndexSet *)indexes toIndex:(unsigned int)destinationIndex
{
	NSArray *tempArray = [images objectsAtIndexes:indexes];
	[images removeObjectsAtIndexes:indexes];
	
	destinationIndex -= [indexes countOfIndexesInRange:NSMakeRange(0, destinationIndex)];
	[images insertObjects:tempArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(destinationIndex, [tempArray count])]];
	[imageBrowser reloadData];
	
	return YES;
}
@end
