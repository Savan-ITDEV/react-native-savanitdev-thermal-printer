//
//  PrinterManager.m
//  Printer
//
//  Created by ding on 2021/12/14.
//  Copyright © 2021 Admin. All rights reserved.
//

#import "PrinterManager.h"

static PrinterManager *shareManager = nil;
@interface PrinterManager ()<GCDAsyncSocketDelegate,BLEManagerDelegate>
//连接的wifi socket对象
@property (nonatomic,strong) GCDAsyncSocket *wifiPrinter;
@property (nonatomic,strong) GCDAsyncSocket *wifiPrinterMonitor;
//ble打印机对象
@property (nonatomic,strong) BLEManager *blePrinter;
@end
@implementation PrinterManager
+ (instancetype)shareManager:(int)printerType threadID:(NSString*)thread{
    shareManager = [[PrinterManager alloc] init:printerType threadID:thread];
    return shareManager;
}

- (instancetype)init:(int)printerType threadID:(NSString*)thread{
    if (self = [super init]) {
        _isConnected=false;
        _printerType=printerType;
        _printerStatus=Disconnected;
        _printSucceed=false;
        _monitorPort=9100;
        _printPort=9100;
        _isAutoRecon=false;
        _isFirstRece=true;
        _isReceivedData=false;
        switch (printerType) {
            case WifiPrinter:
            {
                dispatch_queue_t queue = dispatch_queue_create([thread UTF8String], DISPATCH_QUEUE_SERIAL);
                _wifiPrinter=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
                if(_monitorPort==4000){
                    dispatch_queue_t queue2 = dispatch_queue_create("com.printer.monitor", DISPATCH_QUEUE_SERIAL);
                    _wifiPrinterMonitor=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue2];
                }
            }
                break;
            case BlePrinter:
            {
                
            }
                break;
            default:
                break;
        }
    }
    return self;
}
//连接wifi打印机
-(bool)ConnectWifiPrinter:(NSString *)ip port:(UInt16)port{
    if(!_isConnected){
        _ip=ip;
        _port=port;
        NSError *err = nil;
        _isFirstRece=true;
        _isUserDiscon=false;
        _isConnected=[_wifiPrinter connectToHost:ip onPort:port withTimeout:-1 error:&err];
        if(!_isConnected){
            _isConnected=false;
            _printerStatus=Disconnected;
            _isUserDiscon=true;
            NSLog(@"connect failed\n");
        }else{
            _isConnected=true;
            //NSLog(@"connect success\n");
            _printerStatus=Normal;
        }
        if(_monitorPort==4000&&_isConnected){
            [_wifiPrinterMonitor connectToHost:ip onPort:4000 error:&err];
        }
        NSDate* tmpStartData = [NSDate date];
        while(_isFirstRece){
            double timeout = [[NSDate date] timeIntervalSinceDate:tmpStartData];
            if(timeout>2){//连接超时
                _isConnected=false;
                _printerStatus=Disconnected;
                _isUserDiscon=true;
                NSLog(@"connect timeout,connect failed\n");
                break;
            }
        }
        if(!_isFirstRece){
            _isConnected=true;
            NSLog(@"didconnect,connect success\n");
            _printerStatus=Normal;
            [self exitForbidPrinting];
        }
    }
    return _isConnected;
}
-(void)StartMonitor{
    //开启免丢单功能，发送监控指令，通过timer获取打印机的状态
    //设置一个timer，定时执行OnclickStart方法
    //timer需要增加到当前子线程中
   _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ReadDataFromPrinter) userInfo:nil repeats:YES];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
   // [runloop addTimer:_timer forMode:NSDefaultRunLoopMode];
    [runloop addTimer:_timer forMode:NSRunLoopCommonModes];
    if(_monitorPort==_printPort&&_isConnected){
        //free lost order,需要先设置一次，重启打印机有效
        Byte free[]={0x1B, 0x73, 0x42, 0x45, 0x92, 0x9A, 0x01, 0x00, 0x5F, 0x0A};
        //9100端口监控指令
        Byte b[]={0x1d,0x61,0x1f};
        [_wifiPrinter writeData:[[NSData alloc]initWithBytes:b length:3] withTimeout:-1 tag:1];
    }
    [runloop run];
}
-(void)exitForbidPrinting{
    Byte exitForbidPrinting[]={0x1b,0x41};//退出禁止打印状态
                                   [_wifiPrinter writeData:[[NSData alloc]initWithBytes:exitForbidPrinting length:2] withTimeout:-1 tag:0];
}
-(void)freeLostOrder{
    Byte freeLostOrder[]={0x1B, 0x73, 0x42, 0x45, 0x92, 0x9A, 0x01, 0x00, 0x5F, 0x0A};//免丢单指令
                                   [_wifiPrinter writeData:[[NSData alloc]initWithBytes:freeLostOrder length:freeLostOrder] withTimeout:-1 tag:0];
}
-(bool)ReconWifiPrinter:(NSString *)ip port:(UInt16)port{
    if(!_isConnected){
        _ip=ip;
        _port=port;
        NSError *err = nil;
        _isFirstRece=true;
        _isConnected=[_wifiPrinter connectToHost:ip onPort:port withTimeout:-1 error:&err];
        if(!_isConnected){
            _isConnected=false;
            _printerStatus=Disconnected;
            //NSLog(@"connect failed\n");
        }else{
            _isConnected=true;
            //NSLog(@"connect success\n");
            _printerStatus=Normal;
        }
    }
    return _isConnected;
}
//连接ble打印机
-(void)ConnectBlePrinter:(CBPeripheral *)peripheral{
    
}
// 断开打印机连接
- (void)DisConnectPrinter{
    NSLog(@"disconnect printer");
    _isUserDiscon=true;
    switch (_printerType) {
        case WifiPrinter:
        {
            [_wifiPrinter disconnect];
        }
            break;
        case BlePrinter:
        {
            
        }
            break;
        default:
            break;
    }
}
//发送数据到打印机
-(bool)SendReceiptToPrinter:(NSData *)data{
    switch (_printerType) {
        case WifiPrinter:
        {
            _printSucceed=false;
            if((_printerStatus==Normal||_printerStatus==PrintCompleted)&&_isConnected){
                NSMutableData* dataM=[[NSMutableData alloc] initWithData:data];
                Byte cutPaper[]={0x1D,0x56,0x42,0x00,0x0A,0x0A,0x00};//切纸指令需要在订单指令前
                Byte b[]={0x1D,0x28,0x48,0x06,0x00,0x30,0x30,0x30,0x30,0x30,0x31};//订单号，会在打印完数据后返回到客户端
                [dataM appendBytes:cutPaper length:sizeof(cutPaper)];
                [dataM appendBytes:b length:sizeof(b)];
                [_wifiPrinter writeData:dataM withTimeout:-1 tag:0];
                NSDate* tmpStartData = [NSDate date];
                while(!_printSucceed){
                    double timeout = [[NSDate date] timeIntervalSinceDate:tmpStartData];
                    if(timeout>60||_printerStatus==CoverOpened||_printerStatus==NoPaper||_printerStatus==Error||_printerStatus==Disconnected){//打印数据超时,默认为1分钟;出现错误状况打印失败
                        Byte exitForbidPrinting[]={0x1b,0x41};//退出禁止打印状态
                                                       [_wifiPrinter writeData:[[NSData alloc]initWithBytes:exitForbidPrinting length:2] withTimeout:-1 tag:0];
                        NSLog(@"timeout,cost time = %f seconds", timeout);
                        _printSucceed=false;
                        if (_printerStatus==Normal) {
                            _isConnected=false;
                            _printerStatus=Disconnected;
                        }
                        break;
                    }
                }
            }else{
                Byte exitForbidPrinting[]={0x1b,0x41};//退出禁止打印状态
                                               [_wifiPrinter writeData:[[NSData alloc]initWithBytes:exitForbidPrinting length:2] withTimeout:-1 tag:0];
                _printSucceed=false;
                NSLog(@"Printer status %@\n",[self statusToString:_printerStatus]);
            }
        }
            break;
        case BlePrinter:
        {
            
        }
            break;
        default:
            break;
    }
    return _printSucceed;
}
-(bool)SendDataToPrinter:(NSData *)data{
    switch (_printerType) {
        case WifiPrinter:
        {
            if((_printerStatus==Normal||_printerStatus==PrintCompleted)&&_isConnected){
                NSMutableData* dataM=[[NSMutableData alloc] initWithData:data];
                [_wifiPrinter writeData:dataM withTimeout:-1 tag:0];
            }else{
                _printSucceed=false;
                NSLog(@"Printer status %@\n",[self statusToString:_printerStatus]);
            }
        }
            break;
        case BlePrinter:
        {
            
        }
            break;
        default:
            break;
    }
    return _printSucceed;
}
//读取打印机返回的数据
-(void)ReadDataFromPrinter{
    _receivedData=nil;
    if(_monitorPort==4000){
        //4000端口监控指令，需要在每次读取打印机状态时进行发送
        Byte b[]={0x1b,0x76};
        [_wifiPrinterMonitor writeData:[[NSData alloc]initWithBytes:b length:2] withTimeout:-1 tag:1];
        //调用读取函数，通过didread返回
        [_wifiPrinterMonitor readDataWithTimeout:-1 tag:1];
    }else{
        //调用读取函数，通过didread返回
        [_wifiPrinter readDataWithTimeout:-1 tag:1];
    }
}
//获取打印机当前状态
-(NSString*)GetPrinterStatus{
    if(!_isReceivedData){
        _printerStatus=Error;
    }
    return [self statusToString:_printerStatus];
}
//打印是否完整判断
-(BOOL)IsPrintCompletely{
    return false;
}
//打印机状态字符串
- (NSString*)statusToString:(PrinterStatus)printerStatus {
    NSString *result = nil;
    switch(printerStatus) {
        case Normal:
            result = @"Normal";
            break;
        case Error:
            result = @"Error";
            break;
        case Printing:
            result = @"Printing";
            break;
        case Busy:
            result = @"Busy";
            break;
        case CashDrawerOpened:
            result = @"CashDrawerOpened";
            break;
        case CoverOpened:
            result = @"CoverOpened";
            break;
        case PaperNearEnd:
            result = @"PaperNearEnd";
            break;
        case NoPaper:
            result = @"NoPaper";
            break;
        case CutPaper:
            result = @"CutPaper";
            break;
        case FeedPaper:
            result = @"FeedPaper";
            break;
        case PrintCompleted:
            result=@"PrintCompleted";
            break;
        case Disconnected:
            result=@"Printer Disconnected";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected status."];
    }

    return result;
}
#pragma mark wifi
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    if(sock.isConnected){
        //NSLog(@"didconnect to host");
        _isConnected=true;
        _printerStatus=Normal;
        _isFirstRece=false;
    }
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    if(sock.connectedPort==_monitorPort||sock.connectedPort==_printPort){
        NSLog(@"data=%@,tag=%ld", data,tag);
        _receivedData=data;
        _isReceivedData=true;
        Byte b[data.length];
        bool printCompelte=false;
        Byte jobID[]={0x37,0x22,0x30,0x30,0x30,0x31,0x00};
        for (int i = 0 ; i < data.length; i++) {
            NSData *idata = [data subdataWithRange:NSMakeRange(i, 1)];
            b[i] =((Byte*)[idata bytes])[0];
        }
        //打印机的订单号可能会跟状态一起返回，所以需要判断子串比较准确
        for(int i=0,j=0;i<data.length&&j<sizeof(jobID);i++){
            if(b[i]==jobID[j]){
                j++;
                if(j==sizeof(jobID)){
                    printCompelte=true;
                }
            }
        }
        if(tag==1){
            //0x1400602f 状态下面不能打印
            Byte nomralBytes[]={0x14,0x00,0x00,0x0f};
            if(data.bytes==nomralBytes){
                _printerStatus=Normal;
            }
               else if(printCompelte){  
                    _printerStatus=PrintCompleted;
                    _printSucceed=true;
                }
            else{
                //first byte
                if ((b[0] & (0x04)) != 0) {//cash
                    _printerStatus=CashDrawerOpened;
                    _printerStatus=Normal;
                } else {
                    //n
                }
                if ((b[0] & (0x08)) != 0) {// busy
                    _printerStatus=Busy;
                } else {
                    //n
                }
                if ((b[0] & (0x20)) != 0) { // cover
                    _printerStatus=CoverOpened;
                } else {
                    //n
                }
                if (((b[0] & (0x40)) != 0)){//feedpaper
                    _printerStatus=FeedPaper;
                } else {
                    //n
                }
                //second byte
                if ((b[1] & (0x08)) != 0) {//cutpaper
                    _printerStatus=CutPaper;
                    NSLog(@"Printer status %@\n",[self statusToString:_printerStatus]);
                } else {
                    //n
                }
                if ((b[1] & (0x20)) != 0) {//fatal
                    _printerStatus=Error;
                } else {
                    //n
                }
                if ((b[1] & (0x40)) != 0) {//autorestor
                    //y
                } else {
                    //n
                }
                
                //third byte
                if ((b[2] & (0x03)) != 0) {//papernearend
                    _printerStatus=PaperNearEnd;
                } else {
                    //n
                }
                
                if ((b[2] & (0x0C)) != 0) {//nopaper
                    _printerStatus=NoPaper;
                } else {
                    //n
                }
                
                if ((b[2] & (0x40)) != 0) {//printpaper
                    _printerStatus=Printing;
                    _printerStatus=Normal;
                } else {
                    //n
                }
            }
        }
      
    }
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    if(sock.isDisconnected){
        _isConnected=false;
        _printerStatus=Disconnected;
    }
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    if(sock.isDisconnected){
        _isConnected=false;
        _printerStatus=Disconnected;
       // NSLog(@"printer disconnected");
        if(_isAutoRecon&&!_isUserDiscon){
            //如果重新连接失败就不重复
            _isAutoRecon=[self ReconWifiPrinter:_ip port:_port];
            if(_isAutoRecon){
                //NSLog(@"reconnect success");
            }else{
                NSLog(@"reconnect failed,check printer ip or power");
            }
        }
    }
}
#pragma mark ble
- (void)BLEManagerDelegate:(BLEManager *)BLEmanager connectPeripheral:(CBPeripheral *)peripheral {
    
}

- (void)BLEManagerDelegate:(BLEManager *)BLEmanager didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

- (void)BLEManagerDelegate:(BLEManager *)BLEmanager didWriteValueForCharacteristic:(CBCharacteristic *)character error:(NSError *)error {
    
}

- (void)BLEManagerDelegate:(BLEManager *)BLEmanager disconnectPeripheral:(CBPeripheral *)peripheral isAutoDisconnect:(BOOL)isAutoDisconnect {
    
}

- (void)BLEManagerDelegate:(BLEManager *)BLEmanager updatePeripheralList:(NSArray *)peripherals RSSIList:(NSArray *)RSSIArr {
    
}

@end
