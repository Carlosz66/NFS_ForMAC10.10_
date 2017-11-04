//
//  SingleWavFormView.h
//  NFS4.1
//
//  Created by carlos on 15-12-13.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SingleWavImageView.h"
#import "MyScrollView.h"

@interface SingleWavFormView : NSView
{
    NSURL *_peakFileURL;
    CGPoint *_wavData;
    unsigned long long _dataSize;
    SingleWavImageView *wavImageView;
}

@property (strong) IBOutlet NSView *contentView;
@property (weak) IBOutlet NSTextField *ChannelTypeLabel;
@property (weak) IBOutlet MyScrollView *singleWavFormScrollView;

@property (weak) NSScrollView *fatherScrollView;

@property NSRect singleWavImageRect;
@property NSString *channelType;
@property float playProgress;

-(id)initWithFrame:(NSRect)frameRect withChannelType:(NSString *)channeltype withPeakFileURL:(NSURL *)peakFileURL withImageRect:(NSRect)singleWavImageRect  withScrollView:(NSScrollView *)scrollView;


@end
