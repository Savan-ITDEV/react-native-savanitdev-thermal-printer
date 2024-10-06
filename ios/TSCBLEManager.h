//
//  TSCBLEManager.h
//  Printer
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol TSCBLEManagerDelegate <NSObject>
@optional
/**
 *  found peripheral list
 */
- (void)TSCbleUpdatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)rssiList;
/**
 *  connect success
 */
- (void)TSCbleConnectPeripheral:(CBPeripheral *)peripheral;
/**
 *  connect fail
 */
- (void)TSCbleFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
/**
 *  disconnect
 */
- (void)TSCbleDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
/**
 *  send data success
 */
- (void)TSCbleWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
/**
 *  receive printer data
 */
- (void)TSCbleReceiveValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/**
 *  bleCentralManager state update
 */
- (void)TSCbleCentralManagerDidUpdateState:(NSInteger)state;

@end

/****************************************************************************************************/

typedef void (^TSCBLEManagerReceiveCallBackBlock)(CBCharacteristic *characteristic, NSError *error);
typedef void (^TSCBLEManagerWriteCallBackBlock) (CBCharacteristic *characteristic, NSError *error);
typedef void (^TSCBLEPrinterStatusBlock)(NSData *status);
typedef void (^TSCBLEPrinterSNBlock)(NSString *sn);

 
 /****************************************************************************************************/

@interface TSCBLEManager : NSObject

// bt name
@property (nonatomic, copy) NSString *name;
// connect status
@property (nonatomic, assign) BOOL isConnecting;
// scan status
@property (nonatomic, assign) BOOL isScaning;
//peripheral that write
@property (nonatomic,strong) CBPeripheral *writePeripheral;
// write characteristic
@property (nonatomic, strong) CBCharacteristic *write_characteristic;
// read characteristic
@property (nonatomic, strong) CBCharacteristic *read_characteristic;
// notify characteristic
@property (nonatomic, strong) CBCharacteristic *notify_characteristic;
// search filter printer through uuid
@property (nonatomic, strong) CBUUID *searchFilterUUID;
// characteristic uuid
@property (nonatomic, strong) CBUUID *characteristicUUID;

@property (nonatomic,weak) id<TSCBLEManagerDelegate> delegate;

@property (nonatomic, copy) TSCBLEManagerReceiveCallBackBlock receiveBlock;
@property (nonatomic, copy) TSCBLEManagerWriteCallBackBlock writeBlock;
@property (nonatomic, copy) TSCBLEPrinterStatusBlock statusBlock;
@property (nonatomic, copy) TSCBLEPrinterSNBlock snBlock;
@property (nonatomic, copy) TSCBLEPrinterStatusBlock stateBlock;

/**
 *  singleton
 */
+ (instancetype)sharedInstance;

/**
 *  remove a delegate
 */
- (void)removeDelegate:(id<TSCBLEManagerDelegate>) delegate;

/**
 *  remove all delegates
 */
- (void)removeAllDelegates;

/**
 *  start scan
 */
- (void)startScan;

/**
 *  stop scan
 */
- (void)stopScan;

/**
 *  connect special one
 */
- (void)connectDevice:(CBPeripheral *)peripheral;

/**
 *  disconnect manual
 */
- (void)disconnectRootPeripheral;

/**
 *  send command
 */
- (void)writeCommandWithData:(NSData *)data;

/**
 *  send command data with receicve callback
 */
- (void)writeCommandWithData:(NSData *)data receiveCallBack:(TSCBLEManagerReceiveCallBackBlock)receiveBlock;

/**
 *  send command data with write callback
 */
- (void)writeCommandWithData:(NSData *)data writeCallBack:(TSCBLEManagerWriteCallBackBlock)writeBlock;

/**
 *  get copyright
 */
+ (NSString *)GetCopyRight;

/**
 * printer status
 */
- (void)printerStatus:(TSCBLEPrinterStatusBlock)statusBlock;

@end
