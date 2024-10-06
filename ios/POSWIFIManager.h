//
//  POSWIFIManager.h
//  Printer
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PrinterProfile.h"

@class POSWIFIManager;
@protocol POSWIFIManagerDelegate <NSObject>
@optional
/**
 * connect success
 */
- (void)POSwifiConnectedToHost:(NSString *)host port:(UInt16)port;
/**
 * disconnect error
 */
- (void)POSwifiDisconnectWithError:(NSError *)error;
/**
 * send data success
 */
- (void)POSwifiWriteValueWithTag:(long)tag;
/**
 * receive printer data
 */
- (void)POSwifiReceiveValueForData:(NSData *)data;
@end

/**********************************************************************/

typedef void (^POSWIFIManagerReceiveBlock)(NSData *data);
typedef void (^POSWIFIManagerWriteBlock)(BOOL success, NSError *error);
typedef void (^POSWiFiPrinterStatusBlock)(NSData *status);
typedef void (^POSWiFiPrinterSNBlock)(NSString *sn);
typedef void (^POSWiFiPrinterCheckBlock)(NSData *check);
@class PrinterProfile;
typedef void (^POSWiFiManagerFoundPrinterBlock)(PrinterProfile *foundPrinter);

/**********************************************************************/

@interface POSWIFIManager : NSObject
// host
@property (nonatomic, copy) NSString *hostStr;
// port
@property (nonatomic, assign) UInt16 port;
// whether connect
@property (nonatomic, assign) BOOL isConnect;

@property (nonatomic, weak) id<POSWIFIManagerDelegate> delegate;

@property (nonatomic, copy) POSWIFIManagerReceiveBlock receiveBlock;
@property (nonatomic, copy) POSWIFIManagerWriteBlock writeBlock;

@property (nonatomic, copy) POSWiFiManagerFoundPrinterBlock foundPrinterBlock;
@property (nonatomic, copy) POSWiFiPrinterStatusBlock statusBlock;
@property (nonatomic, copy) POSWiFiPrinterSNBlock snBlock;
@property (nonatomic, copy) POSWiFiPrinterCheckBlock checkBlock;

@property (nonatomic, strong) PrinterProfile *connectedPrinter;

/**
 *  singleton
 */
+ (instancetype)sharedInstance;

/**
 *  remove a delegate
 */
- (void)removeDelegate:(id<POSWIFIManagerDelegate>) delegate;

/**
 *  remove all delegates
 */
- (void)removeAllDelegates;

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
 *  write command to printer with receive callback
 */
- (void)writeCommandWithData:(NSData *)data receiveCallBack:(POSWIFIManagerReceiveBlock)receiveBlock;

/**
 *  write command to printer with write callback
 */
- (void)writeCommandWithData:(NSData *)data writeCallBack:(POSWIFIManagerWriteBlock)receiveBlock;

/**
 * udp socket create
 */
- (BOOL)createUdpSocket;

/**
 * udp socket close
 */
- (void)closeUdpSocket;

/**
 * search printers
 */
- (void)sendFindCmd:(POSWiFiManagerFoundPrinterBlock)foundPrinterBlock;

/**
 * set ip configuration
 */
- (void)setIPConfigWithIP:(NSString *)ip Mask:(NSString *)mask Gateway:(NSString *)gateway DHCP:(BOOL)dhcp;

/**
 * set wifi configuration
 */
- (void)setWiFiConfigWithIP:(NSString *)ip mask:(NSString *)mask gateway:(NSString *)gateway ssid:(NSString *)ssid password:(NSString *)password encrypt:(NSUInteger)encrypt;

/**
 * check connect status
 */
- (BOOL)printerIsConnect;

/**
 * printer sn code
 */
- (void)printerSN:(POSWiFiPrinterSNBlock)snBlock;

/**
 * connect printer address with mac address
 */
- (void)connectWithMac:(NSString *)macStr;


/**
 *  get copyright
 */
+ (NSString *)GetCopyRight;

/**
 * printer status
 * 查询当前打印机常用状态（正常/缺纸/开盖等）
 */
- (void)printerStatus:(POSWiFiPrinterStatusBlock)statusBlock;

/**
 * printer check
 * 这个方法用于查询打印机所有状态
 * type = 1 打印机状态 type = 2 脱机状态 type = 3 错误状态 type = 4 传送纸状态
 */
- (void)printerCheck:(int)type checkBlock:(POSWiFiPrinterCheckBlock)checkBlock;

@end
