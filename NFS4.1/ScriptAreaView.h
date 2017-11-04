//
//  ScriptAreaView.h
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Library.h"
#import "EditLibraryViewController.h"

@interface ScriptAreaView : NSView<NSOutlineViewDataSource,NSOutlineViewDelegate>
{
    Library *_scriptLibrary;
}
@property (weak) IBOutlet NSOutlineView *LibrariesTree;
@property NSWindow *EditLibraryWindow;
@property EditLibraryView *editView;

@property (strong) IBOutlet NSView *contentView;

@end

