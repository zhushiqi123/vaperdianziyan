//
//  DrawingPowerLineViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/26.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "DrawingPowerLineViewController.h"
#import "DrawingPowerLineView.h"
#import "ProgressHUD.h"
#import "LineCGPoint.h"
#import "TYZFileData.h"
#import "InternationalControl.h"

@interface DrawingPowerLineViewController ()
{
    DrawingPowerLineView *powerLineView;
    
    NSMutableArray *choose_arrys;
}

@end

@implementation DrawingPowerLineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"获取本地数据");
    
    if (_ArryType <= 0)
    {
        _ArryType = 1;
    }
    //获取本地数据
    choose_arrys = [TYZFileData GetPowerLineData:_ArryType];
    
    if(choose_arrys.count == 23)
    {
        LineCGPoint *chosePoint = [choose_arrys objectAtIndex:22];
        
        _ArryType = (int)chosePoint.line_y_h;
        
//        NSLog(@"%@",choose_arrys);
    }
    
    //设置电池为白色
    [self preferredStatusBarStyle];
    
    /****************************************************************************/
    
    //设置背景
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, SCREEN_HEIGHT,SCREEN_WIDTH)];
    imageview.image = [UIImage imageNamed:@"icon_background"];
    
    [self.view addSubview:imageview];
    
    /*****************************************************************************/
    
    //设置导航栏
    UIView *barView = [[UIView alloc]initWithFrame:CGRectMake(0,0, SCREEN_HEIGHT, 44)];

    /****************************************************************************/
    
    //设置导航栏背景图片
    barView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];

    [self.view addSubview:barView];
    
    /*****************************************************************************/
    
    //设置title
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 21)];
    
    titleLable.text = [NSString stringWithFormat:@"C%d",_ArryType];
    
    titleLable.textColor = [UIColor whiteColor];
    
    titleLable.center = barView.center;
    
    [barView addSubview:titleLable];
    
    /*******************************************************************************/
    
    //添加返回按钮
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 7, 30, 30)];
    
    [backButton setBackgroundImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(onclick_backButton) forControlEvents:UIControlEventTouchUpInside];
    
    [barView addSubview:backButton];
    
    /*******************************************************************************/
    
    //添加保存按钮
    UIButton *saveButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_HEIGHT - 45, 7, 30, 30)];
    
    [saveButton setBackgroundImage:[UIImage imageNamed:@"icon_set_save_TCR"] forState:UIControlStateNormal];
    
    [saveButton addTarget:self action:@selector(onclick_saveButton) forControlEvents:UIControlEventTouchUpInside];
    
    [barView addSubview:saveButton];
    
    /********************************************************************************/
    //画图板宽
    float drawingViewWidth = SCREEN_HEIGHT;
    
    //画图板高
    float drawingViewHeight = SCREEN_WIDTH - 44;
    
    int width_box = drawingViewWidth / 115;
    int height_box = drawingViewHeight / 55;
    
    //选择单个方框边长
    int drawingViewBox = 0;
    
    if (width_box > height_box)
    {
        drawingViewBox = height_box * 5;
    }
    else
    {
        drawingViewBox = width_box * 5;
    }
    
    int drawingWidth = drawingViewBox * 23;
    int drawingHeight = drawingViewBox * 11;
    
    CGRect framebg = CGRectMake(0,0,drawingWidth,drawingHeight);
    
    powerLineView = [[DrawingPowerLineView alloc] initWithFrame:framebg :drawingViewBox :_ArryType :choose_arrys];
    
    CGPoint viewCenter = CGPointMake(drawingViewWidth/2,drawingViewHeight/2 + 44);
    
    powerLineView.center = viewCenter;
    
    [self.view addSubview:powerLineView];
    
    /***********************************************************************/
    
    //设置纵轴坐标系
    float margin_width_H = ((drawingViewWidth - drawingWidth) / 4);
    float margin_height_H = (drawingViewHeight - drawingHeight) / 2 + 44;
    
    for(int i  = 11;i >= 0;i--)
    {
        UILabel *lable_line_H = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, margin_width_H * 2, drawingViewBox)];
        
        CGPoint lable_line_H_center = CGPointMake(margin_width_H, margin_height_H - ((i - 11) * drawingViewBox));
        
        lable_line_H.center = lable_line_H_center;
        
        lable_line_H.font = [UIFont systemFontOfSize:10];
        
        if(i == 11)
        {
            lable_line_H.text = @"P/%";
        }
        else
        {
            lable_line_H.text = [NSString stringWithFormat:@"%d",i*10];
        }
        
        lable_line_H.textColor = [UIColor darkGrayColor];
        
        lable_line_H.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:lable_line_H];
    }
    
    
    /***************************************************************************/
    
    //设置横轴坐标系
    float margin_width_W = (drawingViewWidth - drawingWidth) / 2;
    float margin_height_W = ((drawingViewHeight - drawingHeight) / 2) + drawingHeight + 44;
    
    for(int i  = 0;i < 22;i++)
    {
        UILabel *lable_line_W = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, drawingViewBox, (drawingViewHeight - drawingHeight) / 2)];
        
        CGPoint lable_line_W_center = CGPointMake(margin_width_W + (i * drawingViewBox), margin_height_W + (drawingViewBox / 2));
        
        lable_line_W.center = lable_line_W_center;
        
        lable_line_W.font = [UIFont systemFontOfSize:10];
        
        lable_line_W.text = [NSString stringWithFormat:@"%d",i];
        
        lable_line_W.textColor = [UIColor darkGrayColor];
        
        lable_line_W.textAlignment = NSTextAlignmentCenter;
        
        [self.view addSubview:lable_line_W];
    }
    
    //最后一个点
    UILabel *lable_line_22 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, drawingViewBox * 2, (drawingViewHeight - drawingHeight) / 2)];
    
    CGPoint lable_line_W_center = CGPointMake(margin_width_W + (22 * drawingViewBox + (drawingViewBox / 2)), margin_height_W + (drawingViewBox / 2));
    
    lable_line_22.center = lable_line_W_center;
    
    lable_line_22.font = [UIFont systemFontOfSize:10];
    
    lable_line_22.text = @"Time/s";
    
    lable_line_22.textColor = [UIColor darkGrayColor];
    
    lable_line_22.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:lable_line_22];
    
    /*************************************************************************************/
    // Do any additional setup after loading the view.
}


-(void)onclick_backButton
{
    NSLog(@"返回");
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"移除");
    }];
}

-(void)onclick_saveButton
{
    NSLog(@"保存");
    NSMutableArray *reustArry = [powerLineView getArryData];
    
    if (reustArry.count == 23)
    {
        NSLog(@"保存到本地");
        //保存到本地
        [TYZFileData SavePowerLineData:reustArry :_ArryType];
        
        [ProgressHUD showSuccess:nil];
        
//        for(LineCGPoint *point in reustArry)
//        {
//            NSLog(@"point - (%f,%f)",point.line_x_w,point.line_y_h);
//        }
    }
    else
    {
        //Custom_PowerLine_dataa_error_01
//        [ProgressHUD showError:@"曲线点需要满足21个"];
        [ProgressHUD showError:[InternationalControl return_string:@"Custom_PowerLine_dataa_error_01"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-----------------------横屏显示---子类---------------------->
- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
//    return UIInterfaceOrientationMaskLandscapeRight;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}
//------------------------------------------------------->

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
