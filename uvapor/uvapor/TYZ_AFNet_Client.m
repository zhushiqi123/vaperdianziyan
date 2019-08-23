//
//  TYZ_AFNet_Client.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/21.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "TYZ_AFNet_Client.h"

@interface TYZ_AFNet_Client()

@property(nonatomic,copy) NSString *appId;
@property(nonatomic,copy) NSString *secret;
@property(nonatomic,copy) NSString *deviceId;

@end

@implementation TYZ_AFNet_Client

static TYZ_AFNet_Client *shareInstance = nil;

+(TYZ_AFNet_Client *) sharedInstance
{
    if (!shareInstance)
    {
        NSLog(@"TYZ_AFNet_Client 没有初始化");
    }
    return shareInstance;
}

+(void)initInstance:(NSString *)appid secret:(NSString *)secret baseUrl:(NSString *)url
{
    if (!shareInstance)
    {
        //网络请求URL头
        shareInstance = [[TYZ_AFNet_Client alloc] initWithBaseURL:[NSURL URLWithString:url]];
        //网络请求携带的appID
        shareInstance.appId = appid;
        //网络请求携带的秘钥
        shareInstance.secret = secret;
        //网络请求携带的UUID
        NSLog(@"设备的UUID -- %@ ",[[[UIDevice currentDevice] identifierForVendor] UUIDString]);
        shareInstance.deviceId = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] og_stringUsingCryptoHashFunction:OGCryptoHashFunctionMD5];
        [shareInstance updateAuthorization];
        [shareInstance AFNetworkStatus];
    }
}
-(void)setUserID:(int)uid
{
    self.uid = uid;
    [self updateAuthorization];
}

-(void)updateAuthorization
{
    NSString *time = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    NSString *key = [[NSString stringWithFormat:@"%@%@",self.secret,time] og_stringUsingCryptoHashFunction:OGCryptoHashFunctionMD5];
    NSString *username = [NSString stringWithFormat:@"%d-%@-%@-%@",self.uid,self.appId,time,self.deviceId];
    NSString *pwd = [username og_stringUsingCryptoHashFunction:OGCryptoHashFunctionSHA256 hmacSignedWithKey:key];
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:pwd];
}

- (void)AFNetworkStatus
{
    //1.创建网络监测者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /*枚举里面四个状态  分别对应 未知 无网络 数据 WiFi
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,      未知
     AFNetworkReachabilityStatusNotReachable     = 0,       无网络
     AFNetworkReachabilityStatusReachableViaWWAN = 1,       蜂窝数据网络
     AFNetworkReachabilityStatusReachableViaWiFi = 2,       WiFi
     };
     */
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
        //这里是监测到网络改变的block  可以写成switch方便
        //在里面可以随便写事件
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络状态");
                [TYZ_AFNet_Client sharedInstance].status_AFNetwork = 0;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无网络");
                [TYZ_AFNet_Client sharedInstance].status_AFNetwork = 0;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝数据网");
                [TYZ_AFNet_Client sharedInstance].status_AFNetwork = 1;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi网络");
                [TYZ_AFNet_Client sharedInstance].status_AFNetwork = 1;
                break;
                
            default:
                break;
        }
    }] ;
    
    [manager startMonitoring];
}

@end
