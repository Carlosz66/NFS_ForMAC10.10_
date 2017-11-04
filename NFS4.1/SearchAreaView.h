//
//  SearchAreaView.h
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ApplicationHelper.h"

@interface SearchAreaView : NSView<NSTableViewDataSource,NSTableViewDelegate>
{
    NSMutableArray *searchHistoryKeyWords;//Array<string>
    NSMutableArray *searchHistoryResult;//Array<Array<Sound>>
    NSMutableArray *searchResult;//Array<Sound>
    
    BOOL DurOrder;
    BOOL DisplayNameOrder;
}
@property (weak) IBOutlet NSTableView *mySearchResultView;
@property (weak) IBOutlet NSSearchField *mySearchBar;

@property (strong) IBOutlet NSView *contentView;


@end
