//
//  LibraryAreaView.m
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "LibraryAreaView.h"

static CreateLibraryWizardView *createWizardView;
static NSWindow *CreateLibraryWizardWindow;
static EditLibraryView *editView;
static NSWindow *EditLibraryWindow;

@implementation LibraryAreaView

-(void)awakeFromNib{
    [super awakeFromNib];
    //[self MyInit];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self MyInit];
    }
    
    return self;
}

-(void)MyInit{
    [[NSBundle mainBundle] loadNibNamed:@"LibraryAreaView" owner:self topLevelObjects:nil];
    [self.contentView setFrame:NSMakeRect(0, 0, self.frame.size.width,self.frame.size.height)];
    [self addSubview:self.contentView];

    
    //!!!!!!!!!!!!!!!!!!  not sure
    editView=[[EditLibraryView alloc] initWithFrame:NSMakeRect(0, 0, 597, 410)];
    EditLibraryWindow = [[NSWindow alloc] initWithContentRect:editView.frame styleMask:(NSTitledWindowMask | NSClosableWindowMask) backing:(NSBackingStoreBuffered) defer:YES];
    [EditLibraryWindow setContentView:editView];
    [EditLibraryWindow setReleasedWhenClosed:NO];
    
    //!!!!!!!!!!!!!!!!!! not sure
    createWizardView=[[CreateLibraryWizardView alloc] initWithFrame:NSMakeRect(0, 0, 600, 454)];
    CreateLibraryWizardWindow = [[NSWindow alloc] initWithContentRect:createWizardView.frame styleMask:(NSTitledWindowMask | NSClosableWindowMask) backing:(NSBackingStoreBuffered) defer:YES];
    [CreateLibraryWizardWindow setContentView:createWizardView];
    [CreateLibraryWizardWindow setReleasedWhenClosed:NO];

    
    [ApplicationHelper ReadStore];
    if ([ApplicationHelper StoreURL]==nil) {
        NSOpenPanel *openPanel =[ApplicationHelper CreateNSOpenPanel:@"请选择数据库文件所保存的文件夹位置" CanChooseDirectories:YES CanChooseFiles:NO];
        if([openPanel runModal]==NSFileHandlingPanelOKButton){
            [ApplicationHelper CreateStore:openPanel.URL];
        }else{
            exit(1);
        }
    }
    
    [ApplicationHelper ReadDatabases];

    [self.LibrariesOutlineView setDataSource:self];
    [self.LibrariesOutlineView setDelegate:self];
    [self.LibrariesOutlineView reloadData];
    [self.LibrariesOutlineView registerForDraggedTypes:@[NSStringPboardType]];

}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [self.contentView setFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
}

-(BOOL)becomeFirstResponder{
    if (self.LibrariesOutlineView.selectedRow!=-1) {
        Sound *sound=[self.LibrariesOutlineView itemAtRow:self.LibrariesOutlineView.selectedRow];
        if (sound!=nil) {
            [[ApplicationHelper player] ResetSound:sound];
        }
    }
    return [super becomeFirstResponder];
}

#pragma mark - IBAction

- (IBAction)RefreshMenuItemClicked:(NSMenuItem *)sender{
    [ApplicationHelper ReadDatabases];
    [self.LibrariesOutlineView reloadData];
    NSBeep();
}

- (IBAction)CreateMenuItemClicked:(NSMenuItem *)sender{
    CreateLibraryWizardWindow.title=sender.title;
    [CreateLibraryWizardWindow makeKeyAndOrderFront:self];
}

- (IBAction)EditMenuItemClicked:(NSMenuItem *)sender{
    if (self.LibrariesOutlineView.selectedRow!=-1) {
        id item = [self.LibrariesOutlineView itemAtRow:self.LibrariesOutlineView.selectedRow];
        if ([item isMemberOfClass:[Library class]]) {
            Library *lib=item;
            if (lib.IsRoot) {
                editView.EditLibrary=item;
            }else{
                editView.EditLibrary=lib.FatherLibrary;
            }
        }else if ([item isMemberOfClass:[Sound class]]){
            Sound *sound =item;
            editView.EditLibrary=sound.FatherLibrary;
        }
        EditLibraryWindow.title=sender.title;
        [editView myBecomeFirstResponder];
        [EditLibraryWindow makeKeyAndOrderFront:self];
    }else{
        NSBeep();
    }
}

- (IBAction)PlayMenuItemClicked:(NSMenuItem *)sender{
    if (self.LibrariesOutlineView.selectedRow!=-1) {
        Sound *sound=[self.LibrariesOutlineView itemAtRow:self.LibrariesOutlineView.selectedRow];
        if (sound!=nil) {
            [[ApplicationHelper player] ResetSound:sound];
            [[ApplicationHelper player] PlayOrPause];
        }
    }
    
}

- (IBAction)CopyMenuItemClicked:(NSMenuItem *)sender{
    [ApplicationHelper setPasteBoard:[NSMutableArray array]];
    [self.LibrariesOutlineView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        Sound *sound = [self.LibrariesOutlineView itemAtRow:idx];
        if (sound!=nil) {
            [[ApplicationHelper PasteBoard] addObject:sound];
        }
    }];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard setString:@"LibrariesOutlineView 04132090NFS" forType:NSStringPboardType];
}

#pragma mark - outlineview delegate & dataSource method

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if (item==nil) {
        return [[ApplicationHelper Libraries] objectAtIndex:index];
    }else{
        if([item isMemberOfClass:[Library class]]){
            Library *lib=item;
            if (index+1>lib.SubSounds.count) {
                NSInteger folderindex = index - lib.SubSounds.count;
                return [lib.SubFolders objectAtIndex:folderindex];
            }else{
                return [lib.SubSounds objectAtIndex:index];
            }
        }
    }
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    return [item isMemberOfClass:[Library class]];
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if([item isMemberOfClass:[Library class]]){
        Library *lib = item;
        return lib.SubFolders.count+lib.SubSounds.count;
    }
    return [[ApplicationHelper Libraries] count];
}

-(id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    if (item==nil) {
        return @"";
    }else if ([item isMemberOfClass:[Library class]]){
        Library *lib=item;
        return lib.Name;
    }else if ([item isMemberOfClass:[Sound class]]){
        Sound *sound=item;
        return [sound.Info objectForKey:[NSNumber numberWithInt:DisplayName]];
    }
    return @"";
}

-(BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{
    if (self.LibrariesOutlineView.selectedRow!=-1) {
        if ([item isMemberOfClass:[Sound class]]) {
            [[ApplicationHelper player] ResetSound:item];
        }
    }
    return YES;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard{
    [ApplicationHelper setPasteBoard:[NSMutableArray array]];
    for(id item in items){
        if([item isMemberOfClass:[Sound class]]){
            Sound *sound=item;
            if (sound!=nil) {
                [[ApplicationHelper PasteBoard] addObject:sound];
            }
        }
    }
    [pasteboard clearContents];
    [pasteboard setString:@"LibrariesOutlineView 04132090NFS" forType:NSStringPboardType];
    return YES;
}

@end
