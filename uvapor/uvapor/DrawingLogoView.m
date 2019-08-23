//
//  DrawingLogoView.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/27.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "DrawingLogoView.h"

#define LEFT_TYPE 1
#define RIGHT_TYPE 0

@implementation DrawingLogoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

//初始化设置
- (id)initWithFrame:(CGRect)frame :(LogoClass *)logoClass
{
    self = [self initWithFrame:frame];
    
    if (self)
    {
        //初始化
        _box_size = logoClass.boxSize;               //box的宽高

        _wightsize = logoClass.drawingBoard_width;   //box的宽度个数
        _heightsize = logoClass.drawingBoard_height;  //box的高度个数
        
        _box_arry_data = [NSMutableArray array];
        
        for (NSString *str_point in logoClass.logo_arrys)
        {
            [_box_arry_data addObject:str_point];
        }
        
        if (_box_arry_data.count != (_heightsize * _wightsize))
        {
            _box_arry_data = [NSMutableArray array];
            
            for(int i = 0;i <= (_heightsize * _wightsize);i++)
            {
                [_box_arry_data addObject:[NSString stringWithFormat:@"%d",RIGHT_TYPE]];
            }
        }
        
        _start_j = 0;
        _end_j = _heightsize;
        _start_i = 0;
        _end_i = _wightsize;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //画所有格子
    for (int j = _start_j; j < _end_j; j++)
    {
        for (int i  = _start_i; i < _end_i; i ++)
        {
            if ([[_box_arry_data objectAtIndex:(j * _wightsize + i)] intValue] == 1)
            {
                [self drawing_view:i*_box_size :j*_box_size :_box_size :_box_size :[UIColor greenColor] :[UIColor lightGrayColor]];
            }
            else
            {
                [self drawing_view:i*_box_size :j*_box_size :_box_size :_box_size :[UIColor blackColor] :[UIColor lightGrayColor]];
            }
        }
    }
}

//手指触摸的状态
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"手指开始点击状态");
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    //    NSLog(@"(%f,%f)",point.x,point.y);
    
    CGPoint point_return = [self check_point_line:point];
    
    int box_num = (point_return.x) + (point_return.y * _wightsize);
    
    if (point_return.x >= 0 && point_return.x <= _wightsize && point_return.y >= 0 && point_return.y < _heightsize)
    {
        NSLog(@"num - > %d",box_num);
        
        [_box_arry_data replaceObjectAtIndex:box_num withObject:[NSString stringWithFormat:@"%d",LEFT_TYPE]];
        
        _start_point = point_return;
        
        //    [self setNeedsDisplay:YES];
        [self refresh_view:_start_point :point_return];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"手指移动状态");
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    //    NSLog(@"(%f,%f)",point.x,point.y);
    
    CGPoint point_return = [self check_point_line:point];
    
    int box_num = (point_return.x) + (point_return.y * _wightsize);
    
    if (point_return.x >= 0 && point_return.x <= _wightsize && point_return.y >= 0 && point_return.y < _heightsize)
    {
        NSLog(@"num - > %d",box_num);
        
        [_box_arry_data replaceObjectAtIndex:box_num withObject:[NSString stringWithFormat:@"%d",LEFT_TYPE]];
        
        [self drawLine:_start_point :point_return :LEFT_TYPE];
        
        //     [self setNeedsDisplay:YES];
        [self refresh_view:_start_point :point_return];
        
        _start_point = point_return;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"手指离开状态");
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    //    NSLog(@"(%f,%f)",point.x,point.y);
    
    CGPoint point_return = [self check_point_line:point];
    
    int box_num = (point_return.x) + (point_return.y * _wightsize);
    
    if (point_return.x >= 0 && point_return.x <= _wightsize && point_return.y >= 0 && point_return.y < _heightsize)
    {
        NSLog(@"num - > %d",box_num);
        
        [_box_arry_data replaceObjectAtIndex:box_num withObject:[NSString stringWithFormat:@"%d",LEFT_TYPE]];
        
        [self drawLine:_start_point :point_return :LEFT_TYPE];
        
        //    [self setNeedsDisplay:YES];
        [self refresh_view:_start_point :point_return];
    }

}

-(CGPoint)check_point_line:(CGPoint)point
{
    int x = point.x / _box_size;
    int y = point.y / _box_size;
    
    NSLog(@"touch (x, y) is (%d, %d)", x, y);
    
    if (x >= 0 && x <= _wightsize && y >= 0 && y <= _heightsize)
    {
        CGPoint point_box = CGPointMake(x, y);
        
        return point_box;
    }
    
    CGPoint point_box_0 = CGPointMake(-1, -1);
    
    return point_box_0;
}

//画一个带边框矩形
-(void)drawing_view:(int) x_point :(int) y_point :(int) wight  :(int) height :(UIColor*) fillColor  :(UIColor*) lineColor
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    //矩形，并填弃颜色
    CGContextSetLineWidth(context, 1.0);//线的宽度
    
    CGContextSetFillColorWithColor(context, fillColor.CGColor);//填充颜色
    
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);//线框颜色
    
    CGContextAddRect(context,CGRectMake(x_point, y_point, wight, height));//画方框
    
    CGContextDrawPath(context, kCGPathFillStroke);//绘画路径
}

-(void)refresh_view:(CGPoint)start_Point :(CGPoint)end_Point
{
    /******************计算局部刷新大小********************/
    _start_i = [self check_min:_start_point.x :end_Point.x];
    _start_j = [self check_min:_start_point.y :end_Point.y];
    
    _end_i = (fabs(start_Point.x - end_Point.x) + 1) + _start_i;
    _end_j = (fabs(start_Point.y - end_Point.y) + 1) + _start_j;
    
    int rect_x = [self check_min:_start_point.x :end_Point.x] * _box_size;
    int rect_y = [self check_min:_start_point.y :end_Point.y] * _box_size;
    int rect_weight = (fabs(start_Point.x - end_Point.x) + 1) * _box_size;
    int rect_height = (fabs(start_Point.y - end_Point.y) + 1)* _box_size;
    
    /******************局部刷新********************/
    CGRect rect = CGRectMake(rect_x, rect_y, rect_weight, rect_height);
    [self setNeedsDisplayInRect:rect];
    /********************************************/
}

//取得两个数中较小的一个数
-(int)check_min:(int)p_x :(int)p_y
{
    if (p_x > p_y)
    {
        return p_y;
    }
    else
    {
        return p_x;
    }
}

//补充丢失的点 - 连线
-(void)drawLine:(CGPoint)start_Point :(CGPoint)end_Point :(int)point_type
{
    int k = (int)(sqrt(pow(fabs(start_Point.x - end_Point.x), 2) + pow(fabs(start_Point.y - end_Point.y), 2))) + 1;
    
    if (fabs(start_Point.x - end_Point.x) >= 1 || fabs(start_Point.y - end_Point.y) >= 1)
    {
        for (int i = 0; i < k; i++)
        {
            int x = 0, y = 0;
            x = start_Point.x + (end_Point.x - start_Point.x) * i / k;
            y = start_Point.y + (end_Point.y - start_Point.y) * i / k;
            if (x < _wightsize && y < _heightsize && x >= 0 && y >= 0)
            {
                CGPoint point = CGPointMake(x, y);
                [self drawMap:point :point_type];
            }
        }
    }
}

//画点
-(void)drawMap:(CGPoint)point :(int)point_type
{
    if (point.x < _wightsize && point.y < _heightsize && point.x >= 0 && point.y >= 0)
    {
        int box_num = (point.x) + (point.y * _wightsize);
        
        [_box_arry_data replaceObjectAtIndex:box_num withObject:[NSString stringWithFormat:@"%d",point_type]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
