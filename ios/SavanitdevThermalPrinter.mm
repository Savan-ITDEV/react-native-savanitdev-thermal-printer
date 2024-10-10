#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(SavanitdevThermalPrinter, NSObject)

RCT_EXTERN_METHOD(initializePrinter)
RCT_EXTERN_METHOD(startScanBLE)
RCT_EXTERN_METHOD(startQuickDiscovery:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(connectNet:(NSString *)ip resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(connectBLE:(NSString *)ip resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)


RCT_EXTERN_METHOD(disConnect:(NSString *)ip resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)

RCT_EXTERN_METHOD(printRawDataESC:(NSString *)ip base64String:(NSString *)base64String resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)

RCT_EXTERN_METHOD(printImgZPL:(NSString *)ip 
                  base64String:(NSString *)base64String
                  width:(NSInteger *)width
                  printCount:(NSInteger *)printCount
                  x:(NSInteger *)x
                  y:(NSInteger *)y
                  resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)

RCT_EXTERN_METHOD(printImgESC:(NSString *)ip
                  base64String:(NSString *)base64String
                  width:(NSInteger *)width
                  resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)

RCT_EXTERN_METHOD(printImgTSPL:(NSString *)ip
                  base64String:(NSString *)base64String
                  width:(NSInteger *)width
                  height:(NSInteger *)height
                  x:(NSInteger *)x
                  y:(NSInteger *)y
                  resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(printImgCPCL:(NSString *)ip
                  base64String:(NSString *)base64String
                  width:(NSInteger *)width
                  height:(NSInteger *)height
                  x:(NSInteger *)x
                  y:(NSInteger *)y
                  resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)

RCT_EXTERN_METHOD(printTestESC:(NSString *)ip resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)

RCT_EXTERN_METHOD(cutESC:(NSString *)ip resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)

RCT_EXTERN_METHOD(pingDevice:(NSString *)ip resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)

RCT_EXTERN_METHOD(getStatus:(NSString *)ip resolver:(RCTPromiseResolveBlock)resolver rejecter:(RCTPromiseRejectBlock)rejecter)

RCT_EXTERN_METHOD(getListDevice:(NSString *)id resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(disconnectBLE:(NSString *)id resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(checkStatusBLE:(NSString *)id resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(rawDataBLE:(NSString *)base64String resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)



RCT_EXTERN_METHOD(image64BaseBLE:(NSString *)base64String
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(setLang:(NSString *)ip codepage:(NSString *)codepage)
RCT_EXTERN_METHOD(getLangModel:(NSString *)ip)
RCT_EXTERN_METHOD(printLangPrinter:(NSString *)ip)
RCT_EXTERN_METHOD(cancelChinese:(NSString *)ip)


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
RCT_EXTERN_METHOD(setEncode:(NSString *)base64String)
RCT_EXTERN_METHOD(line:(NSInteger *)length)
RCT_EXTERN_METHOD(line2:(NSInteger *)length)
RCT_EXTERN_METHOD(line3:(NSInteger *)length)
RCT_EXTERN_METHOD(printTemplate:(NSString *)ip isDisconnect:(BOOL *)isDisconnect
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
