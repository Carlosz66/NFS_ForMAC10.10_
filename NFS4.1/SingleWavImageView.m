//
//  SingleWavImageView.m
//  NFS4.1
//
//  Created by carlos on 15-12-15.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "SingleWavImageView.h"

@implementation SingleWavImageView

-(id)initWithFrame:(NSRect)frameRect withData:(CGPoint *)wavdata dataSize:(unsigned long long)datasize{
    if (self=[self initWithFrame:frameRect]) {
        _wavData=wavdata;
        _dataSize=datasize;
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.

    [self paint];
}

-(void)paint{
    CGImageRef wavImage =[Painter CreatWaveCGImageRef:_wavData Size:self.frame CurrentX:self.progress Length:_dataSize];
    CGContextRef MYContext =[[NSGraphicsContext currentContext] graphicsPort];
    if (wavImage==NULL) {
        return;
    }
    CGContextDrawImage(MYContext,self.frame,wavImage);
    CGImageRelease(wavImage);
}

#pragma mark handle mouse event

-(void)mouseUp:(NSEvent *)theEvent{
    NSPoint p=[theEvent locationInWindow];
    NSPoint upPoint=[self convertPoint:p fromView:nil];
    float progress=upPoint.x/self.frame.size.width;
    NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"seekAtPoint" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:progress] forKey:@"progress"]];
    NSLog(@"mouseUp");
}

-(void)dealloc{
    free(_wavData);
}

@end
