//
//  TYZFileData.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/21.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "MJExtension.h"
#import "Device.h"
#import "LineCGPoint.h"

@interface TYZFileData : NSObject

//保存用户信息
+(int)SaveUserData:(User *)user;

//获取本地缓存的用户信息
+(User *)GetUserData;

//保存用户设备信息
+(int)SaveDeviceData:(NSMutableArray *)deviceArray;

//获取本地缓存的用户设备信息
+(NSMutableArray *)GetDeviceData;

//保存用户Power曲线信息
+(int)SavePowerLineData:(NSMutableArray *)lineArray :(int)lineArrayType;

//获取本地缓存的用户Power曲线信息
+(NSMutableArray *)GetPowerLineData:(int)lineArrayType;

//返回文件缓存目录
+(NSString *)getSaveFilePash:(NSString *)fileName;

@end
