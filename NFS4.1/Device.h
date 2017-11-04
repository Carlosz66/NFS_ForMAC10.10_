//
//  Device.h
//  NFS4.1
//
//  Created by carlos on 15-12-11.
//  Copyright (c) 2015年 carlos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumHelper.h"
#import <CoreAudio/CoreAudio.h>



@interface Device : NSObject
{
    /// 设备系统ID，重启变化
    AudioObjectID _deviceID;
    /// 设备名称
    NSString *_deviceName;
    /// 设备ID，类似GUID
    NSString *_deviceUID;
    /// 设备类型
    enum DeviceTypeEnum _deviceType;
    
}

-(id)init:(AudioObjectID)deviceID name:(NSString *)deviceName UID:(NSString *)deviceUID  type:(enum DeviceTypeEnum)deviceType;

+(NSMutableArray *)CreateOutputDeviceArray;
-(OSStatus)SetToDefaultOutputDevice;
-(NSString *)deviceName;


@end
