//
//  SingleWavFormView.m
//  NFS4.1
//
//  Created by carlos on 15-12-13.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "SingleWavFormView.h"

@implementation SingleWavFormView


#pragma mark - setter and getter




-(id)initWithFrame:(NSRect)frameRect withChannelType:(NSString *)channeltype withPeakFileURL:(NSURL *)peakFileURL withImageRect:(NSRect)singleWavImageRect  withScrollView:(NSScrollView *)scrollView{
    if (self=[self initWithFrame:frameRect]) {
        self.channelType=channeltype;
        _peakFileURL=peakFileURL;
        self.singleWavImageRect=singleWavImageRect;
        self.fatherScrollView=scrollView;
        [self MyInit];
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

-(void)MyInit{
    [[NSBundle mainBundle] loadNibNamed:@"SingleWavFormView" owner:self topLevelObjects:nil];
    [self.contentView setFrame:NSMakeRect(0, 0, self.frame.size.width,self.frame.size.height)];
    [self addSubview:self.contentView];
    self.singleWavFormScrollView.horizontalScrollingEnabed=YES;
    self.singleWavFormScrollView.verticalScrollingEnabled=NO;
    self.singleWavFormScrollView.fatherScrollView=self.fatherScrollView;
    
    [self getData];
    self.singleWavImageRect=NSMakeRect(self.singleWavImageRect.origin.x, self.singleWavImageRect.origin.y, self.singleWavImageRect.size.width, self.singleWavFormScrollView.frame.size.height);
    wavImageView = [[SingleWavImageView alloc] initWithFrame:self.singleWavImageRect withData:_wavData dataSize:_dataSize];
    [self.singleWavFormScrollView setDocumentView:wavImageView];
    [self paint];
}

-(void)getData{
    NSError *error=nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:_peakFileURL.path error:&error];
    unsigned long long fileSize = [fileAttributes fileSize];
    unsigned long long arraySize = fileSize/sizeof(CGPoint);
    NSData *data=[[NSData alloc] initWithContentsOfURL:_peakFileURL];
    
    if (data!=nil) {
        CGPoint* wavdata = malloc(sizeof(CGPoint) * arraySize);
        memset(wavdata, 0, sizeof(CGPoint) * arraySize);
        [data getBytes:wavdata length:fileSize];
        _wavData=wavdata;
        _dataSize=arraySize;
        
    }
}

-(void)paint{
    if (self.channelType!=nil) {
        [self.ChannelTypeLabel setStringValue:self.channelType];
    }
    if (_wavData!=NULL) {
        self.singleWavImageRect=NSMakeRect(self.singleWavImageRect.origin.x, self.singleWavImageRect.origin.y, self.singleWavImageRect.size.width, self.singleWavFormScrollView.frame.size.height);
        
        wavImageView.progress=self.playProgress;
        [wavImageView setFrame:self.singleWavImageRect];
        [wavImageView setNeedsDisplay:YES];
    }
    /*if (self.wavFormImage.size.width*self.progress>self.singleWavFormScrollView.frame.size.width) {
        NSClipView *temp=self.singleWavFormScrollView.contentView;
        NSRect rect=temp.frame;
        rect.origin.x=self.wavFormImage.size.width*self.progress;
        [temp setFrame:rect];
        [self.singleWavFormScrollView setContentView:temp];
    }*/
}





@end
