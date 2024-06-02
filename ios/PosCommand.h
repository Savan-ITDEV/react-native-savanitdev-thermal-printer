//
//  PosCommand.h
//  Printer
//
//  Created by LeeLee on 16/7/19.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageTranster.h"

/**
 pos指令类，调用其类方法可返回Nsdata类型的数据，用于发送，此类只适用于pos打印机
 */
@interface PosCommand:NSObject

/**
 水平定位
 HT
 09
 */
+(NSData *) horizontalPosition;
/**
 打印并换行
 LF
 0A
 */
+(NSData *) printAndFeedLine;
/**
 打印并回到标准模式
 FF
 OC
 */
+(NSData *) printAndBackStandardModel;
/**
 打印并跳格
 CR
 0D
 */
+(NSData *) printAndTabs;
/**
 页模式下取消打印数据
 CAN
 18
 */
+(NSData *) canclePrintDataByPageModel;
/**
 实时状态传送
 DLE EOT n
 10 04 n
 @param n 1<=n<=4.
 */
+(NSData *) sendRealTimeStatus:(int) n;
/**
 实时对打印机请求
 DLE ENQ n
 10 05 n
 @param n 1<=n<=2.
 */
+(NSData *) requestRealTimeForPrint:(int) n;
/**
 实时产生开钱箱脉冲
 DLE DC4 n m t
 10 14 01 m t
 @param m m=0,或1；
 @param t 1<=t<=8.
 */
+(NSData *) openCashBoxRealTimeWithM:(int) m andT:(int) t;
/**
 页模式下打印
 ESC FF
 1B 0C
 该命令只在页模式下有效
 */
+(NSData *) printUnderPageModel;
/**
 设置字符右间距
 1B 20 n
 @param n 0~255,in dots.
 */
+(NSData *) setCharRightSpace:(int) n;
/**
 选择打印模式
 ESC !n
 1B 21 n
 @param n 0~255,只有n的最后一位有效，0代表取消，1代表选择.
 */
+(NSData *) selectPrintModel:(int) n;
/**
 设置绝对打印位置
 ESC $ nL nH
 1B 24 nL nH
 nL+nH*256 代表距离行首位置
 */
+(NSData *) setAbsolutePrintPositionWithNL:(int) nL andNH:(int) nH;
/**
 选择或取消用户自定义字符
 ESC % n
 1B 25 n
 @param n 0~255,只有n的最后一位有效，0代表取消，1代表选择.
 */
+(NSData *) selectOrCancleCustomChar:(int) n;
/**
 定义用户自定义字符
 ESC * m nL nH d1 d2 ...dk
 @param c1 起始字符代码
 @param c2 终止字符代码，32<=c1<=c2<=127
 @param bytes 字符下载的字符的二进制数据。
 */
+(NSData *) defineUserDefinedCharactersWithM:(int) m andNL:(int) nL andNH:(int) nH andBytes:(Byte *) bytes;
/**
 选择位图模式
 ESC * m nL nH d1 d2 ...dk
 b={d1,d2...dk},m=0,1时，k=nL+256*nH;m=32,33时，k=(nL+256*nH)*3;d:0-255;
 @param m m 范围：0，1，32，33，代表不同点的密度
 @param nL nL范围：0-255
 @param nH nH范围：0-3
 @param data b={d1,d2...dk},m=0,1时，k=nL+256*nH;m=32,33时，k=(nL+256*nH)*3;d:0-255;
 */
+(NSData *) selectBmpModelWithM:(int) m andnL:(int) nL andnH:(int) nH andNSData:(NSData *) data;
/**
 选择或取消下划线模式
 ESC-n
 1B 2D n
 @param n 0 or 48 cancel;1 or 49 select(by 1 dot);2 or 50 select (by 2 dots).
 */
+(NSData *) selectOrCancleUnderLineModel:(int) n;
/**
 设置默认行间距
 ESC 2
 */
+(NSData *) setDefultLineSpace;
/**
 设置行间距
 ESC 3 n
 1B 33 n
 */
+(NSData *) setDefultLineSpace:(int) n;
/**
 选择打印机
 ESC = n
 1B 3D n
 n 0或1
 */
+(NSData *) selectPrinter:(int) n;
/**
 取消用户自定义字符
 ESC ? n
 取消用户自定义字符中代码为n的字符
 n 范围：32-127
 */
+(NSData *) cancleUserDefinedCharacters:(int) n;
/**
 初始化打印机
 ESC @
 1B 40
 */
+(NSData *) initializePrinter;
/**
 设置横向跳格位置
 ESC D n1 ...nk NUL
 @param data data={n1...nk};k<=32;跳格距离=字符宽度*k,参数data内的n值和k值请参考编程手册
 */
+(NSData *) setHorizontalTabsPosition:(NSData *) data;
/**
 选择或取消加粗模式
 ESC E n
 1B 45 n
 @param n 0~255,只有n的最后一位有效，0代表取消，1代表选择.
 */
+(NSData *) selectOrCancleBoldModel:(int) n;
/**
 选择或取消双重打印模式
 ESC G n
 1B 47 n
 @param n 0~255,只有n的最后一位有效，0代表取消，1代表选择.
 */
+(NSData *) selectOrCancleDoublePrintModel:(int) n;
/**
 打印并走纸
 ESC J n
 1B 4A n
 @param n specify the length(in inch) feeds.
 */
+(NSData *) printAdnFeed:(int) n;
/**
 选择页模式
 ESC L
 1B 4C
 
 */
+(NSData *) selectPagemodel;
/**
 选择字体
 ESC M n
 1B 4D n
 n 范围： 0，1，48，49；
 */
+(NSData *) selectFont:(int) n;
/**
 选择国际字符集
 ESC R n
 n 0-15，代表一种国际字符集
 1B 52 n
 */
+(NSData *) selectInternationCharacterSets:(int) n;
/**
 选择标准模式
 ESC S
 1B 53
 */
+(NSData *) selectStabdardModel;
/**
 在页模式下选择打印区域方向
 ESC T n
 1B 54 n
 @param n 0<=n<=3 or 48<=n<=51;n指定打印区域的方向和起始位置。
 */
+(NSData *) selectPrintDirectionUnderPageModel:(int) n;
/**
 选择或取消顺时针旋转90度
 此命令只在页模式下有效
 ESC V n
 1B 56 n
 @param n n=0 or 48代表取消；n=1 or 49代表选择.
 */
+(NSData *) selectOrCancleCW90:(int) n;
/**
 页模式下设置打印区域
 ESC W xL xH yL yH dxL dxH dyL dyH
 1B 57 xL xH yL yH dxL dxH dyL dyH
 xL+xH*256 代表x方向起始位置
 yL+yH*256 代表y方向起始位置
 dxL+dxH*256 代表x方向的宽度
 dyL+dyH*256 代表y方向的高度
 */
+(NSData *) setPrintAreaUnderPageModelWithxL:(int) xL
                                       andxH:(int) xH
                                       andyL:(int) yL
                                       andyH:(int) yH
                                      anddxL:(int) dxL
                                      anddxH:(int) dxH
                                      anddyL:(int) dyL
                                      anddyK:(int) dyH;
/**
 设置相对横向打印位置
 ESC \ nL nH
 1B 5C nL nH
 nL+nH*256 代表设置的大小
 */
+(NSData *) setRelativeHorizontalPrintPositionWithnL:(int) nL andnH:(int) nH;
/**
 选择对齐方式
 ESC a n
 1B 61 n
 */
+(NSData *) selectAlignment:(int) n;
/**
 选择打印机传感器以输出却纸信号
 ESC c 3 n
 1B 63 33 n
 @param n 0~255.
 */
+(NSData *) selectPrintTransducerOutPutPageOutSignal:(int) n;
/**
 选择打印机传感器-停止打印
 ESC c 4 n
 1B 63 34 n
 @param n 0~255.
 */
+(NSData *) selectPrintTransducerStopPrint:(int) n;
/**
 允许或禁止按键
 ESC c 5 n
 1B 63 35 n
 @param n n的最后一位决定，1则允许，0则禁止。
 */
+(NSData *) allowOrForbidPressButton:(int) n;
/**
 打印并向前走纸n行
 ESC d n
 1B 64 n
 @param n 0~255.
 */
+(NSData *) printAndFeedForwardWhitN:(int) n;
/**
 产生钱箱控制脉冲
 ESC p m t1 t2
 1B 70 m t1 t2
 @param m:连接引脚,0 or 1 or 48 or 49.
 t1 ,t2 :0~255.
 */
+(NSData *) creatCashBoxContorPulseWithM:(int) m andT1:(int) t1 andT2:(int) t2;
/**
 选择字符代码表
 ESC t n
 1B 74 n
 @param n 0~10 or 16~19
 */
+(NSData *) selectCharacterCodePage:(int) n;
/**
 选择或取消倒置打印
 ESC { n
 1B 7B n
 @param n n的最后一位决定，1则选择，0则取消。
 */
+(NSData *) selectOrCancleConvertPrintModel:(int) n;
/**
 打印下载到FLASH中的位图
 FS p n m
 @param n 代表FLASH缓存中的第n个位置的图像
 @param m 打印FLASH位图的方式，0~3 or 48~51，分别代表正常，倍宽，倍高，倍宽高。
 */
+(NSData *) printBmpInFLASHWithN:(int) n andM:(int) m;
/**
 定义FLASH位图
 FS q n [xL xH yL yH d1...dk]...[xL xH yL yH d1...dk]
 1C 71 n data
 n:定义的位图数量
 data=[xL xH yL yH d1...dk]...[xL xH yL yH d1...dk]，代表多个位图的数据，每个位图前都包含了xL xH yL yH代表图像数据宽和高
 */
+(NSData *) definedFlashBmpWithN:(int) n andBmp:(UIImage *) image andBmpType:(BmpType) bmptype andPrintType:(PrintRasterType) type;
/**
 选择字符大小
 GS ! n
 @param n 0~255,n的0-3位设定字符高度，4-7为来设定字符宽度。
 */
+(NSData *) selectCharacterSize:(int) n;
/**
 页模式下设置绝对位置
 GS $ nL nH
 1D 24 nL nH
 nL ,nH 范围：0~255，nL+nH*256代表位置，单位inch
 */
+(NSData *) setAbsolutePositionUnderPageModelWithnL:(int) nL andnH:(int) nH;
/**
 定义下载位图
 GS x y[d1...d(8*xy)]
 1D 2A data
 @param image  image对象
 */
+(NSData *) definedDownLoadBmp:(UIImage *) image byType:(BmpType) bmptype;
/**
 执行打印机数据十六进制转储
 GS ( A pL pH n m
 1D 28 41 02 00 00 01
 */
+(NSData *) executePrintDataSavaByTeansformToHex;
/**
 打印下载位图
 GS / m
 1D 2F m
 @param m:打印模式，范围：0~3 or 48~51.
 */
+(NSData *) printDownLoadBmp:(int) m;
/**
 开始或结束宏定义
 GS :
 1D 3A
 */
+(NSData *) startOrStopMacrodeFinition;
/**
 选择或取消黑白反显打印模式
 GS B n
 1D 42 n
 @param n n的最后一位为1，选择，为0，取消.
 */
+(NSData *) selectOrCancleInvertPrintModel:(int) n;
/**
 选择HRI字符打印位置
 GS H n
 1D 48 n
 @param n 0~3 or 48~51,代表字符相对条码的打印位置。
 */
+(NSData *) selectHRICharactersPrintPosition:(int) n;
/**
 设置左边距
 GS L nL nH
 1D 4C nL nH
 (nL+nH*256)*横向移动单位，代表设置的左边距，单位：inch.
 */
+(NSData *) setLeftSpaceWithnL:(int) nL andnH:(int) nH;
/**
 设置横向和纵向移动单位
 GS P x y
 1D 50 x y
 @param x 横向移动单位，0~255.
 @param y 纵向移动单位，0~255.
 */
+(NSData *) setHorizontalAndVerticalMoveUnitWithX:(int) x andY:(int) y;
/**
 选择切纸模式并切纸
 GS V m
 1D 56 m
 @param m 0 or 48,全切;1 or 49，半切.
 */
+(NSData *) selectCutPageModelAndCutpage:(int) m;

/**
 选择切纸模式并切纸
 GS V m n
 1D 56 m n
 @param m m=66.
 @param n 进纸n，然后半切纸。
 
 */
+(NSData *) selectCutPageModelAndCutpageWithM:(int) m andN:(int) n;
/**
 设置打印区域宽度
 GS W nL nH
 1D 57 nL nH
 (nL+nH*256)*横向移动单位，代表打印区域宽度.
 */
+(NSData *) setPrintAreaWidthWithnL:(int) nL andnH:(int) nH;
/**
 页模式下设置绝对打印位置
 GS \ nL nH
 1D 5C nL nH
 (nL+nH*256)*纵向移动单位，代表相对于当前打印位置纵向移动距离.
 */
+(NSData *) setVertivalRelativePositionUnderPageModelWithNL:(int) nL andNH:(int) nH;
/**
 执行宏命令
 GS ^ r t m
 1D 5E r t m
 @param r 0~255,执行次数.
 @param t 0~255,执行等待时间。
 @param m 0 or 1,执行模式。
 */
+(NSData *) executeMacrodeCommandWithR:(int) r andT:(int) t andM:(int) m;
/**
 打开或关闭自动状态返回功能
 GS a n
 1D 61 n
 @param n 0~255,n的每一位代表不同类型的状态返回.
 */
+(NSData *) openOrCloseAutoReturnPrintState:(int) n;
/**
 选择HRI使用字体
 GS f n
 1D 66 n
 @param n 0 or 48 代表标准；1 or 49 代表压缩字体。
 
 */
+(NSData *) selectHRIFont:(int) n;
/**
 选择条码高度
 GS h n
 1D 68 n
 @param n 1~255,defualt:162.
 */
+(NSData *) setBarcodeHeight:(int) n;
/**
 打印条码
 GS k m d1...dk NUL
 1D 6B m d1...dk 00
 @param m 条码类型，0~6.
 @param content 条码内容。
 
 */
+(NSData *) printBarcodeWithM:(int) m andContent:(NSString *) content useEnCodeing:(NSStringEncoding) strEncoding;

/**
 打印条码
 GS k m n d1...dk
 1D 6B m n d1...dk
 @param m 条码类型,66~73.
 @param n 条码内容content的长度。
 */
+(NSData *) printBarcodeWithM:(int)m andN:(int) n andContent:(NSString *)content useEnCodeing:(NSStringEncoding) strEncoding;
/**
 返回状态
 GS r n
 1D 72 n
 @param n 1,2,49,50;1 or 49返回传感器状态，2 or 50返回钱箱状态。
 */
+(NSData *) returnState:(int) n;
/**
 打印光栅位图
 GS V 0 m
 (PrintRasterType) m:打印模式。
 (UIImage *) image:图片对象。
 (BmpType) type:图片处理采用的方式，二值法或者抖动算法处理。
 
 */
+(NSData *) printRasteBmpWithM:(PrintRasterType) m andImage:(UIImage *) image andType:(BmpType) type;
/**
 设置条码宽度
 GS w n
 1D 77 n
 @param n:2~6,defualt 3.
 */
+(NSData *) setBarcoeWidth:(int) n;
/**
 设置汉字字符模式
 FA ! n
 1C 21 n
 @param n 0~255,n的不同位定义字符模式。
 */
+(NSData *) setChineseCharacterModel:(int) n;
/**
 选择汉字模式
 FS &
 1C 26
 */

+(NSData *) selectChineseCharacterModel;
/**
 选择或取消汉字下划线模式
 FS - n
 1C 2D n
 @param n 0~2 or 48~50.
 */

+(NSData *) selectOrCancelChineseCharUnderLineModel:(int) n;
/**
 取消汉字模式
 FS .
 1C 2E
 */

+(NSData *) CancelChineseCharModel;
/**
 定义用户自定义汉字
 FS 2 c1 c2 d1...dk
 1C 32 FE c2 d1...dk
 @param c2 A1H<=c2<=FEH.
 @param bytes 代表汉字数据的字节数组。
 */
+(NSData *) definedUserDefinedChineseCharWithCPosition:(int) c2 andNsdata:(Byte *) bytes;
/**
 设置汉字字符左右间距
 FS S n1 n2
 1C 53 n1 n2
 @param n1:左间距，0~255.
 @param n2:右间距，0~255.
 */
+(NSData *) setChineseCharLeftAndRightSpaceWithN1:(int) n1 andN2:(int) n2;
/**
 选择或取消汉字倍宽倍宽
 FS W n
 1C 57 n
 @param n 0~255,n的最低位为1，代表选择，为0，代表取消。
 */

+(NSData *) selectOrCancelChineseCharDoubleWH:(int) n;
/**
 打印机来单打印蜂鸣提示
 ESC B n t
 1B 42 n t
 @param n 蜂鸣次数，1~9.
 @param t t*50ms代表每次蜂鸣时间，1~9.
 */
+(NSData *) printerOrderBuzzingHintWithRes:(int) n andTime:(int) t;
/**
 打印机来单蜂鸣提示及报警灯闪烁
 ESC C m t n
 1B 43 m t n
 @param m 蜂鸣次数，报警灯闪烁次数，1~20.
 @param t (t*50ms)代表间隔时间，1~20.
 @param n 0~3,分别代表是否鸣叫，闪烁.
 */
+(NSData *) printerOrderBuzzingAndWaringLightWithM:(int) m andT:(int) t andN:(int) n;
/**
 QRCODE:设置单元大小
 GS ( 0 g n
 1D 28 6B 30 67 n
 @param n 0~255.
 */

+(NSData *) setQRcodeUnitsize:(int) n;
/**
 设置错误纠正等级
 GS ( 0 i n
 1D 28 6B 30 69 n
 */

+(NSData *) setErrorCorrectionLevelForQrcode:(int) n;
/**
 传输数据到编码缓存
 GS ( 0 & nL nH d1...dk
 1D 28 6B 30 80 nL nH d1...dk
 (NSString *) str 二维码的内容。
 */

+(NSData *) sendDataToStoreAreaWitQrcodeConent:(NSString *) str usEnCoding:(NSStringEncoding) strEnCoding;
/**
 打印编码缓存的二维码
 GS ( 0 ?
 1D 28 6B 30 81
 */

+(NSData *) printTheQRcodeInStore;

/**
 Set the number of columns in the data region
 1D 28 6B 03 00 30 41 n
 
 */

+(NSData *) setPdf417Columns:(int) n;

/**
 set the width of the moudule
 1D 28 6B 03 00 30 43 n
 
 */

+(NSData *) setpdf417WidthOfModule:(int) n;

/**
 set the row height
 1D 28 6B 03 00 30 44 n
 
 */

+(NSData *) setpdf417RowHeight:(int) n;

/**
 store the data in the symbol storage area
 1D 28 68 F9 00 30 50 30 d1...dk
 
 */
+(NSData *) storethepdf417WithpL:(int) pL andpH:(int) pH andContent:(NSString*) content usEnCoding:(NSStringEncoding) strEnCoding;

/**
 print the pdf417 symbol data in the symbol storage area
 1D 28 6B 03 00 30 51 n
 
 */

+(NSData *) printPdf417InStore;
@end
