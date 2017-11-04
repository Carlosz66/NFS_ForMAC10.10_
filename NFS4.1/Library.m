//
//  Library.m
//  NFS4.1
//
//  Created by carlos on 15-12-10.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "Library.h"

#define updateValue(x,y) setObject:x forKey:y
#define nodesForXPath(x) nodesForXPath:x error:nil
#define Dictionary(x,y) [[NSMutableDictionary alloc] init]
#define append(x) addObject:x
#define Array(x) [[NSMutableArray alloc] init]
#define subpathsOfDirectoryAtPath(x) subpathsOfDirectoryAtPath:x error:nil
#define createDirectoryAtURL(x) createDirectoryAtURL:x withIntermediateDirectories:true attributes:nil error:nil
#define URLByAppendingPathComponent(x,y) URLByAppendingPathComponent:x isDirectory: y
#define contentsOfDirectoryAtURL(x) contentsOfDirectoryAtURL:x includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil
#define SoundFileTypeEnum(x) [[SoundFileTypeEnum alloc] init:x]
#define SoundTypeEnum(x) [[SoundTypeEnum alloc] init:x]
#define NSXMLElement(x,y) [[NSXMLElement alloc] initWithName:x stringValue:y]


@implementation Library {
    NSURL* _url;
    NSString* _path;
    id<LibraryCreateDatabaseDelegate> _createdatabasedelegate;
    
    int progressIndex;
    int libraryFilescount;
}

@synthesize Name,FatherLibrary,FatherFolder,WholeSounds,SubSounds,SubFolders;

-(void) sealinit {
    _url = [[NSURL alloc] init];
    _path = @"";
    _createdatabasedelegate = nil;
    progressIndex = 1;
    libraryFilescount = 1;
    Name =@"";
    FatherFolder = nil;
    FatherLibrary = nil;
    WholeSounds = [[NSMutableArray alloc] init];
    SubSounds = [[NSMutableArray alloc] init];
    SubFolders = [[NSMutableArray alloc] init];
}

-(BOOL) getIsRoot {
    return FatherLibrary == nil ? true : false;
}

-(NSString*) getPath {
    return _path;
}

-(void) setPath:(NSString*)newValue {
    _url = [NSURL fileURLWithPath: newValue isDirectory: true];
    _path = newValue;
}

-(NSURL*) getURL {
    return _url;
}

-(void) setURL:(NSURL*)newValue {
    _url = newValue;
    if (newValue.path != nil) {
        _path = newValue.path;
    }
}

-(id)init
{
    self = [super init];
    if (self) {
        [self sealinit];
    }
    return self;
}

-(Library*) init:(NSURL*)libraryURL {
    self = [super init];
    if (self) {
        [self sealinit];
        [self ReadDatabaseFile:libraryURL];
    }
    return self;
}

-(Library*) init:(NSString*)libraryPath delegat:(id<LibraryCreateDatabaseDelegate>)delegate createChoice:(BOOL)isCreateCacheFile {
    self = [super init];
    if (self) {
        [self sealinit];
        _createdatabasedelegate = delegate;
        [self CreateDatabase:libraryPath :isCreateCacheFile];
        
    }
    return self;
}

-(OSStatus)SaveLibraryToDatabase:(BOOL)isSaveAs {
    NSXMLElement* databaseXMLRoot = [[NSXMLElement alloc] initWithName:@"Library"];
    [databaseXMLRoot addChild:NSXMLElement(@"Name",self.Name)];
    [databaseXMLRoot addChild:NSXMLElement(@"Path",self.Path)];
    NSXMLElement* subcontentsnode = [[NSXMLElement alloc] initWithName:@"Contents"];
    [[NSFileManager defaultManager] createDirectoryAtURL:[[ApplicationHelper StoreURL] URLByAppendingPathComponent:self.Name isDirectory: true] withIntermediateDirectories: true attributes: nil error:nil];
    [self SaveLibraryToDatabase:@"" FatherFolder:self Root:subcontentsnode IsSaveAs:isSaveAs];
    [databaseXMLRoot addChild:subcontentsnode];
    //0x80000019 MacOSX 简体中文编码
    NSURL* databaseURL = [[ApplicationHelper StoreURL] URLByAppendingPathComponent:self.Name  isDirectory: true];
    [[NSFileManager defaultManager] createDirectoryAtURL:databaseURL withIntermediateDirectories: true attributes: nil error:nil];
    databaseURL = [[databaseURL URLByAppendingPathComponent:@"database" isDirectory: true] URLByAppendingPathExtension:@"xml"];
    NSXMLDocument* databaseXMLDocument = [[NSXMLDocument alloc] initWithRootElement:databaseXMLRoot];
    [databaseXMLDocument setCharacterEncoding:@"UTF-8"];
    [databaseXMLDocument.XMLData writeToURL:databaseURL atomically: true];
    return 0;
}
//递归
-(void) SaveLibraryToDatabase:(NSString*)homePath FatherFolder:(Library*)fatherFolder Root:(NSXMLElement*)root IsSaveAs:(BOOL)isSaveAs {
    for (Library* folder in fatherFolder.SubFolders) {
        NSXMLElement* folderXMLRoot = [[NSXMLElement alloc] initWithName:@"Folder"];
        [folderXMLRoot addChild:NSXMLElement(@"Name",folder.Name)];
        NSXMLElement* subcontentsnode = [[NSXMLElement alloc] initWithName:@"Contents"];
        [[NSFileManager defaultManager] createDirectoryAtURL:[[[ApplicationHelper StoreURL] URLByAppendingPathComponent:self.Name isDirectory: true] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",homePath,folder.Name] isDirectory: true] withIntermediateDirectories: true attributes: nil error:nil];
        [self SaveLibraryToDatabase:@""FatherFolder:folder Root:subcontentsnode IsSaveAs:isSaveAs];
        [folderXMLRoot addChild:subcontentsnode];
        [root addChild:folderXMLRoot];
    }
    for (Sound* sound in fatherFolder.SubSounds) {
        if (isSaveAs) {
            
        }
        NSXMLElement* soundXMLRoot = [[NSXMLElement alloc] initWithName:@"Sound"];
        NSXMLElement* soundLibraryURL = [[NSXMLElement alloc] initWithName:@"SoundLibraryURL" stringValue:sound.FatherLibraryURL.path];
       [soundXMLRoot addChild:soundLibraryURL];
        NSXMLElement* peakfilesnodes = [[NSXMLElement alloc] initWithName:@"PeakFiles"];
        for (NSNumber *peakfile in sound.ChannelPeakFiles.keyEnumerator) {
            NSXMLElement* peakfilenode = [[NSXMLElement alloc] initWithName:@"PeakFile"];
            
            NSString* ____string = [EnumHelper GetChannelTypeEnumAsString:[peakfile integerValue]];
            [peakfilenode addChild:NSXMLElement(@"PeakFileChannelType",____string)];
            [peakfilenode addChild:NSXMLElement(@"PeakFileRelPath", sound.ChannelPeakFiles[peakfile])];
            [peakfilesnodes addChild:peakfilenode];
        }
        [soundXMLRoot addChild:peakfilesnodes];
        NSXMLElement* soundfilesnodes = [[NSXMLElement alloc] initWithName:@"SoundFiles"];
        for (NSNumber *soundfile in sound.AudioFiles.keyEnumerator) {
            NSXMLElement* soundfilenode = [[NSXMLElement alloc] initWithName:@"SoundFile"];
            NSString* ____string = [EnumHelper GetChannelTypeEnumAsString:[soundfile integerValue]];
            [soundfilenode addChild:NSXMLElement(@"SoundFileChannelType", ____string)];
            [soundfilenode addChild:NSXMLElement(@"SoundFileRelPath", sound.AudioFiles[soundfile])];
            [soundfilesnodes addChild:soundfilenode];
        }
        [soundXMLRoot addChild:soundfilesnodes];
        NSXMLElement* infonode = [[NSXMLElement alloc] initWithName:@"Info"];
        for (NSNumber* info in sound.Info.keyEnumerator) {
            NSString* ____string = [EnumHelper GetSoundInfoEnumAsString:[info integerValue]];
            [infonode addChild:NSXMLElement(____string,sound.Info[info])];
        }
        [soundXMLRoot addChild:infonode];
        [root addChild:soundXMLRoot];
    }
}

-(void) ReadDatabaseFile:(NSURL *)libraryURL {
    NSURL* databaseURL = [libraryURL URLByAppendingPathComponent:@"database.xml" isDirectory:false];
    NSError *err;
    NSXMLDocument* databaseFile = [[NSXMLDocument alloc] initWithContentsOfURL:databaseURL options:0 error:&err];
    NSXMLNode* root = [[databaseFile nodesForXPath:@"Library" error:nil]objectAtIndex:0];
    self.Name = [[[root nodesForXPath:@"Name" error:nil] objectAtIndex:0] stringValue];
    self.Path = [[[root nodesForXPath:@"Path" error:nil] objectAtIndex:0] stringValue];
    self.FatherLibrary = nil;
    self.FatherFolder = nil;
    WholeSounds = [[NSMutableArray alloc] init];
    SubSounds = [[NSMutableArray alloc] init];
    SubFolders = [[NSMutableArray alloc] init];
    [self ReadDatabaseFile:self :[[root nodesForXPath:@"Contents" error:nil]objectAtIndex:0]];
}

-(void) ReadDatabaseFile:(Library *)fatherFolder:(NSXMLNode *)root {
    //添加声音
    for (NSXMLNode* soundNode in [root nodesForXPath:@"Sound" error:nil]) {
        Sound* sound = [[Sound alloc] init];
        sound.FatherLibrary = self;
        sound.FatherFolder = fatherFolder;
        NSString* fpath = [[[soundNode nodesForXPath:@"SoundLibraryURL" error:nil] objectAtIndex:0] stringValue];
        sound.FatherLibraryURL = [[NSURL alloc] initFileURLWithPath:fpath];
        sound.ChannelPeakFiles = [[NSMutableDictionary alloc] init];
        for (NSXMLNode* peakfilenode in [[[soundNode nodesForXPath:@"PeakFiles" error:nil]objectAtIndex:0] children]) {
            NSString* value = [[[peakfilenode nodesForXPath(@"PeakFileRelPath")] objectAtIndex:0] stringValue];
            NSString* ketstring = [[[peakfilenode nodesForXPath(@"PeakFileChannelType")] objectAtIndex:0] stringValue];
            enum ChannelTypeEnum ket = [EnumHelper StringToChannelTypeEnum:ketstring];
            //ChannelTypeEnum* forkey = [ChannelTypeEnum StringToChannelTypeEnum:ket];
            //[sound.ChannelPeakFiles updateValue(value, forkey)];
            [sound.ChannelPeakFiles updateValue(value,[NSNumber numberWithInt:ket])];
        }
        sound.AudioFiles = Dictionary(ChannelTypeEnum, String);
        for (NSXMLNode* audiofilenode in [[[soundNode nodesForXPath(@"SoundFiles")]objectAtIndex:0]children]) {
            NSString* value = [[[audiofilenode nodesForXPath(@"SoundFileRelPath")] objectAtIndex:0]stringValue];
            NSString* ketstring = [[[audiofilenode nodesForXPath(@"SoundFileChannelType")] objectAtIndex:0] stringValue];
            enum ChannelTypeEnum ket = [EnumHelper StringToChannelTypeEnum:ketstring];
            [sound.AudioFiles updateValue(value, [NSNumber numberWithInt:ket])];
        }
        for (NSXMLNode* info in [[[soundNode nodesForXPath(@"Info")] objectAtIndex:0] children]) {
            enum SoundInfoEnum ket = [EnumHelper StringToSoundInfoEnum:info.name];
            [sound.Info updateValue(info.stringValue,[NSNumber numberWithInt:ket])];
        }
        [self.WholeSounds append(sound)];
        [fatherFolder.SubSounds append(sound)];
    }
    //添加文件夹
    for (NSXMLNode* folderNode in [root nodesForXPath(@"Folder")]) {
        Library* folder = [[Library alloc] init];
        folder.Name = [[[folderNode nodesForXPath(@"Name")] objectAtIndex:0] stringValue];
        folder.FatherLibrary = self;
        folder.FatherFolder = fatherFolder;
        folder.URL = [[NSURL alloc] init]; //子文件夹这个值没用
        folder.WholeSounds = Array(Sound); //子文件夹这个值没用
        folder.SubSounds = Array(Sound);
        folder.SubFolders = Array(Library);
        [self ReadDatabaseFile:folder:[[folderNode nodesForXPath(@"Contents")] objectAtIndex:0]];
        [fatherFolder.SubFolders append(folder)];
    }
    
}

-(void) CreateDatabase:(NSString*)libraryPath:(BOOL)isCreateCacheFile {
    libraryFilescount = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath(libraryPath)].count;
    
    self.Name = [[NSURL fileURLWithPath:libraryPath] lastPathComponent];//!!!!!!!!!
    self.URL = [NSURL fileURLWithPath:libraryPath];
    self.FatherLibrary = nil;
    self.FatherFolder = nil;
    self.WholeSounds = Array(Sound);
    self.SubSounds = Array(Sound);
    self.SubFolders = Array(Library);
    NSURL* __url = [[ApplicationHelper StoreURL] URLByAppendingPathComponent(self.Name,true)];
    [[NSFileManager defaultManager] createDirectoryAtURL(__url)];
    
    [self CreateDatabase:@"":self:isCreateCacheFile];
    
    [self SaveLibraryToDatabase:false];
    
    if (_createdatabasedelegate != nil) {
        [_createdatabasedelegate LibraryClassDidCreateDatabase:@"创建完成"];
    }
}

-(void) CreateDatabase:(NSString*)homePath:(Library* )fatherFolder:(BOOL)isCreateCacheFile {
    NSURL* __url = [self.URL URLByAppendingPathComponent(homePath, true)];
    NSArray* URLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL(__url)];
    for (int i=0; i<URLs.count;){
        if (_createdatabasedelegate != nil) {
            [_createdatabasedelegate LibraryClassCreatingDatabase:[NSString stringWithFormat:@"%d/%d %@",progressIndex,libraryFilescount,@" 正在扫描波形文件，请勿在本软件中进行其他操作！"]];
        }
        BOOL __isDirectory = false;
        [[NSFileManager defaultManager] fileExistsAtPath:[URLs[i] path] isDirectory:&__isDirectory];
        if (__isDirectory) {
            Library* folder = [[Library alloc]init];
            folder.Name = [URLs[i] lastPathComponent];
            folder.FatherLibrary = self;
            folder.FatherFolder = fatherFolder;
            folder.URL = URLs[i]; //子文件夹这个值没用
            folder.WholeSounds = Array(Sound);
            folder.SubSounds = Array(Sound);
            folder.SubFolders = Array(Library);
            NSString* __string = [NSString stringWithFormat:@"%@/%@",homePath,[URLs[i] lastPathComponent]];
            NSURL* ___url = [[ApplicationHelper.StoreURL URLByAppendingPathComponent:self.Name  isDirectory: true] URLByAppendingPathComponent:__string isDirectory: true];
            [[NSFileManager defaultManager] createDirectoryAtURL(___url)];
            [self CreateDatabase:__string:folder:isCreateCacheFile];
            [fatherFolder.SubFolders append(folder)];
            i++;
            progressIndex++;
        } else if ([[URLs[i] pathExtension] isEqualToString:[EnumHelper GetSoundFileTypeEnumAsString:wav]]|| [[URLs[i] pathExtension] isEqualToString:[EnumHelper GetSoundFileTypeEnumAsString:aif]]) {//!!!!!!!!!!!!!!
            NSString* soundName = @"";
            int filescount = 0;
          for (int k=8;k>0;k--) {
                enum SoundTypeEnum soundtype =k;
                if ((k== 8 || k == 7 || k == 5 || k == 6 || k == 2 || k == 1) && (k <= ([URLs count] - i))){//!!!!!!!!!!!
                    soundName = [Sound RemovePostfixs:[[URLs[i] URLByDeletingPathExtension] lastPathComponent] PostFixs:[[EnumHelper postfixs] objectForKey:[NSNumber numberWithInt:soundtype]]];//!!!!!!
                    BOOL isGet = true;
                    for(int j=0;(j<soundtype && (i+j)<[URLs count]);j++){
                        NSString* ____string = [[URLs objectAtIndex:(i+j)] URLByDeletingPathExtension].lastPathComponent;
                        if (![soundName isEqualToString:[Sound RemovePostfixs:____string PostFixs:[[EnumHelper postfixs] objectForKey:[NSNumber numberWithInt:soundtype]]]]) {//!!!!!!!!!!!
                            isGet = false;
                            break;
                        }
                    }
                    if (isGet) {
                        filescount = soundtype;
                        NSString* ____string = [URLs[i] URLByDeletingPathExtension].lastPathComponent;
                        soundName = [Sound RemovePostfixs:____string PostFixs:[[EnumHelper postfixs] objectForKey:[NSNumber numberWithInt:soundtype]]];//!!!!!!!!!!!!!!!!
                        break;
                    }
                }
            }
          
            AVAudioPlayer* tempPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:URLs[i] error:nil];
            NSDateFormatter* formatter =[[NSDateFormatter alloc] init];
            formatter.dateFormat = @"HH:mm:ss";
            formatter.timeZone = [[NSTimeZone alloc] initWithName:@"UTC"];
            NSDate* duration = [[NSDate alloc] initWithTimeIntervalSince1970:tempPlayer.duration];
            NSURL* ______url = [[ApplicationHelper.StoreURL URLByAppendingPathComponent:self.Name  isDirectory:true] URLByAppendingPathComponent:homePath isDirectory:true];
            [[NSFileManager defaultManager] createDirectoryAtURL(______url)];
            Sound* sound = [[Sound alloc] init];
            sound.FatherFolder = fatherFolder;
            sound.FatherLibrary = self;
            sound.FatherLibraryURL = self.URL;
            //第一种方式
            int peakfilecount = filescount == 1 ? tempPlayer.numberOfChannels : filescount;
            sound.ChannelPeakFiles = Dictionary(ChannelTypeEnum, String);
            NSMutableDictionary* peakpostfixs =[[EnumHelper postfixs] objectForKey:[NSNumber numberWithInt:peakfilecount]];//[SoundTypeEnum peakpostfixs:[[SoundTypeEnum alloc] init:peakfilecount]];
            
            for (NSNumber* peakpostfix in peakpostfixs.keyEnumerator) {
                NSString* peakfileName = [NSString stringWithFormat:@"%@%@",soundName,peakpostfixs[peakpostfix]];
                NSString *peakfileRelPath = [NSString stringWithFormat:@"%@/%@.peak",homePath,peakfileName];
                //enum ChannelTypeEnum __cte = [EnumHelper ENStringToChannelTypeEnum:peakpostfixs[peakpostfix]];
                //NSNumber* _ncte = [NSNumber numberWithInt:__cte];
                [sound.ChannelPeakFiles updateValue(peakfileRelPath,peakpostfix)];
            }
            sound.AudioFiles = Dictionary(ChannelTypeEnum, String);
            NSMutableDictionary* postfixs =[[EnumHelper postfixs] objectForKey:[NSNumber numberWithInt:filescount]]; //[SoundTypeEnum postfixs:[[SoundTypeEnum alloc] init:filescount]];
            for (NSNumber* postfix in postfixs.keyEnumerator) {
                NSString* soundfileName = [NSString stringWithFormat:@"%@%@",soundName,postfixs[postfix]];
                NSString *soundfileRelPath = [NSString stringWithFormat:@"%@/%@.%@",homePath,soundfileName,[URLs[i] pathExtension]];
                //enum ChannelTypeEnum __cte = [EnumHelper ENStringToChannelTypeEnum:postfixs[postfix]];
                //NSNumber* _ncte = [NSNumber numberWithInt:__cte];
                [sound.AudioFiles updateValue(soundfileRelPath,postfix)];
            }
            [sound.Info updateValue(soundName,[NSNumber numberWithInt:DisplayName])];
            [sound.Info updateValue([formatter stringFromDate:duration],[NSNumber numberWithInt:Dur])];
            [sound.Info updateValue(@"1", [NSNumber numberWithInt:Score])];
            [sound.Info updateValue(@" ",[NSNumber numberWithInt:Des])];
            
            if (isCreateCacheFile) {
                [sound CreatePeakFile];
            }
            [self.WholeSounds append(sound)];
            [fatherFolder.SubSounds append(sound)];
            i+=filescount;
            progressIndex += filescount;
        } else {
            i++;
            progressIndex++;
        }
    }
}

-(NSMutableArray*) SearchData:(NSArray*)keys{
    NSMutableArray* result = Array(Sound);
    for (Sound* sound in self.WholeSounds) {
        if ([sound CompareWithStrings:keys] != -1) {
            [result append(sound)];
        }
    }
    return result;
}

-(void) RemoveFolder:(Library*)subfolder{
    [self.SubFolders removeObject:subfolder];
}

-(void) RemoveSound:(Sound*)subsound{
    [self.SubSounds removeObject:subsound];
}

-(void) RemoveSoundFromWholeSound:(Sound*)subsound{
    [self.WholeSounds removeObject:subsound];
}

@end



/*
@implementation Library

-(void)setPath:(NSString *)path{
    _Path=path;
    _URL=[NSURL fileURLWithPath:path isDirectory:true];
}

-(void)setURL:(NSURL *)URL{
    _URL=URL;
    if (URL.path) {
        _Path=URL.path;
    }
}

@end

*/
