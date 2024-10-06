//
//  PTable.h
//  PrinterSDK
//
//  Created by Apple Mac mini intel on 2023/11/27.
//  Copyright © 2023 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TableAlignType) {
    ALL_LEFT_ALIGN,    // 全部文本内容左对齐
    ALL_RIGHT_ALIGN,   // 全部文本内容右对齐
    FIRST_LEFT_ALIGN,  // 仅第一列文本内容左对齐，其余右对齐
};

typedef NS_ENUM(NSInteger, BCSBarcodeType) {
    BCS_UPCA,
    BCS_UPCE,
    BCS_EAN13,
    BCS_EAN8,
    BCS_Code39,
    BCS_ITF,
    BCS_Codabar,
    BCS_Code93,
    BCS_Code128
};

typedef NS_ENUM(NSInteger, BarHriText) {
    BAR_HRI_TEXT_NONE = 0,
    BAR_HRI_TEXT_BELOW,
    BAR_HRI_TEXT_ABOVE,
    BAR_HRI_TEXT_BOTH
};



@interface PTable : NSObject

// 超过预设的字符宽度，自动换行
+ (NSData *)addAutoTableH:(NSArray<NSString *> *)titles titleLength:(NSArray<NSNumber *> *)lengths align:(TableAlignType)align;

// 添加条码
+ (NSData *)addBarcodeRow:(NSString *)data type:(BCSBarcodeType)type hri:(BarHriText)hri;

@end

NS_ASSUME_NONNULL_END
