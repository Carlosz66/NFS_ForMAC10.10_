//
//  SearchAreaView.m
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "SearchAreaView.h"

@implementation SearchAreaView

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
    [[NSBundle mainBundle] loadNibNamed:@"SearchAreaView" owner:self topLevelObjects:nil];
    [self.contentView setFrame:NSMakeRect(0, 0, self.frame.size.width,self.frame.size.height)];
    [self addSubview:self.contentView];
    
    searchHistoryKeyWords=[NSMutableArray array];
    searchHistoryResult=[NSMutableArray array];
    searchResult=[NSMutableArray array];

    [self.mySearchResultView setDelegate:self];
    [self.mySearchResultView setDataSource:self];

    [self.mySearchResultView registerForDraggedTypes:@[NSStringPboardType]];
    
    DurOrder=YES;
    DisplayNameOrder=YES;
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [super drawRect:dirtyRect];
    [self.contentView setFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.width)];
}

-(BOOL)becomeFirstResponder{
    if (self.mySearchResultView.selectedRow!=-1) {
        [[ApplicationHelper player] ResetSound:searchResult[self.mySearchResultView.selectedRow]];
    }
    return [super becomeFirstResponder];
}

#pragma mark - IBAction
- (IBAction)MySearchBarDidInput:(NSSearchField *)sender {
    [self mySearchBarDidInput:sender];
}

/// 搜索框按回车后执行的函数
- (void)mySearchBarDidInput:(NSSearchField *)sender{
    if (![self.mySearchBar.stringValue isEqualToString:@""]) {
        for (int i=0; i<searchHistoryKeyWords.count; i++) {
            if ([self.mySearchBar.stringValue isEqualToString:searchHistoryKeyWords[i]]) {
                [searchHistoryKeyWords removeObjectAtIndex:i];
                [searchHistoryResult removeObjectAtIndex:i];
                break;
            }
        }
        if (searchHistoryResult.count==10) {
            [searchHistoryKeyWords removeObjectAtIndex:0];
            [searchHistoryResult removeObjectAtIndex:0];
        }
        [searchHistoryKeyWords addObject:self.mySearchBar.stringValue];
        searchResult = [NSMutableArray array];
        for(Library *library in [ApplicationHelper Libraries]){
            [searchResult addObjectsFromArray:[library SearchData:[self.mySearchBar.stringValue componentsSeparatedByString:@" "]]];
        }
        searchResult =[[NSMutableArray alloc]initWithArray:[searchResult sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Sound *sound1 =obj1;
            Sound *sound2 =obj2;
            return sound1.RelevantScore > sound2.RelevantScore;
        }]];
        [searchHistoryResult addObject:searchResult];
        [self.mySearchResultView reloadData];
        NSMenu *searchbarmenu = [[NSMenu alloc] initWithTitle:@"搜索历史"];
        for(NSString *hkw in searchHistoryKeyWords){
            [searchbarmenu addItem:[[NSMenuItem alloc] initWithTitle:hkw action:@selector(HistoryKeywordMenuItemClicked:)  keyEquivalent:@""]];
        }
        [self.mySearchBar setMenu:searchbarmenu];//!!!!!!!!!not sure
        [self.mySearchResultView reloadData];
    }
}

- (IBAction)PlayMenuItemClicked:(NSMenuItem *)sender{
    if (self.mySearchResultView.selectedRow!=-1) {
        [[ApplicationHelper player] ResetSound:searchResult[self.mySearchResultView.selectedRow]];
        [[ApplicationHelper player] PlayOrPause];
    }
}

- (IBAction)CopyMenuItemClicked:(NSMenuItem *)sender{
    [ApplicationHelper setPasteBoard:[NSMutableArray array]];
    [self.mySearchResultView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [[ApplicationHelper PasteBoard] addObject:searchResult[idx]];
    }];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard setString:@"mySearchResultView 04132090NFS" forType:NSStringPboardType];
}

#pragma mark - tableview delegate&dataResource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return searchResult.count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [[searchResult[row] Info] objectForKey:[NSNumber numberWithInt:[EnumHelper StringToSoundInfoEnum:tableColumn.identifier]]];
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    if (row!=-1) {
        [[ApplicationHelper player] ResetSound:searchResult[row]];
    }
    return YES;
}

-(BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard{
    [ApplicationHelper setPasteBoard:[NSMutableArray array]];
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [[ApplicationHelper PasteBoard] addObject:searchResult[idx]];
    }];
    [pboard clearContents];
    [pboard setString:@"mySearchResultView 04132090NFS" forType:NSStringPboardType];
    return YES;
}

-(void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn{
    if ([tableColumn.identifier isEqualToString:@"DisplayName"]) {
        [searchResult sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Sound *sound1=obj1;
            Sound *sound2=obj2;
            if ([[sound1.Info objectForKey:[NSNumber numberWithInt:DisplayName]] isEqualToString:@""]) {
                return false;
            }
            if ([[sound2.Info objectForKey:[NSNumber numberWithInt:DisplayName]] isEqualToString:@""]) {
                return true;
            }
            NSComparisonResult result = [[sound1.Info objectForKey:[NSNumber numberWithInt:DisplayName]] caseInsensitiveCompare:[sound2.Info objectForKey:[NSNumber numberWithInt:DisplayName]]];
            if (result==NSOrderedAscending) {
                return DisplayNameOrder?NO:YES;
            }else{
                return DisplayNameOrder?YES:NO;
            }
            
        }];
        DisplayNameOrder=!DisplayNameOrder;
        [self.mySearchResultView reloadData];
    }else if ([tableColumn.identifier isEqualToString:@"Des"]){
        
    }else if ([tableColumn.identifier isEqualToString:@"Dur"]){
        [searchResult sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Sound *sound1=obj1;
            Sound *sound2=obj2;
            NSMutableArray *oneCount=[NSMutableArray arrayWithArray:[[sound1.Info objectForKey:[NSNumber numberWithInt:Dur]] componentsSeparatedByString:@":"]];
            NSMutableArray *twoCount=[NSMutableArray arrayWithArray:[[sound2.Info objectForKey:[NSNumber numberWithInt:Dur]] componentsSeparatedByString:@":"]];
            for (NSInteger i=oneCount.count; i<3; i++) {
                [oneCount insertObject:@"00:" atIndex:0];
            }
            for (NSInteger i=twoCount.count; i<3; i++) {
                [twoCount insertObject:@"00:" atIndex:0];
            }
            for (int i=0; i<3; i++) {
                NSComparisonResult result=[[oneCount objectAtIndex:i]caseInsensitiveCompare: [twoCount objectAtIndex:i]];
                if (result==NSOrderedSame) {
                    ;
                }else if (result==NSOrderedAscending){
                    return DurOrder?NO:YES;
                }else{
                    return DurOrder?YES:NO;
                }
                
            }
            return YES;
        }];
        DurOrder=!DurOrder;
        [self.mySearchResultView reloadData];
    }
}

@end
