//
//  PosCommand.m
//  Printer
//
//  Created by LeeLee on 16/7/19.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import "PosCommand.h"

@implementation PosCommand

+(NSData *)horizontalPosition{
    Byte b[1]={0};
    b[0]=0x09;
    
    NSData *data=[NSData dataWithBytes:&b length:1];
    return data;
}

+(NSData *)printAndFeedLine{
    Byte b[1]={0};
    b[0]=0x0A;
    NSData *data=[NSData dataWithBytes:&b length:1];
    return data;
}
+(NSData *)printAndBackStandardModel{
    Byte b[1]={0};
    b[0]=0x0C;
    NSData *data=[NSData dataWithBytes:&b length:1];
    return data;
    
}
+(NSData *)printAndTabs{
    Byte b[1]={0};
    b[0]=0x0D;
    NSData *data=[NSData dataWithBytes:&b length:1];
    return data;
    
}
+(NSData *)canclePrintDataByPageModel{
    Byte b[1]={0};
    b[0]=0x18;
    NSData *data=[NSData dataWithBytes:&b length:1];
    return data;
    
}
+(NSData *)sendRealTimeStatus:(int)n{
    
    Byte b[3]={0};
    b[0]=0x10;
    b[1]=0x04;
    b[2]=n;
    NSData *data=[NSData dataWithBytes:&b length:3];
    return data;
    
}
+(NSData *)requestRealTimeForPrint:(int)n{
    
    
    Byte b[3]={0};
    b[0]=0x10;
    b[1]=0x05;
    b[2]=(Byte)n;
    NSData *data=[NSData dataWithBytes:&b length:3];
    return data;
    
    
}
+(NSData *)openCashBoxRealTimeWithM:(int)m andT:(int)t{
    
    
    Byte b[5]={0};
    b[0]=0x10;
    b[1]=0x14;
    b[2]=0x01;
    b[3]=(Byte) m;
    b[4]=(Byte) t;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
    
}
+(NSData *)printUnderPageModel{
    
    Byte b[2]={0};
    b[0]=0x1B;
    b[1]=0x0C;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}
+(NSData *)setCharRightSpace:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x20;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}
+(NSData *)selectPrintModel:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x21;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}
+(NSData *)setAbsolutePrintPositionWithNL:(int)nL andNH:(int)nH{
    
    Byte b[4]={0};
    b[0]=0x1B;
    b[1]=0x24;
    b[2]=nL;
    b[3]=nH;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}
+(NSData *)selectOrCancleCustomChar:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x25;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}
+(NSData *)defineUserDefinedCharactersWithM:(int)m andNL:(int)nL andNH:(int)nH andBytes:(Byte *)bytes{
    
    Byte b[5]={0};
    b[0]=0x1B;
    b[1]=0x26;
    b[2]=0x03;
    b[3]=nL;
    b[4]=nH;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    NSMutableData *dataM=[[NSMutableData alloc] initWithData:data];
    [dataM appendData:[NSData dataWithBytes:&bytes length:sizeof(bytes)]];
    return  dataM;
}

+(NSData *)selectBmpModelWithM:(int)m
                         andnL:(int)nL
                         andnH:(int)nH
                     andNSData:(NSData *)data{
    
    Byte b[5]={0};
    b[0]=0x1B;
    b[1]=0x2A;
    b[2]=m;
    b[3]=nL;
    b[4]=nH;
    
    NSData *newData=[NSData dataWithBytes:&b length: sizeof(b)];
    NSMutableData *dataM=[[NSMutableData alloc]initWithData:newData];
    [dataM appendData:data];
    return dataM;
}
+(NSData *)selectOrCancleUnderLineModel:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x2D;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)setDefultLineSpace{
    
    Byte b[2]={0};
    b[0]=0x1B;
    b[1]=0x32;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
    
}

+(NSData *)setDefultLineSpace:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x33;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectPrinter:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x3D;
    b[2]=n;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)cancleUserDefinedCharacters:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x3F;
    b[2]=n;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)initializePrinter{
    
    Byte b[2]={0};
    b[0]=0x1B;
    b[1]=0x40;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)setHorizontalTabsPosition:(NSData *)data{
    
    Byte b[2]={0};
    b[0]=0x1B;
    b[1]=0x44;
    NSData *newData=[NSData dataWithBytes:&b length: sizeof(b)];
    NSMutableData *dataM=[[NSMutableData alloc] initWithData:newData];
    [dataM appendData:data];
    Byte b1[1];
    b1[0]=0x00;
    [dataM appendBytes:&b1 length:sizeof(b1)];
    return dataM;
}

+(NSData *)selectOrCancleBoldModel:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x45;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectOrCancleDoublePrintModel:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x47;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)printAdnFeed:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x4A;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectPagemodel{
    
    Byte b[2]={0};
    b[0]=0x1B;
    b[1]=0x4C;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectFont:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x4D;
    b[2]=n;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectInternationCharacterSets:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x52;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectStabdardModel{
    
    Byte b[2]={0};
    b[0]=0x1B;
    b[1]=0x53;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectPrintDirectionUnderPageModel:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x54;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectOrCancleCW90:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x56;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)setPrintAreaUnderPageModelWithxL:(int)xL
                                      andxH:(int)xH
                                      andyL:(int)yL
                                      andyH:(int)yH
                                     anddxL:(int)dxL
                                     anddxH:(int)dxH
                                     anddyL:(int)dyL
                                     anddyK:(int)dyH{
    
    Byte b[10]={0};
    b[0]=0x1B;
    b[1]=0x57;
    b[2]=xL;
    b[3]=xH;
    b[4]=yL;
    b[5]=yH;
    b[6]=dxL;
    b[7]=dxH;
    b[8]=dyL;
    b[9]=dyH;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)setRelativeHorizontalPrintPositionWithnL:(int)nL
                                              andnH:(int)nH{
    
    Byte b[4]={0};
    b[0]=0x1B;
    b[1]=0x5C;
    b[2]=nL;
    b[3]=nH;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectAlignment:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x61;
    
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectPrintTransducerOutPutPageOutSignal:(int)n{
    
    Byte b[4]={0};
    b[0]=0x1B;
    b[1]=0x63;
    b[2]=0x33;
    b[3]=n;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectPrintTransducerStopPrint:(int)n{
    
    Byte b[4]={0};
    b[0]=0x1B;
    b[1]=0x63;
    b[2]=0x34;
    b[3]=n;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
    
}

+(NSData *)allowOrForbidPressButton:(int)n{
    
    Byte b[4]={0};
    b[0]=0x1B;
    b[1]=0x63;
    b[2]=0x35;
    b[3]=n;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)printAndFeedForwardWhitN:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x64;
    
    b[2]=n;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)creatCashBoxContorPulseWithM:(int)m
                                  andT1:(int)t1
                                  andT2:(int)t2{
    
    Byte b[5]={0};
    b[0]=0x1B;
    b[1]=0x70;
    b[2]=m;
    b[3]=t1;
    b[4]=t2;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectCharacterCodePage:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x74;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectOrCancleConvertPrintModel:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x7B;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)printBmpInFLASHWithN:(int)n andM:(int)m{
    
    Byte b[4]={0};
    b[0]=0x1C;
    b[1]=0x70;
    b[2]=n;
    b[3]=m;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)definedFlashBmpWithN:(int)n andBmp:(UIImage *)image andBmpType:(BmpType) bmptype andPrintType:(PrintRasterType) type{
    
    Byte b[3]={0};
    b[0]=0x1C;
    b[1]=0x71;
    b[2]=n;
    
    NSData *newData=[NSData dataWithBytes:&b length: sizeof(b)];
    NSMutableData *dataM=[[NSMutableData alloc]initWithData:newData];
    NSData *data=[ImageTranster rasterImagedata:image andType:bmptype andPrintRasterType:type];
    [dataM appendData:data];
    return dataM;
}

+(NSData *)selectCharacterSize:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1D;
    b[1]=0x21;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)setAbsolutePositionUnderPageModelWithnL:(int)nL andnH:(int)nH{
    
    Byte b[4]={0};
    b[0]=0x1D;
    b[1]=0x24;
    b[2]=nL;
    b[3]=nH;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)definedDownLoadBmp:(UIImage *)image byType:(BmpType) bmptype{
    
    Byte b[2]={0};
    b[0]=0x1D;
    b[1]=0x2A;
    
    NSData *newData=[NSData dataWithBytes:&b length: sizeof(b)];
    NSMutableData *dataM=[[NSMutableData alloc] initWithData:newData];
    //此处还需传入一个枚举参数，单色处理类型
    NSData *data=[ImageTranster Imagedata:image andType:bmptype];
    //此处还需要一个将像素数据单色处理，合并成打印数据的方法
    [dataM appendData:data];
    return dataM;
}

+(NSData *)executePrintDataSavaByTeansformToHex{
    Byte b[7]={0};
    b[0]=0x1D;
    b[1]=0x28;
    b[2]=0x41;
    b[3]=0x02;
    b[4]=0x00;
    b[5]=0x00;
    b[6]=0x01;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)printDownLoadBmp:(int)m{
    
    Byte b[3]={0};
    b[0]=0x1D;
    b[1]=0x2F;
    b[2]=m;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)startOrStopMacrodeFinition{
    
    Byte b[2]={0};
    b[0]=0x1D;
    b[1]=0x3A;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectOrCancleInvertPrintModel:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1D;
    b[1]=0x48;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
    
}

+(NSData *)selectHRICharactersPrintPosition:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1d;
    b[1]=0x48;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)setLeftSpaceWithnL:(int)nL andnH:(int)nH{
    
    Byte b[4]={0};
    b[0]=0x1D;
    b[1]=0x4C;
    b[2]=nL;
    b[3]=nH;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)setHorizontalAndVerticalMoveUnitWithX:(int)x andY:(int)y{
    
    Byte b[4]={0};
    b[0]=0x1D;
    b[1]=0x50;
    b[2]=x;
    b[3]=y;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectCutPageModelAndCutpage:(int)m{
    
    
    Byte b[3]={0};
    b[0]=0x1D;
    b[1]=0x56;
    b[2]=m;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectCutPageModelAndCutpageWithM:(int)m andN:(int)n{
    
    
    Byte b[4]={0};
    b[0]=0x1D;
    b[1]=0x56;
    b[2]=66;
    b[3]=n;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)setPrintAreaWidthWithnL:(int)nL andnH:(int)nH{
    
    Byte b[4]={0};
    b[0]=0x1D;
    b[1]=0x57;
    b[2]=nL;
    b[3]=nH;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)setVertivalRelativePositionUnderPageModelWithNL:(int)nL
                                                     andNH:(int)nH{
    Byte b[4]={0};
    b[0]=0x1D;
    b[1]=0x5C;
    b[2]=nL;
    b[3]=nH;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    
    return data;
}

+(NSData *)executeMacrodeCommandWithR:(int)r andT:(int)t andM:(int)m{
    
    Byte b[5]={0};
    b[0]=0x1D;
    b[1]=0x5E;
    b[2]=r;
    b[3]=t;
    b[4]=m;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)openOrCloseAutoReturnPrintState:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1D;
    b[1]=0x61;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)selectHRIFont:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1D;
    b[1]=0x66;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}

+(NSData *)setBarcodeHeight:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1D;
    b[1]=0x68;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}
+(NSData *)printBarcodeWithM:(int)m andContent:(NSString *)content useEnCodeing:(NSStringEncoding)strEncoding{
    
    Byte b[3]={0};
    b[0]=0x1D;
    b[1]=0x6B;
    b[2]=m;
    
    
    NSMutableData *dataM=[NSMutableData dataWithBytes:&b length:sizeof(b)];
    NSData *data=[content dataUsingEncoding:strEncoding];
    [dataM appendData:data];
    Byte end=0x00;
    [dataM appendBytes:&end length:sizeof(end)];
    return dataM;
}

+(NSData *)printBarcodeWithM:(int)m andN:(int)n andContent:(NSString *)content useEnCodeing:(NSStringEncoding) strEnCoding{
    
    Byte b[4]={0};
    b[0]=0x1D;
    b[1]=0x6B;
    b[2]=m;
    b[3]=n;
    
    NSMutableData *dataM=[NSMutableData dataWithBytes:&b length:sizeof(b)];
    NSData *data=[content dataUsingEncoding:strEnCoding];
    [dataM appendData:data];
    
    return dataM;
}

+(NSData *)returnState:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1D;
    b[1]=0x72;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    return data;
}

+(NSData *)printRasteBmpWithM:(PrintRasterType) m andImage:(UIImage *)image andType:(BmpType)type{
    
    NSData *data=[ImageTranster rasterImagedata:image andType:type andPrintRasterType:m];
    return data;
}

+(NSData *)setBarcoeWidth:(int)n{
    Byte b[3]={0};
    b[0]=0x1D;
    b[1]=0x77;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    
    return data;
}

+(NSData *)setChineseCharacterModel:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1C;
    b[1]=0x21;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    return data;
}

+(NSData *)selectChineseCharacterModel{
    
    Byte b[2]={0};
    b[0]=0x1C;
    b[1]=0x26;
    
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    return data;
}

+(NSData *)selectOrCancelChineseCharUnderLineModel:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1C;
    b[1]=0x2D;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    return data;
}

+(NSData *)CancelChineseCharModel{
    
    Byte b[2]={0};
    b[0]=0x1C;
    b[1]=0x2E;
    
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    return data;
}

+(NSData *)definedUserDefinedChineseCharWithCPosition:(int)c2 andNsdata:(Byte *)bytes{
    
    Byte b[4]={0};
    b[0]=0x1C;
    b[1]=0x32;
    b[2]=0xFE;
    b[3]=c2;
    NSMutableData *dataM=[NSMutableData dataWithBytes:&b length:sizeof(b)];
    [dataM appendBytes:&bytes length:sizeof(bytes)];
    
    
    return dataM;
}

+(NSData *)setChineseCharLeftAndRightSpaceWithN1:(int)n1 andN2:(int)n2{
    
    Byte b[4]={0};
    b[0]=0x1C;
    b[1]=0x53;
    b[2]=n1;
    b[3]=n2;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    return data;
    
}
+(NSData *)selectOrCancelChineseCharDoubleWH:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1C;
    b[1]=0x57;
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    
    return data;
}

+(NSData *)printerOrderBuzzingHintWithRes:(int)n andTime:(int)t{
    
    Byte b[4]={0};
    b[0]=0x1B;
    b[1]=0x42;
    b[2]=n;
    b[3]=t;
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    return data;
}

+(NSData *)printerOrderBuzzingAndWaringLightWithM:(int)m andT:(int)t andN:(int)n{
    
    Byte b[5]={0};
    b[0]=0x1B;
    b[1]=0x43;
    b[2]=m;
    b[3]=t;
    b[4]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    return data;
}

+(NSData *)setQRcodeUnitsize:(int)n{
    
    Byte b[6]={0};
    b[0]=0x1D;
    b[1]=0x28;
    b[2]=0x6B;
    b[3]=0x30;
    b[4]=0x67;
    b[5]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    return data;
}

+(NSData *)setErrorCorrectionLevelForQrcode:(int)n{
    
    Byte b[6]={0};
    b[0]=0x1D;
    b[1]=0x28;
    b[2]=0x6B;
    b[3]=0x30;
    b[4]=0x69;
    b[5]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    
    return data;
    
}

+(NSData *)sendDataToStoreAreaWitQrcodeConent:(NSString *)str usEnCoding:(NSStringEncoding) strEnCoding{
    
    NSData *data=[str dataUsingEncoding:strEnCoding];
    NSInteger len=data.length;
    int x=len%256;
    long y=len/256;
    Byte b[7]={0};
    b[0]=0x1D;
    b[1]=0x28;
    b[2]=0x6B;
    b[3]=0x30;
    b[4]=0x80;
    b[5]=x;
    b[6]=y;
    NSMutableData *dataM=[NSMutableData dataWithBytes:&b length:sizeof(b)];
    
    //NSData *data=[str dataUsingEncoding:strEnCoding];
    [dataM appendData:data];
    return dataM;
}

+(NSData *)printTheQRcodeInStore{
    Byte b[5]={0};
    b[0]=0x1D;
    b[1]=0x28;
    b[2]=0x6B;
    b[3]=0x30;
    b[4]=0x81;
    
    NSData *data=[NSData dataWithBytes:&b length:sizeof(b)];
    return data;
}
+(NSData *)setPdf417Columns:(int)n{
    
    Byte b[8]={0};
    b[0]=0x1D;
    b[1]=0x28;
    b[2]=0x6B;
    b[3]=0x03;
    b[4]=0x00;
    b[5]=0x30;
    b[6]=0x41;
    b[7]=n;
    
    NSData *data=[NSData dataWithBytes:&b length:sizeof(b)];
    return data;
}

+(NSData *)setpdf417WidthOfModule:(int)n{
    
    Byte b[8]={0};
    b[0]=0x1D;
    b[1]=0x28;
    b[2]=0x6B;
    b[3]=0x03;
    b[4]=0x00;
    b[5]=0x30;
    b[6]=0x43;
    b[7]=n;
    
    NSData *data=[NSData dataWithBytes:&b length:sizeof(b)];
    return data;
}

+(NSData *)setpdf417RowHeight:(int)n{
    
    Byte b[8]={0};
    b[0]=0x1D;
    b[1]=0x28;
    b[2]=0x6B;
    b[3]=0x03;
    b[4]=0x00;
    b[5]=0x30;
    b[6]=0x44;
    b[7]=n;
    
    NSData *data=[NSData dataWithBytes:&b length:sizeof(b)];
    return data;
}

+(NSData *)storethepdf417WithpL:(int)pL andpH:(int)pH andContent:(NSString *)content usEnCoding:(NSStringEncoding) strEnCoding{
    
    Byte b[8]={0};
    b[0]=0x1D;
    b[1]=0x28;
    b[2]=0x6B;
    b[3]=pL;
    b[4]=pH;
    b[5]=0x30;
    b[6]=0x50;
    b[7]=0x30;
    
    NSData *data=[NSData dataWithBytes:&b length:sizeof(b)];
    NSMutableData *dataM=[NSMutableData dataWithData:data];
    NSData *contentdata=[content dataUsingEncoding:strEnCoding];
    [dataM appendData:contentdata];
    return dataM;
}

+(NSData *)printPdf417InStore{
    
    Byte b[8]={0};
    b[0]=0x1D;
    b[1]=0x28;
    b[2]=0x6B;
    b[3]=0x03;
    b[4]=0x00;
    b[5]=0x30;
    b[6]=0x51;
    b[7]=0x30;
    
    NSData *data=[NSData dataWithBytes:&b length:sizeof(b)];
    return data;
}

@end
