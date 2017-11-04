//
//  PlayerAreaView.h
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Player.h"
#import "ApplicationHelper.h"
#import "Painter.h"
#import "SingleWavFormView.h"
#import "Device.h"

@interface PlayerAreaView : NSView<NFSAudioPlayerDelegate>
{
    float zoomScale;
    NSMutableArray *deviceArray;
    NSTimer *timer;
    NSMutableDictionary *singleWavFormViewDictionary;
    NSView *wavFormContentView;
}
@property (strong) IBOutlet NSView *contentView;

@property (weak) IBOutlet NSTextField *soundName;
@property (weak) IBOutlet NSTextField *soundDuration;
@property (weak) IBOutlet NSTextField *soundDescriptionTextField;
@property (weak) IBOutlet NSScrollView *wavFormScrollView;
@property (weak) IBOutlet NSComboBox *SoundScoreComboBox;
@property (weak) IBOutlet NSComboBox *SoundCardComboBox;
@property (weak) IBOutlet NSTextField *curTimeLabel;
@property (weak) IBOutlet NSButton *soundIsAutoPlayButton;
@property (weak) IBOutlet NSButton *soundPlayButton;
@property (weak) IBOutlet NSTextField *soundSampleAmoutLabel;
@property (weak) IBOutlet NSTextField *soundChannelNumberLabel;

@end
