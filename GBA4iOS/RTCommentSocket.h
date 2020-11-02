#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@interface RTCommentSocket : NSObject{
    dispatch_queue_t serverQueue;
    dispatch_queue_t connectionQueue;
    GCDAsyncSocket *asyncSocket;
    Class connectionClass;
    NSMutableArray *connectedSockets;
    
    BOOL isRunning;
    int port;
    NSString *interface;
}

- (BOOL)start;
- (BOOL)startWithPort:(int) portNumber;
-(BOOL)connectToHost:(NSString *)host port:(int)port;
- (BOOL)stop;
- (BOOL)isRunning;
- (int) getLocalPort;
-(void)onData:(void(^)(NSData *data))func;
-(void)addDataWithData:(NSData *)data;

@end
