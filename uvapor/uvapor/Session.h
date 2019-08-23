//
//  Session.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/21.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Session : NSObject

//用户数据
@property(nonatomic,retain) User *user;
//用户语言数据 - 1 - 中文
@property(nonatomic,assign) int isLanguage;
//用户设备列表数据
@property(nonatomic,retain) NSMutableArray *deviceArrys;

//用户吸烟列表数据
@property(nonatomic,retain) NSMutableArray *recordMouthArrys;

//用户朋友列表数据
@property(nonatomic,retain) NSMutableArray *friendsArrys;

//获取用户当天吸烟口数
@property(nonatomic,assign) NSUInteger total;
//计划吸烟口数
@property(nonatomic,assign) int smokeCount;

//极光推送 0 - 登录失败   1 - 登录成功
@property(nonatomic,assign) int isJPush;

+ (Session *)sharedInstance;

@end
