//
//  ApplicationHelper.h
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Library.h"
#import "Player.h"


@class Library;
@class Player;
@interface ApplicationHelper : NSObject

+(void)setLibrareis:(NSMutableArray *)libraris;
+ (NSMutableArray*)Libraries;//NSArray<Library *>*

+(void)setPlayer:(Player *)player;
+ (Player *)player;

+(void)setPasteBoard:(NSMutableArray *)pasteboard;
+ (NSMutableArray*)PasteBoard;//NSArray<Sound *>*

+(void)setStoreURL:(NSURL *)storeurl;
+ (NSURL*)StoreURL;

+(void)setStorePath:(NSString *)storepath;
+ (NSString*)StorePath;

+(void)ReadStore;
+(void)CreateStore:(NSURL *)storeURL;
+(void)ReadDatabases;

//extension method
+(NSOpenPanel*) CreateNSOpenPanel:(NSString*)message CanChooseDirectories:(BOOL)canChooseDirectories CanChooseFiles:(BOOL) canChooseFiles;
+(NSAlert*) CreateNSAlert:(NSString*)title Message:(NSString*)message;

@end
