#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(SavanitdevThermalPrinter, NSObject)

RCT_EXTERN_METHOD(connectNet:(NSString *)ip
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(printTest:(NSString *)ip 
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(printImgNet:(NSString *)ip base64String:(NSString *)base64String 
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(printEncodeNet:(NSString *)ip base64String:(NSString *)base64String
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(disconnectNet:(NSString *)ip)

RCT_EXTERN_METHOD(clearLoops)


+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
