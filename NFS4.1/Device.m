//
//  Device.m
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import "Device.h"

@implementation Device

-(id)init{
    if (self=[super init]) {
        _deviceID=0;
        _deviceName=@"";
        _deviceUID=@"";
        _deviceType=Unknown;
    }
    return self;
}

-(id)init:(AudioObjectID)deviceID name:(NSString *)deviceName UID:(NSString *)deviceUID  type:(enum DeviceTypeEnum)deviceType{
    if (self=[super init]) {
        _deviceID=deviceID;
        _deviceName=deviceName;
        _deviceUID=deviceUID;
        _deviceType=deviceType;
    }
    return self;
}

-(NSString *)deviceName{
    return _deviceName;
}


/// 获取所有输出设备
/// - Returns: 可用输出设备列表或nil
/// - Attention: 返回的列表可能为空
+(NSMutableArray *)CreateOutputDeviceArray{
    NSMutableArray *OutputDevices = [NSMutableArray array];
    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mSelector=kAudioHardwarePropertyDevices;
    propertyAddress.mScope=kAudioObjectPropertyScopeGlobal;
    propertyAddress.mElement=kAudioObjectPropertyElementMaster;
    UInt32 dataSize=0;
    OSStatus err=0;
    err=AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize);
    if (err!=0) {
        return nil;
    }
    int deviceCount =(int) (dataSize/sizeof(AudioDeviceID));
    //AudioDeviceID *audioDevices;
    
    AudioDeviceID audioDevices[deviceCount];
    //audioDevices = malloc(sizeof(AudioDeviceID)*deviceCount);
    memset(audioDevices, 0, sizeof(AudioDeviceID)*deviceCount);
    err=AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize, &audioDevices);
    if (err!=0) {
        return nil;
    }
    
    //find the audio output device
    propertyAddress.mScope=kAudioDevicePropertyScopeOutput;
    for(int i=0;i<deviceCount;i++){
        AudioDeviceID device = audioDevices[i];
        dataSize=0;
        propertyAddress.mSelector=kAudioDevicePropertyStreamConfiguration;
        AudioObjectGetPropertyDataSize(device, &propertyAddress, 0, NULL, &dataSize);
        AudioBufferList bufferList;
        AudioObjectGetPropertyData(device, &propertyAddress, 0, NULL, &dataSize, &bufferList);
        
        CFStringRef deviceUID=NULL;
        dataSize = (UInt32)sizeof(deviceUID);
        propertyAddress.mSelector=kAudioDevicePropertyDeviceUID;
        AudioObjectGetPropertyData(device, &propertyAddress, 0, NULL, &dataSize, &deviceUID);
        
        CFStringRef deviceName=NULL;
        dataSize = (UInt32)sizeof(deviceName);
        propertyAddress.mSelector=kAudioDevicePropertyDeviceNameCFString;
        AudioObjectGetPropertyData(device, &propertyAddress, 0, NULL, &dataSize, &deviceName);
        
        if(bufferList.mNumberBuffers!=0){
            [OutputDevices addObject:[[Device alloc] init:device name:(__bridge NSString *)(deviceName) UID:(__bridge NSString *)(deviceUID) type:Output]];
        }
    }
    return OutputDevices;    
}

/// 修改默认输出设备
/// - Parameter device:新的输出设备信息
/// - Returns:修改成功返回0，否则返回其他值
-(OSStatus)SetToDefaultOutputDevice{
    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mSelector=kAudioHardwarePropertyDefaultOutputDevice;
    propertyAddress.mScope=kAudioObjectPropertyScopeGlobal;
    propertyAddress.mElement=kAudioObjectPropertyElementMaster;
    AudioObjectID deviceID = _deviceID;
    OSStatus err=0;
    err=AudioObjectSetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, sizeof(AudioObjectID), &deviceID);
    if (err!=0) {
        return -1;
    }
    return 0;
}



@end
