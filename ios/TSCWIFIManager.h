//
//  TSCWIFIManager.h
//  Printer
//

#import <Foundation/Foundation.h>

typedef void(^TSCWIFIManagerReceiveBlock)(NSData *data);
typedef void(^TSCWIFIManagerWriteBlock)(long tag);
typedef void (^TSCWIFIPrinterStatusBlock)(NSData *status);

@class TSCWIFIManager;
@protocol TSCWIFIManagerDelegate <NSObject>
@optional
/**
 * connect success
 */
- (void)TSCwifiConnectedToHost:(NSString *)host port:(UInt16)port;
/**
 * disconnect error
 */
- (void)TSCwifiDisconnectWithError:(NSError *)error;
/**
 * send data success
 */
- (void)TSCwifiWriteValueWithTag:(long)tag;
/**
 * receive printer data
 */
- (void)TSCwifiReceiveValueForData:(NSData *)data;
@end

@interface TSCWIFIManager : NSObject
// host
@property (nonatomic, copy) NSString *hostStr;
// port
@property (nonatomic, assign) UInt16 port;
// connect status
@property (nonatomic, assign) BOOL isConnect;

@property (nonatomic, weak) id<TSCWIFIManagerDelegate> delegate;

@property (nonatomic, copy) TSCWIFIManagerReceiveBlock receiveBlock;

@property (nonatomic, copy) TSCWIFIManagerWriteBlock writeBlock;

@property (nonatomic, copy) TSCWIFIPrinterStatusBlock statusBlock;

/**
 *  singleton
 */
+ (instancetype)sharedInstance;

/**
 *  connect printer address
 */
- (void)connectWithHost:(NSString *)hostStr port:(UInt16)port;

/**
 *  disconnect
 */
- (void)disconnect;

/**
 *  write command to printer
 */
- (void)writeCommandWithData:(NSData *)data;

/**
 *  remove a delegate
 */
- (void)removeDelegate:(id<TSCWIFIManagerDelegate>) delegate;

/**
 *  remove all delegates
 */
- (void)removeAllDelegates;

/**
 *  write command to printer with receive callback
 */
- (void)writeCommandWithData:(NSData *)data receiveCallBack:(TSCWIFIManagerReceiveBlock)receiveBlock;

/**
 *  write command to printer with write callback
 */
- (void)writeCommandWithData:(NSData *)data writeCallBack:(TSCWIFIManagerWriteBlock)writeBlock;

/**
 * printer status
 */
- (void)printerStatus:(TSCWIFIPrinterStatusBlock)statusBlock;

/**
 *  get copyright
 */
+ (NSString *)GetCopyRight;

@end
