//
//  TSCCommand.h
//  Printer
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger,AutoResponse){
    OFF     = 0,//关闭自动返回状态功能
    ON      = 1,//打开自动返回状态功能，每打印完一张返回一次
    BATCH   = 2,//打开自动返回状态功能，打印完毕后返回一次
};

@interface TSCCommand : NSObject

/**
 Defines the label width and length in millimeters.
 设定标签纸的宽度及长度（单位：毫米）
 @param m Label width
 @param n Label length
 @return Data command
 */
+ (NSData *)sizeBymmWithWidth:(double)m andHeight:(double)n;

/**
 Defines the label width and length in inches.
 设定标签纸的宽度及长度（单位：英寸）
 @param m Label width
 @param n Label length
 @return Data command
 */
+ (NSData *)sizeByinchWithWidth:(double)m andHeight:(double)n;

/**
 Defines the label width and height in dots.
 设定标签纸的宽度及高度（单位：点）
 @param m Label width
 @param n Label height
 @return Data command
 */
+ (NSData *)sizeBydotWithWidth:(int)m andHeight:(int)n;

/**
 Defines the gap distance between two labels vertically.
 设置标签纸的垂直间距（单位：毫米）
 @param m Gap distance between two labels
 @param n Offset distance of the gap
 @return Data command
 */
+ (NSData *)gapBymmWithWidth:(double)m andHeight:(double)n;

/**
 Defines the gap distance between two labels vertically.
 设置标签纸的垂直间距（单位：英寸）
 @param m Gap distance between two labels
 @param n Offset distance of the gap
 @return Data command
 */
+ (NSData *)gapByinchWithWidth:(double)m andHeight:(double)n;

/**
 Defines the gap distance between two labels vertically.
 设置标签纸的垂直间距（单位：点）
 @param m Gap distance between two labels
 @param n Offset distance of the gap
 @return Data command
 */
+ (NSData *)gapBydotWithWidth:(int)m andHeight:(int)n;

/**
 Feeds the paper through the gap sensor to determine the paper and gap sizes.
 在通过间隙传感器的努力下，对纸张和间隙的大小进行测量（单位：点）
 @param x Paper length in dots
 @param y Gap length in dots
 @return Data command
 */
+ (NSData *)gapDetectWithX:(int)x andY:(int)y;

/**
 Feeds the paper through the gap sensor to determine the paper and gap sizes.
 通过间隙传感器将纸张送出，以确定纸张和间隙的大小
 @return Data command
 */
+ (NSData *)gapDetect;

/**
 Feeds the paper through the black mark sensor to determine the paper and black mark size.
 通过黑标传感器将纸张送出，以确定纸张和黑标的大小（单位：点）
 @param x Paper length in dots
 @param y Black mark length in dots
 @return Data command
 */
+ (NSData *)blinedDetectWithX:(int)x andY:(int)y;

/**
 Feeds the paper through the gap/black mark sensor to determine the paper and gap/black mark size.
 通过间隙/黑标传感器将纸张送出，以确定纸张和间隙/黑标的大小（单位：点）
 @param x Paper length in dots
 @param y Gap/Black mark length in dots
 @return Data command
 */
+ (NSData *)autoDetectWithX:(int)x andY:(int)y;

/**
 Sets the height of the black line and the extra label feeding length.
 设置黑线的高度和用户定义的每次进纸所需的额外标签进纸长度（单位：英寸）
 @param m Height of black line in millimeters
 @param n Extra label feeding length
 @return Data command
 */
+ (NSData *)blineByinchWithM:(double)m andN:(double)n;


/**
 Sets the height of the black line and the user-defined extra label feeding length for each feed action.
 设定黑标的高度及偏移位置（单位：毫米）
 @param m Height of black line in inches
 @param n Extra label feeding length
 @return Data command
 */
+ (NSData *)blineBymmWithM:(double)m andN:(double)n;

/**
 Sets the height of the black line and the user-defined extra label feeding length for each feed action.
 设定黑标的高度及偏移位置（单位：点）
 @param m Height of black line in dots
 @param n Extra label feeding length
 @return Data command
 */
+ (NSData *)blineBydotWithM:(int)m andN:(int)n;

/**
 Sets the position of label under the peel-off mode.
 在剥离模式下，设置每张标签停止的位置（单位：英寸）
 @param m Offset distance (in inches)
 @return Data command
 */
+ (NSData *)offSetByinchWithM:(double)m;

/**
 Sets the position of label under the peel-off mode.
 在剥离模式下，设置每张标签停止的位置（单位：毫米）
 @param m Offset distance (in millimeters)
 @return Data command
 */
+ (NSData *)offSetBymmWithM:(double)m;

/**
 Sets the position of label under the peel-off mode.
 在剥离模式下，设置每张标签停止的位置（单位：点）
 @param m Offset distance (in dots)
 @return Data command
 */
+ (NSData *)offSetBydotWithM:(int)m;

/**
 Defines the print speed.
 设置走纸速度（单位：英寸/秒）
 @param n Printing speed in inches per second
 @return Data command
 */
+ (NSData *)speed:(double)n;

/**
 Sets the printing darkness.
 设置打印浓度
 @param n Specifies the lightest/darkest level
 @return Data command
 */
+ (NSData *)density:(int)n;


/**
 Defines the printout direction and mirror image. This will be stored in the printer memory.
 定义打印时出纸方向
 DIRECTION n
 @param n 0 or 1, please refer to the illustrations below.
 @return Data command
 */
+ (NSData *)direction:(int)n;

/**
 Defines the reference point of the label. The reference (origin) point varies with the print direction, as shown.
 用于定义标签的参考坐标原点
 REFERENCE x,y
 @param x Horizontal coordinate (in dots)
 @param y Vertical coordinate (in dots)
 @return Data command
 */
+ (NSData *)referenceWithX:(int)x andY:(int)y;

/**
 Moves the label's vertical position.
 移动标签的垂直位置
 SHIFT n
 @param n The maximum value is 1 inch. For 200 dpi printers, this range is -203 to 203; for 300 dpi printers, the range is -300 to 300. This unit is dots.
 @return Data command
 */
+ (NSData *)shift:(int)n;

/**
 Orients the keyboard for use in different countries via defining special characters on the KP-200 series portable LCD keyboard (option).
 用于选择国际字符集
 COUNTRY n
 @param countryCoding The keyboard for use in different countries via defining special characters
 @return Data command
 */
+ (NSData *)country:(NSString *)countryCoding;

/**
 Orients the keyboard for use in different countries via defining special characters on the KP-200 series portable LCD keyboard (option).
 指定字符编码
 CODEPAGE n
 @param str The name of codepage
 @return Data command
 */
+ (NSData *)codePage:(NSString *)str;

/**
 Clears the image buffer.
 清除缓存
 CLS
 @return Data command
 */
+ (NSData *)cls;

/**
 Feeds label with the specified length. The length is specified by dots.
 控制进纸距离，单位dot
 FEED n
 @param n The length label feeds
 @return Data command
 */
+ (NSData *)feed:(int)n;

/**
 Feeds the label in reverse. The length is specified by dots.
 后退进纸，单位dot
 BACKFEED n
 @param n The length label feeds in reverse
 @return Data command
 */
+ (NSData *)backFeed:(int)n;

/**
 Feeds label to the beginning of next label.
 FORMFEED
 @return Data command
 */
+ (NSData *)formFeed;


/**
 This command will feed label until the sensor has determined origin.
 HOME
 */
+ (NSData *)home;

/**
 This command prints the label format currently stored in the image buffer.
 PRINT m,n
 @param m Specifies how many sets of labels will be printed
 @param n Specifies how many copies should be printed for each particular label set
 */
+ (NSData *)printWithM:(int)m andN:(int)n;

/**
 This command prints the label format currently stored in the image buffer.
 PRINT m
 @param m Specifies how many sets of labels will be printed
 */
+ (NSData *)print:(int)m;

/**
 This command controls the sound frequency of the beeper. There are 10 levels of sounds.
 SOUND level,interval
 @param level Sound level: 0-9
 @param interval Sound interval: 1-4095
 */
+ (NSData *)soundWithLevel:(int)level andInterval:(int)interval;

/**
 This command activates the cutter to immediately cut the labels without back feeding the label.
 CUT
 */
+ (NSData *)cut;

/**
 This command is used to stop feeding paper while feed paper wrong.
 LIMITFEED n
 @param n The limit length of wrong (in inch)
 */
+ (NSData *)limitFeedByinch:(double)n;

/**
 This command is used to stop feeding paper while feed paper wrong.
 LIMITFEED n
 @param n The limit length of wrong (in mm)
 */
+ (NSData *)limitFeedBymm:(double)n;

/**
 This command is used to stop feeding paper while feed paper wrong.
 LIMITFEED n
 @param n The limit length of wrong (in dots)
 */
+ (NSData *)limitFeedBydot:(int)n;

/**
 At this command, the printer will print out the printer information.
 SELFTEST
 */
+ (NSData *)selfTest;

/**
 At this command, the printer will print out the printer information.
 SELFTEST page
 @param page The type of printer information
 */
+ (NSData *)selfTest:(NSString *)page;

/**
 Let the printer wait until process of commands (before EOJ) be then go on the next command.
 EOJ
 */
+ (NSData *)eoj;

/**
 Let the printer wait specific period of time then go on next command.
 DELAY ms
 @param ms Print delay how many seconds
 */
+ (NSData *)delay:(int)ms;

/**
 This command can show the image, which is in printer's image buffer, on LCD panel.
 DISPLAY IMAGE/OFF
 @param str IMAGE: Show the image in printer's image buffer on LCD panel
            OFF: Disable this function
 */
+ (NSData *)display:(NSString *)str;

/**
 This command can restore printer settings to defaults.
 INITIALPRINTER
 */
+ (NSData *)initialPrinter;

/**
 This command draws a bar on the label format.
 BAR x,y,w,h
 @param x The upper left corner x-coordinate (in dots)
 @param y The upper left corner y-coordinate (in dots)
 @param w Bar width (in dots)
 @param h Bar height (in dots)
 */
+ (NSData *)barWithX:(int)x andY:(int)y andWidth:(int)w andHeigt:(int)h;


/**
 This command prints 1D barcodes.
 绘制一维码
 @param x Specify the x-coordinate
 @param y Specify the y-coordinate
 @param codetype Type of barcode
 @param height Height of barcode
 @param readable HRI readable, 0-3
 @param rotation Graphic rotation, 0-90-180-270
 @param narrow Space in unit
 @param wide Width of unit
 @param content Barcode's content
 @param strEnCoding Barcode's content's encoding
 */
+ (NSData *)barcodeWithX:(int)x
                   andY:(int)y
            andCodeType:(NSString *)codetype
              andHeight:(int)height
       andHunabReadable:(int)readable
            andRotation:(int)rotation
              andNarrow:(int)narrow
                andWide:(int)wide
             andContent:(NSString *)content
          usStrEnCoding:(NSStringEncoding)strEnCoding;

/**
 This command draws bitmap images.
 绘制bitmap图像
 @param x Specify the x-coordinate
 @param y Specify the y-coordinate
 @param mode Graphic modes listed below:
             0: OVERWRITE
             1: OR
             2: XOR
 @param image The graphic you want to print
 */
+ (NSData *)bitmapWithX:(int)x
                  andY:(int)y
               andMode:(int)mode
              andImage:(UIImage *)image;

/**
 This command draws rectangles on the label.
 绘制一个方框
 @param x Specify x-coordinate of upper left corner (in dots)
 @param y Specify y-coordinate of upper left corner (in dots)
 @param x_end Specify x-coordinate of lower right corner (in dots)
 @param y_end Specify y-coordinate of lower right corner (in dots)
 @param thickness Specify the round corner, default is 0
 */
+ (NSData *)boxWithX:(int)x
                andY:(int)y
             andEndX:(int)x_end
             andEndY:(int)y_end
        andThickness:(int)thickness;

/**
 This command draws an ellipse on the label.
 绘制一个椭圆
 @param x Specify x-coordinate of upper left corner (in dots)
 @param y Specify y-coordinate of upper left corner (in dots)
 @param width Specify the width of the ellipse (in dots)
 @param height Specify the height of the ellipse (in dots)
 @param thickness Specify the thickness
 */
+ (NSData *)ellipseWithX:(int)x
                    andY:(int)y
                andWidth:(int)width
               andHeight:(int)height
            andThickness:(int)thickness;

/**
 This command draws CODEBLOCK F mode barcode.
 绘制CODEBLOCK F模式的条形码
 @param x Specify the x-coordinate
 @param y Specify the y-coordinate
 @param rotation Rotate rotation degrees clockwise
 @param content Content of codablock barcode
 */
+ (NSData *)codaBlockFModeWithX:(int)x
                           andY:(int)y
                    andRotation:(int)rotation
                     andContent:(NSString *)content;

/**
 This command draws a DataMatrix 2d barcode.
 绘制DataMatrix 2d条码
 @param x Specify x-coordinate of upper left corner (in dots)
 @param y Specify y-coordinate of upper left corner (in dots)
 @param width Specify the width of DataMatrix
 @param height Specify the height of DataMatrix
 @param content The content of DataMatrix
 @param strEnCoding Barcode's content's encoding
 */
+ (NSData *)dmateixWithX:(int)x
                    andY:(int)y
                andWidth:(int)width
               andHeight:(int)height
              andContent:(NSString *)content
           usStrEnCoding:(NSStringEncoding)strEnCoding;

/**
 This command clears a specified region in the image buffer.
 清除对应区域图像缓存
 @param x The x-coordinate of the starting point (in dots)
 @param y The y-coordinate of the starting point (in dots)
 @param width The region width in x-axis direction (in dots)
 @param height The region height in y-axis direction (in dots)
 */
+ (NSData *)eraseWithX:(int)x
                  andY:(int)y
              andWidth:(int)width
             andHeight:(int)height;

/**
 This command defines a PDF417 2d barcode.
 绘制PDF417 2d条码
 */
+ (NSData *)pdf417WithX:(int)x
                   andY:(int)y
               andWidth:(int)width
              andHeight:(int)height
              andRotate:(int)rotate
             andContent:(NSString *)content
          usStrEnCoding:(NSStringEncoding)strEnCoding;

/**
 This command prints BMP format images.
 打印BMP格式的图像
 */
+ (NSData *)pubBmpWithX:(int)x
                   andY:(int)y
            andFileName:(NSString *)filename
            andContrast:(int)contrast;


/**
 This command prints BMP format images.
 打印 BMP 格式的图像
 @param x The x-coordinate of the BMP format image
 @param y The y-coordinate of the BMP format image
 @param filename The download BMP filename
 */
+ (NSData *)putBmpWithX:(int)x
                   andY:(int)y
            andFileName:(NSString *)filename;

/**
 This command prints PCX format images.
 打印 PCX 格式图片
 @param x The x-coordinate of the BMP format image
 @param y The y-coordinate of the BMP format image
 @param filename The download pcx filename
 */
+ (NSData *)putPcxWithX:(int)x
                   andY:(int)y
            andFileName:(NSString *)filename;

/**
 This command prints QR code.
 打印二维码
 @param x The upper left corner x-coordinate of the QRcode
 @param y The upper left corner y-coordinate of the QRcode
 @param ecclevel Error correction recovery level
 @param cellwidth Width of each cell (1~10)
 @param mode A or M
 @param rotation Rotation angle (0, 90, 180, 270)
 @param content The content of QRcode
 @param strEnCoding The encoding of content
 */
+ (NSData *)qrCodeWithX:(int)x
                   andY:(int)y
            andEccLevel:(NSString *)ecclevel
           andCellWidth:(int)cellwidth
                andMode:(NSString *)mode
            andRotation:(int)rotation
             andContent:(NSString *)content
          usStrEnCoding:(NSStringEncoding)strEnCoding;

/**
 This command reverses a region in image buffer.
 将指定区域的图像缓存反白
 @param x The x-coordinate of the starting point (in dots)
 @param y The y-coordinate of the starting point (in dots)
 @param width The x-axis region width (in dots)
 @param height The y-axis region height (in dots)
 */
+ (NSData *)reverseWithX:(int)x
                    andY:(int)y
                andWidth:(int)width
               andHeight:(int)height;

/**
 This command prints text on label.
 在标签上打印文本
 @param x The x-coordinate of text
 @param y The y-coordinate of text
 @param font Font name
 @param rotation Rotation angle of text
 @param x_mul Horizontal multiplication, up to 10x
 @param y_mul Vertical multiplication, up to 10x
 @param content The content of text string
 @param strEnCoding The encoding of the content string
 */
+ (NSData *)textWithX:(int)x
                 andY:(int)y
              andFont:(NSString *)font
          andRotation:(int)rotation
             andX_mul:(int)x_mul
             andY_mul:(int)y_mul
           andContent:(NSString *)content
        usStrEnCoding:(NSStringEncoding)strEnCoding;

/**
 This command prints paragraph on label.
 在标签上打印段落
 */
+ (NSData *)blockWithX:(int)x
                  andY:(int)y
              andWidth:(int)width
             andHeight:(int)height
               andFont:(NSString *)font
           andRotation:(int)rotaion
              andX_mul:(int)x_mul
              andY_mul:(int)y_mul
             andConten:(NSString *)content
         usStrEnCoding:(NSStringEncoding)strEnCoding;

/**
 This command obtains the printer status at any time.
 获取打印机状态
 */
+ (NSData *)checkPrinterStatusByPort9100;

/**
 This command obtains the printer status at any time.
 获取打印机状态
 */
+ (NSData *)checkPrinterStatusByPort4000;

/**
 Download 程序档.
 下载程序档
 @param filename The filename to download
 */
+ (NSData *)download:(NSString *)filename;



/**
 Download 文本档.
 DOWNLOAD "FILENAME",DATASIZE,CONTENT
 @param filename The filename to download
 @param size The size of the data
 @param content The content of the file
 */
+ (NSData *)download:(NSString *)filename
            andSize:(int)size
          andConten:(NSString *)content;


/**
 Download 文本文件档.
 DOWNLOAD "FILENAME",FILE SIZE,DATA CONTENT
 @param filename The filename to download
 @param url The file URL
 */
+ (NSData *)download:(NSString *)filename
            andPath:(NSURL *)url;

/**
 End of program, to declare the start and the end of BASIC language used in program.
 EOP
 */
+ (NSData *)eop;

/**
 This command prints out the total memory size, available memory size and files lists in the printer memory.
 FILES
 */
+ (NSData *)files;

/**
 This command deletes a file in the printer memory.
 此命令会删除打印机记忆体中的文件
 @param filename The name of the file to be deleted
 */
+ (NSData *)kill:(NSString *)filename;

/**
 This command moves download files from DRAM to FLASH memory.
 此命令可以将 DRAM 中的文件移动到 FLASH 中
 */
+ (NSData *)move;

/**
 This command executes a program resident in the printer memory. It is available for TSPL2 printers only.
 此命令用来执行打印机内存中所保存的文件
 @param filename The name of the program file to be executed
 */
+ (NSData *)run:(NSString *)filename;

/**
 This command sets the printer to automatically return information.
 设定打印机自动返回信息
 @param response The type of auto response to set
 */
+ (NSData *)setAutoResponse:(AutoResponse)response;

/**
 This command draws bitmap images.
 绘制bitmap图像
 @param x The x-coordinate
 @param y The y-coordinate
 @param mode Graphic modes listed below:
             0: OVERWRITE
             1: OR
             2: XOR
             3: OVERWRITE + zlib
             4: OR + zlib
             5: XOR + zlib
 @param image The graphic you want to print
 */
+ (NSData *)zlibBitmapWithX:(int)x
                      andY:(int)y
                   andMode:(int)mode
                  andImage:(UIImage *)image;

/**
 设定开启/关闭送纸至撕纸线的功能
 @param isOpen YES 标签打印结束时将送纸至撕纸位置 NO 标签打印结束时会将标签起印点停留至打印线位置
 */
+ (NSData *)setTear:(BOOL)isOpen;

/**
 设定启动/关闭自动剥纸器功能
 @param isOpen YES 开启自动剥纸器的功能 NO 关闭自动剥纸器的功能
 */
+ (NSData *)setPeel:(BOOL)isOpen;

@end
