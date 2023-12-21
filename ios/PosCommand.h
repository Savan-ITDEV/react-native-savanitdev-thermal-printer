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


+(NSData *) selectAlignment:(int) n;

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

+(NSData *) printAndFeedLine;
/**
 打印并回到标准模式
 FF
 OC
 */

+(NSData *) printRasteBmpWithM:(PrintRasterType) m andImage:(UIImage *) image andType:(BmpType) type;
/**
 设置条码宽度
 GS w n
 1D 77 n
 @param n:2~6,defualt 3.
 */


@end
