
//  DrawingPowerLineView.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/26.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "DrawingPowerLineView.h"

#define PI 3.14159265358979323846

@implementation DrawingPowerLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.check_num = 0;
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame :(int)box :(int)arry_type :(NSMutableArray *)setArrys
{
    self = [self initWithFrame:frame];
    if (self)
    {
        //初始化，表盘所表示的最大最小值
        box_Side = box;
        
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
                    float chose_x = chosePoint.line_x_w * box_Side;
//                    float chose_y =  (1 - chosePoint.line_y_h) * PowerView_Height;
                    float chose_y =  ((1 - chosePoint.line_y_h) * (PowerView_Height - box_Side)) + box_Side;
                    
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
            _array_CustomData = [NSMutableArray array];
            
            LineCGPoint *linePoint = [[LineCGPoint alloc] init];
            linePoint.line_x_w = 0;
            linePoint.line_y_h = 11 * box_Side;
            
            [_array_CustomData addObject:linePoint];
        }
    }
    return self;
}

-(NSMutableArray *)getArryData
{
    NSMutableArray *returnArry = [NSMutableArray array];
    
    for (LineCGPoint *linePoint in _array_CustomData)
    {
        float line_x = (linePoint.line_x_w / box_Side);
        float line_y = (PowerView_Height - linePoint.line_y_h) / (PowerView_Height - box_Side);
        
//        NSLog(@"linePoint - (%f,%f)",line_x,line_y);
        
        LineCGPoint *linePoint_return = [[LineCGPoint alloc] init];
        
        linePoint_return.line_x_w = line_x;
        linePoint_return.line_y_h = line_y;
        
        [returnArry addObject:linePoint_return];
    }
    
    //用Array最后一位代表是哪一条曲线
    
    LineCGPoint *linePoint_return_last = [[LineCGPoint alloc] init];
    
    linePoint_return_last.line_x_w = 22;
    linePoint_return_last.line_y_h = _arry_type;
    
    [returnArry addObject:linePoint_return_last];
    
    return returnArry;
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
        pos_x += box_Side;
        
        CGContextStrokePath(context);
    }
       
    CGFloat pos_y = PowerView_Height;
    while (pos_y >= 0)
    {
        CGContextSetLineWidth(context, 0.3);
        
        CGContextMoveToPoint(context, 1, pos_y);
        CGContextAddLineToPoint(context, PowerView_Width, pos_y);
        pos_y -= box_Side;
        
        CGContextStrokePath(context);
    }
    
    CGContextSetLineWidth(context, 0.1);

    float _cell_width = box_Side / 5;

    pos_x = _cell_width;
    while (pos_x < PowerView_Width)
    {
        CGContextMoveToPoint(context, pos_x, 1);
        CGContextAddLineToPoint(context, pos_x, PowerView_Height);
        pos_x += _cell_width;
        
        CGContextStrokePath(context);
    }
    
    pos_y = PowerView_Width;
    while (pos_y >= 0)
    {
        CGContextMoveToPoint(context, 1, pos_y);
        CGContextAddLineToPoint(context, PowerView_Width, pos_y);
        pos_y -= _cell_width;
        
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
            CGContextSetRGBStrokeColor(ctxs, 0, 0, 0, 1);
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
        
        UIColor*aColor = [UIColor blackColor];
        CGContextSetFillColorWithColor(cxt, aColor.CGColor);//填充颜色
        CGContextAddArc(cxt, retrievedPoint.x, retrievedPoint.y, 4, 0, 2*PI, 0); //添加一个圆
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
        CGContextAddArc(context, retrievedPoint.x, retrievedPoint.y, 8, 0, 2*PI, 0); //添加一个圆
        //kCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线，不是填充
        CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充  //        //填充圆，无边框
        //        CGContextAddArc(context, 150, 30, 30, 0, 2*PI, 0); //添加一个圆
        //        CGContextDrawPath(context, kCGPathFill);//绘制填充
        CGContextStrokePath(context);
    }
    /*------------------------------画手指点击的点完成--------------------------------*/
}

//手指触摸的状态
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"手指开始点击状态");
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
//    NSLog(@"(%f,%f)",point.x,point.y);
    
    [self check_point_line:point];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"手指移动状态");
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
//    NSLog(@"(%f,%f)",point.x,point.y);
    
    [self check_point_line:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"手指离开状态");
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
//    NSLog(@"(%f,%f)",point.x,point.y);
    
    [self check_point_line:point];
}

-(void)check_point_line:(CGPoint)point
{
    int num = self.check_num + 1;
    
    int check_x = point.x/box_Side;
    int check_y = point.y/box_Side;
    
//    NSLog(@"check_x - %d  check_y - %d",check_x,check_y);

    if (check_x <= 21 && check_y <= 10 && check_x >= 0 && check_y >= 1)
    {
        if(num > 21)
        {
            if (check_x > 0 && check_x < 22)
            {
                //点击不同的点就可以调节了
//                NSLog(@"选择第%d个点",check_x);
                
                self.point_num = check_x;
                
                LineCGPoint *linePoint = [_array_CustomData objectAtIndex:_point_num];
   
                linePoint.line_y_h = point.y;

                [_array_CustomData replaceObjectAtIndex:_point_num withObject:linePoint];

                [self setNeedsDisplay];
            }
        }
        else
        {
            //还未画满21个点
            if (check_x == num)
            {
                LineCGPoint *linePoint = [[LineCGPoint alloc]init];
                
                linePoint.line_x_w = check_x * box_Side;
                linePoint.line_y_h = point.y;
                
                [_array_CustomData addObject:linePoint];
                
                _check_num++;

                //局部刷新
                [self setNeedsDisplay];
            }
        }
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
