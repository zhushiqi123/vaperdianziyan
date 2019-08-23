//
//  AppDelegate.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/13.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *appKey = @"3cebac42805730387bddb385";
static NSString *channel = @"uVapor";
static BOOL isProduction = FALSE;  //开发环境 FALSE  发布生产环境 True

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

