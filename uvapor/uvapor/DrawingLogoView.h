//
//  DrawingLogoView.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/27.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogoClass.h"

@interface DrawingLogoView : UIView
{
@private
    int box_Side;
    
    float PowerView_Width;
    float PowerView_Height;
}

@property (nonatomic,assign) int box_size;               //box的宽高

@property (nonatomic,assign) int wightsize;              //box的宽度个数
@property (nonatomic,assign) int heightsize;             //box的高度个数

@property (nonatomic,assign) CGPoint start_point;        //画线开始点

@property (nonatomic,assign) int start_i;                //开始绘图坐标x
@property (nonatomic,assign) int start_j;                //开始绘图坐标y
@property (nonatomic,assign) int end_i;                  //结束绘图坐标x
@property (nonatomic,assign) int end_j;                  //结束绘图坐标y

@property (nonatomic,retain) NSMutableArray *box_arry_data;   //画图的数据点


//初始化设置
- (id)initWithFrame:(CGRect)frame :(LogoClass *)logoClass;

@end
