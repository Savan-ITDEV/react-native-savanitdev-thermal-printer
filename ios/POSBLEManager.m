
#import "POSBLEManager.h"
#import "BLEManager.h"

static POSBLEManager *shareInstance = nil;

@interface POSBLEManager ()<BLEManagerDelegate>
@property (nonatomic,strong) BLEManager *manager;
@end

@implementation POSBLEManager
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[POSBLEManager alloc] init];
    });
    return shareInstance;
}

- (instancetype)init {
    if (self == [super init]) {
        _manager = [BLEManager sharedBLEManager];
        _manager.delegate = self;
 
    }
    return self;
}
- (void)setWritePeripheral:(CBPeripheral *)writePeripheral {
    _writePeripheral = writePeripheral;
    _manager.writePeripheral = writePeripheral;
}
#pragma mark - 开始扫描
- (void)POSstartScan {
    [_manager startScan];
}

#pragma mark - 停止扫描
- (void)POSstopScan {
    [_manager stopScan]; 
}

#pragma mark - 手动断开现连设备 不会重连
- (void)POSdisconnectRootPeripheral {
    [_manager disconnectRootPeripheral];
}

#pragma mark - 发送数据
- (void)POSsendDataToPeripheral:(CBPeripheral *)peripheral dataString:(NSString *)dataStr {
    [_manager sendDataWithPeripheral:peripheral withString:dataStr coding:encodingType];
}


//发送指令的方法
-(void)POSWriteCommandWithData:(NSData *)data{

    [_manager writeCommadnToPrinterWthitData:data];
}
//发送指令，并带回调的方法
-(void)POSWriteCommandWithData:(NSData *)data callBack:(TSCCompletionBlock)block{

    [_manager writeCommadnToPrinterWthitData:data withResponse:^(CBCharacteristic *characteristic) {
        block(characteristic);
    }];
}
#pragma mark - 发送TSC指令
//- (void)PosWriteTSCCommondWithData:(NSData *)data callBack:(PosTSCCompletionBlock)block {
//    [_manager writeTSCCommndWithData:data withResponse:^(CBCharacteristic *characteristic) {
//        block(characteristic);
//    }];
//}
//#pragma mark - 发送POS指令
//- (void)PosWritePOSCommondWithData:(NSData *)data callBack:(PosTSCCompletionBlock)block {
//    [_manager writePOSCommndWithData:data withResponse:^(CBCharacteristic *characteristic) {
//        block(characteristic);
//    }];
//}
#pragma mark - 连接指定设备
- (void)POSconnectDevice:(CBPeripheral *)peripheral {
    [_manager connectPeripheral:peripheral completion:^(BOOL isConnected) {
        if (isConnected) {
            if ([self.delegate respondsToSelector:@selector(POSdidConnectPeripheral:)]) {
                [self.delegate POSdidConnectPeripheral:peripheral];
            }
        }else {
            if ([self.delegate respondsToSelector:@selector(POSdidFailToConnectPeripheral:error:)]) {
                [self.delegate POSdidFailToConnectPeripheral:peripheral error:NULL];
            }
        }
    }];
}

#pragma mark - BLEManagerDelegate
/**
 *  扫描到设备后
 */
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager updatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)RSSIArr{
    if ([self.delegate respondsToSelector:@selector(POSdidUpdatePeripheralList:RSSIList:)]) {
        [self.delegate POSdidUpdatePeripheralList:peripherals RSSIList:RSSIArr];
    }
}
/**
 *  连接上设备
 */
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager connectPeripheral:(CBPeripheral *)peripheral {
    
    //    if ([self.delegate respondsToSelector:@selector(didConnectPeripheral:)]) {
    //        [self.delegate didConnectPeripheral:peripheral];
    //    }
}

/**
 *  断开设备
 */
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager disconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect{
    if ([self.delegate respondsToSelector:@selector(POSdidDisconnectPeripheral:isAutoDisconnect:)]) {
        [self.delegate POSdidDisconnectPeripheral:peripheral isAutoDisconnect:isAutoDisconnect];
    }
}

- (void)BLEManagerDelegate:(BLEManager *)BLEmanager didWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(POSdidWriteValueForCharacteristic:error:)]) {
        [self.delegate POSdidWriteValueForCharacteristic:character error:error];
    }
}

- (void)BLEManagerDelegate:(BLEManager *)BLEmanager didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(POSdidFailToConnectPeripheral:error:)]) {
        [self.delegate POSdidFailToConnectPeripheral:peripheral error:error];
    }
}

-(NSArray*)POSGetBuffer
{
    return [_manager GetBuffer];
}

-(void)POSClearBuffer
{
    [_manager ClearBuffer];
}

-(void)sendCommand:(NSData *)data
{
    [_manager sendCommand:data];
    
}

-(void)POSSendCommandBuffer
{
    [_manager SendCommandBuffer];
    [self POSClearBuffer];
}


- (void)POSSetCommandMode:(BOOL)Mode{
    [_manager PosSetCommandMode:Mode];
}

-(void)POSSetDataCodingType:(NSStringEncoding) codingType
{
    encodingType=codingType;
}
@end
