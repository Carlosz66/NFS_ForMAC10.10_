//
//  Painter.m
//  NFS4.1
//
//  Created by carlos on 15-12-13.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "Painter.h"

@implementation Painter


/// 根据给定的点坐标和图片大小创建图片，自动拉伸
/// - Parameter points: 点坐标序列
/// - Parameter imageSize: 图片大小
/// - Returns: 根据点坐标序列和图片大小创建的图片

///cx: 0~100
+(NSImage *)CreatWaveImage:(CGPoint *)points Size:(NSRect)imageSize CurrentX:(float)progress Length:(unsigned long long)arraySize{
    
    CGColorSpaceRef colorSpace =CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef context=CGBitmapContextCreate(NULL, imageSize.size.width, imageSize.size.height, 8, 0, colorSpace,kCGImageAlphaPremultipliedLast);
    CGAffineTransform xf=CGAffineTransformIdentity;
    xf = CGAffineTransformTranslate(xf, 0, imageSize.size.height/2);
    xf=CGAffineTransformScale(xf, imageSize.size.width/arraySize,imageSize.size.height/2);
    CGMutablePathRef path=CGPathCreateMutable();
    CGPathAddLines(path, &xf,points,arraySize);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    //CGContextSaveGState(context);
    //draw the orange size
    if(progress>0){
        
        NSRect clipRect = imageSize;
        clipRect.size.width=(clipRect.size.width-12) * progress;
        clipRect.origin.x+=6;
        CGContextAddRect(context, clipRect);
        CGContextClip(context);
        
        CGContextSetStrokeColorWithColor(context, (__bridge CGColorRef)([NSColor orangeColor]));
        CGContextStrokeRect(context, clipRect);
        //CGContextSetRGBFillColor(context, 242.0/255.0, 147.0/255.0, 0.0/255.0, 1.0);
        //CGContextAddPath(context, path);
        //CGContextFillPath(context);
    
        
        //CGContextSetRGBStrokeColor(context, 47.0/255.0, 47.0/255.0, 48.0/255.0, 1.0);
        //CGContextAddPath(context, path);
        //CGContextStrokePath(context);

        
    }
    //[[NSColor clearColor] setFill];
    CGImageRef image=CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGPathRelease(path);
    CGColorSpaceRelease(colorSpace);
    return [[NSImage alloc] initWithCGImage:image size:NSZeroSize];
}



+(CGImageRef)CreatWaveCGImageRef:(CGPoint *)points Size:(NSRect)imageSize CurrentX:(float)progress Length:(unsigned long long)arraySize{
    
    CGColorSpaceRef colorSpace =CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGContextRef context=CGBitmapContextCreate(NULL, imageSize.size.width, imageSize.size.height, 8, 0, colorSpace,kCGImageAlphaPremultipliedLast);
    CGAffineTransform xf=CGAffineTransformIdentity;
    xf = CGAffineTransformTranslate(xf, 0, imageSize.size.height/2);
    xf=CGAffineTransformScale(xf, imageSize.size.width/arraySize,imageSize.size.height/2);
    CGMutablePathRef path=CGPathCreateMutable();
    CGPathAddLines(path, &xf,points,arraySize);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    //draw the orange size
    if(progress>0){
        
        NSRect clipRect = imageSize;
        clipRect.size.width=(clipRect.size.width - 12) * progress;
        //clipRect.origin.x+=6;
        CGContextAddRect(context, clipRect);
        CGContextClip(context);
        

        CGContextSetRGBFillColor (context,1,0,0,0.4);// 3
        CGContextFillRect (context, clipRect);
        
        //CGContextSetRGBFillColor(context, 242.0/255.0, 147.0/255.0, 0.0/255.0, 1.0);
        //CGContextAddPath(context, path);
        //CGContextFillPath(context);
        
        
        //CGContextSetRGBStrokeColor(context, 47.0/255.0, 47.0/255.0, 48.0/255.0, 1.0);
        //CGContextSetLineWidth(context,3);
        //CGContextAddPath(context, path);
        //CGContextStrokePath(context);
        
        
    }
    //[[NSColor clearColor] setFill];
    CGImageRef image=CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGPathRelease(path);
    CGColorSpaceRelease(colorSpace);
    return image;
}





@end
