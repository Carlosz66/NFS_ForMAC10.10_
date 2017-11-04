//
//  MyScrollView.h
//  NFS4.1
//
//  Created by carlos on 15-12-18.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyScrollView : NSScrollView

@property BOOL horizontalScrollingEnabed;
@property BOOL verticalScrollingEnabled;

@property (weak)NSScrollView *fatherScrollView;
@end
