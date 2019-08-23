//
//  GreenHandsScanView.m
//  uvapor
//
//  Created by tyz on 17/3/21.
//  Copyright © 2017年 TYZ. All rights reserved.
//

#import "GreenHandsScanView.h"

@implementation GreenHandsScanView
{
    float width_view_float;
    float height_view_float;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame :(float)view_width  :(float)view_height
{
    self = [self initWithFrame:frame];
    if (self)
    {
        width_view_float = view_width;
        height_view_float = view_height;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    float width_view = width_view_float;
    float height_view = height_view_float;
    float rabius_view = 0;
    
    if (width_view > height_view)
    {
        rabius_view = height_view/2;
    }
    else
    {
        rabius_view = width_view/2;
    }
    
//    NSLog(@"%f,%f,%f",width_view,height_view,rabius_view);
    
    // 半径
    CGFloat rabius = rabius_view/2;
    // 中心点
    CGPoint point = CGPointMake((width_view/2),(height_view/2));
    
    // 开始角
    CGFloat startAngle = 0;
    
    // 结束角
    CGFloat endAngle = 2*M_PI;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:rabius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc]init];
    layer.path = path.CGPath;       // 添加路径 下面三个同理
    
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    
    [self.layer addSublayer:layer];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
