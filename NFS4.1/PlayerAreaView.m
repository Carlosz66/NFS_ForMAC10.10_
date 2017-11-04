//
//  PlayerAreaView.m
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "PlayerAreaView.h"

@implementation PlayerAreaView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self MyInit];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

-(void)MyInit{
    [[NSBundle mainBundle] loadNibNamed:@"PlayerAreaView" owner:self topLevelObjects:nil];
    [self.contentView setFrame:NSMakeRect(0, 0, self.frame.size.width,self.frame.size.height)];
    [self addSubview:self.contentView];
    
    deviceArray=[Device CreateOutputDeviceArray];
    for(Device *item in deviceArray){
        [self.SoundCardComboBox addItemWithObjectValue:[item deviceName]];
    }
    [self.SoundCardComboBox setStringValue:[self.SoundCardComboBox itemObjectValueAtIndex:0]];
    
    singleWavFormViewDictionary=[NSMutableDictionary dictionary];
    zoomScale=1;
    [ApplicationHelper player]._playerdelegate=self;
    
    
    NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(seekAtPoint:) name:@"seekAtPoint" object:nil];
}//[[[ApplicationHelper player] PlayingSound] ChannelPeakFiles];


#pragma mark - repaint everything except wav form after sound reseted
-(void)repaintAfterSoundReseted{
    Sound *playingSound=[[ApplicationHelper player] PlayingSound];
    [self.soundName setStringValue:[NSString stringWithFormat:@"音频名称: %@",[playingSound.Info objectForKey:[NSNumber numberWithInt:DisplayName]]]];
    [self.soundDuration setStringValue:[NSString stringWithFormat:@"持续时间: %@",[playingSound.Info objectForKey:[NSNumber numberWithInt:Dur]]]];
    [self.soundDescriptionTextField setStringValue:[playingSound.Info objectForKey:[NSNumber numberWithInt:Des]]];
    [self.SoundScoreComboBox setStringValue:[playingSound.Info objectForKey:[NSNumber numberWithInt:Score]]];
    [self.soundChannelNumberLabel setStringValue:[NSString stringWithFormat:@"声道数: %ld",(unsigned long)playingSound.ChannelPeakFiles.allKeys.count]];
    
    NSError *error=nil;
    NSURL *playingSoundURL = [playingSound.FatherLibraryURL URLByAppendingPathComponent:[[playingSound.AudioFiles allValues]objectAtIndex:0] isDirectory:NO];
    AVAudioPlayer *tempPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:playingSoundURL error:&error];
    if (error) {
        return;
    }
    NSNumber *sampleCount=[[tempPlayer settings] objectForKey:AVSampleRateKey];
    float s = sampleCount.floatValue;
    [self.soundSampleAmoutLabel setStringValue:[NSString stringWithFormat:@"采样量化: %.0f",s]];
}



#pragma mark - paint the Wave-Form-View
-(void)paintWaveFormView{
    Sound *playingSound=[[ApplicationHelper player] PlayingSound];
    NSMutableDictionary *channelFiles=playingSound.ChannelPeakFiles;
    NSInteger soundnumber=channelFiles.count;
    
    [singleWavFormViewDictionary removeAllObjects];
    NSRect singleWavViewRect=[self getSingleWavFormViewRect];
    NSRect singleWavImageRect=[self getSingleWavImageRect];
    
    wavFormContentView=[[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.wavFormScrollView.frame.size.width, singleWavViewRect.size.height*soundnumber)];
    
    float progress=[[ApplicationHelper player] GetCurrentProgress];
    
    for(NSNumber *peakfile in channelFiles){
        NSString *peakfilePath=[channelFiles objectForKey:peakfile];
        NSURL *peakfileURL= [[[ApplicationHelper StoreURL]URLByAppendingPathComponent:[playingSound.FatherLibraryURL lastPathComponent] isDirectory:YES] URLByAppendingPathComponent:peakfilePath isDirectory:NO];
        
        SingleWavFormView *singleWavView=[[SingleWavFormView alloc] initWithFrame:singleWavViewRect withChannelType:[EnumHelper GetChannelTypeEnumAsString:peakfile.intValue] withPeakFileURL:peakfileURL withImageRect:singleWavImageRect withScrollView:self.wavFormScrollView];
        //
        singleWavView.fatherScrollView=self.wavFormScrollView;
        singleWavView.playProgress=progress;
        singleWavViewRect.origin.y+=singleWavViewRect.size.height;
        [wavFormContentView addSubview:singleWavView];
        [singleWavFormViewDictionary setObject:singleWavView forKey:peakfile];

    }
    [self.wavFormScrollView setDocumentView:wavFormContentView];
}

-(void)paintWavFormInCircle{
    Sound *playingSound=[[ApplicationHelper player] PlayingSound];
    NSMutableDictionary *channelFiles=playingSound.ChannelPeakFiles;

    
    NSRect singleWavImageRect=[self getSingleWavImageRect];
    
    float progress=[[ApplicationHelper player] GetCurrentProgress];
    
    for(NSNumber *peakfile in channelFiles){
        SingleWavFormView *singleWavView = [singleWavFormViewDictionary objectForKey:peakfile];
        singleWavView.playProgress=progress;
        singleWavView.singleWavImageRect=singleWavImageRect;
        [singleWavView setNeedsDisplay:YES];
    }
}

//for zoom in and zoom out & set the image View
-(NSRect)getSingleWavFormViewRect{
    Sound *playingSound=[[ApplicationHelper player] PlayingSound];
    NSMutableDictionary *channelFiles=playingSound.ChannelPeakFiles;
    NSInteger soundnumber=channelFiles.count;
    CGFloat height = soundnumber > 2 ? 150 : self.wavFormScrollView.frame.size.height / soundnumber;
    height=150;
    return NSMakeRect(0, 0, self.wavFormScrollView.frame.size.width, height);
}

-(NSRect)getSingleWavImageRect{
    Sound *playingSound=[[ApplicationHelper player] PlayingSound];
    NSMutableDictionary *channelFiles=playingSound.ChannelPeakFiles;
    NSInteger soundnumber=channelFiles.count;
    CGFloat height = soundnumber > 2? 120 : (self.wavFormScrollView.frame.size.height / soundnumber) *(4.0/5.0);
    height=100;
    return NSMakeRect(0, 0, (self.wavFormScrollView.frame.size.width)*zoomScale, height);
}


#pragma mark - Repaint the wav form
-(void)drawAndMove{
    int minute = (int)[[ApplicationHelper player] GetCurrentTime]/60;
    int second = (int)ceil([[ApplicationHelper player] GetCurrentTime]-((int)[[ApplicationHelper player] GetCurrentTime]/60)*60);
    [self.curTimeLabel setStringValue:[NSString stringWithFormat:@"%.2d:%.2d",minute,second]];
    [self paintWavFormInCircle];
}



#pragma mark - IBAction
- (IBAction)SaveAsMenuItemClicked:(NSButton *)sender {
    [self saveTheSound];
}

- (IBAction)SaveMenuItemClicked:(NSButton *)sender {
    Sound *playingSound=[[ApplicationHelper player] PlayingSound];
    NSString *stringValue;
    stringValue=self.soundDescriptionTextField.stringValue;
    [[playingSound Info] setObject:stringValue forKey:[NSNumber numberWithInt:Des]];
    stringValue=self.SoundScoreComboBox.stringValue;
    [playingSound.Info setObject:stringValue forKey:[NSNumber numberWithInt:Score]];
    [playingSound.FatherLibrary SaveLibraryToDatabase:false];
    NSAlert *alert=[ApplicationHelper CreateNSAlert:@"Hello" Message:@"已保存"];
    NSBeep();
    [alert runModal];
}

- (IBAction)PlayOrPause:(NSButton *)sender {
    
    if (![[ApplicationHelper player] IsPlaying]) {
        if([ApplicationHelper player]!=nil){
            //play the sound
            [[ApplicationHelper player] PlayOrPause];
            [sender setTitle:@"停止"];
            //set a timer to update the view
            timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(drawAndMove) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        }
    }else{
        if ([ApplicationHelper player]!=nil) {
            //stop playing the sound
            [[ApplicationHelper player] PlayOrPause];
            [sender setTitle:@"播放"];
            //stop the timer to update the view
            [timer invalidate];
        }
    }
}

- (IBAction)VolumnSliderValueChanged:(NSSlider *)sender{
    [[ApplicationHelper player] SetAudioVolume:sender.floatValue];// floatValue is between 0 and 1
}

- (IBAction)SoundCardChanged:(NSComboBox *)sender {
    NSString *string=[self.SoundCardComboBox stringValue];
    for(Device *item in deviceArray){
        [item.deviceName isEqualToString:string];
        [item SetToDefaultOutputDevice];
        break;
    }
}

- (IBAction)WavFormViewZoomOut:(NSButton *)sender {
    if(zoomScale<2){
        zoomScale+=0.1;
        [self paintWavFormInCircle];
    }
}

- (IBAction)WavFormViewZoomIn:(NSButton *)sender {
    if(zoomScale>0.3){
        zoomScale-=0.1;
        [self paintWavFormInCircle];
    }
}


#pragma mark - NFSAudioPlayerDelegate delegate method
-(void)NFSAudioPlayerClassCreateNewPlayer{
    [self repaintAfterSoundReseted];
    [self paintWaveFormView];
    if (self.soundIsAutoPlayButton.state==NSOnState) {
        [[ApplicationHelper player] PlayOrPause];
        [self.soundPlayButton setTitle:@"停止"];
        timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(drawAndMove) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
}
-(void)NFSAudioPlayerClassPlay{
    //[self paintWaveFormView];
}
-(void)NFSAudioPlayerClassStop{
    //[self paintWaveFormView];
    if(![[ApplicationHelper player] IsPlaying]){
        [self.soundPlayButton setTitle:@"播放"];
        //stop the timer to update the view
        [timer invalidate];
    }
}

#pragma mark - go forward & go backward
-(void)seekAtPoint:(NSNotification *)note{
    NSNumber *K=[[note userInfo]objectForKey:@"progress"];
    float duration = [[ApplicationHelper player]GetDuration];
    [[ApplicationHelper player] PlayAudioAtTime:K.floatValue*duration];
    [self drawAndMove];
}

#pragma mark - save the sound file
-(void)saveTheSound{
    Sound *playingSound=[[ApplicationHelper player] PlayingSound];
    if(playingSound!=nil){
        NSOpenPanel *savepanel=[ApplicationHelper CreateNSOpenPanel:@"请选择音频导出的位置" CanChooseDirectories:YES CanChooseFiles:NO];
        if([savepanel runModal]==NSFileHandlingPanelOKButton){
            NSError *error=nil;
            NSString *message=@"已导出音频";
            for(int i=0;i<playingSound.AudioFiles.count;i++){
                NSURL *fromURL = [playingSound.FatherLibraryURL URLByAppendingPathComponent:[[playingSound.AudioFiles allValues]objectAtIndex:i] isDirectory:NO];
                NSURL *toURL = [savepanel.URL URLByAppendingPathComponent:fromURL.lastPathComponent isDirectory:NO];
                [[NSFileManager defaultManager] copyItemAtURL:fromURL toURL:toURL error:&error];
                if(error!=nil){
                    message=@"导出音频失败";
                    break;
                }
                    
            }
            NSAlert *alert=[ApplicationHelper CreateNSAlert:@"Hello" Message:message];
            NSBeep();
            [alert runModal];
        }
    }
    
}


@end
