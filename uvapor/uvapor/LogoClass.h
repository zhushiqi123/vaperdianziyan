//
//  LogoClass.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/27.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogoClass : NSObject

@property (assign,nonatomic) int drawingBoard_width;   //屏幕宽
@property (assign,nonatomic) int drawingBoard_height;  //屏幕高

@property (assign,nonatomic) int boxSize;  //像素点大小

@property (assign,nonatomic) int drawing_type; //屏幕类型
@property (assign,nonatomic) int drawing_way;  //取模方式

@property (assign,nonatomic) int image_type;   //图片用途  0 - 开机LOGO  1 - 无负载提示  2 - 短路提示  3 - 负载过大提示

@property (assign,nonatomic) int image_foreground_color;   //图片前景色
@property (assign,nonatomic) int image_background_color;   //图片背景色

@property (assign,nonatomic) int coordinates_x;   //起始坐标点 x
@property (assign,nonatomic) int coordinates_y;   //起始坐标点 y

@property(nonatomic,retain) NSMutableArray *logo_arrys;  //图片点阵数组

@end
