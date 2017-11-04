//
//  ScriptAreaView.m
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "ScriptAreaView.h"

@implementation ScriptAreaView

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
    [[NSBundle mainBundle] loadNibNamed:@"ScriptAreaView" owner:self topLevelObjects:nil];
    [self.contentView setFrame:NSMakeRect(0, 0, self.frame.size.width,self.frame.size.height)];
    [self addSubview:self.contentView];
    
    
    _scriptLibrary=[[Library alloc] init];
    _scriptLibrary.Name=@"新剧本";
    
    //!!!!!!!!!!!!!!!!!!  not sure 
    self.editView=[[EditLibraryView alloc] initWithFrame:NSMakeRect(0, 0, 597, 410)];
    
    self.EditLibraryWindow = [[NSWindow alloc] initWithContentRect:self.editView.frame styleMask:(NSTitledWindowMask | NSClosableWindowMask) backing:(NSBackingStoreBuffered) defer:YES];
    [self.EditLibraryWindow setContentView:self.editView];

    
    [self.LibrariesTree setDataSource:self];
    [self.LibrariesTree setDelegate:self];
    
    [self.LibrariesTree registerForDraggedTypes:@[NSStringPboardType]];
    [self.LibrariesTree reloadData];
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [self.contentView setFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
}

-(BOOL)becomeFirstResponder{
    if (self.LibrariesTree.selectedRow!=-1) {
        Sound *sound = [self.LibrariesTree itemAtRow:self.LibrariesTree.selectedRow];
        if (sound!=nil) {
            [[ApplicationHelper player] ResetSound:sound];
        }
    }
    return [super becomeFirstResponder];
}

#pragma mark - IBAction

- (IBAction)CreateMenuItemClicked:(NSMenuItem *)sender{
    if (self.LibrariesTree.selectedRow!=-1) {
        id item = [self.LibrariesTree itemAtRow:self.LibrariesTree.selectedRow];
        if ([item isMemberOfClass:[Library class]]) {
            Library *lib=item;
            Library *toplib = lib.FatherLibrary==nil?lib:lib.FatherLibrary;
            Library *newlib=[[Library alloc] init];
            newlib.Name=@"新场景";
            newlib.FatherFolder=lib;
            newlib.FatherLibrary=toplib;
            [lib.SubFolders addObject:newlib];
        }else if ([item isMemberOfClass:[Sound class]]){
            Sound *sound= item;
            Library *lib= sound.FatherFolder;
            Library *toplib=sound.FatherLibrary;
            Library *newlib =[[Library alloc] init];
            newlib.Name=@"新场景";
            newlib.FatherFolder=lib;
            newlib.FatherLibrary=toplib;
            [lib.SubFolders addObject:newlib];
        }
        [self.LibrariesTree reloadData];
    }
}

- (IBAction)DeleteMenuItemClicked:(NSMenuItem *)sender{
    if (self.LibrariesTree.selectedRow!=-1) {
        id item=[self.LibrariesTree itemAtRow:self.LibrariesTree.selectedRow];
        if ([item isMemberOfClass:[Library class]]) {
            Library *lib = item;
            if (lib.IsRoot) {
                _scriptLibrary = [[Library alloc] init];
                _scriptLibrary.Name=@"新剧本";
                [self.LibrariesTree reloadData];
            }else{
                [lib.FatherFolder RemoveFolder:lib];
                [self.LibrariesTree reloadData];
            }
        }else if ([item isMemberOfClass:[Sound class]]){
            Sound *sound = item;
            [sound.FatherFolder RemoveSound:sound];
            [sound.FatherLibrary RemoveSoundFromWholeSound:sound];
            [self.LibrariesTree reloadData];
        }
    }
}

- (IBAction)EditMenuItemClicked:(NSMenuItem *)sender{
    self.editView.EditLibrary=_scriptLibrary;
    self.EditLibraryWindow.title=sender.title;
    [self.EditLibraryWindow makeKeyAndOrderFront:nil];
}

- (IBAction)PlayMenuItemClicked:(NSMenuItem *)sender{
    if (self.LibrariesTree.selectedRow!=-1) {
        Sound *sound=[self.LibrariesTree itemAtRow:self.LibrariesTree.selectedRow];
        if (sound!=nil) {
            [[ApplicationHelper player] ResetSound:sound];
            [[ApplicationHelper player] PlayOrPause];
        }
    }
}

- (IBAction)OpenMenuItemClicked:(NSMenuItem *)sender{
    NSOpenPanel *openPanel = [ApplicationHelper CreateNSOpenPanel:@"请选择数据库文件所在的文件夹位置" CanChooseDirectories:YES CanChooseFiles:NO];
    if ([openPanel runModal]==NSFileHandlingPanelOKButton) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[[openPanel.URL URLByAppendingPathComponent:@"database.xml" isDirectory:NO] path]]) {
            _scriptLibrary = [[Library alloc] init:openPanel.URL];
            [self.LibrariesTree reloadData];
        }else{
            NSAlert *alert=[ApplicationHelper CreateNSAlert:@"打开失败" Message:@"没有找到数据库文件database.xml"];
            NSBeep();
            [alert runModal];
        }
    }
}

- (IBAction)SaveMenuItemClicked:(NSMenuItem *)sender{
    /*NSOpenPanel *openPanel = [ApplicationHelper CreateNSOpenPanel:@"请选择数据库文件所保存的文件夹位置" CanChooseDirectories:YES CanChooseFiles:NO];
    if ([openPanel runModal]==NSFileHandlingPanelOKButton) {
        _scriptLibrary.URL=openPanel.URL;
        [_scriptLibrary SaveLibraryToDatabase:NO];
        NSAlert *alert = [ApplicationHelper CreateNSAlert:@"保存成功" Message:@""];
        NSBeep();
        [alert runModal];
    }*/
    [_scriptLibrary SaveLibraryToDatabase:NO];
    NSAlert *alert = [ApplicationHelper CreateNSAlert:@"保存成功" Message:@""];
    NSBeep();
    [alert runModal];
    
}

- (IBAction)CutMenuItemClicked:(NSMenuItem *)sender{
    [ApplicationHelper setPasteBoard:[NSMutableArray array]];
    [self.LibrariesTree.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        Sound *item = [self.LibrariesTree itemAtRow:idx];//!!!!!!!!! not sure
        if (item!=nil) {
            [[ApplicationHelper PasteBoard] addObject:item];
            [self.LibrariesTree reloadData];
        }
    }];
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard clearContents];
    [pasteBoard setString:@"LibrariesTree 04132090NFS Cut" forType:NSStringPboardType];
}

- (IBAction)CopyMenuItemClicked:(NSMenuItem *)sender{
    [ApplicationHelper setPasteBoard:[NSMutableArray array]];
    [self.LibrariesTree.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        Sound *item = [self.LibrariesTree itemAtRow:idx];//!!!!!!!!!!!!!not sure
        if (item!=nil) {
            [[ApplicationHelper PasteBoard] addObject:item];
        }
    }];
    NSPasteboard *pasteBoard =[NSPasteboard generalPasteboard];
    [pasteBoard clearContents];
    [pasteBoard setString:@"LibrariesTree 04132090NFS" forType:NSStringPboardType];
}

- (IBAction)PasteMenuItemClicked:(NSMenuItem *)sender{
    NSPasteboard *pasteBoard =[NSPasteboard generalPasteboard];
    BOOL isCut = [[pasteBoard stringForType:NSStringPboardType] rangeOfString:@" 04132090NFS Cut"].length!=0? YES:NO;
    Library* lib = nil;
    int index = 0;
    if (self.LibrariesTree.selectedRow != -1) {
        if ([[self.LibrariesTree itemAtRow:self.LibrariesTree.selectedRow] isMemberOfClass:[Library class]]) {
            lib =[self.LibrariesTree itemAtRow:self.LibrariesTree.selectedRow];
            index = 0;
        } else {
            Sound* libsound =[self.LibrariesTree itemAtRow:self.LibrariesTree.selectedRow];
            lib = libsound.FatherFolder;
            while ([libsound.FatherFolder.SubSounds objectAtIndex:index] != libsound) {
                index++;
            }
        }
    }
    /*__block Library *lib =nil;
    [self.LibrariesTree.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        Library *testlib = [self.LibrariesTree itemAtRow:idx];
        if (testlib!=nil) {
            if(lib==nil){
                lib=testlib;
            }
        }
    }];*/
    if (lib!=nil) {
        Library *toplib=lib.FatherLibrary==nil?lib:lib.FatherLibrary;
        for(Sound *sound in [ApplicationHelper PasteBoard]){
            Sound *newsound = [[Sound alloc] init];
            newsound.FatherFolder=lib;
            newsound.FatherLibrary=toplib;
            newsound.FatherLibraryURL = sound.FatherLibraryURL;
            for(NSNumber *info in sound.Info){
                [newsound.Info setObject:[sound.Info objectForKey:info] forKey:info];
            }
            newsound.ChannelPeakFiles=[NSMutableDictionary dictionary];
            for(NSNumber *peakfile in sound.ChannelPeakFiles){
                [newsound.ChannelPeakFiles setObject:[sound.ChannelPeakFiles objectForKey:peakfile] forKey:peakfile];
            }
            newsound.AudioFiles=[NSMutableDictionary dictionary];
            for (NSNumber *soundfile in sound.AudioFiles) {
                [newsound.AudioFiles setObject:[sound.AudioFiles objectForKey:soundfile] forKey:soundfile];
            }
            [toplib.WholeSounds addObject:newsound];
            [lib.SubSounds insertObject:newsound atIndex:index];
            if (isCut) {
                [sound.FatherLibrary RemoveSoundFromWholeSound:sound];
                [sound.FatherFolder RemoveSound:sound];
            }
        }// i think we might directly copy the dictionary from sound to newsound
        [self.LibrariesTree reloadData];
        [ApplicationHelper setPasteBoard:[NSMutableArray array]];
    }
}



#pragma mark - outlineview delegate & dataSource method
-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if (item==nil) {
        return _scriptLibrary;
    }else {
        if([item isMemberOfClass:[Library class]]){
            Library *lib = item;
            if (index+1>lib.SubSounds.count) {
                NSInteger folderindex =index-lib.SubSounds.count;
                return lib.SubFolders[folderindex];
            }else{
                return lib.SubSounds[index];
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
        return lib.SubSounds.count+lib.SubFolders.count;
    }
    return 1;
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

-(void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    if ([item isMemberOfClass:[Library class]]) {
        Library *lib = item;
        lib.Name=object;//!!!!!!!!!!!!!! not sure
    }else if ([item isMemberOfClass:[Sound class]]){
        Sound *sound = item;
        [sound.Info setObject:object forKey:[NSNumber numberWithInt:DisplayName]];
    }
}

-(BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{
    if (self.LibrariesTree.selectedRow!=-1) {
        if ([item isMemberOfClass:[Sound class]]) {
            [[ApplicationHelper player] ResetSound:item];
        }
    }
    return YES;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index{
    BOOL isCut = [[[info draggingPasteboard] stringForType:NSStringPboardType] rangeOfString:@" 04132090NFS Cut"].length!=0? YES:NO;
    NSInteger insertindex = index;
    if([item isMemberOfClass:[Library class]]){
        Library *lib = item;
        if (lib!=nil) {
            Library *toplib=lib.FatherLibrary==nil?lib:lib.FatherLibrary;
            for(Sound *sound in [ApplicationHelper PasteBoard]){
                Sound *newsound = [[Sound alloc] init];
                newsound.FatherFolder=lib;
                newsound.FatherLibrary=toplib;
                newsound.FatherLibraryURL = sound.FatherLibraryURL;
                newsound.Info=[[NSMutableDictionary alloc] initWithDictionary:sound.Info copyItems:YES];
                newsound.ChannelPeakFiles=[[NSMutableDictionary alloc] initWithDictionary:sound.ChannelPeakFiles copyItems:YES];
                newsound.AudioFiles=[[NSMutableDictionary alloc] initWithDictionary:sound.AudioFiles copyItems:YES];
                [toplib.WholeSounds addObject:newsound];
                if (insertindex==-1) {
                    [lib.SubSounds addObject:newsound];
                }else{
                    [lib.SubSounds insertObject:newsound atIndex:insertindex++];
                }
                if (isCut==YES) {
                    [sound.FatherFolder RemoveSound:sound];
                    [sound.FatherLibrary RemoveSoundFromWholeSound:sound];
                }
            }
            [self.LibrariesTree reloadData];
            [ApplicationHelper setPasteBoard:[NSMutableArray array]];
        }
    }
    return YES;
}

-(NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index{
    return NSDragOperationEvery;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard{
    for(id item in items){
        if([item isMemberOfClass:[Sound class]]){
            Sound *sound=item;
            if (sound!=nil) {
                [[ApplicationHelper PasteBoard] addObject:sound];
            }
        }
    }
    [pasteboard clearContents];
    [pasteboard setString:@"LibrariesTree 04132090NFS Cut" forType:NSStringPboardType];
    return YES;
}


-(BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    return YES;
}

@end
