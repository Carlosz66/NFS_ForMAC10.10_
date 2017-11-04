//
//  Sound.m
//  NFS4.1
//
//  Created by carlos on 15-12-10.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "Sound.h"

@implementation Sound

-(id)init{
    if (self=[super init]) {
        self.FatherLibrary=[[Library alloc]init];
        self.FatherFolder=[[Library alloc] init];
        self.ChannelPeakFiles=[NSMutableDictionary dictionary];
        self.AudioFiles=[NSMutableDictionary dictionary];
        self.Info=[NSMutableDictionary dictionary];
    }
    return self;
}

-(void)CreatePeakFile{
    NSLog(@"对于多音轨单音频文件的情况，只对单声道和立体声进行处理，但是对于其他情况的接口已经留出");
    for (NSNumber* channelTypeNumber in self.AudioFiles.keyEnumerator) {
        //enum ChannelTypeEnum channelType = channelTypeNumber.integerValue;
        NSString* soundfile = [self.AudioFiles objectForKey:channelTypeNumber];
        NSURL *soundFileURL= [self.FatherLibraryURL URLByAppendingPathComponent:soundfile isDirectory:FALSE];
        [self OpenAudioFile:soundFileURL];
        [self ConvertAudioFile];
        [self ReadAudioFile];
        [self CalculateAudioPeakFileAndCreatePeakFile: channelTypeNumber];
        //Clear
        ExtAudioFileDispose(audioEAFR);
        free(samples);
        samples = nil;
    }
}

-(OSStatus)OpenAudioFile:(NSURL *)soundFileURL{
    audioEAFR=NULL;
    return ExtAudioFileOpenURL((__bridge CFURLRef)(soundFileURL), &audioEAFR);
}

-(OSStatus)ConvertAudioFile{
    @autoreleasepool {
        //the second approach
        extAFNumChannels=0;
        UInt32 outSize=0;
        Boolean outWritable=FALSE;
        AudioStreamBasicDescription fileFormat;
        UInt32 propSize = sizeof(AudioStreamBasicDescription);
        OSStatus err =ExtAudioFileGetProperty(audioEAFR, kExtAudioFileProperty_FileDataFormat, &propSize, &fileFormat);
        if (err!=0) {
            return err;
        }
        extAFNumChannels=fileFormat.mChannelsPerFrame;
        //convert format
        AudioStreamBasicDescription clientFormat;
        clientFormat.mFormatID = kAudioFormatLinearPCM;
        clientFormat.mSampleRate = 44100.0;
        clientFormat.mFormatFlags = kAudioFormatFlagIsFloat;
        clientFormat.mChannelsPerFrame = extAFNumChannels;
        clientFormat.mBitsPerChannel = (UInt32)(sizeof(float) * 8);
        clientFormat.mFramesPerPacket = 1;
        clientFormat.mBytesPerFrame = (UInt32)(extAFNumChannels* sizeof(float));
        clientFormat.mBytesPerPacket = (UInt32)(extAFNumChannels* sizeof(float));
        clientFormat.mReserved = 0;
        err = ExtAudioFileGetPropertyInfo(audioEAFR, kExtAudioFileProperty_ClientDataFormat, &outSize, &outWritable);
        if (err != 0)
        {
            NSLog(@"Error: %@",[NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil]);
            return err;
        }
        err = ExtAudioFileSetProperty(audioEAFR, kExtAudioFileProperty_ClientDataFormat, outSize, &clientFormat);
        if (err != 0)
        {
            NSLog(@"Error: %@",[NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil]);
            return err;
        }
        return 0;
    }
}

-(OSStatus)ReadAudioFile{
    @autoreleasepool {
        UInt32 outSize=0;
        Boolean outWritable=FALSE;
        OSStatus err;
        err=ExtAudioFileGetPropertyInfo(audioEAFR, kExtAudioFileProperty_FileLengthFrames, &outSize, &outWritable);
        if (err != 0)
        {
            return err;
        }
        UInt32 frameSize = 0;
        err = ExtAudioFileGetProperty(audioEAFR, kExtAudioFileProperty_FileLengthFrames, &outSize, &frameSize);
        if (err != 0)
        {
            return err;
        }
        samples= malloc(sizeof(float)*frameSize*extAFNumChannels);
        if (!samples) {
            NSLog(@"Error:memory allocated failed!");
            return -1;
        }
        samplesCount=frameSize*extAFNumChannels;
        for (int i=0; i<(samplesCount); i++) {
            samples[i]=0;
        }
        AudioBufferList bufferList;
        bufferList.mNumberBuffers = 1;
        bufferList.mBuffers[0].mNumberChannels = extAFNumChannels; // Always 2 channels in this example
        bufferList.mBuffers[0].mData = samples; // data is a pointer (float*) to our sample buffer
        bufferList.mBuffers[0].mDataByteSize = sizeof(float) * (frameSize * extAFNumChannels);
        err = ExtAudioFileRead(audioEAFR, &frameSize, &bufferList);
        if (err != 0)
        {
            return err;
        }
        return 0;
    }
}

-(void)CalculateAudioPeakFileAndCreatePeakFile:(NSNumber*)channelType {
    CGPoint** samplePoints = malloc(sizeof(CGPoint *) * extAFNumChannels);
    int SamplePointsCount = ceil((float)samplesCount / (float)extAFNumChannels / 256.0) * 2;
    for (int i=0; i<extAFNumChannels; i++) {
        samplePoints[i] = malloc(sizeof(CGPoint) * SamplePointsCount);
    }
    for (int i=0,pi=0; i<samplesCount; i+=256*extAFNumChannels,pi+=2) {
        for (int j=0; j<extAFNumChannels; j++) {
            int maxindex=0,minindex=0;
            float max=samples[j*256],min=samples[j*256];
            for(int k=0; k<256; k++) {
                if ((i+j*256+k) < samplesCount) {
                    if (samples[i+j*256+k] > max) {
                        max = samples[i+j*256+k];
                        maxindex = i+j*256+k;
                    } else if (samples[i+j*256+k] < min) {
                        min = samples[i+j*256+k];
                        minindex = i+j*256+k;
                    }
                }
            }
            samplePoints[j][pi] = NSMakePoint((CGFloat)pi, (CGFloat)(max));
            samplePoints[j][pi+1] = NSMakePoint((CGFloat)(pi+1), (CGFloat)(min));
        }
    }
    if (extAFNumChannels == 2) {
        enum ChannelTypeEnum lcte = L;
        enum ChannelTypeEnum rcte = R;
        NSNumber* nlcte = [NSNumber numberWithInt:lcte];
        NSNumber* nrcte = [NSNumber numberWithInt:rcte];
        [self private_CreatePeakFile:[self.ChannelPeakFiles objectForKey:nlcte] :samplePoints[0] :(sizeof(CGPoint) * SamplePointsCount)];
        [self private_CreatePeakFile:[self.ChannelPeakFiles objectForKey:nrcte] :samplePoints[1] :(sizeof(CGPoint) * SamplePointsCount)];
    } else if (extAFNumChannels == 1) {
        [self private_CreatePeakFile:[self.ChannelPeakFiles objectForKey:channelType] :samplePoints[0] :(sizeof(CGPoint) * SamplePointsCount)];
    }
    for (int i=0; i<extAFNumChannels; i++) {
        free(samplePoints[i]);
        samplePoints[i] = nil;
    }
    free(samplePoints);
    samplePoints = nil;
}

-(void)private_CreatePeakFile:(NSString*)peakFile:(CGPoint*)data:(int)datalength{
    NSURL* cacheFileURL = [[[ApplicationHelper StoreURL] URLByAppendingPathComponent:[self.FatherLibraryURL lastPathComponent] isDirectory:YES] URLByAppendingPathComponent:peakFile isDirectory:NO];
    [[NSFileManager defaultManager] createDirectoryAtURL:[cacheFileURL URLByDeletingLastPathComponent] withIntermediateDirectories:TRUE attributes:nil error:nil];
    NSData *nsdata=[NSData dataWithBytes:data length:datalength];
    [nsdata writeToURL:cacheFileURL atomically:TRUE];
    nsdata = nil;
}

-(NSInteger)CompareWithStrings:(NSArray *)keys{
    int score=-1;
    for(NSString *key in keys){
        if([[self.Info objectForKey:[NSNumber numberWithInt:DisplayName]] rangeOfString:key options:NSCaseInsensitiveSearch].length!=0){
            score++;
        }
        if ([[self.Info objectForKey:[NSNumber numberWithInt:Des]] rangeOfString:key options:NSCaseInsensitiveSearch].length!=0) {
            score++;
        }
    }
    self.RelevantScore=score;
    return self.RelevantScore;
}

//extension method
+(NSString *)GetSamePartFormStart:(NSMutableArray *)strings{
    if (strings.count==1) {
        return strings[0];
    }else{
        NSString *commonString = strings[0];
        for(NSString *str in strings){
            commonString = [commonString commonPrefixWithString:str options:NSLiteralSearch];
        }
        return commonString;
    }
}

+(NSString *)RemovePostfixs:(NSString *)filename PostFixs:(NSMutableDictionary *)postfixs{
    NSString *newfilename = filename;
    for (int i=0; i<postfixs.count; i++) {
        NSString *postfix = [[postfixs allValues] objectAtIndex:i];
        if ([filename hasSuffix:postfix]) {
            NSRange range = [filename rangeOfString:postfix options:NSLiteralSearch | NSAnchoredSearch | NSBackwardsSearch];
            newfilename = [filename stringByReplacingCharactersInRange:range withString:@""];
            //newfilename=[filename strin:postfix withString:@""];
        }
    }
    return newfilename;
}

@end
