
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
typedef void(^POSCompletionBlock)(CBCharacteristic *character);
typedef void(^TSCCompletionBlock)(CBCharacteristic *datcharacter);
@protocol POSBLEManagerDelegate <NSObject>
/// Discover the surroundings
/// @param peripherals Device array
/// @param rssiList Signal strength array
- (void)POSdidUpdatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)rssiList;
/// 连接成功
/// @param peripheral Device Information
- (void)POSdidConnectPeripheral:(CBPeripheral *)peripheral;
/// 连接失败
/// @param peripheral Device Information
/// @param error Error
- (void)POSdidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
/// 断开连接
/// @param peripheral Device Information
/// @param isAutoDisconnect Auto disconnect
- (void)POSdidDisconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect;
/// 发送数据成功
/// @param character character
/// @param error Error
- (void)POSdidWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error;

@end

@interface POSBLEManager : NSObject
{
        int commandSendMode; //命令发送模式 0:立即发送 1：批量发送
        /**
         *  指定写入数据的编码方式 utf8等
         */
        NSStringEncoding encodingType;

}
@property (nonatomic,assign) id<POSBLEManagerDelegate> delegate;
/**
 *  Specify the peripheral to write data
 */
@property (nonatomic,strong) CBPeripheral *writePeripheral;


#pragma mark - 基本方法
/**
 *  Singleton method
 *
 *  @return self
 */
+ (instancetype)sharedInstance;
/**
 *  Start scanning
 */
- (void)POSstartScan;
/**
 *  Stop scanning
 */
- (void)POSstopScan;
/**
 *  Connect to designated equipment
 */
- (void)POSconnectDevice:(CBPeripheral *) peripheral;
/**
 *  Manually disconnect the connected device
 */
-(void)POSdisconnectRootPeripheral;

/**
 * Write print data
 * @param peripheral Device Information
 * @param dataStr Input string
 */
- (void)POSsendDataToPeripheral:(CBPeripheral *)peripheral dataString:(NSString *)dataStr ;

/// A unified method of sending instructions, through the instruction tool class, get the complete instruction, and then send
/// @param data Data sent
-(void)POSWriteCommandWithData:(NSData *)data;

/// send data
/// @param data data
/// @param block callback
-(void)POSWriteCommandWithData:(NSData *)data callBack:(TSCCompletionBlock)block;



- (void)POSSetCommandMode:(BOOL)Mode;
/* 33.Return batch print buffer command
 */
-(NSArray*)POSGetBuffer;

/* 34.Clear the contents of the print buffer
 */
-(void)POSClearBuffer;

/* 35.Batch send print buffer command
 */
-(void)POSSendCommandBuffer;

/* 36.Set command data encoding method
 */
-(void)POSSetDataCodingType:(NSStringEncoding) codingType;


@end
