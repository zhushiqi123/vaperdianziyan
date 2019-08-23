//
//  PowerLineDrawingCellView.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/29.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "PowerLineDrawingCellView.h"
#import "LineCGPoint.h"

#define PI 3.14159265358979323846

@implementation PowerLineDrawingCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.check_num = 0;
    }
    return self;
}

//绘制背景
- (void)drawRect:(CGRect)rect
{
    /**---------------------------------------------绘制背景---------------------------------------------**/
    CGContextRef context = UIGraphicsGetCurrentContext();
    //背景图片颜色
    CGContextSetLineWidth(context, 0.3);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    
    int pos_x = 1;
    
    while (pos_x < PowerView_Width)
    {
        CGContextMoveToPoint(context, pos_x, 1);
        CGContextAddLineToPoint(context, pos_x, PowerView_Height);
        pos_x += box_Side_width;
        
        CGContextStrokePath(context);
    }
    
    CGFloat pos_y = PowerView_Height;
    while (pos_y >= 0)
    {
        CGContextSetLineWidth(context, 0.3);
        
        CGContextMoveToPoint(context, 1, pos_y);
        CGContextAddLineToPoint(context, PowerView_Width, pos_y);
        pos_y -= box_Side_height;
        
        CGContextStrokePath(context);
    }
    
    //绘制坐标系
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    //绘制横坐标
    CGContextMoveToPoint(context, 1, PowerView_Height - 1);
    CGContextAddLineToPoint(context, PowerView_Width,PowerView_Height - 1);
    
    CGContextStrokePath(context);
    
    //绘制纵坐标
    CGContextMoveToPoint(context, 1, 1);
    CGContextAddLineToPoint(context, 1, PowerView_Height);
    
    CGContextStrokePath(context);
    
    //绘制横坐标点
    CGFloat pos_x_coordinates = PowerView_Height;
    while (pos_x_coordinates > 0)
    {
        CGContextSetLineWidth(context, 1);
        
        CGContextMoveToPoint(context, 1, pos_x_coordinates);
        CGContextAddLineToPoint(context, box_Side_width/2, pos_x_coordinates);
        pos_x_coordinates -= box_Side_height;
        
        CGContextStrokePath(context);
    }
    
    //绘制纵坐标点
    int pos_y_coordinates = 1;
    
    while (pos_y_coordinates < PowerView_Width)
    {
        CGContextMoveToPoint(context, pos_y_coordinates, PowerView_Height - 1);
        CGContextAddLineToPoint(context, pos_y_coordinates, (PowerView_Height - box_Side_height/2 + 1));
        pos_y_coordinates += box_Side_width;
        
        CGContextStrokePath(context);
    }
    
    /**---------------------------绘制背景完成---------------------------**/
    
    /*--------------------------------画线--------------------------------*/
    //枚举遍历  相当于java中的增强for循环
    for (LineCGPoint *linePoint in _array_CustomData)
    {
        CGContextRef cxt = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(cxt, 0, 0, 0, 1);
        
        CGPoint retrievedPoint = CGPointMake(linePoint.line_x_w, linePoint.line_y_h);
        
        CGPoint check_pointd;
        if (_point_end.x >= 0)
        {
            check_pointd = CGPointMake(_point_end.x, _point_end.y);
        }
        else
        {
            check_pointd = retrievedPoint;
        }
        
        /*-------画两点之间的连线------*/
        _point_start = check_pointd;
        _point_end = retrievedPoint;
        
        if(_point_end.x > _point_start.x)
        {
            //NSLog(@"-->(%f,%f)----(%f,%f)",_point_start.x,_point_start.y,_point_end.x,_point_end.y);
            // 1.获得图形上下文
            CGContextRef ctxs = UIGraphicsGetCurrentContext();
            
            // 2.拼接图形(路径)
            // 设置线段宽度
            CGContextSetLineWidth(ctxs,2);
            
            // 设置线段头尾部的样式
            CGContextSetLineCap(ctxs,kCGLineCapRound);
            
            // 设置线段转折点的样式
            CGContextSetLineJoin(ctxs,kCGLineJoinRound);
            
            // 设置颜色
            CGContextSetRGBStrokeColor(ctxs, 1, 1, 1, 1);
            // 设置一个起点
            CGContextMoveToPoint(ctxs, _point_start.x,_point_start.y);
            // 添加一条线段
            CGContextAddLineToPoint(ctxs,_point_end.x,_point_end.y);
            //        CGContextAddQuadCurveToPoint(context, _point_start.x, _point_start.y, _point_end.x, _point_end.y);
            
            // 渲染一次
            CGContextStrokePath(ctxs);
        }
        /*-------画两点之间的连线------*/
        
        //        float x = retrievedPoint.x - 4;
        //        float y = retrievedPoint.y - 4;
        
        //画图每个点
        //        CGContextFillRect(cxt, CGRectMake(x,y,8.0f,8.0f));
        
        UIColor*aColor = [UIColor whiteColor];
        CGContextSetFillColorWithColor(cxt, aColor.CGColor);//填充颜色
        CGContextAddArc(cxt, retrievedPoint.x, retrievedPoint.y, 2, 0, 2*PI, 0); //添加一个圆
        CGContextDrawPath(cxt, kCGPathFillStroke); //绘制路径加填充
        
        CGContextStrokePath(cxt);
    }
    
    /*------------------------------画线完成--------------------------------*/
    
    /*------------------------------画手指点击的点--------------------------------*/
    if (_point_num > 0)
    {
        LineCGPoint *linePoint = [_array_CustomData objectAtIndex:_point_num];
        
        CGPoint retrievedPoint = CGPointMake(linePoint.line_x_w, linePoint.line_y_h);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIColor*aColor = [UIColor colorWithRed:1 green:0.0 blue:0 alpha:1];
        CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
        CGContextSetLineWidth(context, 3.0);//线的宽度
        CGContextAddArc(context, retrievedPoint.x, retrievedPoint.y, 6, 0, 2*PI, 0); //添加一个圆
        //kCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线，不是填充
        CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充  //        //填充圆，无边框
        //        CGContextAddArc(context, 150, 30, 30, 0, 2*PI, 0); //添加一个圆
        //        CGContextDrawPath(context, kCGPathFill);//绘制填充
        CGContextStrokePath(context);
    }
    /*------------------------------画手指点击的点完成--------------------------------*/
}

//初始化设置
- (id)initWithFrame:(CGRect)frame :(int)box_width :(int)box_height :(int)arry_type :(NSMutableArray *)setArrys
{
    self = [self initWithFrame:frame];
    
    if (self)
    {
        //初始化，表盘所表示的最大最小值
        box_Side_width = box_width;
        box_Side_height = box_height;
        
        PowerView_Width = frame.size.width;
        PowerView_Height = frame.size.height;
        
        _arry_type = arry_type;
        
        if (setArrys.count == 23)
        {
            _array_CustomData = [NSMutableArray array];
            
            for(LineCGPoint *chosePoint in setArrys)
            {
                if (chosePoint.line_x_w < 22)
                {
                    float chose_x = chosePoint.line_x_w * box_Side_width;
                    
                    float chose_y =  ((1 - chosePoint.line_y_h) * (PowerView_Height - box_Side_height)) + box_Side_height;
                    
                    LineCGPoint *CustomchosePoint = [[LineCGPoint alloc] init];
                    
                    CustomchosePoint.line_x_w = chose_x;
                    CustomchosePoint.line_y_h = chose_y;
                    
                    [_array_CustomData addObject:CustomchosePoint];
                }
            }
            self.point_num = 21;
            self.check_num = 21;
        }
        else
        {
            self.point_num = 0;
            self.check_num = 0;
            
            _array_CustomData = [NSMutableArray array];
            
            LineCGPoint *linePoint = [[LineCGPoint alloc] init];
            linePoint.line_x_w = 0;
            linePoint.line_y_h = 11 * box_Side_height;
            
            [_array_CustomData addObject:linePoint];
        }
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
