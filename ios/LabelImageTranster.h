//
//  UIImageTranster.h
//  Printer
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    TSPL_PRINT = 0, //tspl打印
    ZPL_PRINT = 1,  //zpl打印
    CPCL_PRINT = 2, //cpcl打印
} PrintCommand;

@interface LabelImageTranster : NSObject

+ (NSData *)dataWithImage: (UIImage *)mImage printType: (PrintCommand)printType;

@end
