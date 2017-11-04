//
//  SingleWavImageView.h
//  NFS4.1
//
//  Created by carlos on 15-12-15.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Painter.h"

@interface SingleWavImageView : NSView
{
    CGPoint *_wavData;
    unsigned long long _dataSize;
}

@property float progress;


-(id)initWithFrame:(NSRect)frameRect withData:(CGPoint *)wavdata dataSize:(unsigned long long)datasize;

@end
