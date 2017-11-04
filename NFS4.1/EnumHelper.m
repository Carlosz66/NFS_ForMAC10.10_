//
//  EnumHelper.m
//  NFS4.1
//
//  Created by carlos on 15-12-10.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "EnumHelper.h"


static  NSMutableDictionary *_peakpostfixs;
static  NSMutableDictionary *_postfixs;

@implementation EnumHelper


+(void)fillUpDictionarys{
    //fill up peakpostfixs dictionary
    _peakpostfixs=[NSMutableDictionary dictionary];
    NSMutableDictionary *Dic7 =[NSMutableDictionary dictionaryWithDictionary:@{@0: @"_L",@1: @"_R",@2: @"_C",@3: @"_SL", @4: @"_SR", @5: @"_BSL" ,@6: @"_BSR"}];
    NSMutableDictionary *Dic71 =[NSMutableDictionary dictionaryWithDictionary:@{@0: @"_L",@1: @"_R",@2: @"_C",@3: @"_SL", @4: @"_SR", @5: @"_BSL" ,@6: @"_BSR", @7: @"_SW"}];
    NSMutableDictionary *Dic5 =[NSMutableDictionary dictionaryWithDictionary:@{@0: @"_L",@1: @"_R",@2: @"_C",@3: @"_SL", @4: @"_SR"}];
    NSMutableDictionary *Dic51 =[NSMutableDictionary dictionaryWithDictionary:@{@0: @"_L",@1: @"_R",@2: @"_C",@3: @"_SL", @4: @"_SR", @7: @"_SW"}];
    NSMutableDictionary *Dic2 =[NSMutableDictionary dictionaryWithDictionary:@{@0: @"_L",@1: @"_R"}];
    NSMutableDictionary *Dic1 =[NSMutableDictionary dictionaryWithDictionary:@{@2:@""} ];
    
    [_peakpostfixs setObject:Dic7 forKey:@7];
    [_peakpostfixs setObject:Dic71 forKey:@8];
    [_peakpostfixs setObject:Dic5  forKey:@5];
    [_peakpostfixs setObject:Dic51 forKey:@6];
    [_peakpostfixs setObject:Dic2 forKey:@2];
    [_peakpostfixs setObject:Dic1 forKey:@1];
    
    //fill up postfixs dictionary
    _postfixs =[NSMutableDictionary dictionary];
    NSMutableDictionary *dic7 =[NSMutableDictionary dictionaryWithDictionary:@{@0: @"_L",@1: @"_R",@2: @"_C",@3: @"_SL", @4: @"_SR", @5: @"_BSL" ,@6: @"_BSR"}];
    NSMutableDictionary *dic71 =[NSMutableDictionary dictionaryWithDictionary:@{@0: @"_L",@1: @"_R",@2: @"_C",@3: @"_SL", @4: @"_SR", @5: @"_BSL" ,@6: @"_BSR", @7: @"_SW"}];
    NSMutableDictionary *dic5 =[NSMutableDictionary dictionaryWithDictionary:@{@0: @"_L",@1: @"_R",@2: @"_C",@3: @"_SL", @4: @"_SR"}];
    NSMutableDictionary *dic51 =[NSMutableDictionary dictionaryWithDictionary:@{@0: @"_L",@1: @"_R",@2: @"_C",@3: @"_SL", @4: @"_SR", @7: @"_SW"}];
    NSMutableDictionary *dic2 =[NSMutableDictionary dictionaryWithDictionary:@{@0: @"_L",@1: @"_R"}];
    NSMutableDictionary *dic1 =[NSMutableDictionary dictionaryWithDictionary:@{@2:@""} ];
    
    [_postfixs setObject:dic7 forKey:@7];
    [_postfixs  setObject:dic71 forKey:@8];
    [_postfixs  setObject:dic5  forKey:@5];
    [_postfixs  setObject:dic51 forKey:@6];
    [_postfixs  setObject:dic2 forKey:@2];
    [_postfixs  setObject:dic1 forKey:@1];
}

+(NSMutableDictionary *)peakpostfixs{
    if (_peakpostfixs==nil) {
        [self fillUpDictionarys];
    }
    return _peakpostfixs;
}

+(NSMutableDictionary *)postfixs{
    if(_postfixs==nil){
        [self fillUpDictionarys];
    }
    return _postfixs;
}

//enum soundFileType
+(NSString *)GetSoundFileTypeEnumAsString:(enum SoundFileTypeEnum)fileType{
    switch (fileType) {
        case wav:
            return @"wav";
            break;
        case aif:
            return @"aif";
            break;
        default:
            break;
    }
}


//enum soundInfo
+(NSMutableArray *)GetSoundInfoEnumAllValues{
    NSMutableArray *allValues=[NSMutableArray array];
    [allValues addObject:@"DisplayName"];
    [allValues addObject:@"Dur"];
    [allValues addObject:@"Score"];
    [allValues addObject:@"Des"];
    return allValues;
}
+(NSString *)GetSoundInfoEnumAsString:(enum SoundInfoEnum)soundInfo{
    switch (soundInfo) {
        case DisplayName:
            return @"DisplayName";
            break;
        case Dur:
            return @"Dur";
        case Score:
            return @"Score";
        case Des:
            return @"Des";
        default:
            break;
    }
}
+(enum SoundInfoEnum)StringToSoundInfoEnum:(NSString *)stringValue{
    if ([stringValue isEqualToString:@"DisplayName"]) {
        return DisplayName;
    }else if ([stringValue isEqualToString:@"Dur"]){
        return Dur;
    }else if ([stringValue isEqualToString:@"Score"]){
        return Score;
    }else if ([stringValue isEqualToString:@"Des"]){
        return Des;
    }
    return -1;
}

//enum soundType
+(NSMutableArray *)GetSoundTypeEnumAllValues{
    NSMutableArray *allValues=[NSMutableArray arrayWithObjects:@"Surround_70",@"Surround_71",@"Surround_50",@"Surround_51",@"Stereo",@"Single",nil];
    return allValues;
}
+(NSMutableArray *)GetSoundTypeEnumAllValuesAsChineseString{
    NSMutableArray *allValues=[NSMutableArray arrayWithObjects:@"环绕声 7.0",@"环绕声 7.1",@"环绕声 5.0",@"环绕声 5.1",@"立体声",@"单声道/多轨音频",nil];
    return allValues;
}
+(enum SoundTypeEnum)EnglishStringToSoundTypeEnum:(NSString *)stringValue{
    if ([stringValue isEqualToString:@"环绕声 7.0"]) {
        return Surround_70;
    }else if ([stringValue isEqualToString:@"环绕声 7.1"]){
        return Surround_71;
    }else if ([stringValue isEqualToString:@"环绕声 5.0"]){
        return Surround_50;
    }else if ([stringValue isEqualToString:@"环绕声 5.1"]){
        return Surround_51;
    }else if ([stringValue isEqualToString:@"立体声"]){
        return Stereo;
    }else if ([stringValue isEqualToString:@"单声道/多轨音频"]){
        return Single;
    }
    return 1;
}
+(enum SoundTypeEnum)StringToSoundTypeEnum:(NSString *)stringValue{
    if ([stringValue isEqualToString:@"环绕声 7.0"]) {
        return Surround_70;
    }else if ([stringValue isEqualToString:@"环绕声 7.1"]){
        return Surround_71;
    }else if ([stringValue isEqualToString:@"环绕声 5.0"]){
        return Surround_50;
    }else if ([stringValue isEqualToString:@"环绕声 5.1"]){
        return Surround_51;
    }else if ([stringValue isEqualToString:@"立体声"]){
        return Stereo;
    }else if ([stringValue isEqualToString:@"单声道/多轨音频"]){
        return Single;
    }
    return 1;
}

+(NSString *)GetSoundTypeEnumAsString:(enum SoundTypeEnum)soundType{
    switch (soundType) {
        case Surround_70:
            return @"环绕声 7.0";
        case Surround_71:
            return @"环绕声 7.1";
        case Surround_50:
            return @"环绕声 5.0";
        case Surround_51:
            return @"环绕声 5.1";
        case Stereo:
            return @"立体声";
        case Single:
            return @"单声道/多轨音频";
            break;        
        default:
            break;
    }
}


//enum channelType
+(NSMutableArray *)GetChannelTypeAllValues{
    NSMutableArray *allValues=[NSMutableArray arrayWithObjects:@"L",@"R",@"C",@"SL",@"SR",@"BSL",@"BSR",@"SW",nil];
    return allValues;
}

+(enum ChannelTypeEnum)StringToChannelTypeEnum:(NSString *)stringValue{
    if ([stringValue isEqualToString:@"左声道"]) {
        return L;
    }else if ([stringValue isEqualToString:@"右声道"]){
        return R;
    }else if ([stringValue isEqualToString:@"中声道"]){
        return C;
    }else if ([stringValue isEqualToString:@"左环绕声道"]){
        return SL;
    }else if ([stringValue isEqualToString:@"右环绕声道"]){
        return SR;
    }else if ([stringValue isEqualToString:@"左后环绕声道"]){
        return BSL;
    }else if ([stringValue isEqualToString:@"右后环绕声道"]){
        return BSR;
    }else if ([stringValue isEqualToString:@"低频声道"]){
        return SW;
    }
    return -1;
}

+(NSString *)GetChannelTypeEnumAsString:(enum ChannelTypeEnum)channelType{
    switch (channelType) {
        case L:
            return @"左声道";
        case R:
            return @"右声道";
        case C:
            return @"中声道";
        case SL:
            return @"左环绕声道";
        case SR:
            return @"右环绕声道";
        case BSL:
            return @"左后环绕声道";
        case BSR:
            return @"右后环绕声道";
        case SW:
            return @"低频声道";
        default:
            break;
    }
}


+(enum ChannelTypeEnum)ENStringToChannelTypeEnum:(NSString *)stringValue{
    if ([stringValue isEqualToString:@"_L"]) {
        return L;
    }else if ([stringValue isEqualToString:@"_R"]){
        return R;
    }else if ([stringValue isEqualToString:@"_C"]){
        return C;
    }else if ([stringValue isEqualToString:@"_SL"]){
        return SL;
    }else if ([stringValue isEqualToString:@"_SR"]){
        return SR;
    }else if ([stringValue isEqualToString:@"_BSL"]){
        return BSL;
    }else if ([stringValue isEqualToString:@"_BSR"]){
        return BSR;
    }else if ([stringValue isEqualToString:@"_SW"]){
        return SW;
    } else {
        return C;
    }
}

+(NSString *)GetChannelTypeEnumAsENString:(enum ChannelTypeEnum)channelType{
    switch (channelType) {
        case L:
            return @"_L";
        case R:
            return @"_R";
        case C:
            return @"_C";
        case SL:
            return @"_SL";
        case SR:
            return @"_SR";
        case BSL:
            return @"_BSL";
        case BSR:
            return @"_BSR";
        case SW:
            return @"_SW";
        default:
            break;
    }
}


@end
