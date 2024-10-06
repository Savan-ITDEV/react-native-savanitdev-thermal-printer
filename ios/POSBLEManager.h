//
//  POSBLEManager.h
//  Printer
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol POSBLEManagerDelegate <NSObject>

/**
 *  found peripheral list
 */
- (void)POSbleUpdatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)rssiList;
/**
 *  connect success
 */
- (void)POSbleConnectPeripheral:(CBPeripheral *)peripheral;
/**
 *  connect fail
 */
- (void)POSbleFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
/**
 *  disconnect
 */
- (void)POSbleDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
/**
 *  send data success
 */
- (void)POSbleWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error;
/**
 *  receive printer data
 */
- (void)POSbleReceiveValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
/**
 *  bleCentralManager state update
 */
- (void)POSbleCentralManagerDidUpdateState:(NSInteger)state;

@end

/****************************************************************************************************/

typedef void (^POSBLEManagerReceiveCallBackBlock)(CBCharacteristic *characteristic, NSError *error);
typedef void (^POSBLEManagerWriteCallBackBlock) (CBCharacteristic *characteristic, NSError *error);
typedef void (^POSBLEPrinterStatusBlock)(NSData *status);
typedef void (^POSBLEPrinterSNBlock)(NSString *sn);
typedef void (^POSBLEPrinterCheckBlock)(NSData *check);

/****************************************************************************************************/

@interface POSBLEManager : NSObject

// bt name
@property (nonatomic, copy) NSString *name;
// connect status
@property (nonatomic, assign) BOOL isConnecting;
// scan status
@property (nonatomic, assign) BOOL isScaning;
// peripheral write
@property (nonatomic, strong) CBPeripheral *writePeripheral;
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

@property (nonatomic, weak) id<POSBLEManagerDelegate> delegate;

@property (nonatomic, copy) POSBLEManagerReceiveCallBackBlock receiveBlock;
@property (nonatomic, copy) POSBLEManagerWriteCallBackBlock writeBlock;
@property (nonatomic, copy) POSBLEPrinterStatusBlock statusBlock;
@property (nonatomic, copy) POSBLEPrinterSNBlock snBlock;
@property (nonatomic, copy) POSBLEPrinterCheckBlock checkBlock;

/**
 *  singleton
 */
+ (instancetype)sharedInstance;

/**
 *  remove a delegate
 */
- (void)removeDelegate:(id<POSBLEManagerDelegate>)delegate;

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
 * send command data with receive callback
 */
- (void)writeCommandWithData:(NSData *)data receiveCallBack:(POSBLEManagerReceiveCallBackBlock)receiveBlock;

/**
 *  send command data with write callback
 */
- (void)writeCommandWithData:(NSData *)data writeCallBack:(POSBLEManagerWriteCallBackBlock)writeBlock;

/**
 * set bluetooth name and key
 */
- (void)setBluetoothNameAndKeyWith:(NSString *)btName btKey:(NSString *)btKey;

/**
 * check connect status
 */
- (BOOL)printerIsConnect;

/**
 * printer status
 * 查询当前打印机常用状态（正常/缺纸/开盖等）
 */
- (void)printerStatus:(POSBLEPrinterStatusBlock)statusBlock;

/**
 * printer check
 * 这个方法用于查询打印机所有状态
 * type = 1 打印机状态 type = 2 脱机状态 type = 3 错误状态 type = 4 传送纸状态
 */
- (void)printerCheck:(int)type checkBlock:(POSBLEPrinterCheckBlock)checkBlock;

/**
 * printer sn code
 */
- (void)printerSN:(POSBLEPrinterSNBlock)snBlock;

/**
 *  get copyright
 */
+ (NSString *)GetCopyRight;

@end
