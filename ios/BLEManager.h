

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class BLEManager;

//扫描发现设备回调
typedef void (^BleManagerDiscoverPeripheralCallBack) (NSArray *peripherals);
typedef void (^BleManagerConnectPeripheralCallBack) (BOOL isConnected);
typedef void (^BleManagerReceiveCallBack) (CBCharacteristic *characteristic );


/**
Define the proxy BLEManagerDelegate
 */
@protocol BLEManagerDelegate <NSObject>
/// Discovery of peripherals
/// @param BLEmanager Bluetooth management object
/// @param peripherals array of peripherals
/// @param RSSIArr list of printers' rssi
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager updatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)RSSIArr;
/// connection succeeded
/// @param BLEmanager Bluetooth management object
/// @param peripheral peripheral
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager connectPeripheral:(CBPeripheral *)peripheral;
/// Disconnect
/// @param BLEmanager Bluetooth management object
/// @param peripheral peripheral
/// @param isAutoDisconnect Whether to automatically disconnect
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager disconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect;
/// Failed to connect to device
/// @param BLEmanager Bluetooth management object
/// @param peripheral peripheral
/// @param error error
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
// 收到数据
//- (void)BLEManagerDelegate:(BLEManager *)BLEmanager didReceiveDataFromPrinter:(CBCharacteristic *)characteristic;

/// Send data successfully
/// @param BLEmanager Bluetooth management object
/// @param character characters of bluetooth device
/// @param error error
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager didWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error;
@end


@interface BLEManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCharacteristic *write_characteristic;
    CBCharacteristic *read_characteristic;
    int commandSendMode; //命令发送模式 0:立即发送 1：批量发送
}

#pragma mark -

@property (nonatomic,assign) id<BLEManagerDelegate> delegate;

#pragma mark 基本属性

@property (strong, nonatomic) CBCentralManager *manager;        //BLE 管理中心

@property (strong, nonatomic) CBPeripheral     *peripheral;     //外设-蓝牙硬件

@property (nonatomic,assign ) BOOL             isConnected;   //连接成功= yes，失败=no

@property (nonatomic,assign ) BOOL             isAutoDisconnect;     //是否自动连接，是=yes，不=no

@property (atomic,assign    ) BOOL           connectStatu;// 蓝牙连接状态

@property (strong, nonatomic  ) NSMutableArray        *peripherals;// 发现的所有 硬件设备

@property (strong, nonatomic) NSMutableArray *connectedPeripherals;//连接过的Peripherals

@property (strong, nonatomic) NSMutableArray *RSSIArray;// 蓝牙信号数组

@property (assign, readonly) BOOL isScaning; //是否正在扫描 是=yes，没有=no

// Send data to the specified peripheral
@property (nonatomic,strong) CBPeripheral *writePeripheral;
/// Peripheral device scan callback
@property (copy, nonatomic) BleManagerDiscoverPeripheralCallBack scanBlock;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *commandBuffer;
/// Connect Bluetooth callback
@property (copy, nonatomic) BleManagerConnectPeripheralCallBack connectBlock;
/// Receive data callback
@property (nonatomic,copy) BleManagerReceiveCallBack receiveBlock;
#pragma mark -
#pragma mark 基本方法
/**
 *  Singleton method
 *
 *  @return self
 */
+ (instancetype)sharedBLEManager;

/*
 *  Get mobile phone Bluetooth status
 */
- (BOOL)isLECapableHardware;

/**
 *  Turn on Bluetooth scanning
 */
- (void)startScan;

/*
 *  Start scanning and stop after scanInterval seconds
 */
- (void)startScanWithInterval:(NSInteger)scanInterval completion:(BleManagerDiscoverPeripheralCallBack)callBack;

/**
 *  Stop scanning
 */
- (void)stopScan;

/**
 *  Connect to specified device
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral;

/*
 *  Connect Bluetooth device
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral completion:(BleManagerConnectPeripheralCallBack)callBack;

/*
 *  Try to reconnect
 */
- (void)reConnectPeripheral:(CBPeripheral *)peripheral;

/**
 *  Disconnect the specified peripheral
 */
- (void)disconnectPeripheral:(CBPeripheral *)peripheral;


#pragma mark -
#pragma mark 自定义其他属性
/**
 *  向设备写入数据
 *
 *  @param dataArray 需要写入的数据
 *  @param command   命令值，1=消息提醒， 2=跑步目标， 3=跑步完成目标时的灯光提醒， 4=设置低电量灯光提醒， 5=设置灯光常开颜色， 6=灯光常开时间， 7=灯光常开模式， 8=设置设备时间
 */
//- (void)writeDataToDevice:(NSArray *)dataArray command:(int)command;

/**
 Send data to the device, the data sent is of type NSString, and the encoding type must be specified
 @param peripheral peripheral
 @param dataString Data sent
 @param EncodingType EncodingType
 */
-(void)sendDataWithPeripheral:(CBPeripheral *)peripheral withString:(NSString *)dataString coding:(NSStringEncoding)EncodingType;

/**
 Send instructions to the printer
 @param data Command sent
 */
-(void)writeCommadnToPrinterWthitData:(NSData *)data;

/**
 Send instructions to the printer with callback method
 @param data Data sent
 @param block CallBack
 */
-(void)writeCommadnToPrinterWthitData:(NSData  *)data withResponse:(BleManagerReceiveCallBack)block;


//Disconnect rescan of existing devices
-(void)reScan;
//Disconnect current device
-(void)disconnectRootPeripheral;


-(NSArray*)GetBuffer;
/**
 * 33.Clear buffer contents
 */
-(void)ClearBuffer;
/**
 * 34.Send buffer command
 */
-(void)SendCommandBuffer;
/**
 * 34.Send a single command
 * @param data 发送的数据
 */
-(void)sendCommand:(NSData *)data;

/// Set command mode
/// @param Mode mode
- (void)PosSetCommandMode:(int)Mode;
@end

