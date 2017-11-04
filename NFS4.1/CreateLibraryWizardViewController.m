//
//  CreateLibraryWizardViewController.m
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "CreateLibraryWizardViewController.h"

@interface CreateLibraryWizardView ()

@end

@implementation CreateLibraryWizardView

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
    [[NSBundle mainBundle] loadNibNamed:@"CreateLibraryWizardView" owner:self topLevelObjects:nil];
    [self.contentView setFrame:NSMakeRect(0, 0, self.frame.size.width,self.frame.size.height)];
    [self addSubview:self.contentView];
    
    for(NSString *item in [EnumHelper GetSoundTypeEnumAllValuesAsChineseString]){
        [self.SoundTypeComboBox addItemWithObjectValue:item];
    }
    
    [self.SoundTypeComboBox selectItemAtIndex:0];
    
    [self.FilePatternTableView setDelegate:self];
    [self.FilePatternTableView setDataSource:self];
    [self.FilePatternTableView reloadData];
    
}




-(BOOL)becomeFirstResponder{
    return [super becomeFirstResponder];
}
#pragma mark - IBAction

- (IBAction)SoundTypeComboBoxSelectedChanged:(NSComboBox *)sender {
    [self.FilePatternTableView reloadData];
}


- (IBAction)OpenMenuItemClicked:(NSMenuItem *)sender {
    NSOpenPanel *openPanel = [ApplicationHelper CreateNSOpenPanel:@"请选择音频库所在的文件夹位置" CanChooseDirectories:YES CanChooseFiles:NO];
    if ([openPanel runModal]==NSFileHandlingPanelOKButton) {
        [self.FilePathTextField setStringValue:openPanel.URL.path];
    }
    
}

- (IBAction)ConverMenuItemClicked:(NSMenuItem *)sender {
    _createdLibraryPath = self.FilePathTextField.stringValue;
    self.CreatedLibrary=nil;
    BOOL isDirectory = YES;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:self.FilePathTextField.stringValue isDirectory:&isDirectory];
    if (isExist && isDirectory) {
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.CreatedLibrary = [[Library alloc]init:self.FilePathTextField.stringValue delegat:self createChoice:self.isCreateCacheButton.state];
       });
    }
}

#pragma mark - library delegate  method
-(void)LibraryClassCreatingDatabase:(NSString *)message{
    [self.FilePathTextField setStringValue:message];
}

-(void)LibraryClassDidCreateDatabase:(NSString *)message{
    [self.FilePathTextField setStringValue:_createdLibraryPath];
    NSAlert *alert=[ApplicationHelper CreateNSAlert:@"转换结束" Message:@""];
    NSBeep();
    [alert runModal];
}


#pragma mark - Delegate&DataSource Method

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [[[EnumHelper postfixs] objectForKey:[NSNumber numberWithInt:[EnumHelper StringToSoundTypeEnum:self.SoundTypeComboBox.stringValue]]] count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if ([tableColumn.identifier isEqualToString:@"channeltype"]) {
        NSDictionary *channels = [[EnumHelper postfixs] objectForKey:[NSNumber numberWithInt:[EnumHelper StringToSoundTypeEnum:self.SoundTypeComboBox.stringValue]]];
        return [EnumHelper GetChannelTypeEnumAsString:[[[channels allKeys] objectAtIndex:row] intValue]];
    }else if ([tableColumn.identifier isEqualToString:@"pattern"]){
        NSDictionary *channels = [[EnumHelper postfixs] objectForKey:[NSNumber numberWithInt:[EnumHelper StringToSoundTypeEnum:self.SoundTypeComboBox.stringValue]]];
        return [[channels allValues] objectAtIndex:row];
    }
    return @"";
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if ([tableColumn.identifier isEqualToString:@"pattern"]) {
        NSDictionary *channels = [[EnumHelper postfixs] objectForKey:[NSNumber numberWithInt:[EnumHelper StringToSoundTypeEnum:self.SoundTypeComboBox.stringValue]]];
        /*
        NSTableCellView *selectedRow = [tableView viewAtColumn:0 row:row makeIfNecessary:YES];
        NSTextField *selectedRowTextField = [selectedRow textField];
        NSNumber *key = [NSNumber numberWithInt:[EnumHelper ENStringToChannelTypeEnum:[selectedRowTextField stringValue]] ];
         */
        NSNumber *key=[[channels allKeys] objectAtIndex:row];
        [[[EnumHelper postfixs] objectForKey:[NSNumber numberWithInt:[EnumHelper StringToSoundTypeEnum:self.SoundTypeComboBox.stringValue]]] setObject:object forKey:key];
    }
}
/*
if tableColumn?.identifier == "pattern" {
    let channels = SoundTypeEnum.postfixs[SoundTypeEnum.StringToSoundTypeEnum(SoundTypeComboBox.stringValue)]!;
    let key = channels[channels.startIndex.advancedBy(row)].0;
    SoundTypeEnum.postfixs[SoundTypeEnum.StringToSoundTypeEnum(SoundTypeComboBox.stringValue)]?.updateValue(object as! String, forKey: key);
}
*/
-(BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if ([tableColumn.identifier isEqualToString:@"channeltype"]) {
        return FALSE;
    }else if ([tableColumn.identifier isEqualToString:@"pattern"]){
        return [EnumHelper StringToSoundTypeEnum:self.SoundTypeComboBox.stringValue]== Single ? NO:YES;
    }
    return NO;
}



@end


