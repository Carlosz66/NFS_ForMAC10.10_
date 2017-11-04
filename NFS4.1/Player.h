//
//  Player.h
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudio.h>
#import "Sound.h"

@class Sound;
@protocol NFSAudioPlayerDelegate <NSObject>

@optional
-(void)NFSAudioPlayerClassCreateNewPlayer;
-(void)NFSAudioPlayerClassPlay;
-(void)NFSAudioPlayerClassStop;

@end

@interface Player : NSObject<AVAudioPlayerDelegate>
/*
var _playerdelegate:NFSAudioPlayerDelegate? = nil;

var _players = Array<AVAudioPlayer>()

var PlayingSound = Sound();
*/
@property NSObject<NFSAudioPlayerDelegate> *_playerdelegate;
@property NSMutableArray *_players;
@property Sound *PlayingSound;

-(void)ResetSound:(Sound *)sound;
//-(void)SetPlayerDelegate:(NSObject<NFSAudioPlayerDelegate> *)playerdelegate;   //oc will atomatically create a setter
-(void)PlayOrPause;
-(void)PlayAudioAtTime:(NSTimeInterval)time;
-(void)SetAudioVolume:(float)db;
-(float)GetCurrentProgress;
-(float)GetCurrentTime;
-(BOOL)IsPlaying;
-(NSTimeInterval)GetDuration;
@end
