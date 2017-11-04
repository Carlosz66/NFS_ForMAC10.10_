//
//  Sound.h
//  NFS4.1
//
//  Created by carlos on 15-12-10.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudio.h>
#import "EnumHelper.h"
#import "Library.h"

@class Library;
@interface Sound : NSObject
{
    int channelPeakFileIndex;
    ExtAudioFileRef audioEAFR;
    UInt32 extAFNumChannels;
    float *samples;
    long samplesCount;
}

@property Library *FatherLibrary;
@property Library *FatherFolder;
@property NSMutableDictionary *ChannelPeakFiles;//dictionary<ChannelTypeEnum,String>
@property NSMutableDictionary *AudioFiles;//dictionary<ChannelTypeEnum,String>
@property NSInteger RelevantScore;// ranking score
@property NSMutableDictionary *Info;//dictionary<string,string>
@property NSURL* FatherLibraryURL;

-(void)CreatePeakFile;
-(NSInteger)CompareWithStrings:(NSArray *)keys;

//extension method
+(NSString*) GetSamePartFormStart:(NSMutableArray*)strings;
+(NSString*) RemovePostfixs:(NSString*)filename PostFixs:(NSMutableDictionary*)postfixs;
@end
