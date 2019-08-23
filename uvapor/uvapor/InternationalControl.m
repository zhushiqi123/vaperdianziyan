//
//  InternationalControl.m
//  test_language
//
//  Created by bct11-macmini on 15/6/9.
//  Copyright (c) 2015年 bct11-macmini. All rights reserved.
//

#import "InternationalControl.h"
#import "Session.h"

@implementation InternationalControl

static NSBundle *bundle = nil;

+(NSBundle * )bundle
{
    return bundle;
}

+(void)initUserLanguage
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *string = [def valueForKey:@"userLanguage"];
    
    if(string.length == 0)
    {
        //获取系统当前语言版本(中文zh-Hans,英文en)
        
        NSArray* languages = [def objectForKey:@"AppleLanguages"];
        
        NSString *current = [languages objectAtIndex:0];
        
        /**ios9适配 change by Tian Yangzhu 2015/10/12**/
        
        //        NSLog(@"------>获得的语言%@",[current substringWithRange:NSMakeRange(0, 2)]);
        
        if ([[current substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"zh"])
        {
            current = @"zh-Hans";
            [Session sharedInstance].isLanguage = 1;
        }
        else
        {
            current = @"en";
            [Session sharedInstance].isLanguage = 0;
            
        }
//        NSLog(@"语言类型----->%d",[Session sharedInstance].isLanguage);
   
        //测试数据
//        current = @"en";
        
        string = current;
        
        [def setValue:current forKey:@"userLanguage"];
        
        [def synchronize];//持久化，不加的话不会保存
    }
    
//    string = @"en";

//    NSLog(@"string -- > %@",string);
    
    if ([string  isEqualToString:@"zh-Hans"])
    {
        [Session sharedInstance].isLanguage = 1;
    }
    else
    {
        [Session sharedInstance].isLanguage = 0;
    }
    
    //获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:string ofType:@"lproj"];
    
    bundle = [NSBundle bundleWithPath:path];//生成bundle
}

+(NSString *)userLanguage
{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *language = [def valueForKey:@"userLanguage"];
    
    return language;
}

+(void)setUserlanguage:(NSString *)language{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //1.第一步改变bundle的值
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj" ];
    
    bundle = [NSBundle bundleWithPath:path];
    
    //2.持久化
    [def setValue:language forKey:@"userLanguage"];
    
    [def synchronize];
}

//设置语言
+(NSString *)return_string:(NSString *)keys
{
    NSString *strs = [[InternationalControl bundle] localizedStringForKey:keys value:nil table:@"Localizable"];
    
    return strs;
}

//设置新手模式开关
+(NSString *)set_green_hand_status:(NSString *)keys
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:keys forKey:@"GreenHandStaus"];
    [def synchronize];//持久化，不加的话不会保存
    
    return keys;
}

//获取新手模式开关
+(NSString *)get_green_hand_status
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *mode_status = [def valueForKey:@"GreenHandStaus"];
    if ([mode_status isEqualToString:@"on"] || [mode_status isEqualToString:@"off"])
    {
        return mode_status;
    }
    else
    {
        return @"on";
    }
}

@end
