//
//  KDS_Log.h
//  Printer
//
//  Created by Apple Mac mini intel on 2022/11/4.
//  Copyright © 2022 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  自定义Log，可配置开关（用于替换NSLog）
 */
#define KDS_Log(format,...) CustomLog(__FUNCTION__,__LINE__,format,##__VA_ARGS__)

/**
 *  自定义Log
 *  @warning 外部可直接调用 KDS_Log
 *
 *  @param func         方法名
 *  @param lineNumber   行号
 *  @param format       Log内容
 *  @param ...          个数可变的Log参数
 */
void CustomLog(const char *func, int lineNumber, NSString *format, ...);

@interface KDS_Log : NSObject

/**
 *  Log 输出开关 (默认关闭)
 *
 *  @param flag 是否开启
 */
+ (void)setLogEnable:(BOOL)flag;

/**
 *  是否开启了 Log 输出
 *
 *  @return Log 开关状态
 */
+ (BOOL)logEnable;

@end

NS_ASSUME_NONNULL_END
