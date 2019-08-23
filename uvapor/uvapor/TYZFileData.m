//
//  TYZFileData.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/21.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "TYZFileData.h"
#import <objc/runtime.h>

@implementation TYZFileData

//保存用户信息
+(int)SaveUserData:(User *)user
{
    int check_num = 0;
    
    NSString *plistPath = [self getSaveFilePash:@"user.plist"];
    
    NSMutableDictionary *dictplist = [[NSMutableDictionary alloc] init];

    NSDictionary *userDict = user.mj_keyValues;

    NSString *userDict_num = @"userDict-0";
    //设置属性值
    [dictplist setObject:userDict forKey:userDict_num];
    
    //写入文件
    [dictplist writeToFile:plistPath atomically:YES];

    return check_num;
}

//获取本地缓存的用户信息
+(User *)GetUserData
{
    //获取绝对路径 user.plist
    NSString *plistPath = [self getSaveFilePash:@"user.plist"];
    
    //根据路径获取user.plist的全部内容
    NSMutableDictionary *infolist= [[[NSMutableDictionary alloc]initWithContentsOfFile:plistPath] mutableCopy];
    
    //获取第一条信息
    NSString *userDict_num = @"userDict-0";
    
    NSMutableDictionary *userDict = [infolist objectForKey:userDict_num];
    
    User *user = [User mj_objectWithKeyValues:userDict];
    
    return user;
}

//保存用户设备信息
+(int)SaveDeviceData:(NSMutableArray *)deviceArray
{
    int check_num = 0;
    
    NSString *plistPath = [self getSaveFilePash:@"device.plist"];
    
    NSMutableDictionary *dictplist = [[NSMutableDictionary alloc] init];
    
    NSArray *dictDeviceArray = [Device mj_keyValuesArrayWithObjectArray:deviceArray];
    
    NSString *deviceDictarry = @"DeviceArray";
    
    //设置属性值
    [dictplist setObject:dictDeviceArray forKey:deviceDictarry];
    
    //写入文件
    [dictplist writeToFile:plistPath atomically:YES];
    
    return check_num;
}

//获取本地缓存的用户设备信息
+(NSMutableArray *)GetDeviceData
{
    //获取绝对路径 user.plist
    NSString *plistPath = [self getSaveFilePash:@"device.plist"];
    
    //根据路径获取device.plist的全部内容
    NSMutableDictionary *infolist= [[[NSMutableDictionary alloc]initWithContentsOfFile:plistPath] mutableCopy];
    
    //获取信息
    NSString *deviceDictarry = @"DeviceArray";
    
    NSMutableDictionary *dictDeviceArray = [infolist objectForKey:deviceDictarry];
    
    // 将字典数组转为Device模型数组
    NSMutableArray *deviceArray = [Device mj_objectArrayWithKeyValuesArray:dictDeviceArray];
    
    return deviceArray;
}

//保存用户Power曲线信息
+(int)SavePowerLineData:(NSMutableArray *)lineArray :(int)lineArrayType
{
    int check_num = 0;
    
    //构建路径
    NSString *str_pash = [NSString stringWithFormat:@"PowerLine%d.plist",lineArrayType];
    //获取绝对路径 user.plist
    NSString *plistPath = [self getSaveFilePash:str_pash];
    
    NSMutableDictionary *dictplist = [[NSMutableDictionary alloc] init];
    
    NSArray *dictpowerLineArray = [LineCGPoint mj_keyValuesArrayWithObjectArray:lineArray];
    
    NSString *powerLineDictarry = [NSString stringWithFormat:@"PowerLineArry%d",lineArrayType];
    
    //设置属性值
    [dictplist setObject:dictpowerLineArray forKey:powerLineDictarry];
    
    //写入文件
    [dictplist writeToFile:plistPath atomically:YES];
    
    return check_num;
}

//获取本地缓存的用户Power曲线信息
+(NSMutableArray *)GetPowerLineData:(int)lineArrayType
{
    //构建路径
    NSString *str_pash = [NSString stringWithFormat:@"PowerLine%d.plist",lineArrayType];
    //获取绝对路径 user.plist
    NSString *plistPath = [self getSaveFilePash:str_pash];
    
//    NSLog(@"plistPath - %@",plistPath);
    
    //根据路径获取device.plist的全部内容
    NSMutableDictionary *infolist= [[[NSMutableDictionary alloc]initWithContentsOfFile:plistPath] mutableCopy];
    
    //获取信息
    NSString *powerLineDictarry = [NSString stringWithFormat:@"PowerLineArry%d",lineArrayType];
    
    NSMutableDictionary *dictPowerLineArray = [infolist objectForKey:powerLineDictarry];
    
    // 将字典数组转为Device模型数组
    NSMutableArray *lineArray = [LineCGPoint mj_objectArrayWithKeyValuesArray:dictPowerLineArray];
    
    return lineArray;
}


//返回文件缓存目录
+(NSString *)getSaveFilePash:(NSString *)fileName
{
    //获取路径对象
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //获取完整路径
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    return plistPath;
}

@end
