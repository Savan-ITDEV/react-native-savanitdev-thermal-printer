//
//  ZPLCommand.h
//  Printer
//
//  Created by apple on 2022/9/20.
//  Copyright © 2022 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//Rotation
typedef NS_ENUM(NSInteger, ZPLRotation) {
    ROTATION_0 = 0,
    ROTATION_90,
    ROTATION_180,
    ROTATION_270
};

//Font
typedef NS_ENUM(NSInteger, ZPLFont) {
    FNT_9_5 = 0,
    FNT_11_7,
    FNT_18_10,
    FNT_42_20,
    FNT_26_13,
    FNT_60_40,
    FNT_34_22,
    FNT_24_24,
    FNT_20_18,
    FNT_28_24,
    FNT_35_31,
    FNT_40_35,
    FNT_48_42,
    FNT_59_53,
    FNT_80_71,
    FNT_15_12
};

//CodeType
typedef NS_ENUM(NSInteger, ZPLBarCode) {
    CODE_TYPE_11 = 0,
    CODE_TYPE_25,
    CODE_TYPE_39,
    CODE_TYPE_EAN8,
    CODE_TYPE_UPCE,
    CODE_TYPE_93,
    CODE_TYPE_128,
    CODE_TYPE_EAN13,
    CODE_TYPE_CODA,
    CODE_TYPE_MSI,
    CODE_TYPE_PLESSEY,
    CODE_TYPE_UPCEAN,
    CODE_TYPE_UPCA
};

//HriText
typedef NS_ENUM(NSInteger, ZPLHriText) {
    HRI_TEXT_NONE = 0,
    HRI_TEXT_BELOW,
    HRI_TEXT_ABOVE
};

//CodePage
typedef NS_ENUM(NSInteger, ZPLCodePage) {
    CODE_PAGE_USA1 = 0,
    CODE_PAGE_USA2 = 1,
    CODE_PAGE_UK = 2,
    CODE_PAGE_NL = 3,
    CODE_PAGE_DK = 4,
    CODE_PAGE_SWEDE = 5,
    CODE_PAGE_GER = 6,
    CODE_PAGE_FR1 = 7,
    CODE_PAGE_FR2 = 8,
    CODE_PAGE_ITA = 9,
    CODE_PAGE_ES = 10,
    CODE_PAGE_JA = 12,
    CODE_PAGE_UTF8 = 28,
    CODE_PAGE_UTF16_BIG = 29,
    CODE_PAGE_UTF16_LITTLE = 30
};

NS_ASSUME_NONNULL_BEGIN

@interface ZPLCommand : NSObject

/**
 * 命令开始
 * ^XA
 * @return data
 */
+ (NSData *)XA;

/**
 * 命令结束
 * ^XZ
 * @return data
 */
+ (NSData *)XZ;

/**
 * 设置标签宽度
 * @param width label width
 * @return data
 */
+ (NSData *)setLabelWidth:(int)width;

/**
 * 设置标签长度
 * @param height label height
 * @return data
 */
+ (NSData *)setLabelHeight:(int)height;

/**
 * 设置标签浓度
 * @param density label density
 * @return data
 */
+ (NSData *)setDensity:(int)density;

/**
 * 设置标签速度
 * @param speed 打印速度 1~14
 * @return data
 */
+ (NSData *)setSpeed:(int)speed;

/**
 * 打印份数
 * @param count 份数
 * @return data
 */
+ (NSData *)setPageCount:(int)count;

/**
 * 设置自定义字体
 * @param fontName 字体名称
 * @param extension 扩展名
 * @param alias 别名
 * @param codePage ZPLCodePage
 * @return data
 */
+ (NSData *)setCustomFont:(NSString *)fontName extension:(NSString *)extension alias:(NSString *)alias codePage:(ZPLCodePage)codePage;

/**
 * 设置字符编码
 * @param encoding  NSStringEncoding
 */
+ (void)setStringEncoding:(NSStringEncoding)encoding;

/**
 * 文本内容（枚举字体）
 *
 * @param x x-coordinate
 * @param y y-coordinate
 * @param fontName ZPLFont
 * @param content text
 * @return data
 */
+ (NSData *)drawTextWithx:(int)x y:(int)y fontName:(ZPLFont)fontName content:(NSString *)content;

/**
 * 文本内容（枚举字体）
 *
 * @param x x-coordinate
 * @param y y-coordinate
 * @param fontName ZPLFont
 * @param hRatio 整数倍数值 1,2,3...
 * @param wRatio 整数倍数值 1,2,3...
 * @param content text
 * @return data
 */
+ (NSData *)drawTextWithx:(int)x y:(int)y fontName:(ZPLFont)fontName hRatio:(int)hRatio wRatio:(int)wRatio content:(NSString *)content;

/**
 * 文本内容（枚举字体）
 *
 * @param x x-coordinate
 * @param y y-coordinate
 * @param fontName ZPLFont
 * @param rotation ZPLRotation
 * @param hRatio 整数倍数值 1,2,3...
 * @param wRatio 整数倍数值 1,2,3...
 * @param content text
 * @return data
 */
+ (NSData *)drawTextWithx:(int)x y:(int)y fontName:(ZPLFont)fontName rotation:(ZPLRotation)rotation hRatio:(int)hRatio wRatio:(int)wRatio content:(NSString *)content;

/**
 * 文本内容（自定义字体）
 *
 * @param x x-coordinate
 * @param y y-coordinate
 * @param customFontName 自定义字体
 * @param hSize 基础尺寸的整数倍
 * @param wSize 基础尺寸的整数倍
 * @param content text
 * @return data
 */
+ (NSData *)drawTextWithx:(int)x y:(int)y customFontName:(NSString *)customFontName hSize:(int)hSize wSize:(int)wSize content:(NSString *)content;

/**
 * 文本内容（自定义字体）
 *
 * @param x x-coordinate
 * @param y y-coordinate
 * @param customFontName 自定义字体
 * @param rotation ZPLRotation
 * @param hSize 基础尺寸的整数倍
 * @param wSize 基础尺寸的整数倍
 * @param content text
 * @return data
 */
+ (NSData *)drawTextWithx:(int)x y:(int)y customFontName:(NSString *)customFontName rotation:(ZPLRotation)rotation hSize:(int)hSize wSize:(int)wSize content:(NSString *)content;

/**
 * 文本内容（不定义字体，默认FNT_26_13）
 *
 * @param x x-coordinate
 * @param y y-coordinate
 * @param content text
 * @return data
 */
+ (NSData *)drawTextWithx:(int)x y:(int)y content:(NSString *)content;

/**
 * 绘制一维码
 *
 * @param x x-coordinate
 * @param y y-coordinate
 * @param codeType ZPLBarCode
 * @param text 码文内容
 * @return data
 */
+ (NSData *)drawBarcodeWithx:(int)x y:(int)y codeType:(ZPLBarCode)codeType text:(NSString *)text;

/**
 * 绘制一维码
 *
 * @param x x-coordinate
 * @param y y-coordinate
 * @param codeType ZPLBarCode
 * @param height 条码高度
 * @param text 码文内容
 * @return data
 */
+ (NSData *)drawBarcodeWithx:(int)x y:(int)y codeType:(ZPLBarCode)codeType height:(int)height text:(NSString *)text;

/**
 * 绘制一维码
 *
 * @param x x-coordinate
 * @param y y-coordinate
 * @param orientation N:正常 R:旋转90度（顺时针）I:反转180度 B:旋转90度（逆时针）
 * @param width 模块宽度 (以点为单位) 1~10 开机时的初始值:2
 * @param height 条码高度
 * @param hriText ZPLHriText
 * @param text 码文内容
 * @return data
 */
+ (NSData *)drawBarcodeWithx:(int)x y:(int)y orientation:(ZPLRotation)orientation codeType:(ZPLBarCode)codeType width:(int)width height:(int)height hriText:(ZPLHriText)hriText text:(NSString *)text;

/**
 * 绘制二维码
 *
 * @param x x-coordinate
 * @param y y-coordinate
 * @param factor 放大系数:1~10 默认值:在150dpi打印机上为1, 在200dpi打印机上为2, 在300dpi打印机上为3, 在600dpi打印机上为6
 * @param text 二维码内容
 * @return data
 */
+ (NSData *)drawQRCodeWithx:(int)x y:(int)y factor:(int)factor text:(NSString *)text;

/**
 * 绘制图片
 * @param x x-coordinate
 * @param y y-coordinate
 * @param image image
 * @return data
 */
+ (NSData *)drawImageWithx:(int)x y:(int)y image:(UIImage *)image;

/**
 * 绘制图片
 * @param x x-coordinate
 * @param y y-coordinate
 * @param wRatio 1~10
 * @param hRatio 1~10
 * @param image image
 * @return data
 */
+ (NSData *)drawImageWithx:(int)x y:(int)y wRatio:(int)wRatio hRatio:(int)hRatio image:(UIImage *)image;

/**
 * 标签反色打印
 * @param x x-coordinate
 * @param y y-coordinate
 * @param width 宽度
 * @param height 高度
 * @param radius 圆角程度 0~8 default:0
 * @return data
 */
+ (NSData *)drawReverseColorWithx:(int)x y:(int)y width:(int)width height:(int)height radius:(int)radius;

/**
 * 绘制矩形
 * @param x x-coordinate
 * @param y y-coordinate
 * @param width 矩形宽度
 * @param height 矩形高度
 * @param thickness 线条宽度
 * @return data
 */
+ (NSData *)drawBoxWithx:(int)x y:(int)y width:(int)width height:(int)height thickness:(int)thickness;

/**
 * 绘制矩形
 * @param x x-coordinate
 * @param y y-coordinate
 * @param width 矩形宽度
 * @param height 矩形高度
 * @param thickness 线条宽度
 * @param radius 圆角程度 0~8 default:0
 * @return data
 */
+ (NSData *)drawBoxWithx:(int)x y:(int)y width:(int)width height:(int)height thickness:(int)thickness radius:(int)radius;

/**
 * 打印方向
 * @param n 反转标签 YES=正常 NO=反转 默认值:YES
 * @return data
 */
+ (NSData *)direction:(BOOL) n;

/**
 * 调用图形
 * @param x x-coordinate
 * @param y y-coordinate
 * @param source 已存储图像的源设备。接受的值：R、E、B和A，默认值：R 搜索优先级 （R、 E、 B和 A）
 * @param name 已存储图像的名称。接受的值：1 至 8 个字母数字字符。如果未指定名称，则使用 UNKNOWN
 * @param xMagnification x 轴的放大系数。接受的值：1 至 10，默认值：1
 * @param yMagnification y 轴的放大系数。接受的值：1 至 10，默认值：1
 * @return data
 */
+ (NSData *)printGraphic:(int)x
                      y:(int)y
                 source:(NSString *)source
                   name:(NSString *)name
                  xMagnification:(int)xMagnification
                  yMagnification:(int)yMagnification;

/**
 * 下载图形
 * @param source 存储图像的源设备。接受的值：R、E、B和A，默认值：R 搜索优先级 （R、 E、 B和 A）
 * @param name 存储图像的名称。接受的值：1 至 8 个字母数字字符。如果未指定名称，则使用 UNKNOWN
 * @param image image
 * @return data
 */
+ (NSData *)downloadGraphic:(NSString *)source name:(NSString *)name image:(UIImage *)image;

/**
 * 删除已下载的图形
 * @param source 存储图像的源设备。接受的值：R、E、B和A，默认值：R 搜索优先级 （R、 E、 B和 A）
 * @param name 存储图像的名称。接受的值：1 至 8 个字母数字字符。如果未指定名称，则使用 UNKNOWN
 * @return data
 */
+ (NSData *)deleteDownloadGraphic:(NSString *)source name:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
