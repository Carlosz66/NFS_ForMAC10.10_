//
//  CreateLibraryWizardViewController.h
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Library.h"

@interface CreateLibraryWizardView : NSView<NSTableViewDataSource,NSTableViewDelegate,LibraryCreateDatabaseDelegate>
{
    NSString *_createdLibraryPath;
}
@property (weak) IBOutlet NSTextField *FilePathTextField;
@property (weak) IBOutlet NSComboBox *SoundTypeComboBox;
@property (weak) IBOutlet NSTableView *FilePatternTableView;
@property (weak) IBOutlet NSButton *isCreateCacheButton;
@property (strong) IBOutlet NSView *contentView;

@property Library *CreatedLibrary;

@end
