//
//  AlertViewInputBoxView.m
//  uVapour
//
//  Created by 田阳柱 on 16/10/6.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "AlertViewInputBoxView.h"
#import "AppDelegate.h"
#import "InputBoxView.h"
#import "InternationalControl.h"

#define WIDTH [[UIScreen mainScreen] bounds].size.width
#define HEIGHT [[UIScreen mainScreen] bounds].size.height

@implementation AlertViewInputBoxView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
    self.clipsToBounds = YES;
}
 
- (void)showViewWith:(NSString*)string :(UIKeyboardType)keyBoardType
{
    AppDelegate* delegate = [UIApplication sharedApplication].delegate;
    self.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    self.center = CGPointMake(WIDTH/2, (HEIGHT/2));
    
    [self addInputBoxView:string:keyBoardType];
    
    [delegate.window addSubview:self];
//    [self performSelector:@selector(remove) withObject:nil afterDelay:1.0f];
}

//加载注册账号Edit部分
-(void)addInputBoxView:(NSString*)string :(UIKeyboardType)keyBoardType
{
    _inpuBoxView = [[[NSBundle mainBundle]loadNibNamed:@"InputBoxView" owner:self options:nil] lastObject];
    
    CGRect frame = _inpuBoxView.frame;

    frame.size.width = SCREEN_WIDTH - 60.0f;
    frame.size.height = 150.0f;
    
    _inpuBoxView.frame = frame;
    
    [_inpuBoxView.btn_cancle setTitle:[InternationalControl return_string:@"window_cancle"] forState:UIControlStateNormal];
    [_inpuBoxView.btn_confim setTitle:[InternationalControl return_string:@"window_confirm"] forState:UIControlStateNormal];
    
    _inpuBoxView.lable_input.keyboardType = keyBoardType;
    
    _inpuBoxView.center = CGPointMake(WIDTH/2, (HEIGHT/2) - 70);
    
    _inpuBoxView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
    _inpuBoxView.layer.cornerRadius = 10.0f;
    
    _inpuBoxView.lable_title.text = string;
    
    _inpuBoxView.btn_cancle.layer.cornerRadius = 5.0f;
    _inpuBoxView.btn_confim.layer.cornerRadius = 5.0f;
    
    //添加点击事件
    [_inpuBoxView.btn_cancle addTarget:self action:@selector(cancle_btn) forControlEvents:UIControlEventTouchUpInside];
    [_inpuBoxView.btn_confim addTarget:self action:@selector(confim_btn) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:_inpuBoxView];
}

//取消按钮
-(void)cancle_btn
{
    [self remove];
}

//AlertViewBackString
//确定按钮
-(void)confim_btn
{
    if (self.AlertViewBackString)
    {
        //设置回调
        self.AlertViewBackString(_inpuBoxView.lable_input.text);
    }
    [self remove];
}


- (void)remove
{
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
