//
//  PrinterManager.h
//  Printer
//
//  Created by ding on 2021/12/14.
//  Copyright © 2021 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "BLEManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface PrinterManager : NSObject
#pragma mark - 基本属性
//打印机类型
typedef enum {
    WifiPrinter=0,
    BlePrinter
} PrinterType;
//打印机状态
typedef enum {
    Normal=0,
    Error,
    Printing,
    Busy,
    CashDrawerOpened,
    CoverOpened,
    PaperNearEnd,
    NoPaper,
    CutPaper,
    FeedPaper,
    PrintCompleted,
    Disconnected
} PrinterStatus;
//主机地址
@property (nonatomic,copy) NSString *ip;
//端口
@property (nonatomic,assign) UInt16 port;
//是否连接成功
@property (nonatomic,assign) BOOL isConnected;
//接收到的数据
@property(nonatomic,copy)NSData* receivedData;
//是否成功监控打印机的状态
@property (nonatomic,assign) BOOL isReceivedData;
//打印机类型
@property(nonatomic,assign)NSUInteger printerType;
//打印机状态
@property(nonatomic,assign)int printerStatus;
@property(strong,nonatomic) NSTimer *timer;
//监控端口号
@property(nonatomic,assign)int monitorPort;
//打印端口号
@property(nonatomic,assign)int printPort;
//打印是否成功
@property(nonatomic,assign)bool printSucceed;
//是否自动重连
@property(nonatomic,assign)bool isAutoRecon;
//是否是用户主动断开连接
@property(nonatomic,assign)bool isUserDiscon;
@property(nonatomic,assign)bool isFirstRece;
#pragma mark - 基本方法
//+ (instancetype)shareManager:(int)printerType;
+ (instancetype)shareManager:(int)printerType threadID:(NSString*)thread;
//连接wifi打印机
-(bool)ConnectWifiPrinter:(NSString *)ip port:(UInt16)port;
//开启打印机监控
-(void)StartMonitor;
//退出禁止打印状态
-(void)exitForbidPrinting;
//免丢单指令
-(void)freeLostOrder;
//连接ble打印机
-(void)ConnectBlePrinter:(CBPeripheral *)peripheral;
// 断开打印机连接
- (void)DisConnectPrinter;
//发送指令到打印机
-(bool)SendDataToPrinter:(NSData *)data;
//发送订单到打印机，有打印机状态判断
-(bool)SendReceiptToPrinter:(NSData *)data;
//读取打印机返回的数据
-(void)ReadDataFromPrinter;
//获取打印机当前状态
-(NSString*)GetPrinterStatus;
//打印是否完整判断
-(BOOL)IsPrintCompletely;
@end

NS_ASSUME_NONNULL_END
