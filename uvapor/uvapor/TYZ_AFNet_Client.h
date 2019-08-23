//
//  TYZ_AFNet_Client.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/21.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface TYZ_AFNet_Client : AFHTTPSessionManager

@property(nonatomic,assign) int uid;

@property(nonatomic,assign) int status_AFNetwork;

+ (TYZ_AFNet_Client *)sharedInstance;

+(void)initInstance:(NSString *)appid secret:(NSString *)secret baseUrl:(NSString *)url;

-(void)setUserID:(int)uid;

@end
