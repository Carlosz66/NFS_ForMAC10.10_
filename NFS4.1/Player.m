//
//  Player.m
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "Player.h"

@implementation Player

-(id)init{
    if (self=[super init]) {
        self._players=[NSMutableArray array];
        self._playerdelegate=nil;
    }
    return self;
}

-(void)ResetSound:(Sound *)sound{
    NSError *error=nil;
    self.PlayingSound = sound;
    [self._players removeAllObjects];
    for(NSNumber *soundfile in sound.AudioFiles){
        AVAudioPlayer *avaudioplayer=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",sound.FatherLibraryURL.path,sound.AudioFiles[soundfile]]] error:&error];
        avaudioplayer.delegate=self;
        [self._players addObject:avaudioplayer];
    }
    if (error!=nil) {
        return;
    }
    [self._playerdelegate NFSAudioPlayerClassCreateNewPlayer];
}


-(void)PlayOrPause{
    for(AVAudioPlayer *player in self._players){
        if ([player isPlaying]) {
            [player stop];
            [self._playerdelegate NFSAudioPlayerClassPlay];
        }else{
            [player play];
            [self._playerdelegate NFSAudioPlayerClassStop];
        }
    }
}

-(void)PlayAudioAtTime:(NSTimeInterval)time{
    for(AVAudioPlayer *player in self._players){
        player.currentTime=time;
    }
}

-(void)SetAudioVolume:(float)db{
    for(AVAudioPlayer *player in self._players){
        player.volume=db;
    }
}

-(float)GetCurrentProgress{
    AVAudioPlayer *player = [self._players objectAtIndex:0];
    return player.currentTime/player.duration;
}

-(float)GetCurrentTime{
    AVAudioPlayer *player = [self._players objectAtIndex:0];
    return player.currentTime;
}

-(NSTimeInterval)GetDuration{
    AVAudioPlayer *player = [self._players objectAtIndex:0];
    return player.duration;
}

-(BOOL)IsPlaying{
    AVAudioPlayer *player = [self._players objectAtIndex:0];
    return [player isPlaying];
}

#pragma mark - AVAudioPlayer delegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self._playerdelegate NFSAudioPlayerClassStop];
}

@end
