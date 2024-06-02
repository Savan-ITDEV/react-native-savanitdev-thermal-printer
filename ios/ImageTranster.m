//
//  ImageTranster.m
//  Printer
//
//  Created by LeeLee on 16/7/19.
//  Copyright © 2016年 Admin. All rights reserved.
//

#import "ImageTranster.h"

@implementation ImageTranster

#define Mask8(x) ((x)&0xFF)
#define A(x) (Mask8(x))
#define B(x) (Mask8(x>>8))
#define G(x) (Mask8(x>>16))
#define R(x)  (Mask8(x>>24))
#define RGBAMake(r,g,b,a)   (Mask8(a)|Mask8(b)<<8|Mask8(g)<<16|Mask8(r)<<24)
+(UIImage *)covertToGrayScale:(UIImage*)image{
    CGImageRef cgimage=[image CGImage];
    size_t width=CGImageGetWidth(cgimage);
    size_t height=CGImageGetHeight(cgimage);
    
    //像素将画在这个数组
    uint32_t *pixels = (uint32_t *)malloc(width *height *sizeof(uint32_t));
    //清空像素数组
    memset(pixels, 0, width*height*sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //用 pixels 创建一个 context
    CGContextRef context =CGBitmapContextCreate(pixels, width, height, 8, width*sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height),cgimage);
    
    int tt =1;
    CGFloat intensity;
    int bw;
    
    for (int y = 0; y <height; y++) {
        for (int x =0; x <width; x ++) {
            uint8_t *rgbaPixel = (uint8_t *)&pixels[y*width+x];
            intensity = (rgbaPixel[tt] + rgbaPixel[tt + 1] + rgbaPixel[tt + 2]) / 3. / 255.;
            
            bw = intensity > 0.45?255:0;
            
            rgbaPixel[tt] = bw;
            rgbaPixel[tt + 1] = bw;
            rgbaPixel[tt + 2] = bw;
            
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image2 = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image2];
    // we're done with image now too
    CGImageRelease(image2);
    return resultUIImage;
}
+(NSData *)Imagedata:(UIImage *) mIamge andType:(BmpType) bmptype{
    CGImageRef cgimage=[[ImageTranster covertToGrayScale:mIamge] CGImage];
    size_t w=CGImageGetWidth(cgimage);
    size_t h=CGImageGetHeight(cgimage);
    UInt32 *pixels;
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    NSInteger bpp=4;//每个像素的字节
    NSInteger bpc=8;//每个组成像素的位深
    NSInteger bpr=w*bpp;//每行字节数
    pixels=(UInt32 *)calloc(w*h,sizeof(UInt32));
    CGContextRef context=CGBitmapContextCreate(pixels, w, h, bpc, bpr, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), cgimage);
    //将像素数据封装成打印机能识别的数据
    size_t n=(w+7)/8;
    uint8_t *newPixels;
    size_t m=0x01;
    size_t rep=(h+23)/24;
    newPixels=(uint8_t *)calloc(n*h, sizeof(uint8_t));
    for (NSInteger y=0; y<h; y++) {
        for (NSInteger x=0; x<n*8; x++) {
            if (x<w) {
                if ((pixels[y*w+x]&0xff0000)>> 16 != 0) {
                    newPixels[y*n+x/8]|=m<<(7-x%8);
                }
            }else if (x>=w){
                newPixels[y*n+x/8]|=0<<(0-x%8);
            }
        }
    }
    NSMutableData *dataM=[[NSMutableData alloc] init];
    for (NSInteger i=0; i<rep; i++)
    {
        if (i==rep-1)
        {
            if (h%24==0)
            {
                Byte cpyByte[24*n];
                memcpy(cpyByte, newPixels+(24*n*i), 24*n);
                [dataM appendBytes:&cpyByte length:sizeof(cpyByte)];
                
            }
            else
            {
                Byte cpyByte[(h%24)*n];
                memcpy(cpyByte, newPixels+(24*n*i), (h%24)*n);
                [dataM appendBytes:&cpyByte length:sizeof(cpyByte)];
            }
        }
        else
        {
            Byte cpyByte[24*n];
            memcpy(cpyByte, newPixels+(24*n*i), 24*n);
            [dataM appendBytes:&cpyByte length:sizeof(cpyByte)];
        }
    }
    //释放图片
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    //释放内存
    free(pixels);
    free(newPixels);
    return dataM;
}
+(NSData *)rasterImagedata:(UIImage *) mIamge andType:(BmpType) bmptype andPrintRasterType:(PrintRasterType) type{
    //NSMutableData *dataM=[[NSMutableData alloc] init];
//    mIamge=[self imageCompressForWidthScale:mIamge targetWidth:576];
    //得到UIImage,获取图片像素，并转换为UInt32类型数据
    //int pixels[w*h];
    UInt32 aveGray;
    UInt32 sumGray=0;
    CGImageRef cgimage=[mIamge CGImage];
    size_t w=CGImageGetWidth(cgimage);
    size_t h=CGImageGetHeight(cgimage);
    UInt32 *pixels;
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();

    NSInteger bpp=4;//每个像素的字节
    NSInteger bpc=8;//每个组成像素的位深
    NSInteger bpr=w*bpp;//每行字节数

    pixels=(UInt32 *)calloc(w*h,sizeof(UInt32));

    CGContextRef context=CGBitmapContextCreate(pixels, w, h, bpc, bpr, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), cgimage);
    //操作像素
    UInt8 *gradPixels;
    gradPixels=(UInt8 *)calloc(w*h, sizeof(UInt8));
    //1.灰度处理
    for (NSInteger j=0; j<h; j++) {
        for (NSInteger i=0; i<w; i++) {
            UInt32 currentPixel=pixels[(w*j)+i];
            UInt32 color=currentPixel;
            //灰度化当前像素点
            UInt32 grayColor=//(R(color)+G(color)+B(color))/3;
            (R(color)*299+G(color)*587+B(color)*114+500)/1000;
            gradPixels[w*j+i]=grayColor;
            sumGray+=grayColor;
            // NSLog(@"%i",grayColor);
            pixels[w*j+i]=RGBAMake(grayColor, grayColor, grayColor, A(color));

        }
    }
    //2.黑白处理（二值法，抖动算法）
    //int e=0;
    //NSInteger g;
    //uint8_t *grayPixels;
    //int g;
    switch (bmptype) {
        case Dithering:

            //二值法处理
            aveGray=sumGray/(w*h);
            aveGray=150;//调整打印浓度、粗细
            for (NSInteger j=0; j<h; j++) {
                for (NSInteger i=0; i<w; i++) {
                    UInt32 currentPixel=pixels[(w*j)+i];
                    UInt32 color=currentPixel;
                    if (R(color)<aveGray) {
                        pixels[w*j+i]=RGBAMake(0, 0, 0, A(color));
                    }else{
                        pixels[w*j+i]=RGBAMake(0xff, 0xff, 0xff, A(color));
                    }

                }
            }

            break;
        case Threshold:
            //抖动算法
            for (NSInteger j=0; j<h; j++) {
                for (NSInteger i=0; i<w; i++) {
                    //UInt32 currentPixel=pixels[(w*j)+i];
                    //UInt32 color=*currentPixel;
                    NSInteger e=0;
                    NSInteger g=gradPixels[w*j+i];
                    if (g>=150) {
                        pixels[w*j+i]=RGBAMake(0xff, 0xff, 0xff, 0xff);
                        e=g-255;
                    }else{
                        pixels[w*j+i]=RGBAMake(0x00 , 0x00, 0x00, 0xff);
                        e=g-0;
                    }

                    if (i<w-1&&j<h-1) {//不靠右边和下边的像素
                        //右边像素处理
                        //                        UInt8 leftPixel1=gradPixels[(w*j)+i+1];
                        //                        int lred1=Mask8(leftPixel1);
                        //                        lred1+=3*e/8;
                        //                       leftPixel1=lred1;
                        gradPixels[(w*j)+i+1]+=3*e/8;


                        //下边像素处理
                        //                        UInt8 lowPixel1=gradPixels[(w*j)+i+w];
                        //
                        //                        int lowred1=Mask8(lowPixel1);
                        //                        lowPixel1+=3*e/8;
                        //                        lowPixel1=lowred1;
                        gradPixels[(w*(j+1))+i]+=3*e/8;
                        //右下方像素处理
                        //                        UInt8 leftlowPixel1=gradPixels[(w*j)+i+w+1];
                        //                        int llred1=Mask8(leftlowPixel1);
                        //                       llred1+=e/4;
                        //                        leftlowPixel1=llred1;
                        gradPixels[w*(j+1)+i+1]+=e/4;

                    }else if (i==w-1&&j<h-1){//靠右边界的像素
                        //下边像素处理
                        //                        UInt8 lowPixel1=gradPixels[(w*j)+i+w];
                        //
                        //                        int lowred1=Mask8(lowPixel1);
                        //                        lowred1+=3*e/8;
                        //                        lowPixel1=lowred1;
                        gradPixels[(w*(j+1))+i]+=3*e/8;

                    }else if (i<w-1&&j==h-1){//靠底部的像素

                        //右边像素处理
                        //                        UInt8 leftPixel1=gradPixels[(w*j)+i+1];
                        //                        int lred1=Mask8(leftPixel1);
                        //                        lred1+=3*e/8;
                        //                        leftPixel1=lred1;
                        gradPixels[(w*j)+i+1]+=e/4;
                    }
                }
            }

            break;
        default:
            break;
    }

    //将像素数据封装成打印机能识别的数据
    size_t n=(w+7)/8;
    uint8_t *newPixels;
    size_t m=0x01;
    Byte xL=n%256;
    Byte xH=n/256;
    size_t rep=(h+23)/24;
    newPixels=(uint8_t *)calloc(n*h, sizeof(uint8_t));
    for (NSInteger y=0; y<h; y++) {
        for (NSInteger x=0; x<n*8; x++) {
            if (x<w) {
                if (R(pixels[y*w+x])==0) {
                    newPixels[y*n+x/8]|=(m<<(7-x%8));
                }
            }else if (x>=w){
                newPixels[y*n+x/8]|=(0<<(7-x%8));
            }
        }
    }
    NSMutableData *dataM=[[NSMutableData alloc] init];
    //将像素数据封装成光栅位图格式
    Byte head[8]={0x1D,0x76,0x30,type,xL,xH,0x18,0x00};

    for (NSInteger i=0; i<rep; i++)
    {
        if (i==rep-1)
        {
            if (h%24==0)
            {
                head[6]=0x18;
                [dataM appendBytes:&head length:sizeof(head)];
                Byte cpyByte[24*n];
                memcpy(cpyByte, newPixels+(24*n*i), 24*n);

                [dataM appendBytes:&cpyByte length:sizeof(cpyByte)];

            }
            else
            {

                head[6]=h%24;
                [dataM appendBytes:&head length:sizeof(head)];
                Byte cpyByte[(h%24)*n];
                memcpy(cpyByte, newPixels+(24*n*i), (h%24)*n);
                [dataM appendBytes:&cpyByte length:sizeof(cpyByte)];
            }


        }
        else
        {
            head[6]=0x18;
            [dataM appendBytes:&head length:sizeof(head)];
            Byte cpyByte[24*n];
            memcpy(cpyByte, newPixels+(24*n*i), 24*n);
            [dataM appendBytes:&cpyByte length:sizeof(cpyByte)];

        }
    }

    //释放图片
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    //释放内存
    free(pixels);
    free(gradPixels);
    free(newPixels);
    
    //3.通过处理后的像素来重新得到新的图片

    //直接返回像素数据会跟合适
    return dataM;
}
//指定宽度按比例缩放，缩放有些时候只对宽度进行了缩放
+(UIImage *) imageCompressForWidthScale:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

@end
