//
//  TscCommand.m
//  Printer
//
//  Created by LeeLee on 16/7/19.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import "TscCommand.h"

@implementation TscCommand

+(NSData *)sizeBymmWithWidth:(double)m andHeight:(double)n{
    NSString *pstr=[NSString stringWithFormat:@"SIZE %f mm,%f mm\n",m,n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)sizeBydotWithWidth:(int)m andHeight:(int)n{
    NSString *pstr=[NSString stringWithFormat:@"SIZE %d dot,%d dot\n",m,n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
    
}

+(NSData *)sizeByinchWithWidth:(double)m andHeight:(double)n{
    
    NSString *pstr=[NSString stringWithFormat:@"SIZE %f,%f\n",m,n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)gapBymmWithWidth:(double)m andHeight:(double)n{
    
    NSString *pstr=[NSString stringWithFormat:@"GAP %f mm,%f mm\n",m,n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)gapBydotWithWidth:(int)m andHeight:(int)n{
    
    NSString *pstr=[NSString stringWithFormat:@"GAP %d dot,%d dot\n",m,n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)gapByinchWithWidth:(double)m andHeight:(double)n{
    
    NSString *pstr=[NSString stringWithFormat:@"SIZE %f,%f\n",m,n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)gapDetect{
    
    NSString *pstr=[NSString stringWithFormat:@"GAPDETECT\n"];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)gapDetectWithX:(int)x andY:(int)y{
    
    NSString *pstr=[NSString stringWithFormat:@"GAPDETECT %d,%d\n",x,y];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)blinedDetectWithX:(int)x andY:(int)y{
    
    NSString *pstr=[NSString stringWithFormat:@"BLINEDETECT %d,%d\n",x,y];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)autoDetectWithX:(int)x andY:(int)y{
    
    NSString *pstr=[NSString stringWithFormat:@"AUTODETECT %d,%d\n",x,y];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)blineBymmWithM:(double)m andN:(double)n{
    
    NSString *pstr=[NSString stringWithFormat:@"BLINE %f mm,%f mm\n",m,n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}
+(NSData *)blineByinchWithM:(double)m andN:(double)n{
    
    NSString *pstr=[NSString stringWithFormat:@"BLINE %f,%f\n",m,n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)blineBydotWithM:(int)m andN:(int)n{
    
    NSString *pstr=[NSString stringWithFormat:@"BLINE %d dot,%d dot\n",m,n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)offSetBymmWithM:(double)m{
    
    NSString *pstr=[NSString stringWithFormat:@"OFFSET %f mm\n",m];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)offSetByinchWithM:(double)m{
    
    NSString *pstr=[NSString stringWithFormat:@"OFFSET %f\n",m];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)offSetBydotWithM:(int)m{
    
    NSString *pstr=[NSString stringWithFormat:@"OFFSET %d dot\n",m];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)speed:(double)n{
    
    NSString *pstr=[NSString stringWithFormat:@"SPEED %f\n",n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)density:(int)n{
    
    NSString *pstr=[NSString stringWithFormat:@"DENSITY %d\n",n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+(NSData *)direction:(int)n{
    
    NSString *pstr=[NSString stringWithFormat:@"DIRECTION %d\n",n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)referenceWithX:(int)x andY:(int)y{
    
    NSString *pstr=[NSString stringWithFormat:@"REFERENCE %d,%d",x,y];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
    
}

+(NSData *)shift:(int)n{
    
    NSString *pstr=[NSString stringWithFormat:@"SHIFT %d\n",n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}
+(NSData *)country:(NSString *)countryCoding{
    
    NSString *pstr=[NSString stringWithFormat:@"COUNTRY \"%@\"\n",countryCoding];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}
+(NSData *)codePage:(NSString *)str{
    
    NSString *pstr=[NSString stringWithFormat:@"CODEPAGE \"%@\"\n",str];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)cls{
    
    NSString *pstr=[NSString stringWithFormat:@"CLS\n"];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)feed:(int)n{
    
    NSString *pstr=[NSString stringWithFormat:@"FEED %d\n",n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)backFeed:(int)n{
    
    NSString *pstr=[NSString stringWithFormat:@"BACKFEED %d\n",n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)formFeed{
    
    NSString *pstr=[NSString stringWithFormat:@"FORMFEED\n"];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)home{
    
    NSString *pstr=[NSString stringWithFormat:@"HOME\n"];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)print:(int)m{
    
    NSString *pstr=[NSString stringWithFormat:@"PRINT %d\n",m];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)printWithM:(int)m andN:(int)n{
    
    NSString *pstr=[NSString stringWithFormat:@"PRINT %d,%d\n",m,n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)soundWithLevel:(int)level andInterval:(int)interval{
    
    NSString *pstr=[NSString stringWithFormat:@"SOUND %d,%d\n",level,interval];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)cut{
    
    NSString *pstr=[NSString stringWithFormat:@"CUT\n"];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)limitFeedBymm:(double)n{
    
    NSString *pstr=[NSString stringWithFormat:@"LIMITFEED %f mm\n",n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)limitFeedBydot:(int)n{
    
    NSString *pstr=[NSString stringWithFormat:@"LIMITFEED %d dot\n",n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)limitFeedByinch:(double)n{
    
    NSString *pstr=[NSString stringWithFormat:@"LIMITFEED %f\n",n];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)selfTest{
    
    NSString *pstr=[NSString stringWithFormat:@"SELFTEST\n"];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)selfTest:(NSString *)page{
    
    NSString *pstr=[NSString stringWithFormat:@"SELFTEST \"%@\"\n",page];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)eoj{
    
    NSString *pstr=[NSString stringWithFormat:@"EOJ\n"];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)delay:(int)ms{
    
    NSString *pstr=[NSString stringWithFormat:@"DELAY %d\n",ms];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)display:(NSString *)str{
    
    NSString *pstr=[NSString stringWithFormat:@"DISPLAY \"%@\"\n",str];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)initialPrinter{
    
    NSString *pstr=[NSString stringWithFormat:@"INITIALPRINTER\n"];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)barWithX:(int)x andY:(int)y andWidth:(int)w andHeigt:(int)h{
    
    NSString *pstr=[NSString stringWithFormat:@"BAR %d,%d,%d,%d\n",x,y,w,h];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)barcodeWithX:(int)x
                   andY:(int)y
            andCodeType:(NSString *)codetype
              andHeight:(int)height
       andHunabReadable:(int)readable
            andRotation:(int)rotation
              andNarrow:(int)narrow
                andWide:(int)wide
             andContent:(NSString *)content
          usStrEnCoding:(NSStringEncoding)strEnCoding{
    
    //这里的codetype的类型是字符串，所以要加引号才对
    NSString *pstr=[NSString stringWithFormat:@"BARCODE %d,%d,\"%@\",%d,%d,%d,%d,%d,\"%@\"\n",x,y,codetype,height,readable,rotation,narrow,wide,content];
    NSData *data=[pstr dataUsingEncoding:strEnCoding];
    return data;
}

+(NSData *)bitmapWithX:(int)x andY:(int)y andMode:(int)mode andImage:(UIImage *)image andBmpType:(BmpType)bmptype{
    size_t width=(CGImageGetWidth(image.CGImage)+7)/8;
    size_t height=CGImageGetHeight(image.CGImage);
    int w=(int)width;
    int h=(int)height;
    NSString *pstr=[NSString stringWithFormat:@"BITMAP %d,%d,%d,%d,%d,",x,y,w,h,mode];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableData *dataM=[NSMutableData dataWithData:data];
    NSData *imageData=[ImageTranster Imagedata:image andType:bmptype];
//    imageData=[ImageTranster rasterImagedata:image andType:bmptype andPrintRasterType:RasterNolmorWH];
    [dataM appendData:imageData];
    Byte b[1];
    b[0]=0x0A;
    [dataM appendBytes:&b length:sizeof(b)];
    return dataM;
}

+(NSData *)boxWithX:(int)x andY:(int)y andEndX:(int)x_end andEndY:(int)y_end andThickness:(int)thickness{
    
    NSString *pstr=[NSString stringWithFormat:@"BOX %d,%d,%d,%d,%d\n",x,y,x_end,y_end,thickness];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)ellipseWithX:(int)x andY:(int)y andWidth:(int)width andHeight:(int)height andThickness:(int)thickness{
    
    NSString *pstr=[NSString stringWithFormat:@"ELLIPSE %d,%d,%d,%d,%d\n",x,y,width,height,thickness];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)codaBlockFModeWithX:(int)x andY:(int)y andRotation:(int)rotation andContent:(NSString *)content{
    
    NSString *pstr=[NSString stringWithFormat:@"CODABLOCK %d,%d,%d,\"%@\"\n",x,y,rotation,content];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)dmateixWithX:(int)x
                   andY:(int)y
               andWidth:(int)width
              andHeight:(int)height
             andContent:(NSString *)content
          usStrEnCoding:(NSStringEncoding)strEnCoding{
    
    NSString *pstr=[NSString stringWithFormat:@"DMATRIX %d,%d,%d,%d,\"%@\"\n",x,y,width,height,content];
    NSData *data=[pstr dataUsingEncoding:strEnCoding];
    return data;
}

+(NSData *)eraseWithX:(int)x andY:(int)y andWidth:(int)width andHeight:(int)height{
    
    NSString *pstr=[NSString stringWithFormat:@"ERASE %d,%d,%d,%d\n",x,y,width,height];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)pdf417WithX:(int)x
                  andY:(int)y
              andWidth:(int)width
             andHeight:(int)height
             andRotate:(int)rotate
            andContent:(NSString *)content
         usStrEnCoding:(NSStringEncoding)strEnCoding{
    
    NSString *pstr=[NSString stringWithFormat:@"PDF417 %d,%d,%d,%d,%d,\"%@\"\n",x,y,width,height,rotate,content];
    NSData *data=[pstr dataUsingEncoding:strEnCoding];
    return data;
}

+(NSData *)putBmpWithX:(int)x andY:(int)y andFileName:(NSString *)filename{
    
    NSString *pstr=[NSString stringWithFormat:@"PUTBMP %d,%d,\"%@\"\n",x,y,filename];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)pubBmpWithX:(int)x andY:(int)y andFileName:(NSString *)filename andContrast:(int)contrast{
    
    NSString *pstr=[NSString stringWithFormat:@"PUTBMP %d,%d,\"%@\", %d\n",x,y,filename,contrast];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)putPcxWithX:(int)x andY:(int)y andFileName:(NSString *)filename{
    
    NSString *pstr=[NSString stringWithFormat:@"PUTPCX %d,%d,\"%@\"\n",x,y,filename];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)qrCodeWithX:(int)x
                  andY:(int)y
           andEccLevel:(NSString *)ecclevel
          andCellWidth:(int)cellwidth
               andMode:(NSString *)mode
           andRotation:(int)rotation
            andContent:(NSString *)content
         usStrEnCoding:(NSStringEncoding)strEnCoding{
    
    NSString *pstr=[NSString stringWithFormat:@"QRCODE %d,%d,%@,%d,%@,%d,\"%@\"\n",x,y,ecclevel,cellwidth,mode,rotation,content];
    NSData *data=[pstr dataUsingEncoding:strEnCoding];
    return data;
}

+(NSData *)reverseWithX:(int)x andY:(int)y andWidth:(int)width andHeight:(int)height{
    
    NSString *pstr=[NSString stringWithFormat:@"REVERSE %d,%d,%d,%d\n",x,y,width,height];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)textWithX:(int)x
                andY:(int)y
             andFont:(NSString *)font
         andRotation:(int)rotation
            andX_mul:(int)x_mul
            andY_mul:(int)y_mul
          andContent:(NSString *)content
       usStrEnCoding:(NSStringEncoding)strEnCoding{
    
    NSString *pstr=[NSString stringWithFormat:@"TEXT %d,%d,\"%@\",%d,%d,%d,\"%@\"\n",x,y,font,rotation,x_mul,y_mul,content];
    NSData *data=[pstr dataUsingEncoding:strEnCoding];
    return data;
}

+(NSData *)blockWithX:(int)x
                 andY:(int)y
             andWidth:(int)width
            andHeight:(int)height
              andFont:(NSString *)font
          andRotation:(int)rotaion
             andX_mul:(int)x_mul
             andY_mul:(int)y_mul

            andConten:(NSString *)content
        usStrEnCoding:(NSStringEncoding)strEnCoding{
    
    NSString *pstr=[NSString stringWithFormat:@"BLOCK %d,%d,%d,%d,\"%@\",%d,%d,%d,\"%@\"\n",x,y,width,height,font,rotaion,x_mul,y_mul,content];
    NSData *data=[pstr dataUsingEncoding:strEnCoding];
    return data;
}

+(NSData *)checkPrinterStatusByPort9100{
    Byte b[3];
    b[0]=0x1D;
    b[1]=0x61;
    b[2]=0x1f;
    
    NSData *data=[NSData dataWithBytes:&b length:sizeof(b)];
    return data;
}

+(NSData *)checkPrinterStatusByPort4000{
    Byte b[3];
    b[0]=0x1B;
    b[1]=0x76;
    b[2]=0x00;
    
    NSData *data=[NSData dataWithBytes:&b length:sizeof(b)];
    return data;
    
}

+(NSData *)download:(NSString *)filename{
    
    NSString *pstr=[NSString stringWithFormat:@"DOWNLOAD \"%@\"\n",filename];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
    
}

+(NSData *)download:(NSString *)filename andSize:(int)size andConten:(NSString *)content{
    
    NSString *pstr=[NSString stringWithFormat:@"DOWNLOAD \"%@\",%d,%@\n",filename,size,content];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)download:(NSString *)filename andPath:(NSURL *)url{
    NSData *filedata=[NSData dataWithContentsOfURL:url];
    int size=(int)filedata.length;
    NSString *pstr=[NSString stringWithFormat:@"DOWNLOAD \"%@\",%d",filename,size];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableData *dataM=[NSMutableData dataWithData:data];
    [dataM appendData:filedata];
    Byte b=0x0A;
    [dataM appendBytes:&b length:1];
    return dataM;
}

+(NSData *)eop{
    
    NSString *pstr=[NSString stringWithFormat:@"EOP\n"];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
    
}

+(NSData *)files{
    
    NSString *pstr=[NSString stringWithFormat:@"FILES\n"];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)kill:(NSString *)filename{
    
    NSString *pstr=[NSString stringWithFormat:@"KILL \"%@\"\n",filename];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)move{
    
    NSString *pstr=[NSString stringWithFormat:@"MOVE\n"];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

+(NSData *)run:(NSString *)filename{
    
    NSString *pstr=[NSString stringWithFormat:@"RUN \"%@\"\n",filename];
    NSData *data=[pstr dataUsingEncoding:NSASCIIStringEncoding];
    return data;
}

@end
