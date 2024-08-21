#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(SavanitdevThermalPrinter, NSObject)

RCT_EXTERN_METHOD(connectNet:(NSString *)ip
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(printTest:(NSString *)ip 
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(printImgNet:(NSString *)ip base64String:(NSString *)base64String isDisconnect:(BOOL *)isDisconnect
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(printImgNetSticker:(NSString *)ip base64String:(NSString *)base64String isCut:(BOOL *)isCut
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(printEncodeNet:(NSString *)ip base64String:(NSString *)base64String isDisconnect:(BOOL *)isDisconnect
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)



RCT_EXTERN_METHOD(disconnectNet:(NSString *)ip)

RCT_EXTERN_METHOD(setLang:(NSString *)codepage)
RCT_EXTERN_METHOD(getLangModel)
RCT_EXTERN_METHOD(printLangPrinter)
RCT_EXTERN_METHOD(cancelChinese)
RCT_EXTERN_METHOD(CancelChineseCharModel)

RCT_EXTERN_METHOD(clearLoops)
RCT_EXTERN_METHOD(connectBLE:(NSString *)id resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(rawDataBLE:(NSString *)base64String resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(image64BaseBLE:(NSString *)base64String
                  
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(initBLE)
RCT_EXTERN_METHOD(startScanBLE)
RCT_EXTERN_METHOD(disconnectBLE:(NSString *)id resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(checkStatusBLE:(NSString *)id resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getListDevice:(NSString *)id resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)


RCT_EXTERN_METHOD(clearPaper:(RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(initializeText)
RCT_EXTERN_METHOD(cut)
RCT_EXTERN_METHOD(printAndFeedLine)
RCT_EXTERN_METHOD(selectAlignment:(NSInteger *)n)
RCT_EXTERN_METHOD(text:(NSString *)txt ch:(NSString *)ch)
RCT_EXTERN_METHOD(selectCharacterSize:(NSString *)n)
RCT_EXTERN_METHOD(selectOrCancelBoldModel:(NSInteger *)n)
RCT_EXTERN_METHOD(selectCharacterCodePage:(NSInteger *)n)
RCT_EXTERN_METHOD(selectInternationalCharacterSets:(NSInteger *)n)
RCT_EXTERN_METHOD(setAbsolutePrintPosition:(NSInteger *)n m:(NSInteger *)m)
RCT_EXTERN_METHOD(setImg:(NSString *)base64String)
RCT_EXTERN_METHOD(getEncode:(NSString *)base64String)
RCT_EXTERN_METHOD(line:(NSInteger *)length)
RCT_EXTERN_METHOD(line2:(NSInteger *)length)
RCT_EXTERN_METHOD(line3:(NSInteger *)length)
RCT_EXTERN_METHOD(printTemplate:(NSString *)ip isDisconnect:(BOOL *)isDisconnect
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(printText:(RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getByteArrayList:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
