//
//  LibraryAreaView.h
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CreateLibraryWizardViewController.h"
#import "EditLibraryViewController.h"

@interface LibraryAreaView : NSView <NSOutlineViewDataSource,NSOutlineViewDelegate>

@property (weak) IBOutlet NSOutlineView *LibrariesOutlineView;
@property (strong) IBOutlet LibraryAreaView *contentView;


//@property NSWindow *CreateLibraryWizardWindow;
//@property NSWindow *EditLibraryWindow;

//@property CreateLibraryWizardView *createWizardView;
//@property EditLibraryView *editView;

@end
