//
//  EditLibraryViewController.m
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "EditLibraryViewController.h"

@interface EditLibraryView ()

@end

@implementation EditLibraryView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self MyInit];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

-(void)MyInit{
    [[NSBundle mainBundle] loadNibNamed:@"EditLibraryView" owner:self topLevelObjects:nil];
    [self.contentView setFrame:NSMakeRect(0, 0, self.frame.size.width,self.frame.size.height)];
    [self addSubview:self.contentView];
    
    [self.EditTableView setDataSource:self];
    [self.EditTableView setDelegate:self];
    
    [self.EditTableView reloadData];
    
    NSString *path = [self.EditLibrary getPath];//may change!!!!!!!!!!
    [self.LibraryPathTextField setStringValue:[NSString stringWithFormat:@"音频库物理路径:%@",path]];
    
    [self.EditTableView reloadData];
}

-(void)myBecomeFirstResponder{
    NSString *path = [self.EditLibrary getPath];//may change!!!!!!!!!!
    [self.LibraryPathTextField setStringValue:[NSString stringWithFormat:@"音频库物理路径:%@",path]];
    
    [self.EditTableView reloadData];
}




#pragma mark -IBAction
- (IBAction)PasteMenuItemClicked:(NSMenuItem *)sender {
    NSArray *Deses1 = [[[NSPasteboard generalPasteboard] stringForType:NSStringPboardType] componentsSeparatedByString:@"\r"];
    NSArray *Deses2 = [[[NSPasteboard generalPasteboard] stringForType:NSStringPboardType] componentsSeparatedByString:@"\n"];
    NSArray *Deses3 = [[[NSPasteboard generalPasteboard] stringForType:NSStringPboardType] componentsSeparatedByString:@"\r\n"];
    NSArray *Deses4 = [[[NSPasteboard generalPasteboard] stringForType:NSStringPboardType] componentsSeparatedByString:@"\n\r"];
    NSArray *Deses34 = ([Deses3 count] > [Deses4 count] ? Deses3 : Deses4);
    NSArray *Deses12 = ([Deses1 count] > [Deses2 count] ? Deses1 : Deses2);
    NSArray *Deses = ([Deses34 count] > [Deses12 count] ? Deses34 : Deses12);
    if (Deses==nil) {
        return;
    }
    NSInteger rowindex=self.EditTableView.selectedRow == -1? 0 : self.EditTableView.selectedRow;
    NSInteger pastecount = self.EditLibrary.WholeSounds.count - self.EditTableView.selectedRow;
    for(int desindex=0;desindex<pastecount;rowindex++,desindex++){
        [[self.EditLibrary.WholeSounds[rowindex] Info] setObject:Deses[desindex] forKey:[NSNumber numberWithInt:Des]];
        
    }
    [self.EditTableView reloadData];


}
- (IBAction)SaveMenuItemClicked:(NSMenuItem *)sender{
    [self.EditLibrary SaveLibraryToDatabase:NO];
    NSAlert *alertwindow=[ApplicationHelper CreateNSAlert:@"保存成功" Message:@"请回到主界面，并刷新查看结果"];
    NSBeep();
    [alertwindow runModal];
}

- (IBAction)OpenMenuItemClicked:(NSMenuItem *)sender{
    NSOpenPanel *openPanel=[ApplicationHelper CreateNSOpenPanel:@"请选择新的音频库文件夹位置" CanChooseDirectories:YES CanChooseFiles:NO];
    if([openPanel runModal]==NSFileHandlingPanelOKButton){
        [self.EditLibrary setURL:openPanel.URL];
        for (Sound* sound in self.EditLibrary.WholeSounds) {
            sound.FatherLibraryURL = openPanel.URL;
        }
        NSString *path = openPanel.URL.path;
        [self.LibraryPathTextField setStringValue:[NSString stringWithFormat:@"音频库物理路径:%@",path]];
    }
}

#pragma mark - Delegate&DataResource Method
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.EditLibrary.WholeSounds.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if ([tableColumn.identifier isEqualToString:@"RelPath"]) {
        NSString *relpath=[[self.EditLibrary.WholeSounds[row] Info] objectForKey:[NSNumber numberWithInt:DisplayName]];
        Library *fatherfolder = [[self.EditLibrary.WholeSounds objectAtIndex:row] FatherFolder];
        while (!fatherfolder.IsRoot ) {
            relpath = [NSString stringWithFormat:@"%@/%@",fatherfolder.Name,relpath];
            fatherfolder = fatherfolder.FatherFolder;
        }
        relpath = [NSString stringWithFormat:@"%@/%@",[self.EditLibrary.WholeSounds[row] FatherFolder].Path,relpath];
        return relpath;
    }
    
    return [[self.EditLibrary.WholeSounds[row] Info] objectForKey:[NSNumber numberWithInt:[EnumHelper StringToSoundInfoEnum:tableColumn.identifier]]];
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    [[self.EditLibrary.WholeSounds[row] Info] setObject:object forKey:[NSNumber numberWithInt:[EnumHelper StringToSoundInfoEnum:tableColumn.identifier] ]];
}

@end
