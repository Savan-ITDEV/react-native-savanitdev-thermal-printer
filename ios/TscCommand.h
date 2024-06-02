//
//  TscCommand.h
//  Printer
//
//  Created by LeeLee on 16/7/19.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "ImageTranster.h"
///TSC指令类，调用其类方法可返回Nsdata类型的数据，用于发送，此类只适用于TSC打印机
@interface TscCommand : NSObject

/**
 this command defines the label width and lenth
 设定标签纸的宽度及长度
 SIZE m mm,n mm
 单位 mm
 @param m label width
 @param n label length
 @discussion
 */
+(NSData *) sizeBymmWithWidth:(double) m andHeight:(double) n;

/**
 this command defines the label width and lenth
 设定标签纸的宽度及长度
 SIZE m ,n
 单位 inch
 @param m label width
 @param n label length
 */
+(NSData *) sizeByinchWithWidth:(double) m andHeight:(double) n;

/**
 this command defines the label width and lenth
 设定标签纸的宽度及高度
 SIZE m ,n
 单位 dot
 @param m  label width
 @param n label length
 */
+(NSData *) sizeBydotWithWidth:(int) m andHeight:(int) n;

/**
 this command defines the gap distance between to labels
 设置标签纸的垂直间距
 GAP m mm,n mm
 单位 mm
 @param m the gap distance between two labels
 @param n the offset distance of the gap
 */
+(NSData *) gapBymmWithWidth:(double) m andHeight:(double) n;


/**
 
 this command defines the gap distance between to labels
 设置标签纸的间距
 GAP m,n
 单位 inch
 @param m the gap distance between two labels
 @param n the offset distance of the gap
 */
+(NSData *) gapByinchWithWidth:(double) m andHeight:(double) n;

/**
 this command defines the gap distance between to labels
 设置标签纸的间距
 GAP m,n
 单位 dot
 @param m the gap distance between two labels
 @param n the offset distance of the gap
 */
+(NSData *) gapBydotWithWidth:(int) m andHeight:(int) n;

/**
 this command feeds the paper throught the gap sensor in an effort to determine the paper and gap sizes,respectively.
 
 GAPDETECT x,y
 单位 （dot）
 @param x paper length（in dots）
 @param y gap length(in dots)
 */
+(NSData *) gapDetectWithX:(int) x andY:(int) y;
/**
 this command feeds the paper through the gap sensor in an effort to determine the paper and gap sizes,respectively.
 
 GAPDETECT
 
 ( */

+(NSData *) gapDetect;

/**
 this command feeds the paper through the black mark sensor in an effort to the determine the paper and black mark size.
 BLINEDDETECT X,Y
 @param x paper lenght(in dots)
 @param y gap lenght(in dots)
 */
+(NSData *) blinedDetectWithX:(int) x andY:(int) y;

/**
 this command feeds the paper through the gap/black mark sensor in an effort to deternine the paper and gap/black mark size.
 AUTODETECT X,Y
 @param x paper length(in dots)
 @param y gap length(in dots)
 */
+(NSData *) autoDetectWithX:(int) x andY:(int) y;

/**
 this command sets the height of the black line and the user-defined extra label feeding length each from feed takes.
 设定黑标的高度及偏移位置
 BLINE M,N
 单位 inch
 @param m the height of black line in  mm
 @param n  the extra label feeding length
 */
+(NSData *) blineByinchWithM:(double) m andN:(double) n;

/**
 this command sets the height of the black line and the user-defined extra label feeding length each from feed takes.
 设定黑标的高度及偏移位置
 BLINE M,N
 单位 inch
 @param m the height of black line in inch
 @param n the extra label feeding length
 */
+(NSData *) blineBymmWithM:(double) m andN:(double) n;

/**
 this command sets the height of the black line and the user-defined extra label feeding length each from feed takes.
 设定黑标的高度及偏移位置
 BLINE M,N
 @param m  the height of black line either in dot
 @param n the extra label feeding length
 */
+(NSData *) blineBydotWithM:(int) m andN:(int) n;

/**
 this command sets the position of label under the pee-off mode.
 OFFSET m
 剥离模式下，控制每张标签停止的位置
 单位 inch
 @param m the offset distance(in inch)
 */
+(NSData *) offSetByinchWithM:(double) m;

/**
 this command sets the position of label under the pee-off mode.
 OFFSET m mm
 剥离模式下，控制每张标签停止的位置
 单位 mm
 @param m the offset distance(in mm)
 */
+(NSData *) offSetBymmWithM:(double) m;

/**
 this command sets the position of label under the pee-off mode.
 OFFSET m mm
 剥离模式下，控制每张标签停止的位置
 单位 dot
 @param m the offset distance(in dots)
 */
+(NSData *) offSetBydotWithM:(int) m;

/**
 this command defines the print speed
 SPEED N
 设置走纸速度
@param n  printing speed in inch per second
 */

+(NSData *) speed:(double) n;

/**
 this command sets the printing daekesss
 DENSITY n
@param n  specifiles the lightest/darkest level
 */

+(NSData *) density:(int) n;

/**
 this command defines the printout direction and mirror image.this will be stored in the printermemory.
 定义打印时出纸方向
 DIRECTION n
@param n  0 or 1,please refer to the illustrations below.
 */

+(NSData *) direction:(int) n;

/**
 this command defines the reference point the of the label.the referce (origin) point varies with the print direction,as shown.
 用于定义标签的参考坐标原点
 REFERENCE x,y
 @param x   Horizontal coordinate(in dots).
 @param y    Vertical coordinate (in dots).
 */
+(NSData *) referenceWithX:(int) x andY:(int) y;

/**
 this command moves the label's vertical position.
 SHIFT n
@param n  the maximum calue is 1 inch.for 200 dpi printers,this range is -203 to 203;for 300 dpi printers,the range is -300 to 300.this unit is dot.
 */

+(NSData *) shift:(int) n;

///this command orients the keyboard for use in different countries via defining special characters on the KP-200 series portable LCD keyboard (option).
///用于选择国际字符集
/// @param countryCoding the keyboard for use in different countries via defining special characters
+(NSData *) country:(NSString *) countryCoding;

/**
 this command orients the keyboard for use in different countries via defining special characters on the KP-200 series portable LCD keyboard (option).
 指定字符编码
 CODEPAE n
 @param str  the name of codepage;
 */

+(NSData *) codePage:(NSString *) str;

/**
 this command clears the iamge buffer.
 清除缓存
 CLS
 
 */

+(NSData *) cls;

/**
 this command feeds label with the specified length. the length is specified by dot.
 控制进纸距离，单位dot
 FEED n
@param n  the length label feeds.
 */

+(NSData *) feed:(int) n;

/**
 this command feeds the label in reverse.the length is specified by dot.
 BACKFEED n
 n的单位 dot
@param n  the length babel feeds in reverse.
 */

+(NSData *) backFeed:(int) n;

/**
 this command feeds label to the beginning of next label.
 FORMFEED
 
 */

+(NSData *) formFeed;

/**
 
 this command will feed label until the sensor has determined origin.
 HOME
 
 */

+(NSData *) home;

/**
 this command prints the label format currently stored in the image buffer.
 PRINT M,N
@param m  specifies how many sets of labels will be printed
@param n  specifies how many copies should be printed for each particular label set.
 */
+(NSData *) printWithM:(int) m andN:(int) n;

/**
 this command prints the label format currently stored in the image buffer.
 PRINT m
 @param m   specifies how many sets of labels will be printed
 */

+(NSData *) print:(int) m;

/**
 this command controls the sound frequency of the beeper .there are 10 levels of sounds
 SOUND level,interval
 @param level sound level:0-9.
 @param interval sound interval:1-4095.
 */
+(NSData *) soundWithLevel:(int) level andInterval:(int) interval;

/**
 this command activates the cutter to immediately cut the labels without back feeding the label.
 切纸
 CUT
 
 */

+(NSData *) cut;

/**
 this command use to stop feeding paper while feed paper wrong.
 用于设定打印机进纸时，无法检测到垂直间距，发送错误，停止进纸
 LIMITFEED n
 单位 inch
@param n the limit length of wrong(in inch).
 */

+(NSData *) limitFeedByinch:(double) n;

/**
 this command use to stop feeding paper while feed paper wrong.
 用于设定打印机进纸时，无法检测到垂直间距，发送错误，停止进纸
 LIMITFEED n
 单位 mm
@param n the limit length of wrong(in mm).
 */

+(NSData *) limitFeedBymm:(double) n;


/**
 this command use to stop feeding paper while feed paper wrong.
 用于设定打印机进纸时，无法检测到垂直间距，发送错误，停止进纸
 LIMITFEED n
 单位 dot
@param n the limit length of wrong(in dots).
 */

+(NSData *) limitFeedBydot:(int) n;

/**
 At this command ,the printer will print out the printer information
 SELFTEST
 
 */

+(NSData *) selfTest;

/**
 At this command,the printer will print out the printer information
 SELFTEST page
@param page the one kind of the printer informations.
 */

+(NSData *) selfTest:(NSString *) page;

/**
 let the printer wait until process of commands (before EOJ) be then go on the next command
 EOJ
 
 */

+(NSData *) eoj;

/**
 let the printer wait specific period of time then go on next command
 DELAY ms
@param ms  print delay how many seconds.
 */

+(NSData *) delay:(int) ms;

/**
 this command can show the image ,which is in printer's image buffer,on LCD panel
 DISPLAY IMAGE/OFF
@param str  IMAGE showthe image in printer's image buffer,on LCD panel
                  OFF   disable this finction.
 */

+(NSData *) display:(NSString*) str;

/**
 this command can restore printer settings to defaults
 INITIALPRINTER
 
 */

+(NSData *) initialPrinter;

/**
 this command draws a bar on the label format.
 BAR x,y,width,heigt
 
 @param x   the upper left corner x-coordinate (in dots).
 @param y    the upper left corner y-coordinate (in dots).
@param w bar width(in dots).
@param h bar height(in dots).
 
 */
+(NSData *) barWithX:(int) x andY:(int) y andWidth:(int) w andHeigt:(int) h;

/**
 this command prints 1D barcodes
 BARCODE X,Y,"codetype",height,humanreadable,rotation,narrow,wide,"content"
 @param x   specify the x-coordinate.
 @param y    specify the y-coordinate.
@param readable HRI readable,0-3;
@param rotation graphic rotation,0-90-180-270;
@param narrow space in uint.
@param wide width of uint.
@param content barcode's content.
@param strEnCoding barcode's content's encoding.
 */
+(NSData *) barcodeWithX:(int) x
                    andY:(int) y
             andCodeType:(NSString*) codetype
               andHeight:(int) height
        andHunabReadable:(int) readable
             andRotation:(int) rotation
               andNarrow:(int) narrow
                 andWide:(int) wide
              andContent:(NSString*) content
           usStrEnCoding:(NSStringEncoding) strEnCoding;


/**
 this command draws bitmap images.
 BITMAP X,Y,width,height,mode,bitmap data
 @param x   specify the x-coordinate
 @param y    specify the y-coordinate
@param mode graphic modes listed below:
                0:OVERWRINTE
                1:OR
                2:XOR
 @param image the graphic you want to print.
 @param bmptype the type you want to print the image.
 */
+(NSData *) bitmapWithX:(int) x
                   andY:(int) y
                andMode:(int) mode
               andImage:(UIImage*) image
             andBmpType:(BmpType) bmptype;

/**
 this command draws rectangles on the label
 BOX X,Y,X_END,Y_END,LINE_THICNESS
 @param x   specify x-coordinate of upper left corner(in dots).
 @param y    specify y-coordinate of upper left corner(in dots).
@param x_end specify x-coordinate of lower right corner(in dots).
@param y_end specify y-coordinate of lower right corner(in dots).
@param thickness sepcify the round corner.default is 0.
 */
+(NSData *) boxWithX:(int) x
                andY:(int) y
             andEndX:(int) x_end
             andEndY:(int) y_end
        andThickness:(int) thickness;

/**
 this command draws an ellipse on the label.
 ELLIPSE X,Y,width,height,thickness.
 @param x   specify x-coordinate of upper left corner(in dots).
 @param y    specify y-coordinate of upper left corner(in dots).
@param width specify the width of the ellipse(in dots).
@param height specify the height of the ellipse(in dots).
 
 */
+(NSData *) ellipseWithX:(int) x
                    andY:(int) y
                andWidth:(int) width
               andHeight:(int) height
            andThickness:(int) thickness;

/**
 this command draws CODEBLOCK F mode barcode.
 CODABLOCK x,y,rotation,x,"content"
 @param x   specify the x-coordinate
 @param y    specify the y-coordinate
@param rotation Rotate rotation degrees clockwise
@param content content of codablock bar code.
 */
+(NSData *) codaBlockFModeWithX:(int) x
                           andY:(int) y
                    andRotation:(int) rotation
                     andContent:(NSString*) content;

/**
 this command draws an DataMatrix 2d barcode .
 绘制二维条码DataMatrix
 DMATRIX x,y,width,height,content
 @param x   specify x-coordinate of upper left corner(in dots).
 @param y    specify y-coordinate of upper left corner(in dots).
@param width specify the width of DataMatrix.
@param height specify the height of DataMatrix.
@param content the content of DataMatrix.
 */
+(NSData *) dmateixWithX:(int) x
                    andY:(int) y
                andWidth:(int) width
               andHeight:(int) height
              andContent:(NSString*) content
           usStrEnCoding:(NSStringEncoding) strEnCoding;

/**
 this command clears a specified region in the image buffer
 ERASE x,y,width,height
 @param x   the x-coordinate of d=the starting point(in dots).
 @param y    the y-coordinate of d=the starting point(in dots).
@param width the region width in x-axis direction(in dots).
@param height the region height in y-axis direction(in dots).
 */
+(NSData *) eraseWithX:(int) x
                  andY:(int) y
              andWidth:(int) width
             andHeight:(int) height;

/**
 this command defines a PDF417 2d bar code
 PDF417 x,y,width,height,rotatte,"content"
 
 */
+(NSData *) pdf417WithX:(int) x
                   andY:(int) y
               andWidth:(int) width
              andHeight:(int) height
              andRotate:(int) rotate
             andContent:(NSString*) content
          usStrEnCoding:(NSStringEncoding) strEnCoding;
/**
 this command prints BMP format images
 PUTBMP x,y,"filename",bpp,contrast
 
 */
+(NSData *) pubBmpWithX:(int) x
                   andY:(int) y
            andFileName:(NSString*) filename
            andContrast:(int) contrast;

/**
 this comand prints BMP format images
 PUTBMP x,y,"filename"
 @param x   the x-coordinate of the BMP format image
 @param y    the y-coordinate of the BMP format image
@param filename the download BMP filename.
 */
+(NSData *) putBmpWithX:(int) x
                   andY:(int) y
            andFileName:(NSString*) filename;

/**
 this command prints PCX format images.
 PUTPCX x,y,"filename"
 @param x   the x-coordinate of the BMP format image
 @param y    the y-coordinate of the BMP format image
@param filename the download pcx filename.

 */
+(NSData *) putPcxWithX:(int) x
                   andY:(int) y
            andFileName:(NSString*) filename;

/**
 this command prints qr code
 QRCODE x,y,ecclevel,cell_width,mode,rotation,"content"
 @param x   the upper left corner x-coordinate of the QRcode.
 @param y    the upper left corner y-coordinate of the QRcode.
@param ecclevel error correction revovery level.
@param cellwidth 1~10.
@param mode A or M.
@param rotation 0 or 90 or 180 or 270.
@param content the content of QRcode.
 @param strEnCoding the encoding of content.
 */
+(NSData *) qrCodeWithX:(int) x
                   andY:(int) y
            andEccLevel:(NSString*) ecclevel
           andCellWidth:(int) cellwidth
                andMode:(NSString*) mode
            andRotation:(int) rotation
             andContent:(NSString*) content
          usStrEnCoding:(NSStringEncoding) strEnCoding;

/**
 this command reverses a region in image buffer.
 REVERSE x_start,y_start,x_width,y_height
 @param x   the x-coordinate of the starting point(in dots).
 @param y    the y-coordinate of the starting point(in dots).
@param width x-axis region width(in dots).
@param height y-axis region height(in dots).
 */
+(NSData *) reverseWithX:(int) x
                    andY:(int) y
                andWidth:(int) width
               andHeight:(int) height;

/**
 this command prints text on label
 TEXT x,y,"font",rotation,x_multiplication,y_multiplication,"content"
 @param x   the x-coordinate of text.
 @param y    the y-coordinate of text.
@param font font name.
@param rotation the rotation angle of text.
@param x_mul horizontal multiplication,up to 10x.
@param y_mul vertical multiplication,up to 10x.
@param content the content of text string.
@param strEnCoding the encoding of the content string.
 */
+(NSData *) textWithX:(int) x
                 andY:(int) y
              andFont:(NSString*) font
          andRotation:(int) rotation
             andX_mul:(int) x_mul
             andY_mul:(int) y_mul
           andContent:(NSString*) content
        usStrEnCoding:(NSStringEncoding) strEnCoding;

/**
 this command prints paragraph on label
 BLOCK x,y,width,"font",rotation,x_mul,y_mul,"content"
 
 */
+(NSData *) blockWithX:(int) x
                  andY:(int) y
              andWidth:(int) width
             andHeight:(int) height
               andFont:(NSString*) font
           andRotation:(int) rotaion
              andX_mul:(int) x_mul
              andY_mul:(int) y_mul

             andConten:(NSString*) content
         usStrEnCoding:(NSStringEncoding) strEnCoding;

/**
 this command obiains the printer status at any time.
 <ESC> !?
 1D 61 1F
 */

+(NSData *) checkPrinterStatusByPort9100;

/**
 this command obiains the printer status at any time.
 
 1B 76 00
 */

+(NSData *) checkPrinterStatusByPort4000;


/**
 Download 程序档
 DOWNLOAD "EXAMPLE.BAS"
 
 */

+(NSData *) download:(NSString*) filename;


/**
 
 Download 文本档
 DOWNLOAD "FILENAME",DATASIZE,CONTENT
 
 */

+(NSData *) download:(NSString*) filename
             andSize:(int) size
           andConten:(NSString*) content;


/**
 Download 文本文件档
 DOWNLOAD "FILENAME",FILE SIZE,DATA CONTENT
 
 */

+(NSData *) download:(NSString*) filename
             andPath:(NSURL*) url;


/**
 Download 图档
 DOWNLOAD "EXAMPLE.BAS"
 
 */

//+(NSData *) download:(NSString*) filename
//          andImage:(UIImage*) image;

/**
 End of program,to declare the start and the end of BASIC language used in progra.
 EOP
 
 */

+(NSData *) eop;

/**
 this command prints out the total memory size,available memory size and files lists in the printer memory.
 FILES
 
 */

+(NSData *) files;

/**
 this command delects a file in the printer memory
 KILL "FILENAME"
 
 */

+(NSData *) kill:(NSString*) filename;

/**
 this command moves download files from DRAM to FLASH memory.
 MOVE
 
 */

+(NSData *) move;

/**
 this command executes a program resdent in the printer memory.it is available for TSPL2 printers only.
 RUN "FILENAME.BAS"
 
 */

+(NSData *) run:(NSString*) filename;

@end
