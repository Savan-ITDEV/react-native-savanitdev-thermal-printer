//
//  WIFIConnecter.h
//  PrinterSDK
//
//  Created by Apple Mac mini intel on 2023/9/1.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PrinterProfile.h"

@class WIFIConnecter;
@class PrinterProfile;

@protocol WIFIConnecterDelegate <NSObject>
@optional
/**
 * connect success
 */
- (void)wifiPOSConnectedToHost:(NSString *)ip port:(UInt16)port mac:(NSString *)mac;
/**
 * disconnect error
 */
- (void)wifiPOSDisconnectWithError:(NSError *)error mac:(NSString *)mac ip:(NSString *)ip;
/**
 * send data success
 */
- (void)wifiPOSWriteValueWithTag:(long)tag mac:(NSString *)mac ip:(NSString *)ip;
/**
 * receive printer data
 */
- (void)wifiPOSReceiveValueForData:(NSData *)data mac:(NSString *)mac ip:(NSString *)ip;

@end

/**********************************************************************/

typedef void (^WIFIConnecterReceiveBlock)(NSData *data);
typedef void (^WIFIConnecterWriteBlock)(BOOL success, NSError *error);
typedef void (^POSWiFiPrinterStatusBlock)(NSData *status);
typedef void (^POSWiFiPrinterSNBlock)(NSString *sn);

/**********************************************************************/

@interface WIFIConnecter : NSObject
// host
@property (nonatomic, copy) NSString *deviceIP;
// port
@property (nonatomic, assign) UInt16 port;
// mac
@property (nonatomic, copy) NSString *deviceMac;

@property (nonatomic, weak) id<WIFIConnecterDelegate> delegate;
@property (nonatomic, copy) WIFIConnecterReceiveBlock receiveBlock;
@property (nonatomic, copy) WIFIConnecterWriteBlock writeBlock;
@property (nonatomic, copy) POSWiFiPrinterStatusBlock statusBlock;
@property (nonatomic, copy) POSWiFiPrinterSNBlock snBlock;
@property (nonatomic, strong) PrinterProfile *connectedPrinter;

/**
 * remove a delegate
 */
- (void)removeDelegate:(id<WIFIConnecterDelegate>) delegate;

/**
 * remove all delegates
 */
- (void)removeAllDelegates;

/**
 * disconnect
 */
- (void)disconnect;

/**
 * write command to printer
 */
- (void)writeCommandWithData:(NSData *)data;

/**
 * write command to printer with receive callback
 */
- (void)writeCommandWithData:(NSData *)data receiveCallBack:(WIFIConnecterReceiveBlock)receiveBlock;

/**
 *  write command to printer with write callback
 */
- (void)writeCommandWithData:(NSData *)data writeCallBack:(WIFIConnecterWriteBlock)writeBlock;

/**
 * write command to printer with subpackage with write callback
 */
- (void)writeCommandWithData:(NSData *)data subpackageLength:(int)subpackageLength writeCallBack:(WIFIConnecterWriteBlock)writeBlock;

/**
 * check connect status
 */
- (BOOL)printerCheckWithMac;

/**
 * printer status
 */
- (void)printerStatus:(POSWiFiPrinterStatusBlock)statusBlock;

/**
 * printer sn code
 */
- (void)printerSNWithSnBlock:(POSWiFiPrinterSNBlock)snBlock;

/**
 *  connect printer address
 */
- (void)connectWithHost:(NSString *)hostStr port:(UInt16)port;

/**
 * connect printer address with mac address
 */
- (void)connectWithMac:(NSString *)mac;

/**
 * connect printer by device profile
 */
- (void)connectWithDevice:(PrinterProfile *)device;

/**
 * printer label status
 */
- (void)labelPrinterStatus:(POSWiFiPrinterStatusBlock)statusBlock;

@end

