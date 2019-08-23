//
//  DrawingLOGOViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/27.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "DrawingLOGOViewController.h"
#import "DrawingLogoView.h"
#import "LogoClass.h"

@interface DrawingLOGOViewController ()
{
    DrawingLogoView *drawingLogoView;
}

@end

@implementation DrawingLOGOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"logoClass - > %d",self.logoClass.drawingBoard_height);
    
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
    
    titleLable.text = @"LOGO";
    
    titleLable.textColor = [UIColor whiteColor];
    
    titleLable.center = barView.center;
    
    [barView addSubview:titleLable];
    
    /*******************************************************************************/
    
    //添加返回按钮
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 7, 30, 30)];
    
    [backButton setBackgroundImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(onclickBack) forControlEvents:UIControlEventTouchUpInside];
    
    [barView addSubview:backButton];
    
    /*******************************************************************************/
    
    //添加保存按钮
    UIButton *saveButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_HEIGHT - 45, 7, 30, 30)];
    
    [saveButton setBackgroundImage:[UIImage imageNamed:@"icon_set_save_TCR"] forState:UIControlStateNormal];
    
    [saveButton addTarget:self action:@selector(onclickSave) forControlEvents:UIControlEventTouchUpInside];
    
    [barView addSubview:saveButton];
    
    /********************************************************************************/
    //画图板宽
    float drawingViewWidth = SCREEN_HEIGHT;
    
    //画图板高
    float drawingViewHeight = SCREEN_WIDTH - 44;
    
    int width_box =  drawingViewWidth / (self.logoClass.drawingBoard_width);
    int height_box = drawingViewHeight / (self.logoClass.drawingBoard_height);
    
    //选择单个方框边长
    int drawingViewBox = 0;
    
    if (width_box > height_box)
    {
        drawingViewBox = height_box;
    }
    else
    {
        drawingViewBox = width_box;
    }
    
    int drawingWidth = drawingViewBox * 128;
    int drawingHeight = drawingViewBox * 32;
    
    CGRect framebg = CGRectMake(0,0,drawingWidth,drawingHeight);
    
    self.logoClass.boxSize = drawingViewBox;
    
    drawingLogoView = [[DrawingLogoView alloc] initWithFrame:framebg :self.logoClass];
    
    CGPoint viewCenter = CGPointMake(drawingViewWidth/2,drawingViewHeight/2 + 44);
    
    drawingLogoView.center = viewCenter;
    
    [self.view addSubview:drawingLogoView];
}

//返回按钮
-(void)onclickBack
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"移除");
    }];
}

//保存按钮
-(void)onclickSave
{
    NSLog(@"Save");
}

- (void)didReceiveMemoryWarning
{
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
