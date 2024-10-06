//
//  POSImageTranster.h
//  Printer
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface POSImageTranster : NSObject

typedef enum {
    Dithering=0,//bitmap binary method
    Threshold//bitmap dithering
} BmpType;

typedef enum {
    RasterNolmorWH = 0,//print raster bitmap：normal
    RasterDoubleWidth,//double width
    RasterDoubleHeight,//double height
    RasterDoubleWH//double width height
} PrintRasterType;

/**
 * print raster bitmap
 */
+ (NSData *)rasterImagedata:(UIImage *) mIamge andType:(BmpType) bmptype andPrintRasterType:(PrintRasterType) type;

/**
 * bitmap compression print
 */
+ (NSData *)compressionImagedata:(UIImage *) mIamge andType:(BmpType) bmptype andPrintRasterType:(PrintRasterType) type;


@end
