//
//  BLEManage.m
//
//
//  Created by ding on 16/7/19.
//  Copyright © 2019年 ding. All rights reserved.
//

#import "BLEManager.h"
#import <UIKit/UIKit.h>

static BLEManager *shareManager = nil;

@implementation BLEManager

#pragma mark -
#pragma mark 基本方法
/**
 *  单例方法
 *
 *  @return self
 */
+ (instancetype)sharedBLEManager {
    if (shareManager == nil) {
        shareManager = [[super allocWithZone:NULL] init];
    }
    return shareManager;
}

// 初始化连接
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
    
//    int iState = (int)[_manager state];
    
//    NSLog(@"Central manager state: %i", iState);
    
    switch ([_manager state]) {
        case CBManagerStateUnsupported://不支持
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBManagerStateUnauthorized://未授权
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBManagerStatePoweredOff://蓝牙关闭
            state = @"Bluetooth is currently powered off.";
            break;
        case CBManagerStatePoweredOn://蓝牙打开
            return TRUE;
        case CBManagerStateUnknown://未知状态
        default:
            return FALSE;
            
    }
    
//    NSLog(@"Central manager state: %@", state);
    
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
-(BOOL)checkConnectedPeripherals
{
    NSArray *arr = [_manager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"18F0"]]];
    for (CBPeripheral *per in arr) {
       // if ([per.name isEqualToString:@"Printer001"]) {
            [self connectPeripheral:per];
            return YES;
       // }
        
    }
    arr = [_manager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFF0"]]];
    for (CBPeripheral *per in arr) {
        // if ([per.name isEqualToString:@"Printer001"]) {
        [self connectPeripheral:per];
        return YES;
        // }
    }
    return NO;
}
#pragma mark 开始扫描并在scanInterval秒后停止
- (void)startScanWithInterval:(NSInteger)scanInterval completion:(BleManagerDiscoverPeripheralCallBack)callBack {
    self.scanBlock = callBack;
    [self startScan];
    [self performSelector:@selector(stopScan) withObject:nil afterDelay:scanInterval];
}

#pragma mark 停止扫描
- (void)stopScan {
    _isScaning = NO;
    [_manager stopScan];
    if (self.scanBlock) {
        self.scanBlock(_peripherals);
        self.scanBlock(nil);
    }
}

#pragma mark 连接到指定设备
- (void)connectPeripheral:(CBPeripheral *)peripheral {
    [_manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    _peripheral = peripheral;
    if (_writePeripheral == nil) {
        _writePeripheral = peripheral;
    }
}

#pragma mark 连接蓝牙设备
- (void)connectPeripheral:(CBPeripheral *)peripheral completion:(BleManagerConnectPeripheralCallBack)callBack {
    self.connectBlock = callBack;
    [self connectPeripheral:peripheral];
    [self performSelector:@selector(connectTimeOutAction) withObject:nil afterDelay:5.0];
}

#pragma mark 尝试重新连接
- (void)reConnectPeripheral:(CBPeripheral *)peripheral {
    [_manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
}

#pragma mark 断开连接
- (void)disconnectPeripheral:(CBPeripheral *)peripheral {
    _isConnected = NO;
    _isAutoDisconnect = NO;
    [_manager cancelPeripheralConnection:peripheral];

}

#pragma mark -
#pragma mark BLE 管理中心的代理方法
#pragma mark -
/*
 *Invoked whenever the central manager's state is updated.
 *设备蓝牙状态发生改变
 */
#pragma mark 设备蓝牙状态发生改变
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([self isLECapableHardware]) {
        if (_peripheral) {
//            [self reConnectPeripheral:_peripheral];
        } else {
            [self startScan];
        }
        
    } else {
        NSLog(@"Bluetooth turned off");
    }
    
}

/*
 *Invoked when the central discovers heart rate peripheral while scanning.
 *发现蓝牙设备
 */
#pragma mark 发现蓝牙设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSArray *serviceUUIDs = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
//    NSLog(@"aPeripheral========%@",aPeripheral.identifier.UUIDString);
//    NSLog(@"APeripheralName==========%@",serviceUUIDs);
//    NSLog(@"advertisementData ======= %@",advertisementData);
//    NSLog(@">>> %@",aPeripheral.services);
    
    
   
    // 针对性的发现设备
    BOOL isExist = NO;
    for (int i = 0; i < serviceUUIDs.count; i++) {
        NSString *uuid = [serviceUUIDs[i] UUIDString];
        if ([uuid isEqualToString:@"18F0"]||[uuid isEqualToString:@"FFF0"]) {//便携打印机为FFF0
            if(![_peripherals containsObject:aPeripheral])
            isExist = YES;
            break;
        }
    }
//    if ([aPeripheral.identifier.UUIDString isEqualToString:@"49535343-FE7D-4AE5-8FA9-9FAFD205E455"]) {//@"49535343-FE7D-4AE5-8FA9-9FAFD205E455"
//        NSLog(@"进入此方法");
//        isExist = YES;
//    }
    if (isExist) {
    
        //添加蓝牙对象到peripherals
        [_peripherals addObject:aPeripheral];
        [_RSSIArray addObject:RSSI];
        if ([self.delegate respondsToSelector:@selector(BLEManagerDelegate:updatePeripheralList:RSSIList:)]) {
            [self.delegate BLEManagerDelegate:self updatePeripheralList:_peripherals RSSIList:_RSSIArray];
        }

    }
    
    //添加蓝牙对象到peripherals
    
//    [_peripherals addObject:aPeripheral];
//    [_RSSIArray addObject:RSSI];
//    if ([self.delegate respondsToSelector:@selector(BLEManagerDelegate:updatePeripheralList:RSSIList:)]) {
//        [self.delegate BLEManagerDelegate:self updatePeripheralList:_peripherals RSSIList:_RSSIArray];
//    }
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
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
//
//    if([_peripherals count] >= 1) {
//        _peripheral = [peripherals objectAtIndex:0];
////        NSLog(@"当中央管理器调用检索列表中已知的外围设备。自动连接到第一个已知的外围........此设备名为==%@",_peripheral.name);
//        [_manager connectPeripheral:_peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
//    }
}

/*
 *Invoked whenever a connection is succesfully created with the peripheral.
 *Discover available services on the peripheral
 *已连接到设备
 */
#pragma mark 已连接到设备-----每当调用是成功创建连接外围。外围发现可用的服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral {
    NSLog(@"蓝牙连接成功%@",aPeripheral.name);
    [aPeripheral setDelegate:self];
    //查找mac地址
//    [aPeripheral discoverServices:@[[CBUUID UUIDWithString:@"180A"]]];
    [aPeripheral discoverServices:nil];
    _isConnected = YES;
    
    if (self.connectBlock) {
        self.connectBlock(YES);
        self.connectBlock = nil;
    }
}
/*
 *Invoked whenever an existing connection with the peripheral is torn down.
 *Reset local variables
 *设备已经断开
 */
#pragma mark 设备已经断开
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
    _isAutoDisconnect = NO;
//    [[NSNotificationCenter defaultCenter]  postNotificationName:kBlueToothDisConnect object:aPeripheral];
}

/*
 *Invoked whenever the central manager fails to create a connection with the peripheral.
 *连接设备失败
 */
#pragma mark 连接设备失败
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
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
//    CBService *service = aPeripheral.services.firstObject;
//    [aPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"2A23"]] forService:service];
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
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
//    NSLog(@"Service : %@", service.UUID);
//    NSLog(@"includedServices :%@",service.includedServices);
//    NSLog(@"characteristics :%@",service.characteristics);
//    if (service.isPrimary) {
////        NSLog(@"service.isPrimary : %@", service.UUID);
//    }
    
    //-------------------------------------------------------
    //此处对服务UUID 进行 一对一 匹配，然后再遍历 其特征值，再对需要用到的特征UUID 进行一对一匹配
//
//    NSLog(@"%s%@",__func__,service.UUID);
    if ([service.UUID isEqual: [CBUUID UUIDWithString:@"18F0"]]||[service.UUID isEqual: [CBUUID UUIDWithString:@"FFF0"]])//便携打印机使用这个uuid：49535343-FE7D-4AE5-8FA9-9FAFD205E455
    {
        write_characteristic = nil;
        read_characteristic = nil;
        NSLog(@"获取特征值");
        for (CBCharacteristic *aChar in service.characteristics)
        {

            const CBCharacteristicProperties properties = [aChar properties];

            // 消息通知类型的特征值
            if (CBCharacteristicPropertyNotify && properties) {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }

            // write 特征值
            if ((CBCharacteristicPropertyWrite && properties) || (CBCharacteristicPropertyWriteWithoutResponse && properties)) {
                write_characteristic = aChar;
                [aPeripheral readValueForCharacteristic:aChar];
                 NSLog(@"write Power Characteristic : %@", aChar.UUID);
            }

            // read 特征值
            if (CBCharacteristicPropertyRead && properties) {
                read_characteristic = aChar;
//                [aPeripheral readValueForCharacteristic:aChar];
//                NSLog(@"read Power Characteristic : %@", aChar.UUID);
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
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"error = %@",error);
//        [[[UIAlertView alloc] initWithTitle:@"获取数据失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
    }else {
        NSString *value = [NSString stringWithFormat:@"%@",characteristic.value];
        NSMutableString *macString = [[NSMutableString alloc] init];
        [macString appendString:[[value substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
        NSLog(@"mac == %@",macString);
        NSLog(@"didUpdateValue :%@",characteristic.value);
        NSLog(@" ******* didUpdateValue--UUID :%@",characteristic.UUID);
        NSData *data = characteristic.value;
        
        if (data == nil || [data isKindOfClass:[NSNull class]] || [data isEqual:@""]) {
            return;
        }
        if (data) {
            
            // 收到数据回调
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
//        NSLog(@"写入数据成功---Did write value for characterstic %@, new value: %@", characteristic, [characteristic value]);
//        NSLog(@">>> %@",[[characteristic value] description]);
//        if ([[[characteristic value] description] isEqualToString:@"<440a0101>"]) {
//            [self disconnectPeripheral:_peripheral];
//        }
    }
}

#pragma mark -
#pragma mark -其他自定义的方法
#pragma mark -

/**
 *  连接超时
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
 *断开计时后确认断开
 */
- (void)disconnectTimerAction {
    if (!_isConnected) {  //确认是否断开
        NSLog(@"蓝牙已断开连接");
        [[[UIAlertView alloc] initWithTitle:@"device disconnect" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        _isAutoDisconnect = NO;
    }
}

#pragma mark 发送数据方法
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

//发送指令，推荐使用
-(void)writeCommadnToPrinterWthitData:(NSData *)data{
    if (commandSendMode==0)
    {
        NSLog(@"writeCommadnToPrinterWthitData");
        NSInteger oneTimeBytes = 20000;
        NSInteger count = [data length] / oneTimeBytes + 1;
        for (int i=0; i<count; i++) {
            if (i<count-1) {
                NSData* data1=[data subdataWithRange:NSMakeRange(i*oneTimeBytes, oneTimeBytes)];
                [_writePeripheral writeValue:data1 forCharacteristic:write_characteristic type:CBCharacteristicWriteWithoutResponse];
            }else{
                NSData* data2=[data subdataWithRange:NSMakeRange(i*oneTimeBytes, [data length]%oneTimeBytes)];
                [_writePeripheral writeValue:data2 forCharacteristic:write_characteristic type:CBCharacteristicWriteWithoutResponse];
            }
        }
////        NSLog(@"---->-->---%lu--%@",(unsigned long)[data length],data);
//        //数据分包
//        int BLE_SEND_MAX_LEN=20;
//        NSData *sendData=[NSData data];
//        for (int i=0; i<[data length]; i+=BLE_SEND_MAX_LEN)
//        {
//            if((i+BLE_SEND_MAX_LEN)<[data length]){
//
//                NSRange range=NSMakeRange(i, BLE_SEND_MAX_LEN);
//                //NSString *rangeStr=[NSString stringWithFormat:@"%i%i",i,i+BLE_SEND_MAX_LEN];
//                NSData *subdata=[data subdataWithRange:range];
//                sendData=subdata;
////                NSLog(@"---->-->---%i--%@",i,subdata);
//
//            }else{
//                NSRange range=NSMakeRange(i, (int)([data length]-i));
//                //NSString *rangeStr=[NSString stringWithFormat:@"%i,@%i",i,(int)([data length]-i)];
//                NSData *subdata=[data subdataWithRange:range];
//                sendData=subdata;
////                NSLog(@"--------ss%@",subdata);
//            }
////            [_writePeripheral writeValue:sendData forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//            [_writePeripheral writeValue:sendData forCharacteristic:write_characteristic type:CBCharacteristicWriteWithoutResponse];
//
//        }
    }
    else
    {
        NSDictionary *dict;
        
        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
        [_commandBuffer addObject:dict];
    }
    
}
//带回调的发送指令方法，推荐使用
-(void)writeCommadnToPrinterWthitData:(NSData *)data withResponse:(BleManagerReceiveCallBack)block{
    self.receiveBlock = block;
    if (commandSendMode==0)
    {
        NSLog(@"writeCommadnToPrinterWthitData");
        NSInteger oneTimeBytes = 10000;
        NSInteger count = [data length] / oneTimeBytes + 1;
        for (int i=0; i<count; i++) {
            if (i<count-1) {
                NSData* data1=[data subdataWithRange:NSMakeRange(i*oneTimeBytes, oneTimeBytes)];
                [_writePeripheral writeValue:data1 forCharacteristic:write_characteristic type:CBCharacteristicWriteWithoutResponse];
            }else{
                NSData* data2=[data subdataWithRange:NSMakeRange(i*oneTimeBytes, [data length]%oneTimeBytes)];
                [_writePeripheral writeValue:data2 forCharacteristic:write_characteristic type:CBCharacteristicWriteWithoutResponse];
            }
        }
////        NSLog(@"---->-->---%lu--%@",(unsigned long)[data length],data);
//        //数据分包
//        int BLE_SEND_MAX_LEN=20;
//        NSData *sendData=[NSData data];
//        for (int i=0; i<[data length]; i+=BLE_SEND_MAX_LEN)
//        {
//            if((i+BLE_SEND_MAX_LEN)<[data length]){
//
//                NSRange range=NSMakeRange(i, BLE_SEND_MAX_LEN);
//                //NSString *rangeStr=[NSString stringWithFormat:@"%i%i",i,i+BLE_SEND_MAX_LEN];
//                NSData *subdata=[data subdataWithRange:range];
//                sendData=subdata;
////                NSLog(@"---->-->---%i--%@",i,subdata);
//
//            }else{
//                NSRange range=NSMakeRange(i, (int)([data length]-i));
//                //NSString *rangeStr=[NSString stringWithFormat:@"%i,@%i",i,(int)([data length]-i)];
//                NSData *subdata=[data subdataWithRange:range];
//                sendData=subdata;
////                NSLog(@"--------ss%@",subdata);
//            }
////            [_writePeripheral writeValue:sendData forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//            [_writePeripheral writeValue:sendData forCharacteristic:write_characteristic type:CBCharacteristicWriteWithoutResponse];
//
//        }
        
        
    }
    else
    {
        NSDictionary *dict;
        
        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
        [_commandBuffer addObject:dict];
    }
    
    
}


//#pragma mark - 发送TSC指令
//- (void)writeTSCCommndWithData:(NSData *)data withResponse:(BleManagerReceiveCallBack)block {
//    self.receiveBlock = block;
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//#pragma mark - 发送POS指令
//- (void)writePOSCommndWithData:(NSData *)data withResponse:(BleManagerReceiveCallBack)block {
//    self.receiveBlock = block;
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}


-(void)reScan
{
    [self stopScan];
    [_peripherals removeAllObjects];
    if (_isConnected) {
        [self disconnectPeripheral:_peripheral];
    }
    else
    {
//        [self startScan];
         [self startScanWithInterval:3 completion: self.scanBlock];
    }
}
-(void)disconnectForReScan
{
    [self startScan];
}

-(void)disconnectRootPeripheral
{
    if (![_peripheral isKindOfClass:[CBPeripheral class]]) {
        return;
    }
    [_manager cancelPeripheralConnection:_peripheral];
    _isConnected = NO;
    _isAutoDisconnect = NO;
}

//#pragma mark - ===============打印机基本指令================
//#pragma mark - 水平定位
//- (void)horizontalPosition {
//    Byte kValue[1] = {0};
//    kValue[0] = 0x09;
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//     NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict=[[NSDictionary alloc]init];
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
//#pragma mark - 打印并换行
//- (void)printAndFeed {
//    Byte kValue[1] = {0};
//    kValue[0] = 0x0A;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
//#pragma mark - 打印并回到标准模式
//- (void)printAndBackToNormalModel {
//    Byte kValue[1] = {0};
//    kValue[0] = 0x0C;
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//#pragma mark - 页模式下取消打印
//- (void)cancelPrintData {
//    Byte kValue[1] = {0};
//    kValue[0] = 0x18;
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
//#pragma mark -实时状态传送
//- (void)updataPrinterState:(int)n completion:(BleManagerReceiveCallBack)callBlock{
//    self.receiveBlock = callBlock;
//    Byte kValue[3] = {0};
//    kValue[0] = 16;
//    kValue[1] = 4;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//
//}
//#pragma mark -  实时对打印机请求
//- (void)updataPrinterAnswer:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 16;
//    kValue[1] = 5;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//
//}
//
//#pragma mark - 实时产生钱箱开启脉冲
//- (void)openBoxAndPulse:(int)n m:(int)m t:(int)t {
//    Byte kValue[5] = {0};
//    kValue[0] = 16;
//    kValue[1] = 20;
//    kValue[2] = n;
//    kValue[3] = m;
//    kValue[4] = t;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
//#pragma mark - 页模式下打印
//- (void)printOnPageModel {
//    Byte kValue[2] = {0};
//    kValue[0] = 0x1B;
//    kValue[1] = 0x0c;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
//#pragma mark - 设置字符右间距
//- (void)setCharRightMargin:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 32;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
//#pragma mark - 选择打印模式
//- (void)selectPrintModel:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 33;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
//#pragma mark - 设置打印绝对位置
//- (void)setPrintLocationWithParam:(int)nL nH:(int)nH{
//
//    Byte kValue[4] = {0};
//    kValue[0] = 27;
//    kValue[1] = 36;
//    kValue[2] = nL;
//    kValue[3] = nH;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
//#pragma mark - 12.选择/取消用户自定义字符
//- (void)selectOrCancelCustomCharacter:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 37;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
//
///**
// * 13.定义用户自定义字符
// */
//- (void)definCustomCharacter:(int)y c1:(int)c1 c2:(int)c2 dx:(NSArray *)points
//{
//    int length = 5 + points.count;
//
//    Byte kValue[length];
//    kValue[0] = 27;
//    kValue[1] = 38;
//    kValue[2] = y;
//    kValue[3] = c1;
//    kValue[4] = c2;
//
//    for (int i = 0; i<points.count; i++) {
//        NSString *str = points[i];
//        kValue[5+i] = str.intValue;
//    }
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
///**
// * 14.选择位图模式
// */
//- (void)selectBitmapModel:(int)m nL:(int)nL nH:(int)nH dx:(NSArray *)points
//{    int length = 5 + points.count;
//    Byte kValue[length];
//    kValue[0] = 27;
//    kValue[1] = 42;
//    kValue[2] = m;
//    kValue[3] = nL;
//    kValue[4] = nH;
//
//    for (int i = 0; i<points.count; i++) {
//        NSString *va = points[i];
//        kValue[5+i] = va.intValue;
//    }
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//
//}
//
///**
// * 15.取消下划线模式
// */
//- (void)cancelUnderLineModel:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 45;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 16.设置默认行间距
// */
//- (void)setDefaultLineMargin {
//    Byte kValue[2] = {0};
//    kValue[0] = 27;
//    kValue[1] = 50;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
///**
// * 17.设置行间距
// */
//- (void)setLineMargin:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 51;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
///**
// * 18.选择打印机
// */
//- (void)selectPrinter:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 61;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 19.取消用户自定义字符
// */
//- (void)cancelCustomCharacter:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 63;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
///**
// * 20.初始化打印机
// */
//- (void)initializePrinter {
//    Byte kValue[2] = {0};
//    kValue[0] = 27;
//    kValue[1] = 64;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 21.设置横向跳格位置
// */
//- (void)setTabLocationWith:(NSArray *)points {
//
//    Byte kValue[3 + points.count];
//    kValue[0] = 27;
//    kValue[1] = 68;
//
//    for (int i = 0; i<points.count; i++) {
//        NSString *str = points[i];
//        kValue[2+i] = str.intValue;
//        if (i == points.count-1) {
//            kValue[3+i] = 0;
//        }
//    }
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 22.选择/取消加粗模式
// */
//- (void)selectOrCancelBoldModel:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 69;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 23.选择/取消双重打印模式
// */
//- (void)selectOrCancelDoublePrintModel:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 71;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 24.打印并走纸
// */
//- (void)printAndPushPage:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 74;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 25.选择页模式
// */
//- (void)selectPageModel {
//    Byte kValue[2] = {0};
//    kValue[0] = 27;
//    kValue[1] = 76;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 26.选择字体
// */
//- (void)selectFont:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 77;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 27.选择国际字符集
// */
//- (void)selectINTL_CHAR_SETWith:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 82;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 28.选择标准模式
// */
//- (void)selectNormalModel {
//    Byte kValue[2] = {0};
//    kValue[0] = 27;
//    kValue[1] = 83;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 29.在页模式下选择打印区域方向
// */
//- (void)selectPrintDirectionOnPageModel:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 84;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 30.选择/取消顺时针旋转90度
// */
//- (void)selectOrCancelRotationClockwise:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 86;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
///**
// * 31.页模式下设置打印区域
// */
//- (void)setprintLocationOnPageModelWithXL:(int)xL
//                                       xH:(int)xH
//                                       yL:(int)yL
//                                       yH:(int)yH
//                                      dxL:(int)dxL
//                                      dxH:(int)dxH
//                                      dyL:(int)dyL
//                                      dyH:(int)dyH
//{
//    Byte kValue[10];
//    kValue[0] = 27;
//    kValue[1] = 87;
//    kValue[2] = xL;
//    kValue[3] = xH;
//    kValue[4] = yL;
//    kValue[5] = yH;
//    kValue[6] = dxL;
//    kValue[7] = dxH;
//    kValue[8] = dyL;
//    kValue[9] = dyH;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
///**
// * 32.设置横向打印位置
// */
//- (void)setHorizonLocationWith:(int)nL nH:(int)nH {
//    Byte kValue[4] = {0};
//    kValue[0] = 27;
//    kValue[1] = 92;
//    kValue[2] = nL;
//    kValue[3] = nH;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
///**
// * 33.选择对齐方式
// */
//- (void)selectAlignmentWithN:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 97;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 34.选择打印纸传感器以输出信号
// */
//- (void)selectSensorForOutputSignal:(int)n {
//    Byte kValue[4] = {0};
//    kValue[0] = 27;
//    kValue[1] = 99;
//    kValue[2] = 51;
//    kValue[3] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
///**
// * 35.选择打印纸传感器以停止打印
// */
//- (void)selectSensorForStopPrint:(int)n {
//    Byte kValue[4] = {0};
//    kValue[0] = 27;
//    kValue[1] = 99;
//    kValue[2] = 52;
//    kValue[3] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 36.允许/禁止按键
// */
//- (void)allowOrDisableKeypress:(int)n {
//    Byte kValue[4] = {0};
//    kValue[0] = 27;
//    kValue[1] = 99;
//    kValue[2] = 53;
//    kValue[3] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 37.打印并向前走纸 N 行
// */
//- (void)printAndPushPageRow:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 100;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 38.产生钱箱控制脉冲
// */
//- (void)makePulseWithCashboxWithM:(int)m t1:(int)t1 t2:(int)t2 {
//    Byte kValue[5];
//    kValue[0] = 27;
//    kValue[1] = 112;
//    kValue[2] = m;
//    kValue[3] = t1;
//    kValue[4] = t2;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 39.选择字符代码表
// */
//- (void)selectCharacterTabN:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 116;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 40.选择/取消倒置打印模式
// */
//- (void)selectOrCancelInversionPrintModel:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 27;
//    kValue[1] = 123;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//
///**
// * 41.打印下载到FLASH中的位图
// */
//- (void)printFlashBitmapWithN:(int)n m:(int)m {
//    Byte kValue[4] = {0};
//    kValue[0] = 28;
//    kValue[1] = 112;
//    kValue[2] = n;
//    kValue[3] = m;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 42.定义FLASH位图
// */
//- (void)definFlashBitmapWithN:(int)n Points:(NSArray *)points;{
//    int length = points.count;
//    Byte kValue[3+length];
//    kValue[0] = 28;
//    kValue[1] = 113;
//    kValue[2] = n;
//
//    for (int i = 0; i<points.count; i++) {
//        NSString *str = points[i];
//        kValue[3+i] = str.intValue;
//    }
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 43.选择字符大小
// */
//- (void)selectCharacterSize:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 29;
//    kValue[1] = 33;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 44.页模式下设置纵向绝对位置
// */
//- (void)setVertLocationOnPageModelWithnL:(int)nL nH:(int)nH {
//    Byte kValue[4] = {0};
//    kValue[0] = 29;
//    kValue[1] = 36;
//    kValue[2] = nL;
//    kValue[3] = nH;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 45.定义下载位图
// */
//- (void)defineLoadBitmapWithX:(int)x Y:(int)y Points:(NSArray *)points {
//    Byte kValue[4+points.count];
//    kValue[0] = 29;
//    kValue[1] = 42;
//    kValue[2] = x;
//    kValue[3] = y;
//
//    for (int i = 0; i<points.count; i++) {
//        NSString *str = points[i];
//        kValue[4+i] = str.intValue;
//    }
//
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 46.执行打印数据十六进制转储
// */
//- (void)printDataAndSaveAsHexWithpL:(int)pL pH:(int)pH n:(int)n m:(int)m {
//    Byte kValue[7];
//    kValue[0] = 29;
//    kValue[1] = 40;
//    kValue[2] = 65;
//    kValue[3] = pL;
//    kValue[4] = pH;
//    kValue[5] = n;
//    kValue[6] = m;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 47.打印下载位图
// */
//- (void)printLoadBitmapM:(int)m {
//    Byte kValue[3] = {0};
//    kValue[0] = 29;
//    kValue[1] = 47;
//    kValue[2] = m;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 48.开始/结束宏定义
// */
//- (void)beginOrEndDefine {
//    Byte kValue[2] = {0};
//    kValue[0] = 29;
//    kValue[1] = 58;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 49.选择/取消黑白反显打印模式
// */
//- (void)selectORCancelBWPrintModel:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 29;
//    kValue[1] = 66;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 50.选择HRI字符的打印位置
// */
//- (void)selectHRIPrintLocation:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 29;
//    kValue[1] = 72;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 51.设置左边距
// */
//- (void)setLeftMarginWithnL:(int)nL nH:(int)nH {
//    Byte kValue[4] = {0};
//    kValue[0] = 29;
//    kValue[1] = 76;
//    kValue[2] = nL;
//    kValue[3] = nH;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 52.设置横向和纵向移动单位
// */
//- (void)setHoriAndVertUnitXWith:(int)x y:(int)y {
//    Byte kValue[4] = {0};
//    kValue[0] = 29;
//    kValue[1] = 80;
//    kValue[2] = x;
//    kValue[3] = y;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 53.选择切纸模式并切纸
// */
//- (void)selectCutPaperModelAndCutPaperWith:(int)m n:(int)n selectedModel:(int)model{
//    Byte kValue[4] = {0};
//    kValue[0] = 29;
//    kValue[1] = 86;
//    kValue[2] = m;
//    if (model == 1) {
//        kValue[3] = n;
//    }
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 54.设置打印区域宽高
// */
//- (void)setPrintLocationWith:(int)nL nH:(int)nH {
//    Byte kValue[4] = {0};
//    kValue[0] = 29;
//    kValue[1] = 87;
//    kValue[2] = nL;
//    kValue[3] = nH;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 55.页模式下设置纵向相对位置
// */
//- (void)setVertRelativeLocationOnPageModelWith:(int)nL nH:(int)nH {
//    Byte kValue[4] = {0};
//    kValue[0] = 29;
//    kValue[1] = 92;
//    kValue[2] = nL;
//    kValue[3] =nH;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 56.执行宏命令
// */
//- (void)runMacroMommandWith:(int)r t:(int)t m:(int)m {
//    Byte kValue[5] = {0};
//    kValue[0] = 29;
//    kValue[1] = 94;
//    kValue[2] = r;
//    kValue[3] = t;
//    kValue[4] = m;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 57.打开/关闭自动状态反传功能(ASB)
// */
//- (void)openOrCloseASB:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 29;
//    kValue[1] = 97;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 58.选择HRI使用字体
// */
//- (void)selectHRIFontToUse:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 29;
//    kValue[1] = 102;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 59. 选择条码高度
// */
//- (void)selectBarcodeHeight:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 29;
//    kValue[1] = 104;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 60.打印条码
// */
//- (void)printBarCodeWithPoints:(int)m n:(int)n points:(NSArray *)points selectModel:(int)model{
//
//    Byte kValue[4+points.count];
//    kValue[0] = 29;
//    kValue[1] = 107;
//    kValue[2] = m;
//
//    if (model == 0) {
//        for (int i = 0; i<points.count; i++) {
//            NSString *str = points[i];
//            kValue[3+i] = str.intValue;
//            if (i == points.count-1) {
//                kValue[4+i] = 0;
//            }
//        }
//    }else if (model == 1) {
//        kValue[3] = n;
//        for (int i = 0; i<points.count; i++) {
//            NSString *str = points[i];
//            kValue[4+i] = str.intValue;
//        }
//    }
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//
//}
///**
// * 61.返回状态
// */
//- (void)callBackStatus:(int)n completion:(BleManagerReceiveCallBack)block{
//    self.receiveBlock = block;
//    Byte kValue[3] = {0};
//    kValue[0] = 29;
//    kValue[1] = 114;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 62.打印光栅位图
// */
//- (void)printRasterBitmapWith:(int)m
//                           xL:(int)xL
//                           xH:(int)xH
//                           yl:(int)yL
//                           yh:(int)yH
//                       points:(NSArray *)points
//{
//    Byte kValue[8+points.count];
//    kValue[0] = 29;
//    kValue[1] = 118;
//    kValue[2] = 48;
//    kValue[3] = m;
//    kValue[4] = xL;
//    kValue[5] = xH;
//    kValue[6] = yL;
//    kValue[7] = yH;
//
//    for (int i = 0; i<points.count; i++) {
//        NSString *str = points[i];
//        kValue[8+i] =str.intValue;
//    }
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 63.设置条码宽度
// */
//- (void)setBarcodeWidth:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 29;
//    kValue[1] = 119;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//#pragma mark - ============汉字字符控制命令============
///**
// * 64.设置汉字字符模式
// */
//- (void)setChineseCharacterModel:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 28;
//    kValue[1] = 33;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 65.选择汉字模式
// */
//- (void)selectChineseCharacterModel {
//    Byte kValue[2] = {0};
//    kValue[0] = 28;
//    kValue[1] = 38;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 66.选择/取消汉字下划线模式
// */
//- (void)selectOrCancelChineseUderlineModel:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 28;
//    kValue[1] = 45;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 67.取消汉字模式
// */
//- (void)cancelChineseModel {
//    Byte kValue[2] = {0};
//    kValue[0] = 28;
//    kValue[1] = 46;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 68.定义用户自定义汉字
// */
//- (void)defineCustomChinesePointsC1:(int)c1 c2:(int)c2 points:(NSArray *)points {
//    Byte kValue[4 + points.count];
//    kValue[0] = 28;
//    kValue[1] = 50;
//    kValue[2] = c1;
//    kValue[3] = c2;
//
//    for (int i=0; i<points.count; i++) {
//        NSString *str = points[i];
//        kValue[4+i] = str.intValue;
//    }
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//
//}
///**
// * 69.设置汉字字符左右间距
// */
//- (void)setChineseMarginWithLeftN1:(int)n1 n2:(int)n2 {
//    Byte kValue[4] = {0};
//    kValue[0] = 28;
//    kValue[1] = 83;
//    kValue[2] = n1;
//    kValue[3] = n2;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 70.选择/取消汉字倍高倍宽
// */
//- (void)selectOrCancelChineseHModelAndWModel:(int)n {
//    Byte kValue[3] = {0};
//    kValue[0] = 28;
//    kValue[1] = 87;
//    kValue[2] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    if (commandSendMode==0)
//    {
//        [_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//    }
//    else
//    {
//        NSDictionary *dict;
//        dict = [NSDictionary dictionaryWithObjectsAndKeys: data,@"data",_writePeripheral,@"writePeripheral",nil];
//        [_commandBuffer addObject:dict];
//    }
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//#pragma mark - ============打印机提示命令============
///**
// * 72.打印机来单打印蜂鸣提示
// */
//- (void)printerSound:(int)n t:(int)t {
//    Byte kValue[4] = {0};
//    kValue[0] = 27;
//    kValue[1] = 66;
//    kValue[2] = n;
//    kValue[3] = t;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
///**
// * 73.打印机来单打印蜂鸣提示及报警灯闪烁
// */
//- (void)printerSoundAndAlarmLight:(int)m t:(int)t n:(int)n{
//    Byte kValue[5] = {0};
//    kValue[0] = 27;
//    kValue[1] = 67;
//    kValue[2] = m;
//    kValue[3] = t;
//    kValue[4] = n;
//
//    NSData *data = [NSData dataWithBytes:&kValue length:sizeof(kValue)];
//    NSLog(@"%@",[NSString stringWithFormat:@"写入:%@",data]);
//    //[_writePeripheral writeValue:data forCharacteristic:write_characteristic type:CBCharacteristicWriteWithResponse];
//}
//#pragma mark - ＝＝＝＝＝＝＝＝＝TSC指令＝＝＝＝＝＝＝＝＝＝
///**
// * 1.设置标签尺寸
// */
//- (void)ZywelladdSizeWidth:(int)width height:(int)height; {
//
//    NSString *sizeStr = [NSString stringWithFormat:@"SIZE %d mm,%d mm",width,height];
//
//    [self writeTSCWith:sizeStr];
//
//}
///**
// * 2.设置间隙长度
// */
//- (void)ZywelladdGap:(int)gap {
//
//    NSString *gapStr = [NSString stringWithFormat:@"GAP %d mm,0",gap];
//    [self writeTSCWith:gapStr];
//}
///**
// * 3.产生钱箱控制脉冲
// */
//- (void)ZywelladdCashDrwer:(int)m  t1:(int)t1  t2:(int)t2 {
//    NSString *cash = [NSString stringWithFormat:@"CASHDRAWER %d,%d,%d",m,t1,t2];
//    [self writeTSCWith:cash];
//}
///**
// * 4.控制每张标签的停止位置
// */
//- (void)ZywelladdOffset:(float)offset {
//    NSString *offsetStr = [NSString stringWithFormat:@"OFFSET %.1f mm",offset];
//    [self writeTSCWith:offsetStr];
//}
///**
// * 5.设置打印速度
// */
//- (void)ZywelladdSpeed:(float)speed {
//    NSString *speedStr = [NSString stringWithFormat:@"SPEED %.1f",speed];
//    [self writeTSCWith:speedStr];
//}
///**
// * 6.设置打印浓度
// */
//- (void)ZywelladdDensity:(int)n {
//    NSString *denStr = [NSString stringWithFormat:@"DENSITY %d",n];
//    [self writeTSCWith:denStr];
//}
///**
// * 7.设置打印方向和镜像
// */
//- (void)ZywelladdDirection:(int)n {
//    NSString *directionStr = [NSString stringWithFormat:@"DIRECTION %d",n];
//    [self writeTSCWith:directionStr];
//}
///**
// * 8.设置原点坐标
// */
//- (void)ZywelladdReference:(int)x  y:(int)y {
//    NSString *refStr = [NSString stringWithFormat:@"REFERENCE %d,%d",x,y];
//    [self writeTSCWith:refStr];
//}
///**
// * 9.清除打印缓冲区数据
// */
//- (void)ZywelladdCls {
//    NSString *clsStr = @"CLS ";
//    [self writeTSCWith:clsStr];
//}
///**
// * 10.走纸
// */
//- (void)ZywelladdFeed:(int)feed {
//    NSString *feedStr = [NSString stringWithFormat:@"FEED %d",feed];
//    [self writeTSCWith:feedStr];
//}
///**
// * 11.退纸
// */
//- (void)ZywelladdBackFeed:(int)feed {
//    NSString *back = [NSString stringWithFormat:@"BACKFEED %d",feed];
//    [self writeTSCWith:back];
//}
///**
// * 12.走一张标签纸距离
// */
//- (void)ZywelladdFormFeed {
//    [self writeTSCWith:@"FORMFEED "];
//}
///**
// * 13.标签位置进行一次校准
// */
//- (void)ZywelladdHome {
//    [self writeTSCWith:@"HOME "];
//}
///**
// * 14.打印标签
// */
//- (void)ZywelladdPrint:(int)m {
//    NSString *printStr = [NSString stringWithFormat:@"PRINT %d",m];
//    [self writeTSCWith:printStr];
//}
///**
// * 15.设置国际代码页
// */
//- (void)ZywelladdCodePage:(int)page {
//    NSString *code = [NSString stringWithFormat:@"CODEPAGE %d",page];
//    [self writeTSCWith:code];
//}
///**
// * 16.设置蜂鸣器
// */
//- (void)ZywelladdSound:(int)level interval:(int)interval {
//    NSString *soundStr = [NSString stringWithFormat:@"SOUND %d,%d",level,interval];
//    [self writeTSCWith:soundStr];
//}
///**
// * 17.设置打印机报错
// */
//- (void)ZywelladdLimitFeed:(int)feed {
//    NSString *limitStr = [NSString stringWithFormat:@"LIMITFEED %d mm",feed];
//    [self writeTSCWith:limitStr];
//}
///**
// * 18.在打印缓冲区绘制黑块
// */
//- (void)ZywelladdBar:(int)x y:(int)y width:(int)width height:(int)height {
//    NSString *barStr = [NSString stringWithFormat:@"BAR %d,%d,%d,%d",x,y,width,height];
//    [self writeTSCWith:barStr];
//}
///**
// * 19.在打印缓冲区绘制一维条码
// */
//- (void)Zywelladd1DBarcodeX:(int)x
//                      y:(int)y
//                   type:(NSString *)type
//                 height:(int)height
//               readable:(int)readable
//               rotation:(int)rotation
//                 narrow:(int)narrow
//                   wide:(int)wide
//                content:(NSString *)content
//{
//    NSString *codeStr = [NSString stringWithFormat:@"BARCODE %d,%d,\"%@\",%d,%d,%d,%d,%d,\"%@\"",x,y,type,height,readable,rotation,narrow,wide,content];
//    [self writeTSCWith:codeStr];
//}
//
///**
// * 20.在打印缓冲区绘制矩形
// */
//- (void)ZywelladdBox:(int)x y:(int)y xend:(int)xend yend:(int)yend {
//    NSString *boxStr = [NSString stringWithFormat:@"BOX %d,%d,%d,%d",x,y,xend,yend];
//    [self writeTSCWith:boxStr];
//}
///**
// * 21.在打印缓冲区绘制位图
// */
//- (void)ZywelladdBitmap:(int)x
//                  y:(int)y
//              width:(int)width
//             height:(int)height
//               mode:(int)mode data:(int)data {
//    NSString *bitStr = [NSString stringWithFormat:@"BITMAP %d,%d,%d,%d,%d,%d",x,y,width,height,mode,data];
//    [self writeTSCWith:bitStr];
//}
///**
// * 22.擦除打印缓冲区中指定区域的数据
// */
//- (void)ZywelladdErase:(int)x y:(int)y xwidth:(int)xwidth yheight:(int)yheight {
//    NSString *eraseStr = [NSString stringWithFormat:@"ERASE %d,%d,%d,%d",x,y,xwidth,yheight];
//    [self writeTSCWith:eraseStr];
//}
///**
// * 23.将指定区域的数据黑白反色
// */
//- (void)ZywelladdReverse:(int)x y:(int)y xwidth:(int)xwidth yheight:(int)yheight {
//    NSString *revStr = [NSString stringWithFormat:@"REVERSE %d,%d,%d,%d",x,y,xwidth,yheight];
//    [self writeTSCWith:revStr];
//}
///**
// * 24.将指定区域的数据黑白反色
// */
//- (void)ZywelladdQRCode:(int)x y:(int)y level:(int)level cellWidth:(int)cellWidth rotation:(int)totation data:(NSString *)dataStr {
//    NSString *text = [NSString stringWithFormat:@"TEXT %d,%d,%d,%d,%d,%@",x,y,level,cellWidth,totation,dataStr];
//    [self writeTSCWith:text];
//}
///**
// * 25.在打印缓冲区中绘制文字
// */
//- (void)ZywelladdQRCode:(NSString *)enable {
//    NSString *qrCode = [@"QRCODE " stringByAppendingString:enable];
//    [self writeTSCWith:qrCode];
//}
///**
// * 26.设置剥离功能是否开启
// */
//- (void)ZywelladdPeel:(NSString *)enable {
//    NSString *peel = [@"SET PEEL " stringByAppendingString:enable];
//    [self writeTSCWith:peel];
//}
///**
// * 27.设置撕离功能是否开启
// */
//- (void)ZywelladdTear:(NSString *)enable {
//    NSString *tear = [@"SET TEAR " stringByAppendingString:enable];
//    [self writeTSCWith:tear];
//}
///**
// * 28.设置切刀功能是否开启
// */
//- (void)ZywelladdCut:(NSString *)enable {
//    NSString *cut = [@"SET CUTTER " stringByAppendingString:enable];
//    [self writeTSCWith:cut];
//}
///**
// * 29.设置打印机出错时，是否打印上一张内容
// */
//- (void)ZywelladdReprint:(NSString *)enable {
//    NSString *reprint = [@"SET REPRINT " stringByAppendingString:enable];
//    [self writeTSCWith:reprint];
//}
///**
// * 30.设置是否按走纸键打印最近一张标签
// */
//- (void)ZywelladdPrintKeyEnable:(NSString *)enable {
//    NSString *printKey = [@"SET PRINTKEY " stringByAppendingString:enable];
//    [self writeTSCWith:printKey];
//}
///**
// * 31.设置按走纸键打印最近一张标签的份数
// */
//- (void)ZywelladdPrintKeyNum:(int)m {
//    NSString *printKey = [NSString stringWithFormat:@"SET PRINTKEY %d",m];
//    [self writeTSCWith:printKey];
//}

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

- (void)ZywellSetCommandMode:(int)Mode{
    commandSendMode=Mode;
}
@end
