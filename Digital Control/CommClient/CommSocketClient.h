#import "CommController.h"

typedef enum _CommSocketClientStatus {
    CommSocketClientStatusUnknown       = 0,
    CommSocketClientStatusLinked        = 1,
    CommSocketClientStatusDisconnected  = 2,
    CommSocketClientStatusLinking       = 3,
    CommSocketClientStatusDisconnecting = 4
    
} CommSocketClientStatus;

void setFullPathInfo(NSMutableArray *fullpathInfo, NSString *fullMessage, NSString *fullValue, NSData *liveViewData, NSString *getSystemLog,  NSString *code, void *obj);

@class CommSocketClient;


@protocol CommSocketClientDelegate <NSObject>
@optional
- (void) handleSocketClientDisconnect:(CommSocketClient *)client;
- (void) handleSocketClientMsgURL:(NSURL *)aURL          client:(CommSocketClient *)client;
- (void) handleSocketClientMsgString:(NSString *)aString client:(CommSocketClient *)client;
- (void) handleSocketClientMsgNumber:(NSNumber *)aNumber client:(CommSocketClient *)client;
- (void) handleSocketClientMsgArray:(NSArray *)aArray    client:(CommSocketClient *)client;
- (void) handleSocketClientMsgDict:(NSDictionary *)aDict client:(CommSocketClient *)client;
@end

@interface CommSocket : NSObject
@property (readonly, nonatomic, getter=isSockRefValid) BOOL sockRefValid;
@property (readonly, nonatomic, getter=isSockConnected) BOOL sockConnected;
@property (readonly, nonatomic) CFSocketRef sockRef;
@property (readonly, strong, nonatomic) NSURL    *sockURL;
@property (readonly, strong, nonatomic) NSData   *sockAddress;
@property (readonly, strong, nonatomic) NSString *sockLastError;
@end

@interface CommSocketClient : CommSocket {
    id <CommSocketClientDelegate> delegate;
    NSMutableArray *fullpathValueArray;
    CommController *socketControl;
    NSString  *streamValue;
}
@property (readwrite, strong, nonatomic) id delegate;
@property (readonly, nonatomic) CommSocketClientStatus sockStatus;
@property (readonly, nonatomic) CFRunLoopSourceRef sockRLSourceRef;
@property (readonly, nonatomic) BOOL startClient;
@property (readonly, nonatomic) BOOL stopClient;
@property (readonly, nonatomic) NSMutableArray *fullpathValueArray;
@property (nonatomic, retain) CommController *socketControl;
@property (nonatomic, retain) NSString *streamValue;

- (id) initWithSocketURL:(NSURL *)socketURL
                        : (NSString *)type;
- (id) initWithSocket:(CFSocketNativeHandle)handle;
+ (id) initAndStartClient:(NSURL *)socketURL
                         :(NSString *)type;
+ (id) initWithSocket:(CFSocketNativeHandle)handle;
//-(void) initFullApplicationType;
- (void) messageReceived:(NSString *)data;
- (BOOL) messageURL:(NSURL *)aURL;
- (BOOL) messageString:(NSString *)aString;
- (BOOL) messageNumber:(NSNumber *)aNumber;
- (BOOL) messageArray:(NSArray *)aArray;
- (BOOL) messageDict:(NSDictionary *)aDict;

@end

