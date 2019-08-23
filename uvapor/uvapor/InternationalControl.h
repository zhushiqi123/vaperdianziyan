//
//  InternationalControl.h
//  test_language
//
//  Created by bct11-macmini on 15/6/9.
//  Copyright (c) 2015年 bct11-macmini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InternationalControl : NSObject

+(NSBundle *)bundle;//获取当前资源文件

+(void)initUserLanguage;//初始化语言文件

+(NSString *)userLanguage;//获取应用当前语言

+(void)setUserlanguage:(NSString *)language;//设置当前语言

//设置语言
+(NSString *)return_string:(NSString *)keys;

//设置新手模式开关
+(NSString *)set_green_hand_status:(NSString *)keys;
//获取新手模式开关
+(NSString *)get_green_hand_status;


@end
