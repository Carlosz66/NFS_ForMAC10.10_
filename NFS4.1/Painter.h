//
//  Painter.h
//  NFS4.1
//
//  Created by carlos on 15-12-13.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <GLKit/GLKit.h>
#import <OpenGL/OpenGL.h>

@interface Painter : NSObject

+(NSImage *)CreatWaveImage:(CGPoint *)points Size:(NSRect)imageSize CurrentX:(float)progress Length:(unsigned long long)arraySize;

+(CGImageRef)CreatWaveCGImageRef:(CGPoint *)points Size:(NSRect)imageSize CurrentX:(float)progress Length:(unsigned long long)arraySize;

@end


/*
if(_playProgress > 0.0) {
    //CGContextSaveGState(cr);
    NSRect clipRect = self.bounds;
    clipRect.size.width = (clipRect.size.width - 12) * _playProgress;
    clipRect.origin.x = clipRect.origin.x + 6;
    CGContextAddRect(cr, clipRect);
    CGContextClip(cr);
    
    CGContextSetRGBFillColor(cr, 242.0/255.0, 147.0/255.0, 0.0/255.0, 1.0);
    CGContextAddPath(cr, path);
    CGContextFillPath(cr);
    
    //CGContextAddRect(cr, self.bounds);
    //CGContextClip(cr);
    //CGContextRestoreGState(cr);
    CGContextSetRGBStrokeColor(cr, 47.0/255.0, 47.0/255.0,48.0/255.0, 1.0);
    CGContextAddPath(cr, path);
    CGContextStrokePath(cr);
}*/