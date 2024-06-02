//
//  ImageTranster.h
//  Printer
//
//  Created by LeeLee on 16/7/19.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ImageTranster : NSObject

typedef enum {
    Dithering=0,//图片单色处理的方式：二值法
    Threshold//抖动算法
} BmpType;

typedef enum {
    RasterNolmorWH=0,//打印光栅位图的模式：正常大小
    RasterDoubleWidth,//倍宽
    RasterDoubleHeight,//倍高
    RasterDoubleWH//倍宽高
} PrintRasterType;



-(UIImage *)covertToGrayScale:(UIImage*)image;
/// Convert the picture to grayscale and then into printer format data
/// @param mImage The picture to be converted
/// @param bmptype Image conversion algorithm type
+(NSData *)Imagedata:(UIImage *) mImage andType:(BmpType) bmptype;
/// Convert pictures to raster bitmap format
/// @param mIamge The picture to be converted
/// @param bmptype Image conversion algorithm type
/// @param type The type of picture print size
+(NSData *)rasterImagedata:(UIImage *) mIamge andType:(BmpType) bmptype andPrintRasterType:(PrintRasterType) type;
+(UIImage *) imageCompressForWidthScale:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
@end
