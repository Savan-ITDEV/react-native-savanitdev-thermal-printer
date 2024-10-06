//
//  POSPrinter.h
//  Printer
//
//  Created by Apple Mac mini intel on 2022/12/7.
//  Copyright © 2022 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSInteger, POSPrinterConnectType) {
    POSPrinterConnectBLE = 0,           //Bluetooth
    POSPrinterConnectWiFi = 1           //WiFi
};

NS_ASSUME_NONNULL_BEGIN

@interface POSPrinter : NSObject

// connect type
@property (nonatomic, assign) POSPrinterConnectType connectType;

// ble name
@property (nonatomic, copy, readwrite) NSString *name;

// mac address
@property (nonatomic, copy, readwrite) NSString *mac;

// unique identifier
@property (nonatomic, copy, readwrite) NSString *uuid;

// rssi
@property (nonatomic, copy, readwrite) NSNumber *rssi;

// peripheral
@property (nonatomic, copy, readwrite) CBPeripheral *peripheral;

// ip
@property (nonatomic, copy, readwrite) NSString *ip;

// port
@property (nonatomic, copy, readwrite) NSString *port;

@end

NS_ASSUME_NONNULL_END
