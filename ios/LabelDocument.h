//
//  LabelDocument.h
//  Printer
//
//  Created by Apple Mac mini intel on 2023/3/21.
//  Copyright © 2023 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

//Rotation
typedef NS_ENUM(NSInteger, DocErrorCode) {
    DocSuccess = 0,
    CGPDFDocumentRefNULL,
    PageNumberExceeds,
};

typedef void (^ParsingDataCallBackBlock) (NSMutableArray<UIImage *> *sourceImages,DocErrorCode errorCode);

@interface LabelDocument : NSObject
// 获取当前PDF文件总页数
+ (int)getPDFPages:(NSString *)filePath pdfPassword:(nullable NSString *)password;
// 解析文档，获取对应的图像数据源集合
+ (void)parsingDoc:(NSString *)filePath start:(int)startPage end:(int)endPage password:(nullable NSString *)password DataCallBack:(ParsingDataCallBackBlock)dataBlock;
// 根据宽度缩放对应的图像数据源
+ (UIImage *)imageWithScaleImage:(UIImage *)image andScaleWidth:(int)width;

@end

NS_ASSUME_NONNULL_END
