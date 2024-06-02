//
//  BLEManage.h
//  
//
//  Created by apple on 16/4/5.
//  Copyright © 2016年 Admin. All rights reserved.
//

/**
 *  #define kBLEM [BLEManager sharedBLEManager]
    if (kBLEM.isConnected) {
        [kBLEM writeDataToDevice:@[@(0)] command:1];
        [kBLEM writeDataToDevice:@[@(1),@(2)] command:2];
    }
 *
 *
 */

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

//#pragma mark - ====================POS指令====================
//#pragma mark - 其他方法
///**
// * 1.水平定位
// */
//- (void)horizontalPosition;
///**
// * 2.打印并换行
// */
//- (void)printAndFeed;
///**
// * 3.打印并回到标准模式
// */
//- (void)printAndBackToNormalModel;
///**
// * 4.页模式下取消打印数据
// */
//- (void)cancelPrintData;
///**
// * 5.实时状态传送
// */
//- (void)updataPrinterState:(int)n
//                completion:(BleManagerReceiveCallBack)callBlock;
///**
// * 6.实时对打印机请求
// */
//- (void)updataPrinterAnswer:(int) n;
///**
// * 7.实时产生钱箱开启脉冲
// */
//- (void)openBoxAndPulse:(int) n m:(int) m t:(int) t;
///**
// * 8.页模式下打印
// */
//- (void)printOnPageModel;
///**
// * 9.设置字符右间距
// */
//- (void)setCharRightMargin:(int)n;
///**
// * 10.选择打印模式
// */
//- (void)selectPrintModel:(int)n;
///**
// * 11.设置绝对打印位置
// */
//- (void)setPrintLocationWithParam:(int)nL nH:(int)nH;
///**
// * 12.选择/取消用户自定义字符
// */
//- (void)selectOrCancelCustomCharacter:(int)n;
//
///**
// * 13.定义用户自定义字符
// */
//- (void)definCustomCharacter:(int)y c1:(int)c1 c2:(int)c2 dx:(NSArray *)points;
///**
// * 14.选择位图模式
// */
//- (void)selectBitmapModel:(int)m nL:(int)nL nH:(int)nH dx:(NSArray *)points;
//
///**
// * 15.取消下划线模式
// */
//- (void)cancelUnderLineModel:(int)n;
///**
// * 16.设置默认行间距
// */
//- (void)setDefaultLineMargin;
///**
// * 17.设置行间距
// */
//- (void)setLineMargin:(int)n;
///**
// * 18.选择打印机
// */
//- (void)selectPrinter:(int)n;
///**
// * 19.取消用户自定义字符
// */
//- (void)cancelCustomCharacter:(int)n;
///**
// * 20.初始化打印机
// */
//- (void)initializePrinter;
///**
// * 21.设置横向跳格位置
// */
//- (void)setTabLocationWith:(NSArray *)points;
///**
// * 22.选择/取消加粗模式
// */
//- (void)selectOrCancelBoldModel:(int)n;
///**
// * 23.选择/取消双重打印模式
// */
//- (void)selectOrCancelDoublePrintModel:(int)n;
///**
// * 24.打印并走纸
// */
//- (void)printAndPushPage:(int)n;
///**
// * 25.选择页模式
// */
//- (void)selectPageModel;
///**
// * 26.选择字体
// */
//- (void)selectFont:(int)n;
///**
// * 27.选择国际字符集
// */
//- (void)selectINTL_CHAR_SETWith:(int)n;
///**
// * 28.选择标准模式
// */
//- (void)selectNormalModel;
///**
// * 29.在页模式下选择打印区域方向
// */
//- (void)selectPrintDirectionOnPageModel:(int)n;
///**
// * 30.选择/取消顺时针旋转90度
// */
//- (void)selectOrCancelRotationClockwise:(int)n;
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
//                                      dyH:(int)dyH;
//
///**
// * 32.设置横向打印位置
// */
//- (void)setHorizonLocationWith:(int)nL nH:(int)nH;
///**
// * 33.选择对齐方式
// */
//- (void)selectAlignmentWithN:(int)n;
///**
// * 34.选择打印纸传感器以输出信号
// */
//- (void)selectSensorForOutputSignal:(int)n;
///**
// * 35.选择打印纸传感器以停止打印
// */
//- (void)selectSensorForStopPrint:(int)n;
///**
// * 36.允许/禁止按键
// */
//- (void)allowOrDisableKeypress:(int)n;
///**
// * 37.打印并向前走纸 N 行
// */
//- (void)printAndPushPageRow:(int)n;
///**
// * 38.产生钱箱控制脉冲
// */
//- (void)makePulseWithCashboxWithM:(int)m t1:(int)t1 t2:(int)t2;
///**
// * 39.选择字符代码表
// */
//- (void)selectCharacterTabN:(int)n;
///**
// * 40.选择/取消倒置打印模式
// */
//- (void)selectOrCancelInversionPrintModel:(int)n;
///**
// * 41.打印下载到FLASH中的位图
// */
//- (void)printFlashBitmapWithN:(int)n m:(int)m;
///**
// * 42.定义FLASH位图
// */
//- (void)definFlashBitmapWithN:(int)n Points:(NSArray *)points;
///**
// * 43.选择字符大小
// */
//- (void)selectCharacterSize:(int)n;
///**
// * 44.页模式下设置纵向绝对位置
// */
//- (void)setVertLocationOnPageModelWithnL:(int)nL nH:(int)nH;
///**
// * 45.定义下载位图
// */
//- (void)defineLoadBitmapWithX:(int)x Y:(int)y Points:(NSArray *)points;
///**
// * 46.执行打印数据十六进制转储
// */
//- (void)printDataAndSaveAsHexWithpL:(int)pL pH:(int)pH n:(int)n m:(int)m;
///**
// * 47.打印下载位图
// */
//- (void)printLoadBitmapM:(int)m;
///**
// * 48.开始/结束宏定义
// */
//- (void)beginOrEndDefine;
///**
// * 49.选择/取消黑白反显打印模式
// */
//- (void)selectORCancelBWPrintModel:(int)n;
///**
// * 50.选择HRI字符的打印位置
// */
//- (void)selectHRIPrintLocation:(int)n;
///**
// * 51.设置左边距
// */
//- (void)setLeftMarginWithnL:(int)nL nH:(int)nH;
///**
// * 52.设置横向和纵向移动单位
// */
//- (void)setHoriAndVertUnitXWith:(int)x y:(int)y;
///**
// * 53.选择切纸模式并切纸
// */
//- (void)selectCutPaperModelAndCutPaperWith:(int)m n:(int)n selectedModel:(int)model;
///**
// * 54.设置打印区域宽高
// */
//- (void)setPrintLocationWith:(int)nL nH:(int)nH;
///**
// * 55.页模式下设置纵向相对位置
// */
//- (void)setVertRelativeLocationOnPageModelWith:(int)nL nH:(int)nH;
///**
// * 56.执行宏命令
// */
//- (void)runMacroMommandWith:(int)r t:(int)t m:(int)m;
///**
// * 57.打开/关闭自动状态反传功能(ASB)
// */
//- (void)openOrCloseASB:(int)n;
///**
// * 58.选择HRI使用字体
// */
//- (void)selectHRIFontToUse:(int)n;
///**
// * 59. 选择条码高度
// */
//- (void)selectBarcodeHeight:(int)n;
///**
// * 60.打印条码
// */
//- (void)printBarCodeWithPoints:(int)m n:(int)n points:(NSArray *)points selectModel:(int)model;
///**
// * 61.返回状态
// */
//- (void)callBackStatus:(int)n completion:(BleManagerReceiveCallBack)block;
///**
// * 62.打印光栅位图
// */
//- (void)printRasterBitmapWith:(int)m
//                           xL:(int)xL
//                           xH:(int)xH
//                           yl:(int)yL
//                           yh:(int)yH
//                       points:(NSArray *)points;
///**
// * 63.设置条码宽度
// */
//- (void)setBarcodeWidth:(int)n;
//#pragma mark - ============汉字字符控制命令============
///**
// * 64.设置汉字字符模式
// */
//- (void)setChineseCharacterModel:(int)n;
///**
// * 65.选择汉字模式
// */
//- (void)selectChineseCharacterModel;
///**
// * 66.选择/取消汉字下划线模式
// */
//- (void)selectOrCancelChineseUderlineModel:(int)n;
///**
// * 67.取消汉字模式
// */
//- (void)cancelChineseModel;
///**
// * 68.定义用户自定义汉字
// */
//- (void)defineCustomChinesePointsC1:(int)c1 c2:(int)c2 points:(NSArray *)points;
///**
// * 69.设置汉字字符左右间距
// */
//- (void)setChineseMarginWithLeftN1:(int)n1 n2:(int)n2;
///**
// * 70.选择/取消汉字倍高倍宽
// */
//- (void)selectOrCancelChineseHModelAndWModel:(int)n;
//#pragma mark - ============打印机提示命令============
///**
// * 72.打印机来单打印蜂鸣提示
// */
//- (void)printerSound:(int)n t:(int)t;
///**
// * 73.打印机来单打印蜂鸣提示及报警灯闪烁
// */
//- (void)printerSoundAndAlarmLight:(int)m t:(int)t n:(int)n;
//
//#pragma mark - ＝＝＝＝＝＝＝＝＝TSC指令＝＝＝＝＝＝＝＝＝＝
///**
// * 1.设置标签尺寸
// */
//- (void)PosaddSizeWidth:(int)width height:(int)height;
///**
// * 2.设置间隙长度
// */
//- (void)PosaddGap:(int)gap;
///**
// * 3.产生钱箱控制脉冲
// */
//- (void)PosaddCashDrwer:(int)m  t1:(int)t1  t2:(int)t2;
///**
// * 4.控制每张标签的停止位置
// */
//- (void)PosaddOffset:(float)offset;
///**
// * 5.设置打印速度
// */
//- (void)PosaddSpeed:(float)speed;
///**
// * 6.设置打印浓度
// */
//- (void)PosaddDensity:(int)n;
///**
// * 7.设置打印方向和镜像
// */
//- (void)PosaddDirection:(int)n;
///**
// * 8.设置原点坐标
// */
//- (void)PosaddReference:(int)x  y:(int)y;
///**
// * 9.清除打印缓冲区数据
// */
//- (void)PosaddCls;
///**
// * 10.走纸
// */
//- (void)PosaddFeed:(int)feed;
///**
// * 11.退纸
// */
//- (void)PosaddBackFeed:(int)feed;
///**
// * 12.走一张标签纸距离
// */
//- (void)PosaddFormFeed;
///**
// * 13.标签位置进行一次校准
// */
//- (void)PosaddHome;
///**
// * 14.打印标签
// */
//- (void)PosaddPrint:(int)m;
///**
// * 15.设置国际代码页
// */
//- (void)PosaddCodePage:(int)page;
///**
// * 16.设置蜂鸣器
// */
//- (void)PosaddSound:(int)level interval:(int)interval;
///**
// * 17.设置打印机报错
// */
//- (void)PosaddLimitFeed:(int)feed;
///**
// * 18.在打印缓冲区绘制黑块
// */
//- (void)PosaddBar:(int)x y:(int)y width:(int)width height:(int)height;
///**
// * 19.在打印缓冲区绘制一维条码
// */
//- (void)Posadd1DBarcodeX:(int)x
//                      y:(int)y
//                   type:(NSString *)type
//                 height:(int)height
//               readable:(int)readable
//               rotation:(int)rotation
//                 narrow:(int)narrow
//                   wide:(int)wide
//                content:(NSString *)content;
///**
// * 20.在打印缓冲区绘制矩形
// */
//- (void)PosaddBox:(int)x y:(int)y xend:(int)xend yend:(int)yend;
///**
// * 21.在打印缓冲区绘制位图
// */
//- (void)PosaddBitmap:(int)x
//                  y:(int)y
//              width:(int)width
//             height:(int)height
//               mode:(int)mode data:(int)data;
///**
// * 22.擦除打印缓冲区中指定区域的数据
// */
//- (void)PosaddErase:(int)x y:(int)y xwidth:(int)xwidth yheight:(int)yheight;
///**
// * 23.将指定区域的数据黑白反色
// */
//- (void)PosaddReverse:(int)x y:(int)y xwidth:(int)xwidth yheight:(int)yheight;
///**
// * 24.在打印缓冲区中绘制文字
// */
//- (void)PosaddText:(int)x y:(int)y font:(NSString *)font rotation:(int)rotation x_mul:(int)xmul y_mul:(int)ymul content:(NSString *)content;
///**
// * 25.在打印缓冲区中绘制文字
// */
//- (void)PosaddQRCode:(int)x y:(int)y level:(int)level cellWidth:(int)cellWidth rotation:(int)totation data:(NSString *)dataStr;
///**
// * 26.设置剥离功能是否开启
// */
//- (void)PosaddPeel:(NSString *)enable;
///**
// * 27.设置撕离功能是否开启
// */
//- (void)PosaddTear:(NSString *)enable;
///**
// * 28.设置切刀功能是否开启
// */
//- (void)PosaddCut:(NSString *)enable;
///**
// * 29.设置打印机出错时，是否打印上一张内容
// */
//- (void)PosaddReprint:(NSString *)enable;
///**
// * 30.设置是否按走纸键打印最近一张标签
// */
//- (void)PosaddPrintKeyEnable:(NSString *)enable;
///**
// * 31.设置按走纸键打印最近一张标签的份数
// */
//- (void)PosaddPrintKeyNum:(int)m;
/**
 * 32.Return the contents of the buffer to be sent
 */
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

