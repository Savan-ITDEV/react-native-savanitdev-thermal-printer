//
//  POSBLEManager.m
//  Printer
//
//  Created by ding on 16/7/19.
//  Copyright © 2019年 ding. All rights reserved.
//

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
//    [_manager startScan];
    [_manager reScan];
}

#pragma mark - 停止扫描
- (void)POSstopScan {
    [_manager stopScan];
}

#pragma mark - 手动断开现连设备 不会重连
- (void)POSdisconnectRootPeripheral {
    [_manager disconnectRootPeripheral];
    _connectOK=NO;
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
                self->_connectOK=YES;
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
    //这里在打印机主动断开连接时，会使APP闪退
//    if ([self.delegate respondsToSelector:@selector(POSdidDisconnectPeripheral:isAutoDisconnect:)]) {
//        [self.delegate POSdidDisconnectPeripheral:peripheral isAutoDisconnect:isAutoDisconnect];
//    }
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

//#pragma mark - 其他方法
//#pragma mark - 水平定位
//- (void)PoshorizontalPosition {
//    [_manager horizontalPosition];
//}
//
//#pragma mark - 打印并换行
//- (void)PosprintAndFeed {
//    [_manager printAndFeed];
//}
//
//#pragma mark - 打印并回到标准模式
//- (void)PosPrintAndBackToNormalModel {
//    [_manager printAndBackToNormalModel];
//}
//
//#pragma mark - 取消打印
//- (void)PosCancelPrintData {
//    [_manager cancelPrintData];
//}
//
//#pragma mark - 实时状态传送
//- (void)PosUpdataPrinterState:(int)param completion:(PosPOSCompletionBlock)callBlock{
//    [_manager updataPrinterState:param completion:^(CBCharacteristic *characteristic) {
//        callBlock(characteristic);
//    }];
//}
//
//#pragma mark - 实时请求打印机
//- (void)PosUpdataPrinterAnswer:(int)param {
//    [_manager updataPrinterAnswer:param];
//}
//
//#pragma mark - 实时产生钱箱脉冲
//- (void)PosOpenBoxAndPulse:(int)n m:(int)m t:(int)t {
//    [_manager openBoxAndPulse:n m:m t:t];
//}
//
//#pragma mark - 页模式下打印
//- (void)PosPrintOnPageModel {
//    [_manager printOnPageModel];
//}
//
//#pragma mark - 设置字符右间距
//- (void)PosSetCharRightMargin:(int)n {
//    [_manager setCharRightMargin:n];
//}
//
//#pragma mark - 选择打印模式
//- (void)PosSelectPrintModel:(int)n {
//    [_manager selectPrintModel:n];
//}
//
///**
// * 11.设置绝对打印位置
// *  0 <= nL <= 255
// *  0 <= nh <= 255
// */
//- (void)PosSetPrintLocationWithParam:(int)nL nH:(int)nH
//{
//    [_manager setPrintLocationWithParam:nL nH:nH];
//}
//
///**
// * 12.选择/取消用户自定义字符
// *   0 <= n <= 255
// */
//- (void)PosSelectOrCancelCustomCharacter:(int)n {
//    [_manager selectOrCancelCustomCharacter:n];
//}
//
///**
// * 13.定义用户自定义字符
// */
//- (void)PosDefinCustomCharacter:(int)y c1:(int)c1 c2:(int)c2 dx:(NSArray *)points {
//    [_manager definCustomCharacter:y c1:c1 c2:c2 dx:points];
//}
//
///**
// * 14.选择位图模式
// */
//- (void)PosSelectBitmapModel:(int)m nL:(int)nL nH:(int)nH dx:(NSArray *)points
//{
//    [_manager selectBitmapModel:m nL:nL nH:nH dx:points];
//}
//
///**
// * 15.取消下划线模式
// */
//- (void)PosCancelUnderLineModelWith:(int)n {
//    [_manager cancelUnderLineModel:n];
//}
//
///**
// * 16.设置默认行间距
// */
//- (void)PosSetDefaultLineMargin {
//    [_manager setDefaultLineMargin];
//}
//
///**
// * 17.设置行间距
// */
//- (void)PosSetLineMarginWith:(int)n {
//    [_manager setLineMargin:n];
//}
//
///**
// * 18.选择打印机
// */
//- (void)PosSelectPrinterWith:(int)n {
//    [_manager selectPrinter:n];
//}
//
///**
// * 19.取消用户自定义字符
// */
//- (void)PosCancelCustomCharacterWith:(int)n {
//    [_manager cancelCustomCharacter:n];
//}
//
///**
// * 20.初始化打印机
// */
//- (void)PosInitializePrinter {
//    [_manager initializePrinter];
//}
//
///**
// * 21.设置横向跳格位置
// */
//- (void)PosSetTabLocationWith:(NSArray *)points {
//    [_manager setTabLocationWith:points];
//}
///**
// * 22.选择/取消加粗模式
// */
//- (void)PosSelectOrCancelBoldModelWith:(int)n {
//    [_manager selectOrCancelBoldModel:n];
//}
///**
// * 23.选择/取消双重打印模式
// */
//- (void)PosSelectOrCancelDoublePrintModel:(int)n {
//    [_manager selectOrCancelDoublePrintModel:n];
//}
///**
// * 24.打印并走纸
// */
//- (void)PosPrintAndPushPageWith:(int)n {
//    [_manager printAndPushPage:n];
//}
///**
// * 25.选择页模式
// */
//- (void)PosSelectPageModel {
//    [_manager selectPageModel];
//}
///**
// * 26.选择字体
// */
//- (void)PosSelectFontWith:(int)n {
//    [_manager selectFont:n];
//}
///**
// * 27.选择国际字符集
// */
//- (void)PosSelectINTL_CHAR_SETWith:(int)n {
//    [_manager selectINTL_CHAR_SETWith:n];
//}
///**
// * 28.选择标准模式
// */
//- (void)PosSelectNormalModel {
//    [_manager selectNormalModel];
//}
///**
// * 29.在页模式下选择打印区域方向
// */
//- (void)PosSelectPrintDirectionOnPageModel:(int)n {
//    [_manager selectPrintDirectionOnPageModel:n];
//}
///**
// * 30.选择/取消顺时针旋转90度
// */
//- (void)PosSelectOrCancelRotationClockwise:(int)n {
//    [_manager selectOrCancelRotationClockwise:n];
//}
///**
// * 31.页模式下设置打印区域
// */
//- (void)PosSetprintLocationOnPageModelWithXL:(int)xL
//                                         xH:(int)xH
//                                         yL:(int)yL
//                                         yH:(int)yH
//                                        dxL:(int)dxL
//                                        dxH:(int)dxH
//                                        dyL:(int)dyL
//                                        dyH:(int)dyH
//{
//    [_manager setprintLocationOnPageModelWithXL:xL xH:xH yL:yL yH:yH dxL:dxL dxH:dxH dyL:dyL dyH:dyH];
//}
//
///**
// * 32.设置横向打印位置
// */
//- (void)PosSetHorizonLocationWith:(int)nL nH:(int)nH {
//    [_manager setHorizonLocationWith:nL nH:nH];
//}
///**
// * 33.选择对齐方式
// */
//- (void)PosSelectAlignmentWithN:(int)n {
//    [_manager selectAlignmentWithN:n];
//}
///**
// * 34.选择打印纸传感器以输出信号
// */
//- (void)PosSelectSensorForOutputSignal:(int)n {
//    [_manager selectSensorForOutputSignal:n];
//}
///**
// * 35.选择打印纸传感器以停止打印
// */
//- (void)PosSelectSensorForStopPrint:(int)n {
//    [_manager selectSensorForStopPrint:n];
//}
///**
// * 36.允许/禁止按键
// */
//- (void)PosAllowOrDisableKeypress:(int)n {
//    [_manager allowOrDisableKeypress:n];
//}
///**
// * 37.打印并向前走纸 N 行
// */
//- (void)PosPrintAndPushPageRow:(int)n {
//    [_manager printAndPushPageRow:n];
//}
///**
// * 38.产生钱箱控制脉冲
// */
//- (void)PosMakePulseWithCashboxWithM:(int)m t1:(int)t1 t2:(int)t2 {
//    [_manager makePulseWithCashboxWithM:m t1:t1 t2:t2];
//}
///**
// * 39.选择字符代码表
// */
//- (void)PosSelectCharacterTabN:(int)n {
//    [_manager selectCharacterTabN:n];
//}
///**
// * 40.选择/取消倒置打印模式
// */
//- (void)PosSelectOrCancelInversionPrintModel:(int)n {
//    [_manager selectOrCancelInversionPrintModel:n];
//}
///**
// * 41.打印下载到FLASH中的位图
// */
//- (void)PosPrintFlashBitmapWithN:(int)n m:(int)m {
//    [_manager printFlashBitmapWithN:n m:m];
//}
///**
// * 42.定义FLASH位图
// */
//- (void)PosDefinFlashBitmapWithN:(int)n Points:(NSArray *)points {
//    [_manager definFlashBitmapWithN:n Points:points];
//}
///**
// * 43.选择字符大小
// */
//- (void)PosSelectCharacterSize:(int)n {
//    [_manager selectCharacterSize:n];
//}
///**
// * 44.页模式下设置纵向绝对位置
// */
//- (void)PosSetVertLocationOnPageModelWithnL:(int)nL nH:(int)nH {
//    [_manager setVertLocationOnPageModelWithnL:nL nH:nH];
//}
///**
// * 45.定义下载位图
// */
//- (void)PosDefineLoadBitmapWithX:(int)x Y:(int)y Points:(NSArray *)points; {
//    [_manager defineLoadBitmapWithX:x Y:y Points:points];
//}
///**
// * 46.执行打印数据十六进制转储
// */
//- (void)PosPrintDataAndSaveAsHexWithpL:(int)pL pH:(int)pH n:(int)n m:(int)m {
//    [_manager printDataAndSaveAsHexWithpL:pL pH:pH n:n m:m];
//}
///**
// * 47.打印下载位图
// */
//- (void)PosPrintLoadBitmapM:(int)m {
//    [_manager printLoadBitmapM:m];
//}
///**
// * 48.开始/结束宏定义
// */
//- (void)PosBeginOrEndDefine {
//    [_manager beginOrEndDefine];
//}
///**
// * 49.选择/取消黑白反显打印模式
// */
//- (void)PosSelectORCancelBWPrintModel:(int)n {
//    [_manager selectORCancelBWPrintModel:n];
//}
///**
// * 50.选择HRI字符的打印位置
// */
//- (void)PosSelectHRIPrintLocation:(int)n {
//    [_manager selectHRIPrintLocation:n];
//}
///**
// * 51.设置左边距
// */
//- (void)PosSetLeftMarginWithnL:(int)nL nH:(int)nH {
//    [_manager setLeftMarginWithnL:nL nH:nH];
//}
///**
// * 52.设置横向和纵向移动单位
// */
//- (void)PosSetHoriAndVertUnitXWith:(int)x y:(int)y {
//    [_manager setHoriAndVertUnitXWith:x y:y];
//}
///**
// * 53.选择切纸模式并切纸
// */
//- (void)PosSelectCutPaperModelAndCutPaperWith:(int)m n:(int)n selectedModel:(int)model {
//    [_manager selectCutPaperModelAndCutPaperWith:m n:n selectedModel:model];
//}
///**
// * 54.设置打印区域宽高
// */
//- (void)PosSetPrintLocationWith:(int)nL nH:(int)nH {
//    [_manager setPrintLocationWith:nL nH:nH];
//}
///**
// * 55.页模式下设置纵向相对位置
// */
//- (void)PosSetVertRelativeLocationOnPageModelWith:(int)nL nH:(int)nH {
//    [_manager setVertRelativeLocationOnPageModelWith:nL nH:nH];
//}
///**
// * 56.执行宏命令
// */
//- (void)PosRunMacroMommandWith:(int)r t:(int)t m:(int)m {
//    [_manager runMacroMommandWith:r t:t m:m];
//}
///**
// * 57.打开/关闭自动状态反传功能(ASB)
// */
//- (void)PosOpenOrCloseASB:(int)n {
//    [_manager openOrCloseASB:n];
//}
///**
// * 58.选择HRI使用字体
// */
//- (void)PosSelectHRIFontToUse:(int)n {
//    [_manager selectHRIFontToUse:n];
//}
///**
// * 59. 选择条码高度
// */
//- (void)PosSelectBarcodeHeight:(int)n {
//    [_manager selectBarcodeHeight:n];
//}
///**
// * 60.打印条码
// */
//- (void)PosPrintBarCodeWithPoints:(int)m n:(int)n points:(NSArray *)points selectModel:(int)model {
//    [_manager printBarCodeWithPoints:m n:n points:points selectModel:model];
//}
///**
// * 61.返回状态
// */
//- (void)PosCallBackStatus:(int)n completion:(PosPOSCompletionBlock)block {
//    [_manager callBackStatus:n completion:^(CBCharacteristic *characteristic) {
//        block(characteristic);
//    }];
//}
///**
// * 62.打印光栅位图
// */
//- (void)PosPrintRasterBitmapWith:(int)m
//                             xL:(int)xL
//                             xH:(int)xH
//                             yl:(int)yL
//                             yh:(int)yH
//                         points:(NSArray *)points
//{
//    [_manager printRasterBitmapWith:m xL:xL xH:xH yl:yL yh:yH points:points];
//}
///**
// * 63.设置条码宽度
// */
//- (void)PosSetBarcodeWidth:(int)n {
//    [_manager setBarcodeWidth:n];
//}
//#pragma mark - ============汉字字符控制命令============
///**
// * 64.设置汉字字符模式
// */
//- (void)PosSetChineseCharacterModel:(int)n {
//    [_manager setChineseCharacterModel:n];
//}
///**
// * 65.选择汉字模式
// */
//- (void)PosSelectChineseCharacterModel {
//    [_manager selectChineseCharacterModel];
//}
///**
// * 66.选择/取消汉字下划线模式
// */
//- (void)PosSelectOrCancelChineseUderlineModel:(int)n {
//    [_manager selectOrCancelChineseUderlineModel:n];
//}
///**
// * 67.取消汉字模式
// */
//- (void)PosCancelChineseModel {
//    [_manager cancelChineseModel];
//}
///**
// * 68.定义用户自定义汉字
// */
//- (void)PosDefineCustomChinesePointsC1:(int)c1 c2:(int)c2 points:(NSArray *)points {
//    [_manager defineCustomChinesePointsC1:c1 c2:c2 points:points];
//}
///**
// * 69.设置汉字字符左右间距
// */
//- (void)PosSetChineseMarginWithLeftN1:(int)n1 n2:(int)n2 {
//    [_manager setChineseMarginWithLeftN1:n1 n2:n2];
//}
///**
// * 70.选择/取消汉字倍高倍宽
// */
//- (void)PosSelectOrCancelChineseHModelAndWModel:(int)n {
//    [_manager selectOrCancelChineseHModelAndWModel:n];
//}
//#pragma mark - ============打印机提示命令============
///**
// * 72.打印机来单打印蜂鸣提示
// */
//- (void)PosPrinterSound:(int)n t:(int)t {
//    [_manager printerSound:n t:t];
//}
///**
// * 73.打印机来单打印蜂鸣提示及报警灯闪烁
// */
//- (void)PosPrinterSoundAndAlarmLight:(int)m t:(int)t n:(int)n {
//    [_manager printerSoundAndAlarmLight:m t:t n:n];
//}
//
//#pragma mark - ＝＝＝＝＝＝＝＝＝TSC指令＝＝＝＝＝＝＝＝＝＝
///**
// * 1.设置标签尺寸
// */
//- (void)PosaddSizeWidth:(int)width height:(int)height {
//    [_manager PosaddSizeWidth:width height:height];
//}
///**
// * 2.设置间隙长度
// */
//- (void)PosaddGap:(int)gap {
//    [_manager PosaddGap:gap];
//}
///**
// * 3.产生钱箱控制脉冲
// */
//- (void)PosaddCashDrwer:(int)m  t1:(int)t1  t2:(int)t2 {
//    [_manager PosaddCashDrwer:m t1:t1 t2:t2];
//}
///**
// * 4.控制每张标签的停止位置
// */
//- (void)PosaddOffset:(float)offset {
//    [_manager PosaddOffset:offset];
//}
///**
// * 5.设置打印速度
// */
//- (void)PosaddSpeed:(float)speed {
//    [_manager PosaddSpeed:speed];
//}
///**
// * 6.设置打印浓度
// */
//- (void)PosaddDensity:(int)n {
//    [_manager PosaddDensity:n];
//}
///**
// * 7.设置打印方向和镜像
// */
//- (void)PosaddDirection:(int)n {
//    [_manager PosaddDirection:n];
//}
///**
// * 8.设置原点坐标
// */
//- (void)PosaddReference:(int)x  y:(int)y {
//    [_manager PosaddReference:x y:y];
//}
///**
// * 9.清除打印缓冲区数据
// */
//- (void)PosaddCls {
//    [_manager PosaddCls];
//}
///**
// * 10.走纸
// */
//- (void)PosaddFeed:(int)feed {
//    [_manager PosaddFeed:feed];
//}
///**
// * 11.退纸
// */
//- (void)PosaddBackFeed:(int)feed {
//    [_manager PosaddBackFeed:feed];
//}
///**
// * 12.走一张标签纸距离
// */
//- (void)PosaddFormFeed {
//    [_manager PosaddFormFeed];
//}
///**
// * 13.标签位置进行一次校准
// */
//- (void)PosaddHome {
//    [_manager PosaddHome];
//}
///**
// * 14.打印标签
// */
//- (void)PosaddPrint:(int)m {
//    [_manager PosaddPrint:m];
//}
///**
// * 15.设置国际代码页
// */
//- (void)PosaddCodePage:(int)page {
//    [_manager PosaddCodePage:page];
//}
///**
// * 16.设置蜂鸣器
// */
//- (void)PosaddSound:(int)level interval:(int)interval {
//    [_manager PosaddSound:level interval:interval];
//}
///**
// * 17.设置打印机报错
// */
//- (void)PosaddLimitFeed:(int)feed {
//    [_manager PosaddLimitFeed:feed];
//}
///**
// * 18.在打印缓冲区绘制黑块
// */
//- (void)PosaddBar:(int)x y:(int)y width:(int)width height:(int)height {
//    [_manager PosaddBar:x y:y width:width height:height];
//}
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
//                content:(NSString *)content {
//    [_manager Posadd1DBarcodeX:x y:y type:type height:height readable:readable rotation:rotation narrow:narrow wide:wide content:content];
//}
///**
// * 20.在打印缓冲区绘制矩形
// */
//- (void)PosaddBox:(int)x y:(int)y xend:(int)xend yend:(int)yend {
//    [_manager PosaddBox:x y:y xend:xend yend:yend];
//}
///**
// * 21.在打印缓冲区绘制位图
// */
//- (void)PosaddBitmap:(int)x
//                  y:(int)y
//              width:(int)width
//             height:(int)height
//               mode:(int)mode data:(int)data {
//    [_manager PosaddBitmap:x y:y width:width height:height mode:mode data:data];
//}
///**
// * 22.擦除打印缓冲区中指定区域的数据
// */
//- (void)PosaddErase:(int)x y:(int)y xwidth:(int)xwidth yheight:(int)yheight {
//    [_manager PosaddErase:x y:y xwidth:xwidth yheight:yheight];
//}
///**
// * 23.将指定区域的数据黑白反色
// */
//- (void)PosaddReverse:(int)x y:(int)y xwidth:(int)xwidth yheight:(int)yheight {
//    [_manager PosaddReverse:x y:y xwidth:xwidth yheight:yheight];
//}
///**
// * 24.在打印缓冲区中绘制文字
// */
//- (void)PosaddText:(int)x y:(int)y font:(NSString *)font rotation:(int)rotation x_mul:(int)xmul y_mul:(int)ymul content:(NSString *)content {
//    [_manager PosaddText:x y:y font:font rotation:rotation x_mul:xmul y_mul:ymul content:content];
//}
///**
// * 25.在打印缓冲区中绘制文字
// */
//- (void)PosaddQRCode:(int)x y:(int)y level:(int)level cellWidth:(int)cellWidth rotation:(int)totation data:(NSString *)dataStr {
//    [_manager PosaddQRCode:x y:y level:level cellWidth:cellWidth rotation:totation data:dataStr];
//}
///**
// * 26.设置剥离功能是否开启
// */
//- (void)PosaddPeel:(NSString *)enable {
//    [_manager PosaddPeel:enable];
//}
///**
// * 27.设置撕离功能是否开启
// */
//- (void)PosaddTear:(NSString *)enable {
//    [_manager PosaddTear:enable];
//}
///**
// * 28.设置切刀功能是否开启
// */
//- (void)PosaddCut:(NSString *)enable {
//    [_manager PosaddCut:enable];
//}
///**
// * 29.设置打印机出错时，是否打印上一张内容
// */
//- (void)PosaddReprint:(NSString *)enable {
//    [_manager PosaddReprint:enable];
//}
///**
// * 30.设置是否按走纸键打印最近一张标签
// */
//- (void)PosaddPrintKeyEnable:(NSString *)enable {
//    [_manager PosaddPrintKeyEnable:enable];
//}
///**
// * 31.设置按走纸键打印最近一张标签的份数
// */
//- (void)PosaddPrintKeyNum:(int)m {
//    [_manager PosaddPrintKeyNum:m];
//}

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
