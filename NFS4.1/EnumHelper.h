//
//  EnumHelper.h
//  NFS4.1
//
//  Created by carlos on 15-12-10.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Foundation/Foundation.h>


enum SoundFileTypeEnum:NSInteger{
    wav=0,
    aif=1
};

enum SoundInfoEnum:NSInteger{
    DisplayName=0,
    Dur=1,
    Score=2,
    Des=3,

};

enum SoundTypeEnum:NSInteger{
    Surround_70 = 7,
    Surround_71 = 8,
    Surround_50 = 5,
    Surround_51 = 6,
    Stereo = 2,
    Single = 1
};
    
    
///5.1环绕声 低音标识SUB, 杜比使用LFE
enum ChannelTypeEnum: NSInteger {
    L=0,
    R=1,
    C=2,
    SL=3,
    SR=4,
    BSL=5,
    BSR=6,
    SW=7

};
    
/// 设备类型
/// - Note: Input,Output,Unknown
enum DeviceTypeEnum{
    /// 输入设备
    Input,
    /// 输出设备
    Output,
    /// 未知设备
    Unknown,
};


@interface EnumHelper : NSObject
//enum soundFileType
+(NSString *)GetSoundFileTypeEnumAsString:(enum SoundFileTypeEnum)fileType;
//enum soundInfo
+(NSMutableArray *)GetSoundInfoEnumAllValues;
+(NSString *)GetSoundInfoEnumAsString:(enum SoundInfoEnum)soundInfo;
+(enum SoundInfoEnum)StringToSoundInfoEnum:(NSString *)stringValue;
//enum soundType
+(NSMutableArray *)GetSoundTypeEnumAllValues;
+(NSMutableArray *)GetSoundTypeEnumAllValuesAsChineseString;
+(enum SoundTypeEnum)StringToSoundTypeEnum:(NSString *)stringValue;
+(NSString *)GetSoundTypeEnumAsString:(enum SoundTypeEnum)soundType;
//enum channelType
+(NSMutableArray *)GetChannelTypeAllValues;
+(enum ChannelTypeEnum)StringToChannelTypeEnum:(NSString *)stringValue;
+(NSString *)GetChannelTypeEnumAsString:(enum ChannelTypeEnum)channelType;
+(enum ChannelTypeEnum)ENStringToChannelTypeEnum:(NSString *)stringValue;
+(NSString *)GetChannelTypeEnumAsENString:(enum ChannelTypeEnum)channelType;

+(NSMutableDictionary *)peakpostfixs;
+(NSMutableDictionary *)postfixs;


@end
