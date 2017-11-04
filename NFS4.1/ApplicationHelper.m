//
//  ApplicationHelper.m
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "ApplicationHelper.h"


static NSMutableArray *_Libraries;
static Player *_Player;
static NSMutableArray *_PasteBoard;
static NSURL *_storeURL;
static NSString *_storePath;

@implementation ApplicationHelper

+(void)setLibrareis:(NSMutableArray *)libraris{
    _Libraries=libraris;
}
+ (NSMutableArray*)Libraries{
    if (_Libraries==nil) {
        _Libraries=[NSMutableArray array];
    }
    return _Libraries;
}

+(void)setPlayer:(Player *)player{
    _Player=player;
}
+ (Player *)player{
    if (_Player==nil) {
        _Player=[[Player alloc] init];
    }
    return _Player;
}

+(void)setPasteBoard:(NSMutableArray *)pasteboard{
    _PasteBoard=pasteboard;
}
+ (NSMutableArray*)PasteBoard{
    if (_PasteBoard==nil) {
        _PasteBoard=[NSMutableArray array];
    }
    return _PasteBoard;
}

+(void)setStoreURL:(NSURL *)storeurl{
    _storeURL=storeurl;
    _storePath=@"";
    if (_storeURL!=nil) {
        _storePath=_storeURL.path;
    }
}
+ (NSURL*)StoreURL{
    return _storeURL;
}

+(void)setStorePath:(NSString *)storepath{
    _storeURL=[NSURL fileURLWithPath:storepath isDirectory:TRUE];
    _storePath=storepath;
}
+ (NSString*)StorePath{
    /*if (_storePath==nil) {
        _storePath=@"";
    }*/
    return _storePath;
}


//file manage
+(void)ReadStore{
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"NFSConfig" ofType:@"plist"];
    NSMutableDictionary *PListData=[NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if ([PListData objectForKey:@"StorePathUTF8"]==nil) {
        [PListData setObject:@"" forKey:@"StorePathUTF8"];
        [PListData writeToFile:plistPath atomically:FALSE];
        _storeURL=nil;
    }else{
        NSString *StorePathUTF8=[PListData objectForKey:@"StorePathUTF8"];
        _storeURL=[NSURL fileURLWithPath:StorePathUTF8];
    }
}

+(void)CreateStore:(NSURL *)storeURL{
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"NFSConfig" ofType:@"plist"];
    NSMutableDictionary *PListData=[NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if ([PListData objectForKey:@"StorePathUTF8"]==nil) {
        [PListData setObject:@"" forKey:@"StorePathUTF8"];
        [PListData writeToFile:plistPath atomically:FALSE];
    }
    _storeURL=storeURL;
    //默认 UTF8 10.11
    NSString *StorePathUTF8=storeURL.path;
    //UTF8转换 10.10
    //StorePathUTF8 = StorePathUTF8.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!;
    [PListData setObject:StorePathUTF8 forKey:@"StorePathUTF8"];
    [PListData writeToFile:plistPath atomically:FALSE];
    
}

+(void)ReadDatabases{
    NSError *error=nil;
    _Libraries=[NSMutableArray array];
    NSArray *URLs=[[NSFileManager defaultManager] contentsOfDirectoryAtURL:_storeURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    if (error) {
        NSLog(@"Error: in ApplicationHelper: ReadDatabases");
        return ;
    }
    for (int i=0; i<URLs.count;i++) {
        BOOL isDirectory=TRUE;
        [[NSFileManager defaultManager] fileExistsAtPath:[[URLs objectAtIndex:i] path] isDirectory:&isDirectory];
        if (isDirectory && [[NSFileManager defaultManager] fileExistsAtPath:[[[URLs objectAtIndex:i] URLByAppendingPathComponent:@"database.xml" isDirectory:FALSE]path]]) {
            [_Libraries addObject:[[Library alloc] init:[URLs objectAtIndex:i]]];
        }
    }
}


//extension method

+(NSAlert *)CreateNSAlert:(NSString *)title Message:(NSString *)message{
    NSAlert *alertWindow=[[NSAlert alloc]init];
    alertWindow.messageText=title;
    alertWindow.informativeText=message;
    return alertWindow;
}


+(NSOpenPanel *)CreateNSOpenPanel:(NSString *)message CanChooseDirectories:(BOOL)canChooseDirectories CanChooseFiles:(BOOL)canChooseFiles{
    NSOpenPanel *openPanel=[NSOpenPanel openPanel];
    openPanel.message=@"请选择音频库所在的文件夹位置";
    openPanel.canChooseDirectories=TRUE;
    openPanel.canChooseFiles=FALSE;
    return openPanel;
}



@end
