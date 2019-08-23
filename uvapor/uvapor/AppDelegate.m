//
//  AppDelegate.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/13.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "AppDelegate.h"
#import "TYZ_AFNet_Client.h"
#import "Session.h"
#import "STW_BLE_SDK.h"
#import "TYZFileData.h"
#import "STW_BLEService.h"
#import "InternationalControl.h"
#import "DB_Sqlite3.h"
#import "JPUSHService.h"
#import "JPushMessage.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()//<JPUSHRegisterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    //初始化数据库
//    [DB_Sqlite3 sharedInstance];
//    
//    //先删除掉时间过长的数据
//    [DB_Sqlite3 Delete_MoreData_JPushMsg];
    
    //-------------------- 加入极光推送 --------------------
//    //初始化极光推送
//    [Session sharedInstance].isJPush = 0;
//    // Required
//    // notice: 3.0.0及以后版本注册可以这样写,也可以继续 旧的注册 式
//    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
//    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
//    {
//        if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0)
//        {
//          NSSet<UNNotificationCategory *> *categories;
//          entity.categories = categories;
//        }
//        else
//        {
//          NSSet<UIUserNotificationCategory *> *categories;
//          entity.categories = categories;
//        }
//    }
//    
//    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
//    
//    //如不需要使用IDFA，advertisingIdentifier 可为nil
//    [JPUSHService setupWithOption:launchOptions appKey:appKey
//                          channel:channel       //不需要其他功能nil
//                 apsForProduction:isProduction     //开发环境FALSE
//            advertisingIdentifier:nil];     //不需要广告功能nil
//    
//    //2.1.9版本新增获取registration id block接口。
//    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID)
//    {
//        if(resCode == 0)
//        {
//            NSLog(@"registrationID获取成功：%@",registrationID);
//            
//        }
//        else
//        {
//            NSLog(@"registrationID获取失败，code：%d",resCode);
//        }
//    }];
    //-------------------- 极光推送加载结束 --------------------
    
    // Override point for customization after application launch.
    
    // 初始化语言
    [InternationalControl initUserLanguage];
    
//    //初始化新手模式开关
//    [STW_BLE_SDK STW_SDK].greenhand_on_off =  [InternationalControl get_green_hand_status];
    
    //初始化初始界面
    [STW_BLE_SDK STW_SDK].voumebarType = BLEProtocolModeTypePower;
    [STW_BLE_SDK STW_SDK].weightType_left = BLEProtocolModeTypeTemperature;
    [STW_BLE_SDK STW_SDK].weightType_right = BLEProtocolModeTypeVoltage;
    
    [STW_BLE_SDK STW_SDK].power = 10;
    [STW_BLE_SDK STW_SDK].voltage = 0;
    [STW_BLE_SDK STW_SDK].temperature = 200;
    [STW_BLE_SDK STW_SDK].temperatureMold = BLEProtocolTemperatureUnitFahrenheit;
    [STW_BLE_SDK STW_SDK].vaporModel = BLEProtocolModeTypePower;
    [STW_BLE_SDK STW_SDK].curvePowerModel = BLEProtocolCustomLineCommand01;
    
    [STW_BLE_SDK STW_SDK].vaporStatus = 0x00;  //开始并没有吸烟
    
    [STW_BLE_SDK STW_SDK].max_power = 80;   //当前的设备最大功率值
    
    [STW_BLE_SDK STW_SDK].voumebarMax = 80;
    [STW_BLE_SDK STW_SDK].voumebarMin = 1;
    
    //是否正在升级
    [STW_BLE_SDK STW_SDK].Update_Now = 0;
    
    //初始化
//    [STW_BLEService initInstance];
    //初始化吸烟
    [STW_BLEService sharedInstance].isVaporNow = NO;
    //初始化蓝牙检测
    [STW_BLEService sharedInstance].isReadyScan = YES;
    //蓝牙还未连接
    [STW_BLEService sharedInstance].isBLEStatus = NO;
    //蓝牙断开
    [STW_BLEService sharedInstance].isBLEType = STW_BLE_IsBLETypeOff;
#warning  网络地址的切换
    //初始化网络连接
    [TYZ_AFNet_Client initInstance:@"f046fffc913a01482c585f553ed91381" secret:@"6ff16bc1ede69e46663bfd6cffaa29cb" baseUrl:@"http://120.24.175.35/uvapor-web/public/"];
   // [TYZ_AFNet_Client initInstance:@"f046fffc913a01482c585f553ed91381" secret:@"6ff16bc1ede69e46663bfd6cffaa29cb" baseUrl:@"http://www.uvapour.com/uvapor-web/public/"];
    
    //初始化用户Session
    [[TYZ_AFNet_Client sharedInstance] setUserID:0];
    
    //检测用户是否存在进行自动登录
    [self performSelector:@selector(UserLogin) withObject:nil afterDelay:0.5f];
    
    return YES;
}

/*********************************** 极光推送配置 *****************************************/
////极光推送回调上报极光服务器deviceToken
//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//{
////    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
//    //回调上报极光服务器deviceToken
//    [JPUSHService registerDeviceToken:deviceToken];
//}
//
////极光推送APNs 注册失败
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//{
//    //Optional
//    NSLog(@"APNs 注册失败 -> did Fail To Register For Remote Notifications With Error: %@", error);
//}
//
//#pragma mark - JPUSHRegisterDelegate
////**************** 获取APNS消息 *******************
//// iOS 10 Support
//- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler
//{
//    // Required
//    NSDictionary * userInfo = notification.request.content.userInfo;
//    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
//    {
//        [JPUSHService handleRemoteNotification:userInfo];
//    }
//    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
//    //获取到了APNS消息
//    [self doAPNSMessage:@"10.1" :userInfo];
//}
//
//// iOS 10 Support
//- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
//{
//    // Required
//    NSDictionary * userInfo = response.notification.request.content.userInfo;
//    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
//    {
//        [JPUSHService handleRemoteNotification:userInfo];
//    }
//    completionHandler();  // 系统要求执行这个方法
//    //获取到了APNS消息
//    [self doAPNSMessage:@"10.2" :userInfo];
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    // Required, iOS 7 Support
//    [JPUSHService handleRemoteNotification:userInfo];
//    completionHandler(UIBackgroundFetchResultNewData);
//    
//    //获取到了APNS消息
//    [self doAPNSMessage:@"7 - 9" :userInfo];
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    // Required,For systems with less than or equal to iOS6
//    [JPUSHService handleRemoteNotification:userInfo];
//    
//    //获取到了APNS消息
//    [self doAPNSMessage:@"6" :userInfo];
//}
////处理获取到的APNS消息
//-(void)doAPNSMessage:(NSString *)iosVersion :(NSDictionary *)userInfo
//{
//    NSLog(@"ios %@ - 收到推送消息 ： %@",iosVersion,[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
//    //处理ASPN消息
//}
////**************** 获取APNS消息结束 *******************
/********************************** 极光推送配置完成 ******************************************/

-(void)UserLogin
{
    User *userDit = [TYZFileData GetUserData];
    
    if (userDit.cellphone)
    {
        [User login:userDit.cellphone password:userDit.password success:^(User *user)
         {
             //登录成功
             user.password = userDit.password;
             
             [Session sharedInstance].user = user;
             
             [[TYZ_AFNet_Client sharedInstance]setUserID:user.uid];
             
             //获取用户存储的各种信息
             NSString *string = [NSString stringWithFormat:@"%d",[Session sharedInstance].user.uid];
             [User devicesList:string success:^(id data)
            {
                //将字典数组转为Device模型数组
                [Session sharedInstance].deviceArrys = [Device mj_objectArrayWithKeyValuesArray:data];

                //保存网络数据到本地
                [TYZFileData SaveDeviceData:[Session sharedInstance].deviceArrys];
            }
            failure:^(NSString *message)
            {
                //没有绑定的设备
                [Session sharedInstance].deviceArrys = [NSMutableArray array];
                //保存网络数据到本地
                [TYZFileData SaveDeviceData:[Session sharedInstance].deviceArrys];
            }];
             
             //保存账号密码到本地
             [TYZFileData SaveUserData:user];
         }
         failure:^(NSString *error)
         {
             if([error intValue] == 400)
             {
                 NSLog(@"网络不可用");
                 //取出本地的设备
                 [Session sharedInstance].deviceArrys = [TYZFileData GetDeviceData];
             }
             else
             {
                 NSLog(@"账户名或者密码错误");
             }
         }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"APP - applicationDidEnterBackground");
    
    if ([STW_BLE_SDK STW_SDK].Update_Now == 1)
    {
        [STW_BLE_SDK STW_SDK].Update_Now = 0;
    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

//当应用程序入活动状态执行
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //先删除掉时间过长的数据
    [DB_Sqlite3 Delete_MoreData_JPushMsg];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"APP - applicationWillEnterForeground");
    if([STW_BLEService sharedInstance].isBLEStatus)
    {
        //查询所有配置信息
        [STW_BLE_Protocol the_find_all_data];
        //延时设置设备时间
        [self performSelector:@selector(setDeviceTime) withObject:nil afterDelay:0.2f];
    }
}

//当程序从后台将要重新回到前台时候调用，这个刚好跟上面的那个方法相反。
- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"程序进入-----------applicationWillTerminate---------->5");
}

//设置设备系统时间
-(void)setDeviceTime
{
//    NSLog(@"进行时间设置");
    //设置
    [STW_BLE_Protocol the_set_time];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

@end
