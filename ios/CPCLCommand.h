//
//  CPCLCommand.h
//  Printer
//
//  Created by apple on 2022/9/20.
//  Copyright © 2022 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//Rotation
typedef NS_ENUM(NSInteger, CPCLRotation) {
    ROTA_0 = 0,
    ROTA_90,
    ROTA_180,
    ROTA_270
};

//Font
typedef NS_ENUM(NSInteger, CPCLFont) {
    FNT_0 = 0,
    FNT_1 = 1,
    FNT_2 = 2,
    FNT_3 = 3,
    FNT_4 = 4,
    FNT_5 = 5,
    FNT_6 = 6,
    FNT_7 = 7,
    FNT_24 = 24,
    FNT_55 = 55
};

//BarCode
typedef NS_ENUM(NSInteger, CPCLBarCode) {
    BC_128 = 0,
    BC_UPCA,
    BC_UPCE,
    BC_EAN13,
    BC_EAN8,
    BC_39,
    BC_93,
    BC_CODABAR
};

//Bar Code Ratio
typedef NS_ENUM(NSInteger, CPCLBarCodeRatio) {
    BCR_RATIO_0 = 0,
    BCR_RATIO_1 = 1,
    BCR_RATIO_2 = 2,
    BCR_RATIO_3 = 3,
    BCR_RATIO_4 = 4,
    BCR_RATIO_20 = 20,
    BCR_RATIO_21 = 21,
    BCR_RATIO_22 = 22,
    BCR_RATIO_23 = 23,
    BCR_RATIO_24 = 24,
    BCR_RATIO_25 = 25,
    BCR_RATIO_26 = 26,
    BCR_RATIO_27 = 27,
    BCR_RATIO_28 = 28,
    BCR_RATIO_29 = 29,
    BCR_RATIO_30 = 30
};

//QR Code Mode
typedef NS_ENUM(NSInteger, CPCLQRCodeMode) {
    CODE_MODE_ORG = 1,
    CODE_MODE_ENHANCE = 2
};

//Alignment
typedef NS_ENUM(NSInteger, CPCLAlignment) {
    ALIGNMENT_LEFT = 0,
    ALIGNMENT_CENTER,
    ALIGNMENT_RIGHT
};

@interface CPCLCommand : NSObject

/**
 * 标签初始化
 * @param height 标签高度
 * @return data
 */
+ (NSData *)initLabelWithHeight:(int)height;

/**
 * 标签初始化
 * @param height 标签高度
 * @param count 标签数量
 * @return data
 */
+ (NSData *)initLabelWithHeight:(int)height count:(int)count;


/**
 * 标签初始化
 * @param height  标签高度
 * @param count  标签数量
 * @param offsetx  横向偏移位置
 * @return data
 */
+ (NSData *)initLabelWithHeight:(int)height count:(int)count offsetx:(int)offsetx;

/**
 * 设置字体放大倍数
 * @param w 宽度放大倍数 1～16
 * @param h 高度放大倍数 1～16
 * @return data
 */
+ (NSData *)setmagWithw:(int)w h:(int)h;

/**
 * 设置字段的对齐方式 default:左对齐所有字段。
 * @param alignment CPCLAlignment
 * @return data
 */
+ (NSData *)setAlignment:(CPCLAlignment)alignment;


/**
 * 设置字段的对齐方式 default:左对齐所有字段。
 * @param alignment CPCLAlignment
 * @param end 对齐的结束点
 * @return data
 */
+ (NSData *)setAlignment:(CPCLAlignment)alignment end:(int)end;

/**
 * 设置打印速度
 * @param level 速度级别 0~5
 * @return data
 */
+ (NSData *)setSpeedLevel:(int)level;

/**
 * 设置打印宽度
 * @param width 页面的单位宽度
 * @return data
 */
+ (NSData *)setPageWidth:(int)width;

/**
 * 设置蜂鸣发出时间
 * @param length 蜂鸣持续时间，以1/8秒为单位，例如16表示发声时间为2秒
 * @return data
 */
+ (NSData *)setBeepLength:(int)length;

/**
 * 设置字符编码
 * @param encoding NSStringEncoding
 */
+ (void)setStringEncoding:(NSStringEncoding)encoding;

/**
 绘制文本内容
 @param x x-coordinate
 @param y y-coordinate
 @param content 内容
 @return data
 */
+ (NSData *)drawTextWithx:(int)x y:(int)y content:(NSString *)content;

/**
 绘制文本内容
 @param x x-coordinate
 @param y y-coordinate
 @param font FontType
 @param content 内容
 @return data
 */
+ (NSData *)drawTextWithx:(int)x y:(int)y font:(CPCLFont)font content:(NSString *)content;

/**
 绘制文本内容
 @param x x-coordinate
 @param y y-coordinate
 @param font FontType
 @param rotation RotationType
 @param content 内容
 @return data
 */
+ (NSData *)drawTextWithx:(int)x y:(int)y rotation:(CPCLRotation)rotation font:(CPCLFont)font content:(NSString *)content;

/**
 指示打印机在一页打印结束后切换至下一页顶部
 @return data
 */
+ (NSData *)form;

/**
 结束命令 将会启动打印
 @return data
 */
+ (NSData *)print;

/**
 绘制一维码
 @param x x-coordinate
 @param y y-coordinate
 @param codeType CPCLBarCode
 @param height 条码高度
 @param content 内容
 @return data
 */
+ (NSData *)drawBarcodeWithx:(int)x y:(int)y codeType:(CPCLBarCode)codeType height:(int)height content:(NSString *)content;

/**
 绘制一维码
 @param x x-coordinate
 @param y y-coordinate
 @param codeType CPCLBarCode
 @param height 条码高度
 @param ratio 宽条与窄条的比率，默认 BCR_RATIO_1
 @param content 内容
 @return data
 */
+ (NSData *)drawBarcodeWithx:(int)x y:(int)y codeType:(CPCLBarCode)codeType height:(int)height ratio:(CPCLBarCodeRatio)ratio content:(NSString *)content;

/**
 绘制一维码
 @param x x-coordinate
 @param y y-coordinate
 @param codeType CPCLBarCode
 @param height 条码高度
 @param content 内容
 @return data
 */
+ (NSData *)drawBarcodeVerticalWithx:(int)x y:(int)y codeType:(CPCLBarCode)codeType height:(int)height content:(NSString *)content;

/**
 绘制一维码
 @param x x-coordinate
 @param y y-coordinate
 @param codeType CPCLBarCode
 @param height 条码高度
 @param ratio 宽条与窄条的比率，默认 BCR_RATIO_1
 @param content 内容
 @return data
 */
+ (NSData *)drawBarcodeVerticalWithx:(int)x y:(int)y codeType:(CPCLBarCode)codeType height:(int)height ratio:(CPCLBarCodeRatio)ratio content:(NSString *)content;

/**
 添加条码注释
 @param offsetx 文本距离条码的单位偏移量
 */
+ (NSData *)barcodeText:(int)offsetx;


/**
 * 取消条码注释
 */
+ (NSData *)barcodeTextOff;

/**
 绘制二维码
 @param x x-coordinate
 @param y y-coordinate
 @param content 内容
 @return data
 */
+ (NSData *)drawQRCodeWithx:(int)x y:(int)y content:(NSString *)content;

/**
 绘制二维码
 @param x x-coordinate
 @param y y-coordinate
 @param codeModel CPCLBarCode
 @param cellWidth 单元格大小 1~32 default:6
 @param content 内容
 @return data
 */
+ (NSData *)drawQRCodeWithx:(int)x y:(int)y codeModel:(CPCLQRCodeMode)codeModel cellWidth:(int)cellWidth content:(NSString *)content;

/**
 绘制图片
 @param x x-coordinate
 @param y y-coordinate
 @param image UIImage
 @return data
 */
+ (NSData *)drawImageWithx:(int)x y:(int)y image:(UIImage *)image;

/**
 绘制矩形
 @param x x-coordinate
 @param y y-coordinate
 @param width 矩形宽度
 @param height 矩形高度
 @param thickness 矩形线宽
 @return data
 */
+ (NSData *)drawBoxWithx:(int)x y:(int)y width:(int)width height:(int)height thickness:(int)thickness;

/**
 绘制线条
 @param x 线条起始横坐标 单位为点
 @param y 线条起始纵坐标 单位为点
 @param xend 线条结束横坐标 单位为点
 @param yend 线条结束纵坐标 单位为点
 @param width 线条宽度
 @return data
 */
+ (NSData *)drawLineWithx:(int)x y:(int)y xend:(int)xend yend:(int)yend width:(int)width;

/**
 将指定区域的数据黑白反向显示
 @param x 反显区域起始横坐标 单位为点
 @param y 反显区域起始纵坐标 单位为点
 @param xend 反显区域结束横坐标 单位为点
 @param yend 反显区域结束纵坐标 单位为点
 @param width 反显区域宽度 单位为点
 @return data
 */
+ (NSData *)drawInverseLineWithx:(int)x y:(int)y xend:(int)xend yend:(int)yend width:(int)width;


@end

NS_ASSUME_NONNULL_END
