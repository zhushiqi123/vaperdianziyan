//
//  User.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/21.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BThumbnail.h"

@interface User : NSObject

@property(nonatomic,assign) int uid;
@property(nonatomic,retain) NSString *nikename;
@property(nonatomic,retain) NSString *cellphone;
@property(nonatomic,retain) NSString *password;
@property(nonatomic,retain) NSString *email;
@property(nonatomic,assign) int electricity;
@property(nonatomic,retain) NSString *photoStr;
@property(nonatomic,retain) BThumbnail *bthumbnail;

+(User *)initdata:(id)data;

//用户注册
+(void)regist:(NSString *)username password:(NSString *)password nickname:(NSString *)nickname success:(void (^)(NSString *))success failure:(void (^)(NSString *))failure;

//用户登录
+(void)login:(NSString *)username password:(NSString *)password success:(void (^)(User *))success failure:(void (^)(NSString *))failure;
// 获取验证码
+ (void)code:(NSString *)tel :(void (^)(NSString *))success failure:(void (^)(NSString *))failure;

//重置密码第一步获取验证码
+(void)forgetPassword:(NSString *)cellphone success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//重置密码第二步
+(void)resetPassword:(NSString *)cellphone code:(NSString *)code password:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//用户个人信息里修改密码
+(void)UserResetPassword:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//+(void)feedback:(int)uid content:(NSString *)content success:(void (^)(id))success failure:(void (^)(NSString *))failure;
// 附近的人
+(void) personAroundLongitude:(NSString *)longitude andLatitude:(NSString *)latitude success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//好友列表
+(void) getUserFriend:(void (^)(id))success failure:(void (^)(NSString *))failure;

//用户好友列表
+(void) getUserAllFriend:(void (^)(id))success failure:(void (^)(NSString *))failure;

//新朋友列表
+(void) getNewqAllFriend:(void (^)(id))success failure:(void (^)(NSString *))failure;

//添加好友
+(void) addFriend:(int)friendid success:(void (^)(id))success failure:(void (^)(NSString *message))failure;

+(void) deleteFriend:(int)friendid success:(void (^)(id))success failure:(void (^)(NSString *message))failure;

//者拒绝好友
+(void) addFriendNO:(int)friendid success:(void (^)(id json))success failure:(void (^)(NSString *message))failure;
//同意好友
+(void) addFriendYES:(int)friendid success:(void (^)(id json))success failure:(void (^)(NSString *message))failure;

+(void)AddElectricity:(int)uid electricity:(int)electricity success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//+(void)setPersonalCenter:(NSString *)cellphone email:(NSString *)email realname:(NSString *)realname heading:(NSString *)heading success:(void (^)(id))success failure:(void (^)(NSString *))failure;
+(void)setNickname:(NSString *)nickname success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//设置用户手机
+(void)setCellphone:(NSString *)cellphone success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//设置用户邮箱
+(void)setEmail:(NSString *)email success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//设置用户头像
+(void)setHeading:(NSString *)headimage success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//绑定设备
+(void)addDevice:(NSString *)device :(NSString *)name success:(void (^)(id))success failure:(void (^)(NSString *))failure;
//解绑设备
+(void)delectDevice:(NSString *)device success:(void (^)(id))success failure:(void (^)(NSString *))failure;
//查询设备列表
+(void)devicesList:(NSString *)customer_id success:(void (^)(id))success failure:(void (^)(NSString *))failure;
//更改设备名称
+(void)updateName:(NSString *)device :(NSString *)name success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//获取设备可用固件列表
+(void)device_update:(NSString *)device_id success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//吸烟记录
+(void)recordData:(int)deviceid startime:(int)startime endtime:(int)endtime day:(NSDate *)day time:(int)time longitude:(float)longitude latitude:(float) latitude success:(void (^)(id))success failure:(void (^)(NSString *))failure;
//获取吸烟记录
+(void)getRecordData:(NSString *)type  success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//获取吸烟记录下一级具体数据
+(void)getRecordAllData:(NSString *)type time:(NSString *)time  success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//吸烟计划
+(void)somkePlan:(int)mymouth price:(int)price smokemouth:(int)smokemouth  success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//读取吸烟计划
+(void)readSomkePlan:(void (^)(id))success failure:(void (^)(NSString *))failure;

//每周设置
+(void)setWeek:(id )days success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//读取每周记录
+(void)readWeek:(NSString *)days success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//月份设置
+(void)setMonth:(int)months mouth:(int)mouth success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//读取月的记录
+(void)readMonths:(NSString *)months success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//一天吸烟的记录
+(void)mapData:(void (^)(id))success failure:(void (^)(NSString *))failure;

//获取当天的吸烟口数
+(void)daySmockCount:(void (^)(id))success failure:(void (^)(NSString *))failure;

+(void)getRCToken:(void (^)(id json))success failure:(void (^)(NSString *message))failure;
//上传离线信息
+(void)offlineArray:(NSArray *)items success:(void (^)(id))success failure:(void (^)(NSString *))failure;

//获取硬件设备信息 - deviceVersion 硬件编号
+(void)getDeviceDataToNet:(int)deviceVersion success:(void (^)(id))success failure:(void (^)(NSString *))failure;

@end
