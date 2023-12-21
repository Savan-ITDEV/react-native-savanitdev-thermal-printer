
#import "BLEManager.h"
#import <UIKit/UIKit.h>

static BLEManager *shareManager = nil;

@implementation BLEManager

#pragma mark -
#pragma mark 基本方法
/**
 * Singleton method
 *
 * @return self
 */
+ (instancetype)sharedBLEManager {
    if (shareManager == nil) {
        shareManager = [[super allocWithZone:NULL] init];
    }
    return shareManager;
}


- (instancetype)init {
    self = [super init];
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _manager.delegate = self;
    _dataArray = [NSMutableArray array];
    _isAutoDisconnect = YES;
    _commandBuffer=[[NSMutableArray alloc]init];
    return self;
}

#pragma mark 获取手机蓝牙状态
- (BOOL)isLECapableHardware {
    NSString * state = nil;
    
    int iState = (int)[_manager state];
    
    NSLog(@"Central manager state: %i", iState);
    
    switch ([_manager state]) {
        case CBCentralManagerStateUnsupported://不支持
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized://未授权
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff://蓝牙关闭
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn://蓝牙打开
            return TRUE;
        case CBCentralManagerStateUnknown://未知状态
        default:
            return FALSE;
            
    }
    
    NSLog(@"Central manager state: %@", state);
    
    return FALSE;
}

#pragma mark 开启蓝牙扫描-(可针对性扫描)
- (void)startScan {
    if ([self isLECapableHardware]) {
        
        if (_peripherals) {
            [_peripherals removeAllObjects];
            [_RSSIArray removeAllObjects];
        } else {
            _peripherals = [NSMutableArray array];
            _RSSIArray = [NSMutableArray array];
        }
        _isScaning = YES;
        
        BOOL result = [self checkConnectedPeripherals];
        
        if (result) {
            return;
        }
        
        [_manager scanForPeripheralsWithServices:nil options:nil];
        
        // 针对性扫描  serviceUUIDs = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]]
        // 其中  180D 就是对外公开的 1 级 服务UUID
//        [_manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"6E40FFA0-B5A3-F393-E0A9-E50E24DCCA9E"]] options:nil];
        
    } else {
        
        if (self.scanBlock) {
            self.scanBlock(_peripherals);
            self.scanBlock(nil);
        }
    }
}
#pragma mark - 检查已与手机连接的设备
/// Check connected devices
-(BOOL)checkConnectedPeripherals
{
    NSArray *arr = [_manager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"18F0"]]];
    for (CBPeripheral *per in arr) {
       // if ([per.name isEqualToString:@"Printer001"]) {
            [self connectPeripheral:per];
            return YES;
       // }
        
    }
    return NO;
}
#pragma mark 开始扫描并在scanInterval秒后停止
/// Start scanning and stop after scanInterval seconds
/// @param scanInterval scanInterval
/// @param callBack callBack
- (void)startScanWithInterval:(NSInteger)scanInterval completion:(BleManagerDiscoverPeripheralCallBack)callBack {
    self.scanBlock = callBack;
    [self startScan];
    [self performSelector:@selector(stopScan) withObject:nil afterDelay:scanInterval];
}

#pragma mark 停止扫描
/// stopScan
- (void)stopScan {
    _isScaning = NO;
    [_manager stopScan];
    
    if (self.scanBlock) {
        self.scanBlock(_peripherals);
        self.scanBlock(nil);
    }
}

#pragma mark 连接到指定设备
/// Connect to the specified device
/// @param peripheral peripheral
- (void)connectPeripheral:(CBPeripheral *)peripheral {
    [_manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    _peripheral = peripheral;
    if (_writePeripheral == nil) {
        _writePeripheral = peripheral;
    }
}

#pragma mark 连接蓝牙设备
/// Connect bluetooth device
/// @param peripheral Peripheral
/// @param callBack CallBack
- (void)connectPeripheral:(CBPeripheral *)peripheral completion:(BleManagerConnectPeripheralCallBack)callBack {
    self.connectBlock = callBack;
    [self connectPeripheral:peripheral];
    [self performSelector:@selector(connectTimeOutAction) withObject:nil afterDelay:5.0];
}

#pragma mark 尝试重新连接
/// Reconnect device
/// @param peripheral Peripheral
- (void)reConnectPeripheral:(CBPeripheral *)peripheral {
    [_manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
}

#pragma mark 断开连接
/// Disconnect device
/// @param peripheral peripheral
- (void)disconnectPeripheral:(CBPeripheral *)peripheral {
    _isConnected = NO;
    _isAutoDisconnect = YES;
    [_manager cancelPeripheralConnection:peripheral];

}

#pragma mark -
#pragma mark BLE 管理中心的代理方法
#pragma mark -
/*
 *Invoked whenever the central manager's state is updated.
 */
#pragma mark 设备蓝牙状态发生改变
/// Device Bluetooth status has changed
/// @param central Central Management Object
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([self isLECapableHardware]) {
        if (_peripheral) {
            [self reConnectPeripheral:_peripheral];
        } else {
            [self startScan];
        }
        
    } else {
        NSLog(@"手机蓝牙已关闭");
    }
    
}

/*
 *Invoked when the central discovers heart rate peripheral while scanning.
 *发现蓝牙设备
 */
#pragma mark 发现蓝牙设备
/// Discover Bluetooth devices
/// @param central Central Management Object
/// @param aPeripheral Device Information
/// @param advertisementData Broadcast data
/// @param RSSI Signal strength
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSArray *serviceUUIDs = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    NSLog(@"aPeripheral========%@",aPeripheral.identifier.UUIDString);
    NSLog(@"APeripheralName==========%@",serviceUUIDs);
    NSLog(@"advertisementData ======= %@",advertisementData);
    NSLog(@">>> %@",aPeripheral.services);
    // 针对性的发现设备
    BOOL isExist = NO;
    for (int i = 0; i < serviceUUIDs.count; i++) {
        NSString *uuid = [serviceUUIDs[i] UUIDString];
        if ([uuid isEqualToString:@"18F0"]) {//便携打印机为FFF0
            isExist = YES;
            break;
        }
    }
    if ([aPeripheral.identifier.UUIDString isEqualToString:@"49535343-FE7D-4AE5-8FA9-9FAFD205E455"]) {//@"49535343-FE7D-4AE5-8FA9-9FAFD205E455"
        NSLog(@"进入此方法");
        isExist = YES;
    }
    if (isExist) {
        //添加蓝牙对象到peripherals
        [_peripherals addObject:aPeripheral];
        [_RSSIArray addObject:RSSI];
        
        if ([self.delegate respondsToSelector:@selector(BLEManagerDelegate:updatePeripheralList:RSSIList:)]) {
            [self.delegate BLEManagerDelegate:self updatePeripheralList:_peripherals RSSIList:_RSSIArray];
        }
        
    }
    
//    //-------------------------------------------------------
//    //发现所有的设备---打开注释就好
//    [_peripherals addObject:aPeripheral];
//    [_RSSIArray addObject:RSSI];
//    
//    self.scanBlock(_peripherals);
//    [[NSNotificationCenter defaultCenter] postNotificationName:kBlueToothDisCoverPeripheral object:nil];
}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 Automatically connect to first known peripheral
 */
#pragma mark 当中央管理器调用检索列表中已知的外围设备。自动连接到第一个已知的外围
/// When the central manager is called to retrieve the known peripherals in the list. Automatically connect to the first known peripheral
/// @param central Central manager
/// @param peripherals Device Information
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    
    if([_peripherals count] >= 1) {
        _peripheral = [peripherals objectAtIndex:0];
//        NSLog(@"当中央管理器调用检索列表中已知的外围设备。自动连接到第一个已知的外围........此设备名为==%@",_peripheral.name);
        [_manager connectPeripheral:_peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}

/*
 *Invoked whenever a connection is succesfully created with the peripheral.
 *Discover available services on the peripheral
 *已连接到设备
 */
#pragma mark 已连接到设备-----每当调用是成功创建连接外围。外围发现可用的服务
/// Connected to the device-----every time the call is successfully created to connect to the peripheral. Peripheral discovery of available services
/// @param central Central manager
/// @param aPeripheral Device Information
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral {
    NSLog(@"蓝牙连接成功");
    
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
    _isConnected = YES;
    if (self.connectBlock) {
        self.connectBlock(YES);
        self.connectBlock = nil;
    }
    
    [self stopScan];
}

/*
 *Invoked whenever an existing connection with the peripheral is torn down.
 *Reset local variables
 */
#pragma mark 设备已经断开
/// Device is disconnected
/// @param central Central manager
/// @param aPeripheral Device Information
/// @param error wrong description
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    if(_peripheral )
    {
        [_peripheral setDelegate:nil];
        _peripheral = nil;

    }else {

    }
    _isConnected = NO;
//    if (_isAutoDisconnect == NO) {
//        //断开n秒计时
////        [self performSelector:@selector(disconnectTimerAction) withObject:nil afterDelay:0.0];
//    } else {
////        [self connectPeripheral:aPeripheral];
//        [[[UIAlertView alloc] initWithTitle:@"device disconnect" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//    }
    
    if (self.connectBlock) {
        self.connectBlock(NO);
        self.connectBlock = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(BLEManagerDelegate:disconnectPeripheral:isAutoDisconnect:)]) {
        [self.delegate BLEManagerDelegate:self disconnectPeripheral:aPeripheral isAutoDisconnect:_isAutoDisconnect];
    }
    _isAutoDisconnect = YES;
//    [[NSNotificationCenter defaultCenter]  postNotificationName:kBlueToothDisConnect object:aPeripheral];
}

/*
 *Invoked whenever the central manager fails to create a connection with the peripheral.
 *连接设备失败
 */
#pragma mark 连接设备失败
/// Failed to connect to device
/// @param central Central manager
/// @param aPeripheral Device Information
/// @param error wrong description
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error {
    
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    if(_peripheral) {
        [_peripheral setDelegate:nil];
        _peripheral = nil;
    }

    // -- 可以做其他处理
    if ([self.delegate respondsToSelector:@selector(BLEManagerDelegate:didFailToConnectPeripheral:error:)]) {
        [self.delegate BLEManagerDelegate:self didFailToConnectPeripheral:aPeripheral error:error];
    }
}

#pragma mark -
#pragma mark -外设 的代理方法
#pragma mark -
/*
 *Invoked upon completion of a -[discoverServices:] request.
 *Discover available characteristics on interested services
 *发现服务
 */
#pragma mark 发现服务
/// Discovery Service
/// @param aPeripheral Device Information
/// @param error wrong description
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in aPeripheral.services) {
//        NSLog(@"Service found with UUID : %@", aService.UUID);
        [aPeripheral discoverCharacteristics:nil forService:aService];
    }
}

/*
 *Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 *Perform appropriate operations on interested characteristics
 *发现服务特征值
 */
#pragma mark 发现服务特征值
/// Discovery of service characteristic values
/// @param aPeripheral Device Information
/// @param service 服务
/// @param error wrong description
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
//    NSLog(@"Service : %@", service.UUID);
//    NSLog(@"includedServices :%@",service.includedServices);
//    NSLog(@"characteristics :%@",service.characteristics);
    if (service.isPrimary) {
//        NSLog(@"service.isPrimary : %@", service.UUID);
    }
    
    //-------------------------------------------------------
    //此处对服务UUID 进行 一对一 匹配，然后再遍历 其特征值，再对需要用到的特征UUID 进行一对一匹配
//
    NSLog(@"%s%@",__func__,service.UUID);
    if ([service.UUID isEqual: [CBUUID UUIDWithString:@"18F0"]])//便携打印机使用这个uuid：49535343-FE7D-4AE5-8FA9-9FAFD205E455
    {
        write_characteristic = nil;
        read_characteristic = nil;
        NSLog(@"jsjsjssjsjsjs");
        for (CBCharacteristic *aChar in service.characteristics)
        {
            
            NSLog(@"jsjsjsjsjsskkk======%@",aChar);
            const CBCharacteristicProperties properties = [aChar properties];
            
            // 消息通知类型的特征值
            if (CBCharacteristicPropertyNotify && properties) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            
            // write 特征值
            if ((CBCharacteristicPropertyWrite && properties) || (CBCharacteristicPropertyWriteWithoutResponse && properties)) {
                write_characteristic = aChar;
                [aPeripheral readValueForCharacteristic:aChar];
                 NSLog(@"Power Characteristic : %@", aChar.UUID);
            }
            
            // read 特征值
            if (CBCharacteristicPropertyRead && properties) {
                read_characteristic = aChar;
                [aPeripheral readValueForCharacteristic:aChar];
            }
            
//            NSLog(@"aChar.UUID==:%@",aChar.UUID);
//            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"49535343-8841-43F4-A8D4-ECBE34729BB3"]]) {
//                // 匹配成功后：
//                //广播
//                [_peripheral setNotifyValue:YES forCharacteristic:aChar];
//                write_characteristic = aChar;
//                [aPeripheral readValueForCharacteristic:aChar];
//                NSLog(@"Power Characteristic : %@", aChar.UUID);
//                //-------------------------------------------------------
//                //此处可以对特征值进行保存
//            }
//            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"49535343-1E4D-4BD9-BA61-23C647249616"]]) {
//                // 匹配成功后：
//                //广播
//                [_peripheral setNotifyValue:YES forCharacteristic:aChar];
//                read_characteristic = aChar;
//                [aPeripheral readValueForCharacteristic:aChar];
//
//                NSLog(@"Power Characteristic : %@", aChar.UUID);
//                //-------------------------------------------------------
//                //此处可以对特征值进行保存
//            }
        }
        
    }
}

/**
 * -->描述：获取蓝牙的信号强度
 */
#pragma mark 获取蓝牙的信号强度
/// 获取蓝牙的信号强度
/// @param peripheral Device Information
/// @param error wrong description
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
   // NSLog(@"RSSI:%i", [[peripheral RSSI] intValue]);
    int rssi;
    rssi=[[peripheral RSSI] intValue];
    NSString *fid;
    fid= peripheral.identifier.UUIDString;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLE-RSSI-信号强度通知-Name" object:[NSString stringWithFormat:@"%@,%i",fid,rssi]];
}

/*
 *Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 *收到数据
 */

#pragma mark -收到数据
/// 收到数据
/// @param aPeripheral Device Information
/// @param characteristic characteristic
/// @param error wrong description
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"error = %@",error);
//        [[[UIAlertView alloc] initWithTitle:@"获取数据失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
    }else {
        
        NSLog(@"didUpdateValue :%@",characteristic.value);
        NSLog(@" ******* didUpdateValue--UUID :%@",characteristic.UUID);
        NSData *data = characteristic.value;
        
        if (data == nil || [data isKindOfClass:[NSNull class]] || [data isEqual:@""]) {
            return;
        }
        if (data) {
            
            // 收到数据Callback
            if (self.receiveBlock!=nil) {
                self.receiveBlock(characteristic);
            }
            
            [_dataArray addObject:[NSString stringWithFormat:@"收到:%@",data]];
        }
        if (_dataArray.count > 1000) {
            [_dataArray removeObjectAtIndex:0];
        }
        
        
        //-------------------------------------------------------
        //对接收到的数据进行处理
    }

}

/*
 *写数据成功
 */
#pragma mark 写入数据成功会进入此方法
/// 写入数据成功
/// @param peripheral Device Information
/// @param characteristic characteristic
/// @param error wrong description
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if ([self.delegate respondsToSelector:@selector(BLEManagerDelegate:didWriteValueForCharacteristic:error:)]) {
        [self.delegate BLEManagerDelegate:self didWriteValueForCharacteristic:characteristic error:error];
    }
    
    if (error)
    {
        NSLog(@"写入数据失败---Failed to write value for characteristic %@, reason: %@", characteristic, error);
    }
    else
    {
        NSLog(@"写入数据成功---Did write value for characterstic %@, new value: %@", characteristic, [characteristic value]);
        NSLog(@">>> %@",[[characteristic value] description]);
//        if ([[[characteristic value] description] isEqualToString:@"<440a0101>"]) {
//            [self disconnectPeripheral:_peripheral];
//        }
        
    }
}

#pragma mark -
#pragma mark -其他自定义的方法
#pragma mark -

/**
 *  Connection timed out
 */
- (void)connectTimeOutAction {
    if (!self.isConnected) {
        if (self.connectBlock) {
            self.connectBlock(NO);
            self.connectBlock = nil;
        }
    }
}

/*
 *Confirm disconnection after disconnecting timing
 */
- (void)disconnectTimerAction {
    if (!_isConnected) {  //确认是否断开
        NSLog(@"蓝牙已断开连接");
        [[[UIAlertView alloc] initWithTitle:@"device disconnect" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        _isAutoDisconnect = NO;
    }
}

#pragma mark 发送数据方法
/// send data
/// @param peripheral Device Information
/// @param dataString Data sent
/// @param EncodingType EncodingType
-(void)sendDataWithPeripheral:(CBPeripheral *)peripheral withString:(NSString *)dataString coding:(NSStringEncoding)EncodingType
{
    _writePeripheral = peripheral;
    NSData *data;
    data = [dataString dataUsingEncoding:EncodingType];
    
    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
    if (commandSendMode==0)
    {
        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
    }
    else
    {
        NSDictionary *dict;

        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
        [_commandBuffer addObject:dict];
    }
    if (data) {
        [_dataArray addObject:[NSString stringWithFormat:@"写入:%@",data]];
    }

}

/// Send command, recommended
/// @param data Data sent
-(void)writeCommadnToPrinterWthitData:(NSData *)data{
    
    if (commandSendMode==0)
    {
        //数据分包
        int BLE_SEND_MAX_LEN=20;
        NSData *sendData=[NSData data];
        for (int i=0; i<[data length]; i+=BLE_SEND_MAX_LEN)
        {
            if((i+BLE_SEND_MAX_LEN)<[data length]){
                
                NSRange range=NSMakeRange(i, BLE_SEND_MAX_LEN);
                //NSString *rangeStr=[NSString stringWithFormat:@"%i%i",i,i+BLE_SEND_MAX_LEN];
                NSData *subdata=[data subdataWithRange:range];
                sendData=subdata;
                //NSLog(@"---->-->---%i--%@",i,subdata);
                
            }else{
                NSRange range=NSMakeRange(i, (int)([data length]-i));
                //NSString *rangeStr=[NSString stringWithFormat:@"%i,@%i",i,(int)([data length]-i)];
                NSData *subdata=[data subdataWithRange:range];
                sendData=subdata;
               // NSLog(@"--------ss%@",subdata);
            }
            [_writePeripheral writeValue:sendData forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
            
        }
        
        
        
    }
    else
    {
        NSDictionary *dict;
        
        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
        [_commandBuffer addObject:dict];
    }
    
}
///Send instruction method with Callback, recommended
/// @param data Data sent
/// @param block Callback
-(void)writeCommadnToPrinterWthitData:(NSData *)data withResponse:(BleManagerReceiveCallBack)block{
    self.receiveBlock = block;
    if (commandSendMode==0)
    {
        //数据分包
        int BLE_SEND_MAX_LEN=20;
        NSData *sendData=[NSData data];
        for (int i=0; i<[data length]; i+=BLE_SEND_MAX_LEN)
        {
            if((i+BLE_SEND_MAX_LEN)<[data length]){
                
                NSRange range=NSMakeRange(i, BLE_SEND_MAX_LEN);
                //NSString *rangeStr=[NSString stringWithFormat:@"%i%i",i,i+BLE_SEND_MAX_LEN];
                NSData *subdata=[data subdataWithRange:range];
                sendData=subdata;
                //NSLog(@"---->-->---%i--%@",i,subdata);
                
            }else{
                NSRange range=NSMakeRange(i, (int)([data length]-i));
                //NSString *rangeStr=[NSString stringWithFormat:@"%i,@%i",i,(int)([data length]-i)];
                NSData *subdata=[data subdataWithRange:range];
                sendData=subdata;
                // NSLog(@"--------ss%@",subdata);
            }
            [_writePeripheral writeValue:sendData forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
            
        }
        
        
        
    }
    else
    {
        NSDictionary *dict;
        
        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
        [_commandBuffer addObject:dict];
    }
    
    
}




/// 再次扫描
-(void)reScan
{
    [self stopScan];
    [_peripherals removeAllObjects];
    if (_isConnected) {
        
        [self disconnectPeripheral:_peripheral];
    }
    else
    {
        [self startScan];
    }
}
/// 再次扫描前断开连接
-(void)disconnectForReScan
{
    [self startScan];
}

/// 断开设备
-(void)disconnectRootPeripheral
{
    if (![_peripheral isKindOfClass:[CBPeripheral class]]) {
        return;
    }
    [_manager cancelPeripheralConnection:_peripheral];
    _isConnected = NO;
    _isAutoDisconnect = NO;
}

- (void)writeTSCWith:(NSString *)str {
    str = [str stringByAppendingString:@"\r\n"];
    NSData *data = [str dataUsingEncoding:NSASCIIStringEncoding];
    if (commandSendMode==0)
    {
        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
    }
    else
    {
        NSDictionary *dict;
        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
        [_commandBuffer addObject:dict];
    }
    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
}

-(NSArray*)GetBuffer
{
    NSMutableArray *commandBufferFilter;
    commandBufferFilter=[[NSMutableArray alloc]init];
    for (int t=0;t<[_commandBuffer count];t++)
    {
        NSDictionary *dict;
        CBPeripheral *dictPeripheral;
        NSData *data;
        dict=[_commandBuffer objectAtIndex:t];
        dictPeripheral=[dict objectForKey:@"writePeripheral"];
        //if (dictPeripheral == aPeripheral)
        {
            data=[dict objectForKey:@"data"];
            [commandBufferFilter addObject:data];
        }
    }

    return [commandBufferFilter copy ];
}

-(void)ClearBuffer
{
    [_commandBuffer removeAllObjects];
}

-(void)sendCommand:(NSData *)data
{

    [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];


}

-(void)SendCommandBuffer
{
    float timeInterver=0.5;
    
    for (int t=0;t<[_commandBuffer count];t++)
    {
        NSDictionary *dict;
        CBPeripheral *dictPeripheral;
        NSData *data;
        dict=[_commandBuffer objectAtIndex:t];
        data=[dict objectForKey:@"data"];
        [self performSelector:@selector(sendCommand:) withObject:data afterDelay:timeInterver];
        timeInterver=timeInterver+0.2;
    }
}

- (void)PosSetCommandMode:(int)Mode{
    commandSendMode=Mode;
}
@end
