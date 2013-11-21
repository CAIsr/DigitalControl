 #import "CommSocketClient.h"
#import "CommController.h"
#import <sys/un.h>
#import <sys/socket.h>

// Superclass
@interface CommSocket ()
@property (readwrite, nonatomic) CFSocketRef sockRef;
@property (readwrite, strong, nonatomic) NSURL *sockURL;
@end

@implementation CommSocket
@synthesize sockConnected;
@synthesize sockRef, sockURL;

- (BOOL) isSockRefValid {
    if ( self.sockRef == nil ) return NO;
    return (BOOL)CFSocketIsValid( self.sockRef );
}

- (NSData *) sockAddress {
    
    struct sockaddr_un address;
    address.sun_family = AF_UNIX;
    strcpy( address.sun_path, [[self.sockURL path] fileSystemRepresentation] );
    address.sun_len = SUN_LEN( &address );
    return [NSData dataWithBytes:&address length:sizeof(struct sockaddr_un)];
}

- (NSString *) sockLastError {
    return [NSString stringWithFormat:@"%s (%d)", strerror( errno ), errno ];
}

@end
// End of Superclass


// The Client Interface

@interface CommSocketClient ()
@property (readonly, nonatomic) BOOL startClientCleanup;
@property (readwrite, nonatomic) CommSocketClientStatus sockStatus;
@property (readwrite, nonatomic) CFRunLoopSourceRef sockRLSourceRef;
static void SocketClientCallback (CFSocketRef sock, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);
@end

#pragma mark - Client Implementation:

@implementation CommSocketClient

static NSTimeInterval const kCommSocketClientTimeout = 5.0;

@synthesize delegate;
@synthesize sockStatus;
@synthesize sockRLSourceRef, fullpathValueArray, socketControl, streamValue;
@synthesize startClient,stopClient;

#pragma mark - Helper Methods:

- (BOOL) socketClientCreate:(CFSocketNativeHandle)sock {
    
    if ( self.sockRef != nil ) return NO;
    CFSocketContext context = { 0, (__bridge void *)self, nil, nil, nil };
    CFSocketCallBackType types = kCFSocketDataCallBack;
    CFSocketRef refSock = CFSocketCreateWithNative( nil, sock, types, SocketClientCallback, &context );
    if ( refSock == nil ) return NO;
    
    int opt = 1;
    setsockopt(sock, SOL_SOCKET, SO_NOSIGPIPE, (void *)&opt, sizeof(opt));
    
    self.sockRef = refSock;
    CFRelease( refSock );
    
    return YES;
}

- (BOOL) socketClientBind {
    @autoreleasepool {
        if ( self.sockRef == nil ) return NO;
        if ( CFSocketConnectToAddress(self.sockRef,
                                      (__bridge CFDataRef)self.sockAddress,
                                      (CFTimeInterval)kCommSocketClientTimeout) != kCFSocketSuccess ) return NO;
        return YES;
    }
}

#pragma mark - Client Messaging:
#pragma mark - Start / Stop Client:

- (BOOL) startClientCleanup { [self stopClient]; return NO; }

- (BOOL) startClient {
    
    if ( self.sockStatus == CommSocketClientStatusLinked ) return YES;
    self.sockStatus = CommSocketClientStatusLinking;
    
    CFSocketNativeHandle sock = socket( AF_UNIX, SOCK_STREAM, 0 );
    if ( ![self socketClientCreate:sock] ) return self.startClientCleanup;
    if ( ![self socketClientBind]        ) return self.startClientCleanup;
    
    CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource( kCFAllocatorDefault, self.sockRef, 0 );
    CFRunLoopAddSource( CFRunLoopGetCurrent(), sourceRef, kCFRunLoopCommonModes );
    
    self.sockRLSourceRef = sourceRef;
    CFRelease( sourceRef );
    
    self.sockStatus = CommSocketClientStatusLinked;
    return YES;
}

- (BOOL) stopClient {
    
    self.sockStatus = CommSocketClientStatusDisconnecting;
    
    if ( self.sockRef != nil ) {
        if ( self.sockRLSourceRef != nil ) {
            
            CFRunLoopSourceInvalidate( self.sockRLSourceRef );
            self.sockRLSourceRef = nil;
        }
        
        CFSocketInvalidate(self.sockRef);
        self.sockRef = nil;
    }
    
    if ( [self.delegate respondsToSelector:@selector(handleSocketClientDisconnect:)] )
        [self.delegate handleSocketClientDisconnect:self];
    
    self.sockStatus = CommSocketClientStatusDisconnected;
    
    return YES;
}

#pragma mark - Client Validation:

- (BOOL) isSockConnected {
    
    if ( self.sockStatus == CommSocketClientStatusLinked )
        return self.isSockRefValid;
    
    return NO;
}

#pragma mark - Initialization:

+ (id) initAndStartClient: (NSURL *)socketURL
                         : (NSString *) type {
    
    CommSocketClient *client = [[CommSocketClient alloc] initWithSocketURL:socketURL:type];
    [client startClient];
    return client;
}

+ (id) initWithSocket:(CFSocketNativeHandle)handle {
    
    CommSocketClient *client = [[CommSocketClient alloc] initWithSocket:handle];
    return client;
}

- (id) initWithSocketURL: (NSURL *)socketURL
                        : (NSString *) type {
    
    if ( (self = [super init]) ) {
        self.sockURL    = socketURL;
        self.sockStatus = CommSocketClientStatusDisconnected;
        self.socketControl = [[CommController alloc]init];
        self.streamValue = type;
    } return self;
}

- (id) initWithSocket:(CFSocketNativeHandle)handle {
    
    if ( (self = [super init]) ) {
        
        self.sockStatus = CommSocketClientStatusLinking;
        
        if ( ![self socketClientCreate:handle] ) [self startClientCleanup];
        
        else {
            
            CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource( kCFAllocatorDefault, self.sockRef, 0 );
            CFRunLoopAddSource( CFRunLoopGetCurrent(), sourceRef, kCFRunLoopCommonModes );
            
            self.sockRLSourceRef = sourceRef;
            CFRelease( sourceRef );
            
            self.sockStatus = CommSocketClientStatusLinked;
        }
        
    } return self;
}

#pragma mark - Client Callback:

void SocketClientCallback (CFSocketRef sock, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    
    static int size = 0;
    static unsigned long currentsize = 0;
    
    static int          nb = 0;
    static int          sizeinit = 0;
    static short        initialized = 0;
    static NSString     *initPartial = @"";
    
    CommSocketClient *socketClientCom   = (__bridge CommSocketClient *)(info);
    
    if([[socketClientCom streamValue] isEqualToString:@"comm"]){
        @autoreleasepool {
            if ( kCFSocketDataCallBack == type ) {
                NSString *callBackString = [[NSString alloc] initWithData:(__bridge NSData *)data encoding:NSUTF8StringEncoding];
                if (nb == 0)
                {
                    sizeinit = [[[[callBackString componentsSeparatedByString:@"||"] mutableCopy] objectAtIndex:1] intValue];
                }
                if (nb != 0 && initialized == 0){
                    initPartial = [NSString stringWithFormat:@"%@%@", initPartial, callBackString];
                    if ([initPartial length] == sizeinit)
                    {
                        initialized = 1;
                        [[socketClientCom socketControl] parsingMessage:initPartial];
                        [[socketClientCom socketControl] initFirstLoadMessage:initPartial :sizeinit];
                        setFullPathInfo(finalCallBackFirstMessage, NULL, NULL,NULL, NULL,NULL,NULL);
                    }
                }
                
                if ([callBackString length] <= 1000 && initialized == 1){
                    [[socketClientCom socketControl] parsingMessage:callBackString];
                    [[socketClientCom socketControl] checkMessage];
                    setFullPathInfo(NULL, getMessageFromCamera, getValueFromCamera, NULL, getSystemLogMessage, getSystemCode, NULL);
                 }
            }
        }
        nb++;
    }
    else if([[socketClientCom streamValue] isEqualToString:@"data"]){
        @autoreleasepool {
            static NSMutableData   *data_part;
            const void *data2 = NULL;
            NSMutableData *mdata = nil;
            if([(__bridge NSData *)data length] > 1){ // check length incase socket connection failed
                if(size == 0){ // fix later
                    NSString *header = [[NSString alloc] initWithData:(__bridge NSData *)(data) encoding:NSASCIIStringEncoding];
                    char *cheader = (char *)[header UTF8String];
                    cheader[12] = '\0';
                    cheader = &cheader[4];
                    size = atoi(cheader);
                    mdata = [(__bridge NSData *)data mutableCopy];
                    [mdata replaceBytesInRange:NSMakeRange(0, 16) withBytes:NULL length:0];
                    data2 = (__bridge const void *)(mdata);
                    currentsize = 0;
                }
                if (size != 0)
                {
                    if (currentsize == 0)
                    {
                        data_part = [[NSMutableData alloc] init];
                        if (data2 == NULL)
                        {
                            [data_part appendData:(__bridge NSData *)data];
                            currentsize = [(__bridge NSData *)data length];
                        }
                        else
                        {
                            [data_part appendData:(__bridge NSData *)data2];
                            currentsize = [(__bridge NSData *)data2 length];
                        }
                        if ((int)currentsize == size)
                        {
                            size = 0;
                            currentsize = 0;
                            setFullPathInfo(NULL, NULL, NULL, data_part, NULL, NULL, NULL);
                        }
                    }
                    else
                    {
                        if (data2 == NULL)
                        {
                            [data_part appendData:(__bridge NSData *)data];
                            currentsize += [(__bridge NSData *)data length];
                        }
                        else
                        {
                            [data_part appendData:(__bridge NSData *)data2];
                            currentsize += [(__bridge NSData *)data2 length];
                        }
                        if ((int)currentsize > size)
                        {
                            size = 0;
                            currentsize = 0;
                        }
                        else if ((int)currentsize >= size)
                        {
                            size = 0;
                            currentsize = 0;
                            setFullPathInfo(NULL, NULL, NULL, data_part, NULL, NULL, NULL);
                        }
                    }
                }
            }
        }
    }
}
@end