#import "RTCommentSocket.h"
#import "GCDAsyncSocket.h"

#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0

@implementation RTCommentSocket{
    void(^mOnData)(NSData *data);
}

- (id)init {
    if ((self = [super init]))
    {
        // Initialize underlying dispatch queue and GCD based tcp socket
        serverQueue = dispatch_queue_create("TCP_EVENT_SERVER", NULL);
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:serverQueue];
        
        // Setup an array to store all accepted client connections
        connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        
        isRunning = NO;
        //bind on all available interfaces
        interface = nil;
    }
    return self;
}

-(BOOL) start{
    __block BOOL success = YES;
    __block NSError *err = nil;
    
    dispatch_sync(serverQueue, ^{
        success = [self->asyncSocket acceptOnPort:[self->asyncSocket localPort] error:&err];
        if (success){
            //NSLog(@"Started TCP server on port %hu", [asyncSocket localPort]);
            self->isRunning = YES;
        } else {
            //NSLog(@"Failed to start TCP Server: %@", err);
        }
        
    });
    
    return success;
}

- (BOOL)startWithPort:(int) portNumber{
    __block BOOL success = YES;
    __block NSError *err = nil;
    port = portNumber;
    dispatch_sync(serverQueue, ^{
        success = [self->asyncSocket acceptOnPort:self->port error:&err];
        if (success){
            //NSLog(@"Started TCP server on port %hu", [asyncSocket localPort]);
            self->isRunning = YES;
        } else {
            //NSLog(@"Failed to start TCP Server: %@", err);
        }
        
    });
    
    return success;
}

-(BOOL)connectToHost:(NSString *)host port:(int)port{
    return [self->asyncSocket connectToHost:host onPort:port error:nil];
}

-(void)onData:(void(^)(NSData *data))func{
    mOnData = func;
}

- (BOOL)stop{
    dispatch_sync(serverQueue, ^{
        // Stop listening / accepting incoming connections
        [self->asyncSocket disconnect];
        self->isRunning = NO;
    });
    
    return YES;
}

-(void)addDataWithData:(NSData *)data{
    [self->asyncSocket writeData:data withTimeout:-1 tag:0];
}

- (BOOL)isRunning{
    __block BOOL result;
    dispatch_sync(serverQueue, ^{
        result = self->isRunning;
    });
    
    return result;
}

- (int) getLocalPort{
    return [asyncSocket localPort];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"%@:%d", host, port);
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    // This method is executed on the socketQueue (not the main thread)
    
    @synchronized(connectedSockets)
    {
        [connectedSockets addObject:newSocket];
    }

    NSString *host = [newSocket connectedHost];
    UInt16 clientPort = [newSocket connectedPort];
    NSLog(@"Event Server Accepted client %@:%d===%lu", host, clientPort, (unsigned long)[connectedSockets count]);

    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // This method is executed on the socketQueue (not the main thread)
    NSLog(@"didWriteDataWithTag");
    //if (tag == ECHO_MSG){
//    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
    //}
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // This method is executed on the socketQueue (not the main thread)
    NSLog(@"didReadData");
    if(mOnData) mOnData([data mutableCopy]);
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [sock disconnect];
    [connectedSockets removeObject:sock];
}

@end
