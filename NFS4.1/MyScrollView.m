//
//  MyScrollView.m
//  NFS4.1
//
//  Created by carlos on 15-12-18.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "MyScrollView.h"

@implementation MyScrollView

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
}



- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self setUpOnInit];
    }
    return self;
}

-(void)setUpOnInit
{
    //Set all default values.
    self.horizontalScrollingEnabed=YES;
    self.verticalScrollingEnabled=YES;
}

-(void)scrollWheel:(NSEvent *)theEvent
{
    if (self.verticalScrollingEnabled&&self.horizontalScrollingEnabed) {
        [super scrollWheel:theEvent];
    }
    else if(theEvent.scrollingDeltaY!=0&&self.verticalScrollingEnabled){
        [super scrollWheel:theEvent];
    }else if (theEvent.scrollingDeltaX!=0&&self.horizontalScrollingEnabed){
        [super scrollWheel:theEvent];
    }else{
        [self.fatherScrollView scrollWheel:theEvent];
    }
}

@end
