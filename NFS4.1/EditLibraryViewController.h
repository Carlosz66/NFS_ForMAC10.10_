//
//  EditLibraryViewController.h
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Library.h"
#import "ApplicationHelper.h"

@interface EditLibraryView : NSView<NSTableViewDataSource,NSTableViewDelegate>

@property (weak) IBOutlet NSTextField *LibraryPathTextField;
@property (weak) IBOutlet NSTableView *EditTableView;
@property (strong) IBOutlet NSView *contentView;

@property (strong,nonatomic)Library *EditLibrary;

-(void)myBecomeFirstResponder;
@end
