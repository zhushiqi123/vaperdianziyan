//
//  User.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/21.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "User.h"
#import "NSDictionary+Stwid.h"
#import "TYZ_AFNet_Client.h"
#import "OfflineInfo.h"

@implementation User

+(User *)initdata:(id)data
{
    User * obj = [[User alloc]init];
    obj.uid = [data intForKey:@"id"];
    obj.nikename = [data stringForKey:@"realname"];
    obj.cellphone = [data stringForKey:@"cellphone"];
    obj.email = [data stringForKey:@"email"];
//    obj.image= [NSString stringWithFormat:@"%@%@",IMAGE_HOST,[data stringForKey:@"imgurl"]];
    obj.electricity = [data intForKey:@"electricity"];
    obj.photoStr = [data stringForKey:@"headimg"];
    
    obj.bthumbnail = [BThumbnail initWithData:[data objectForKey:@"thumbnail"]];
    
    return obj;
}

//用户注册
+(void)regist:(NSString *)username password:(NSString *)password nickname:(NSString *)nickname success:(void (^)(NSString *))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] POST:(@"rest/register") parameters:@{@"cellphone":username,@"password":password,@"realname":nickname} progress:^(NSProgress * _Nonnull uploadProgress)
     {
         NSLog(@"用户注册中");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     } ];
    
}
//用户登陆
+(void)login:(NSString *)username password:(NSString *)password success:(void (^)(User *))success failure:(void (^)(NSString *))failure
{
    if ([TYZ_AFNet_Client sharedInstance].status_AFNetwork > 0)
    {
        [[TYZ_AFNet_Client sharedInstance] POST:(@"rest/login") parameters:@{@"cellphone":username,@"password":password} progress:^(NSProgress * _Nonnull uploadProgress)
         {
             NSLog(@"用户登录中");
         }
        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
         {
             User *data = [self initdata:responseObject];
//             NSLog(@"用户信息:%@",responseObject);
             success(data);
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
         {
             failure([NSString stringWithFormat:@"%@",error]);
         } ];
    }
    else
    {
        failure(@"400");
    }
    
}

//  获取验证码
+ (void)code:(NSString *)tel :(void (^)(NSString *))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] GET:[NSString stringWithFormat:@"rest/code?cellphone=%@",tel] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
//         NSLog(@"正在获取验证码");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSString *str = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"code"]];
         success(str);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     }];
}

//重置密码第一步获取验证码
+(void)forgetPassword:(NSString *)cellphone success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] GET:[NSString stringWithFormat:@"rest/forget?cellphone=%@",cellphone] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
//         NSLog(@"正在获取验证码");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     }];
}

//重置密码第二步

+(void)resetPassword:(NSString *)cellphone code:(NSString *)code password:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] POST:(@"rest/forget") parameters:@{@"cellphone":cellphone,@"code":code,@"password":password} progress:^(NSProgress * _Nonnull uploadProgress)
    {
        NSLog(@"重置密码中");
    }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    } ];
}

//用户个人信息里修改密码
+(void)UserResetPassword:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] POST:(@"rest/resetpassword") parameters:@{@"password":password} progress:^(NSProgress * _Nonnull uploadProgress)
     {
         NSLog(@"用户个人信息里修改密码");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     } ];
}

////反馈
//
//+(void)feedback:(int)uid content:(NSString *)content success:(void (^)(id))success failure:(void (^)(NSString *))failure{
//    [[BctClient sharedInstance] POST:@"rest/member/feedback" parameters:@{@"customer_id":@(uid),@"password":content} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//        success(responseObject);
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error %@",[operation responseString]);
//        failure([operation responseString]);
//    }];
//}

//查找附近的人

+(void) personAroundLongitude:(NSString *)longitude andLatitude:(NSString *)latitude success:(void (^)(id))success failure:(void (^)(NSString *))failure{
    
    id params = @{@"longitude":longitude,@"latitude":latitude};
    
    [[TYZ_AFNet_Client sharedInstance] GET:@"rest/member/person-around" parameters:params progress:^(NSProgress * _Nonnull downloadProgress)
     {
         NSLog(@"查找附近的人");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     }];
}

//好友列表

+(void) getUserFriend:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] GET:@"rest/member/friend" parameters:nil progress:nil
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSLog(@"好友列表 - %@",task.response);
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     }];
}

//新好友列表

+(void) getUserAllFriend:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] GET:@"rest/member/add-friend?type=add" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
         NSLog(@"新好友列表");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     }];
}

//添加好友

+(void) addFriend:(int)friendid success:(void (^)(id))success failure:(void (^)(NSString *))failure
 {
    [[TYZ_AFNet_Client sharedInstance] POST:[NSString stringWithFormat:@"rest/member/add-friend/%d",friendid] parameters:nil progress:^(NSProgress * _Nonnull uploadProgress)
     {
         NSLog(@"添加好友中");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     } ];
}

//新朋友列表

+(void) getNewqAllFriend:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] GET:@"rest/member/add-friend" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
         NSLog(@"新好友列表");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     }];
}


//同意或者拒绝好友
+(void) stateFriend:(int)friendid satus:(int)status success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] PUT:@"rest/member/add-friend" parameters:@{@"friend_id":@(friendid),@"status":@(status)}
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}

+(void)addFriendNO:(int)friendid success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] DELETE:[NSString stringWithFormat:@"rest/member/add-friend/%d",friendid] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}

//同意添加好友
+(void)addFriendYES:(int)friendid success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] PUT:[NSString stringWithFormat:@"rest/member/add-friend/%d",friendid] parameters:nil
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}

//删除好友
+(void)deleteFriend:(int)friendid success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] DELETE:[NSString stringWithFormat:@"rest/member/friend/%d",friendid] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}
//设置充电提醒

+(void)AddElectricity:(int)uid electricity:(int)electricity success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] POST:@"rest/device" parameters:@{@"customer_id":@(uid),@"electricity":@(electricity)} progress:^(NSProgress * _Nonnull uploadProgress)
    {
     NSLog(@"设置充电提醒");
    }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    } ];
}

//修改电话
+(void)setCellphone:(NSString *)cellphone success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] PUT:@"rest/member/user-reviser" parameters:@{@"cellphone":cellphone}
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}

//修改邮箱
+(void)setEmail:(NSString *)email success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] PUT:@"rest/member/user-reviser" parameters:@{@"email":email}
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}

//修改昵称
+(void)setNickname:(NSString *)nickname success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] PUT:@"rest/member/user-reviser" parameters:@{@"realname":nickname}
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}

//修改头像
+(void)setHeading:(NSString *)headimage success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] PUT:@"rest/member/user-reviser" parameters:@{@"headimg":headimage}
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}

//添加设备
+(void)addDevice:(NSString *)device :(NSString *)deviceName success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
//    NSLog(@"device - %@ devicename - %@",device,deviceName);
    
    [[TYZ_AFNet_Client sharedInstance] POST:@"rest/device/devices" parameters:@{@"address":device,@"name":deviceName} progress:^(NSProgress * _Nonnull uploadProgress)
     {
         NSLog(@"添加设备");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
         NSLog(@"error - %@",error);
     } ];
}

//解绑设备
+(void)delectDevice:(NSString *)device success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] POST:@"rest/device/devicesDelete" parameters:@{@"address":device} progress:^(NSProgress * _Nonnull uploadProgress)
     {
         NSLog(@"解绑设备");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     } ];
}

//查询设备列表
+(void)devicesList:(NSString *)customer_id success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] POST:@"rest/device/devicesList" parameters:@{@"customer_id":customer_id} progress:^(NSProgress * _Nonnull uploadProgress)
     {
         NSLog(@"网络设备列表");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     } ];
}
//更改设备名称
+(void)updateName:(NSString *)device :(NSString *)name success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] POST:@"rest/device/updateName" parameters:@{@"address":device,@"name":name} progress:^(NSProgress * _Nonnull uploadProgress)
     {
         NSLog(@"更改设备名称");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     } ];
}

//获取设备可用固件列表
+(void)device_update:(NSString *)device_id success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] POST:@"rest/device/device_update" parameters:@{@"device_id":device_id} progress:^(NSProgress * _Nonnull uploadProgress)
     {
         NSLog(@"获取设备可用固件列表");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     } ];
}


//记录每一条数据
+(void)recordData:(int)deviceid startime:(int)startime endtime:(int)endtime day:(NSDate *)day time:(int)time longitude:(float)longitude latitude:(float) latitude success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] POST:@"rest/member/record" parameters:@{@"device_id":@(deviceid),@"start_time":@(startime),@"end_time":@(endtime),@"second":@(time),@"day":day,@"longitude":@(longitude),@"latitude":@(latitude)} progress:^(NSProgress * _Nonnull uploadProgress)
     {
         NSLog(@"记录每一条数据");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     } ];
}

//获取吸烟记录
+(void)getRecordData:(NSString *)type  success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] GET:[NSString stringWithFormat:@"rest/member/record?type=%@",type] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
    {
        NSLog(@"获取吸烟记录");
    }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}

//获取吸烟记录下一级具体数据
+(void)getRecordAllData:(NSString *)type time:(NSString *)time  success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] GET:[NSString stringWithFormat:@"rest/member/record?type=%@&date=%@",type,time] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
         NSLog(@"获取吸烟记录下一级具体数据");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     }];
}


//设置吸烟计划
+(void)somkePlan:(int)mymouth price:(int)price smokemouth:(int)smokemouth  success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] PUT:@"rest/member/plan" parameters:@{@"my_mouth":@(mymouth),@"price":@(price),@"smoke_mouth":@(smokemouth)}
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}

//读取吸烟计划
+(void)readSomkePlan:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] GET:@"rest/member/plan" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
    {
        NSLog(@"读取吸烟计划");
    }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}


//每周设置
+(void)setWeek:(id)days success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] PUT:@"rest/device/day" parameters:days
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}

//读取每周记录
+(void)readWeek:(NSString *)days success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] GET:[NSString stringWithFormat:@"rest/device/day?days=%@",days] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
         NSLog(@"读取每周记录");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     }];
}

//月份设置
+(void)setMonth:(int)months mouth:(int)mouth success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] PUT:@"rest/device/month" parameters:@{@"months":@(months),@"mouth":@(mouth)}
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}

//读取每月记录
+(void)readMonths:(NSString *)months success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] GET:[NSString stringWithFormat:@"rest/device/month?months=%@",months] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
         NSLog(@"读取每月记录");
     }
                                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
                                   failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     }];
}

//一天吸烟的记录
+(void)mapData:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance] GET:@"rest/member/record" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
         NSLog(@"读取一天吸烟的记录");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     }];
}

//获取当天的吸烟口数
+(void)daySmockCount:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    [[TYZ_AFNet_Client sharedInstance]  GET:@"rest/day-mouth" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
    {
//        NSLog(@"获取当天的吸烟口数");
    }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    }];
}

//获取当天的吸烟口数
+(void)getRCToken:(void (^)(id json))success failure:(void (^)(NSString *message))failure
{
    [[TYZ_AFNet_Client sharedInstance]  GET:@"rest/member/token" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
//         NSLog(@"获取当天的吸烟口数");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     }];
}

//上传离线信息
+(void)offlineArray:(NSArray *)items success:(void (^)(id))success failure:(void (^)(NSString *))failure{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    int i=0;
    for (OfflineInfo *off in items)
    {
        id v1 = @{@"device_id":@(off.deviceid),@"start_time":@([off.dates timeIntervalSince1970]),@"end_time":@([off.dates timeIntervalSince1970]+off.second),@"second":@(off.second),@"day":off.dates,@"longitude":@(off.longitude),@"latitude":@(off.latitude)};
        NSLog(@"%@",v1);
        [params setObject:v1 forKey:[NSString stringWithFormat:@"data[%@]",@(i)]];
        i++;
    }

    [[TYZ_AFNet_Client sharedInstance] POST:@"rest/device/offlinedata" parameters:params progress:^(NSProgress * _Nonnull uploadProgress)
    {
         NSLog(@"上传离线信息");
    }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure([NSString stringWithFormat:@"%@",error]);
    } ];
}

//获取硬件设备信息 - deviceVersion 硬件编号
+(void)getDeviceDataToNet:(int)deviceVersion success:(void (^)(id))success failure:(void (^)(NSString *))failure
{
    AFHTTPSessionManager *httpSessionManager = [[AFHTTPSessionManager alloc] init];
    
    [httpSessionManager POST:@"http://www.uvapour.com:8080/stwServices/stw/web/getbinbyid" parameters:@{@"deviceid":@(deviceVersion)} progress:^(NSProgress * _Nonnull uploadProgress)
     {
         NSLog(@"查询适合的升级文件");
     }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         success(responseObject);
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         failure([NSString stringWithFormat:@"%@",error]);
     } ];
}

@end
