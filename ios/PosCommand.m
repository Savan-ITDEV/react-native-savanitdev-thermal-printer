
#import "PosCommand.h"

@implementation PosCommand

// OK
+(NSData *)selectAlignment:(int)n{
    
    Byte b[3]={0};
    b[0]=0x1B;
    b[1]=0x61;
    
    b[2]=n;
    
    NSData *data=[NSData dataWithBytes:&b length: sizeof(b)];
    return data;
}
// OK 
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


// OK
+(NSData *)printAndFeedLine{
    Byte b[1]={0};
    b[0]=0x0A;
    NSData *data=[NSData dataWithBytes:&b length:1];
    return data;
}

// OK
+(NSData *)printRasteBmpWithM:(PrintRasterType) m andImage:(UIImage *)image andType:(BmpType)type{
    
    NSData *data=[ImageTranster rasterImagedata:image andType:type andPrintRasterType:m];
    return data;
}
@end
