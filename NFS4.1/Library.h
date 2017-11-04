//
//  Library.h
//  NFS4.1
//
//  Created by carlos on 15-12-10.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "EnumHelper.h"
#import "Sound.h"
#import "AppDelegate.h"
#import "ApplicationHelper.h"

@protocol LibraryCreateDatabaseDelegate  <NSObject>

@optional
-(void)LibraryClassWillCreateDatabase:(NSString *)message;
-(void)LibraryClassCreatingDatabase:(NSString *)message;
-(void)LibraryClassDidCreateDatabase:(NSString *)message;

@end

@class Sound;
@class ApplicationHelper;

@interface Library : NSObject

@property NSString* Name;
@property Library* FatherLibrary;
@property Library* FatherFolder;
@property NSMutableArray* WholeSounds;
@property NSMutableArray* SubSounds;
@property NSMutableArray* SubFolders;

@property (readonly, getter=getIsRoot) BOOL IsRoot;
@property (getter=getPath, setter=setPath:) NSString* Path;
@property (getter=getURL, setter=setURL:) NSURL* URL;

-(BOOL) getIsRoot;

-(NSString*) getPath;

-(void) setPath:(NSString*)newValue;

-(NSURL*) getURL;

-(void) setURL:(NSURL*)newValue;

-(Library*) init:(NSURL*)libraryURL;

-(Library*) init:(NSString*)libraryPath delegat:(id<LibraryCreateDatabaseDelegate>)delegate createChoice:(BOOL)isCreateCacheFile;

-(OSStatus) SaveLibraryToDatabase:(BOOL)isSaveAs;

-(NSMutableArray*)SearchData:(NSArray*)keys;

-(void) RemoveFolder:(Library*)subfolder;

-(void) RemoveSound:(Sound*)subsound;

-(void) RemoveSoundFromWholeSound:(Sound*)subsound;
@end


/*
@class Sound;
@interface Library : NSObject
{
    NSObject<LibraryCreateDatabaseDelegate> *createdatabasedelegate;
}
@property NSString *Path;
@property NSURL *URL;
@property(readonly)BOOL IsRoot;

@property NSString *Name;
@property Library *FatherLibrary;
@property Library *FatherFolder;
@property NSMutableArray *_wholeSounds;//array<Sound>
@property NSMutableArray *SubSounds;//array<Sound>
@property NSMutableArray *SubFolders;//array<Library>

-(id)init:(NSURL *)libraryURL;
-(id)init:(NSString *)libraryPath type:(enum SoundTypeEnum)libraryType delegat:(NSObject <LibraryCreateDatabaseDelegate> *)delegate isCreateCacheFile:(NSInteger)choice;

-(OSStatus)SaveLibraryToDatabase:(BOOL)isSaveAs;

-(NSMutableArray *)SearchData:(NSArray *)keys;

-(void)RemoveFolder:(Library *)subfolder;

-(void)RemoveSound:(Sound *)subsound;

-(void)RemoveSoundFromWholeSound:(Sound *)subsound;
@end
*/