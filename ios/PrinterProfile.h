//
//  PrinterProfile.h
//  PrinterSDK
//
//  Created by Apple Mac mini intel on 2023/9/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PrinterProfile : NSObject
@property (nonatomic, readonly) NSString *printerName;
@property (nonatomic, readonly) NSString *printerDesc;

- (void)setMAC:(NSData *)mac;
- (void)setIP:(NSData *)ip;
- (void)setMask:(NSData *)mask;
- (void)setGateway:(NSData *)gw;
- (void)setDHCP:(char)dhcp;
- (NSString *)getIPString;
- (NSString *)getMaskString;
- (NSString *)getGatewayString;
- (char)getDHCP;
- (Byte *)getMACArray;
@end

NS_ASSUME_NONNULL_END
