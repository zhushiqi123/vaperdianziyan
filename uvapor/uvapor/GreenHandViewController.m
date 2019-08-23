//
//  GreenHandViewController.m
//  uvapor
//
//  Created by tyz on 17/3/6.
//  Copyright © 2017年 TYZ. All rights reserved.
//

#import "GreenHandViewController.h"
#import "STW_BLE_SDK.h"
#import "InternationalControl.h"
#import "GreenHandsScanView.h"
#import "GreenHandTableViewCell.h"
#import "ShopViewController.h"
#import "STW_BLE_SDK.h"
#import "TYZ_AFNet_Client.h"

//检查列表对象
@class Check_List_Object;

@interface Check_List_Object : NSObject
@property(nonatomic,retain) NSString *text_lable;
@property(nonatomic,retain) NSString *head_type_image;
@property(nonatomic,retain) NSString *status_image;
@end

@implementation Check_List_Object
@end

@interface GreenHandViewController ()
{
    //一键体检动画按钮视图
    UIView *background_view;
    
    //新手进阶 视图
    UIView *advanced_view;
    
    //一键体检视图
    UIView *hand_view;
    
    //一键体检结果视图
    UIView *result_hand_view;
    
    //体检过程视图
    UITableView *tableview;
    
    //体检动画计时
    NSTimer *scan_timer;
    
    //体检流程计时
    NSTimer *check_list_timer;
    
    //正在体检的流程
    int check_list_steps;
    
    //体检流程数据源方法
    NSMutableArray *check_list_arry;
    
    //当前处于什么视图
    int page_view_now;
    
    //处理结果
    NSString *result_check_str;
    
    //检测阻值
    int num_atomizer;
}

@end

@implementation GreenHandViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
//    [self.tableview reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

-(void)root_view
{
    //去掉返回按钮上的文字
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    //改变返回按钮颜色为白色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //设置电池为白色
    [self preferredStatusBarStyle];
    //设置导航栏背景图片
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_fooder"]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.view.backgroundColor = RGBCOLOR(0xea, 0xea, 0xea);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化主题
    [self root_view];
    
    scan_timer = nil;
    
    check_list_timer = nil;
    
    check_list_steps = 0;
    
    check_list_arry = [NSMutableArray array];
    
    // Do any additional setup after loading the view.
    self.title = [InternationalControl return_string:@"GreenHandStatus"];
    
    //一键体检动画按钮视图
    background_view = [[UIView alloc] initWithFrame:CGRectMake(0,64.0f,SCREEN_WIDTH,((SCREEN_HEIGHT/2) - 64.0f))];
    background_view.backgroundColor = RGBCOLOR(0x00, 0x98, 0x00);
    [self.view addSubview:background_view];
    
    //加载一键体检模块
    [self addCheckUp];
    
    //加载一个视图盖住
    [self add_round_view:SCREEN_WIDTH :((SCREEN_HEIGHT/2) - 64.0f)];
    
    //加载主视图
    [self addViewPage_01];
}

//主视图
-(void)addViewPage_01
{
    page_view_now = 1;
    //新手进阶 视图
    advanced_view = [[UIView alloc] initWithFrame:CGRectMake(0,(SCREEN_HEIGHT/2.0f),SCREEN_WIDTH,(SCREEN_HEIGHT/2.0f))];
    advanced_view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:advanced_view];
    //加载四个雾化器计算模块 - 进阶模块
    [self addMakeAtomizer];
}

//体检视图
-(void)addViewPage_02
{
    page_view_now = 2;
    //一键体检进行视图
    hand_view = [[UIView alloc] initWithFrame:CGRectMake(0,(SCREEN_HEIGHT/2.0f),SCREEN_WIDTH,(SCREEN_HEIGHT/2.0f))];
    hand_view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:hand_view];
    //一键体检进行
    [self add_hand_view_list];
}

//体检结果视图
-(void)addViewPage_03:(NSString *)result_str
{
    page_view_now = 3;
    //一键体检结果视图
    result_hand_view = [[UIView alloc] initWithFrame:CGRectMake(0,(SCREEN_HEIGHT/2.0f),SCREEN_WIDTH,(SCREEN_HEIGHT/2.0f))];
    result_hand_view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:result_hand_view];
    //一键体检结果报告
    [self add_result_hand_view:result_str];
}

//加载一键体检模块
-(void)addCheckUp
{
    //计算屏幕的宽高 SCREEN_WIDTH  SCREEN_HEIGHT
    GreenHandsScanView *scanView = [[GreenHandsScanView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,((SCREEN_HEIGHT/2) - 64.0f)) :SCREEN_WIDTH :((SCREEN_HEIGHT/2) - 64.0f)];
    
    scanView.backgroundColor = [UIColor clearColor];
    
    scanView.userInteractionEnabled=YES;
    UITapGestureRecognizer *onclick_view =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(start_animation)];
    [scanView addGestureRecognizer:onclick_view];
    
    [background_view addSubview:scanView];
    
    [UIView animateWithDuration:2 animations:^{
        scanView.transform = CGAffineTransformScale(scanView.transform, 2, 2);
        scanView.alpha = 0;
    }
    completion:^(BOOL finished)
    {
        [scanView removeFromSuperview];
    }];
}

//加载四个雾化器计算模块 - 下部分视图1 - 新手进阶 视图
-(void)addMakeAtomizer
{
    //加载第一个控件
    UIView *Atomizer_view01 = [[UIView alloc] initWithFrame:CGRectMake(0,0,(SCREEN_WIDTH/2.0f - 1.0f),SCREEN_HEIGHT/4.0f - 1.0f)];
    Atomizer_view01.backgroundColor = [UIColor whiteColor];
    
    //加载图片视图
    UIImageView *image_view_01 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH/8.0f), (SCREEN_WIDTH/8.0f))];
    image_view_01.center = CGPointMake((SCREEN_WIDTH/4.0f), ((SCREEN_WIDTH/4.0f) - 15.f));
    image_view_01.image = [UIImage imageNamed:@"icon_greenhand_ohm"];
    [Atomizer_view01 addSubview:image_view_01];
    
    //加载lable视图
    UILabel *lable_view_01 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH/2), 20)];
    lable_view_01.center = CGPointMake((SCREEN_WIDTH/4.0f), (SCREEN_WIDTH * 5.0f /16.0f));
    [lable_view_01 setTextAlignment:NSTextAlignmentCenter];
    [lable_view_01 setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [lable_view_01 setTextColor:[UIColor blackColor]];
    lable_view_01.text = @"功率计算";
    [Atomizer_view01 addSubview:lable_view_01];
    
    [advanced_view addSubview:Atomizer_view01];
    
    //加载第二个控件
    UIView *Atomizer_view02 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH -(SCREEN_WIDTH/2)),0,(SCREEN_WIDTH/2),SCREEN_HEIGHT/4.0f - 1.0f)];
    Atomizer_view02.backgroundColor = [UIColor whiteColor];
    
    UIImageView *image_view_02 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH/8.0f), (SCREEN_WIDTH/8.0f))];
    image_view_02.center = CGPointMake((SCREEN_WIDTH/4.0f), ((SCREEN_WIDTH/4.0f) - 15.f));
    image_view_02.image = [UIImage imageNamed:@"icon_greenhand_coil"];
    [Atomizer_view02 addSubview:image_view_02];
    
    //加载lable视图
    UILabel *lable_view_02 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH/2), 20)];
    lable_view_02.center = CGPointMake((SCREEN_WIDTH/4.0f), (SCREEN_WIDTH * 5.0f /16.0f));
    [lable_view_02 setTextAlignment:NSTextAlignmentCenter];
    [lable_view_02 setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [lable_view_02 setTextColor:[UIColor blackColor]];
    lable_view_02.text = @"线圈计算";
    [Atomizer_view02 addSubview:lable_view_02];
    
    [advanced_view addSubview:Atomizer_view02];
    
    //加载第三个控件
    UIView *Atomizer_view03 = [[UIView alloc] initWithFrame:CGRectMake(0,((SCREEN_HEIGHT/2.0f) - (SCREEN_HEIGHT/4.0f)),(SCREEN_WIDTH/2.0f - 1.0f),SCREEN_HEIGHT/4)];
    Atomizer_view03.backgroundColor = [UIColor whiteColor];
    
    UIImageView *image_view_03 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH/8.0f), (SCREEN_WIDTH/8.0f))];
    image_view_03.center = CGPointMake((SCREEN_WIDTH/4.0f), ((SCREEN_WIDTH/4.0f) - 15.f));
    image_view_03.image = [UIImage imageNamed:@"icon_greenhand_resistance"];
    [Atomizer_view03 addSubview:image_view_03];
    
    //加载lable视图
    UILabel *lable_view_03 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH/2), 20)];
    lable_view_03.center = CGPointMake((SCREEN_WIDTH/4.0f), (SCREEN_WIDTH * 5.0f /16.0f));
    [lable_view_03 setTextAlignment:NSTextAlignmentCenter];
    [lable_view_03 setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [lable_view_03 setTextColor:[UIColor blackColor]];
    lable_view_03.text = @"阻值计算";
    [Atomizer_view03 addSubview:lable_view_03];
    
    [advanced_view addSubview:Atomizer_view03];
    
    //加载第四个控件
    UIView *Atomizer_view04 = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH -(SCREEN_WIDTH/2)),((SCREEN_HEIGHT/2.0f) - (SCREEN_HEIGHT/4.0f)),(SCREEN_WIDTH/2),SCREEN_HEIGHT/4)];
    Atomizer_view04.backgroundColor = [UIColor whiteColor];
    
    UIImageView *image_view_04 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH/8.0f), (SCREEN_WIDTH/8.0f))];
    image_view_04.center = CGPointMake((SCREEN_WIDTH/4.0f), ((SCREEN_WIDTH/4.0f) - 15.f));
    image_view_04.image = [UIImage imageNamed:@"icon_greenhand_battery"];
    [Atomizer_view04 addSubview:image_view_04];
    
    //加载lable视图
    UILabel *lable_view_04 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH/2), 20)];
    lable_view_04.center = CGPointMake((SCREEN_WIDTH/4.0f), (SCREEN_WIDTH * 5.0f /16.0f));
    [lable_view_04 setTextAlignment:NSTextAlignmentCenter];
    [lable_view_04 setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [lable_view_04 setTextColor:[UIColor blackColor]];
    lable_view_04.text = @"电池性能";
    [Atomizer_view04 addSubview:lable_view_04];
    
    [advanced_view addSubview:Atomizer_view04];
    
    //添加点击事件
    Atomizer_view01.userInteractionEnabled=YES;
    Atomizer_view02.userInteractionEnabled=YES;
    Atomizer_view03.userInteractionEnabled=YES;
    Atomizer_view04.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *onclick_view_01 =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(page2_onclick_01)];
    UITapGestureRecognizer *onclick_view_02 =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(page2_onclick_02)];
    UITapGestureRecognizer *onclick_view_03 =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(page2_onclick_03)];
    UITapGestureRecognizer *onclick_view_04 =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(page2_onclick_04)];
    
    [Atomizer_view01 addGestureRecognizer:onclick_view_01];
    [Atomizer_view02 addGestureRecognizer:onclick_view_02];
    [Atomizer_view03 addGestureRecognizer:onclick_view_03];
    [Atomizer_view04 addGestureRecognizer:onclick_view_04];
}

//一键体检流程 - 下部分视图2
-(void)add_hand_view_list
{
    //检测过程
    tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 5.0f, SCREEN_WIDTH, ((SCREEN_HEIGHT/2.0f) - 55.0f))];
    tableview.backgroundColor = [UIColor clearColor];
    
    //在设置UItableView
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.tableFooterView = [[UIView alloc]init];//关键语句
    tableview.separatorStyle = UITableViewCellSelectionStyleNone; //无分割线
    
    [hand_view addSubview:tableview];
    
    //取消按钮背景视图
    UIView *hand_view_btn_black_view = [[UIView alloc] initWithFrame:CGRectMake(0, ((SCREEN_HEIGHT/2.0f) - 50.0f), SCREEN_WIDTH, 50.0f)];
    hand_view_btn_black_view.backgroundColor = RGBCOLOR(0xea, 0xea, 0xea);
    [hand_view addSubview:hand_view_btn_black_view];
    
    //取消按钮
    UIButton *button_cancle = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH - 10.0f), 40.0f)];
    button_cancle.center = CGPointMake(SCREEN_WIDTH/2.0f, 25.0f);
    [button_cancle setTitle:@"取消体检" forState:UIControlStateNormal];
    button_cancle.titleLabel.font = [UIFont systemFontOfSize:16];
    [button_cancle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button_cancle.imageView.layer.cornerRadius = 5.0f;
    [button_cancle setImage:[UIImage imageNamed:@"icon_navigationbar"] forState:UIControlStateHighlighted]; //icon_fooder  icon_navigationbar
    button_cancle.layer.cornerRadius = 5.0f;
    [button_cancle setBackgroundColor:RGBCOLOR(0x00, 0x98, 0x00)];
    [button_cancle addTarget:self action:@selector(onclick_cancleButton) forControlEvents:UIControlEventTouchUpInside];
    [hand_view_btn_black_view addSubview:button_cancle];
    
    //开始体检
    [self start_check_atom];
}

//一键体检结果 - 下部分视图3
-(void)add_result_hand_view:(NSString *)result_str
{
    //检测结果
    UITextView *result_text_view = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ((SCREEN_HEIGHT/2.0f) - 50.0f))];
    [result_text_view setBackgroundColor:[UIColor clearColor]]; //设置背景颜色
    result_text_view.textColor = [UIColor blackColor];  //文字颜色
    result_text_view.font = [UIFont systemFontOfSize:18.0f]; //字体大小
    result_text_view.textAlignment = NSTextAlignmentLeft; //对齐方式
    
    result_text_view.text = result_str; //@"体检结果报告：\n1.支持功率 10W - 40W";
    
    //添加到界面容器
    [result_hand_view addSubview:result_text_view];
    
    //取消按钮背景视图
    UIView *result_hand_view_btn_black_view = [[UIView alloc] initWithFrame:CGRectMake(0, ((SCREEN_HEIGHT/2.0f) - 50.0f), SCREEN_WIDTH, 50.0f)];
    result_hand_view_btn_black_view.backgroundColor = RGBCOLOR(0xea, 0xea, 0xea);
    [result_hand_view addSubview:result_hand_view_btn_black_view];
    
    //取消按钮
    UIButton *button_result = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH - 10.0f), 40.0f)];
    button_result.center = CGPointMake(SCREEN_WIDTH/2.0f, 25.0f);
    [button_result setTitle:@"完成" forState:UIControlStateNormal];
    button_result.titleLabel.font = [UIFont systemFontOfSize:16];
    [button_result setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button_result.imageView.layer.cornerRadius = 5.0f;
    [button_result setImage:[UIImage imageNamed:@"icon_navigationbar"] forState:UIControlStateHighlighted]; //icon_fooder  icon_navigationbar
    button_result.layer.cornerRadius = 5.0f;
    [button_result setBackgroundColor:RGBCOLOR(0x00, 0x98, 0x00)];
    [button_result addTarget:self action:@selector(onclick_resultButton) forControlEvents:UIControlEventTouchUpInside];
    [result_hand_view_btn_black_view addSubview:button_result];
}

//扫描中心部分控件
-(void)add_round_view:(float)view_width_func  :(float)view_height_func;
{
    float width_view = view_width_func;
    float height_view = view_height_func;
    float rabius_view = 0;
    
    if (width_view > height_view)
    {
        rabius_view = height_view/2;
    }
    else
    {
        rabius_view = width_view/2;
    }

    UIView *round_view = [[UIView alloc] initWithFrame:CGRectMake(0,0,rabius_view,rabius_view)];
    round_view.center = CGPointMake(view_width_func/2, (view_height_func/2) + 64.0f);
    round_view.backgroundColor = [UIColor whiteColor];
    
    //设置圆角
    round_view.layer.cornerRadius = round_view.frame.size.width/2;

    round_view.userInteractionEnabled=YES;
    UITapGestureRecognizer *onclick_view =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(start_animation)];
    [round_view addGestureRecognizer:onclick_view];
    
    //设置图片
    UIImageView *round_image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (rabius_view/2.0f),(rabius_view/2.0f))];
    round_image.center = CGPointMake(rabius_view/2, (rabius_view/2) - 10.0f);
    round_image.image = [UIImage imageNamed:@"icon_greenhand_hammer"];
    [round_view addSubview:round_image];
    
    //设置文字
    UILabel *roung_lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rabius_view, 20)];
    roung_lable.center = CGPointMake(rabius_view/2, ((rabius_view * 3)/4));
    [roung_lable setTextAlignment:NSTextAlignmentCenter];
    [roung_lable setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [roung_lable setTextColor:[UIColor blackColor]];
    roung_lable.text = @"一键体检";
    [round_view addSubview:roung_lable];
    
    [self.view addSubview:round_view];
}

//开始体检
-(void)start_animation
{
    if (scan_timer == nil && page_view_now == 1)
    {
        scan_timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(addCheckUp) userInfo:nil repeats:YES];
        
        [UIView animateWithDuration:1 animations:^{
            advanced_view.transform = CGAffineTransformMakeTranslation(-SCREEN_WIDTH,0);
            advanced_view.alpha = 0;
        }
        completion:^(BOOL finished)
        {
             [advanced_view removeFromSuperview];
            //显示正在体检视图
            [self addViewPage_02];
        }];
    }
}

//取消体检
-(void)onclick_cancleButton
{
//    NSLog(@"取消体检");
    //结束动画计时
    [scan_timer invalidate];
    scan_timer = nil;
    
    //结束体检计时
    [check_list_timer invalidate];
    check_list_timer = nil;
    
    //回到主界面
    [UIView animateWithDuration:1 animations:^{
        hand_view.transform = CGAffineTransformMakeTranslation(SCREEN_WIDTH,0);
        hand_view.alpha = 0;
    }
    completion:^(BOOL finished)
    {
         [hand_view removeFromSuperview];
         //显示正在体检视图
         [self addViewPage_01];
    }];
}

//完成体检
-(void)onclick_resultButton
{
    //回到主界面
    [UIView animateWithDuration:1 animations:^{
        result_hand_view.transform = CGAffineTransformMakeTranslation(SCREEN_WIDTH,0);
        result_hand_view.alpha = 0;
    }
    completion:^(BOOL finished)
    {
         [result_hand_view removeFromSuperview];
         //显示正在体检视图
         [self addViewPage_01];
    }];
}

//开始体检
-(void)start_check_atom
{
    check_list_steps = 0;
    check_list_arry = [NSMutableArray array];
    check_list_timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(do_check_list) userInfo:nil repeats:YES];
}

//处理检测逻辑
-(void)do_check_list
{
//    NSLog(@"处理检测逻辑");
    if (check_list_steps < 13)
    {
        Check_List_Object *check_object = [[Check_List_Object alloc] init];
        
        switch (check_list_steps)
        {
            case 0:
            {
                result_check_str = @"";
                //一键体检初始化
                //icon_greenhand_error  icon_greenhand_head
                //icon_greenhand_success  icon_greenhand_warning
                check_object.text_lable = @"一键体检初始化";
                check_object.head_type_image = @"icon_greenhand_head";
                check_object.status_image = @"icon_greenhand_success";
                [check_list_arry addObject:check_object];
            }
                break;
            case 1:
            {
                //获取蓝牙连接状态
                //icon_greenhand_error  icon_greenhand_head
                //icon_greenhand_success  icon_greenhand_warning
                if ([STW_BLEService sharedInstance].isBLEStatus)
                {
                    check_object.text_lable = @"获取蓝牙连接状态";
                    check_object.head_type_image = @"icon_greenhand_head";
                    check_object.status_image = @"icon_greenhand_success";
                    [check_list_arry addObject:check_object];
                }
                else
                {
                    check_object.text_lable = @"没有设备连接";
                    check_object.head_type_image = @"icon_greenhand_error";
                    check_object.status_image = @"icon_greenhand_warning";
                    [check_list_arry addObject:check_object];
                    
                    //取消检测
                    [self out_check_cancle];
                }
            }
                break;
            case 2:
            {
                if ([TYZ_AFNet_Client sharedInstance].status_AFNetwork == 1)
                {
                    //获取网络连接状态
                    //icon_greenhand_error  icon_greenhand_head
                    //icon_greenhand_success  icon_greenhand_warning
                    check_object.text_lable = @"网络连接状态正常";
                    check_object.head_type_image = @"icon_greenhand_head";
                    check_object.status_image = @"icon_greenhand_success";
                    [check_list_arry addObject:check_object];
                }
                else
                {
                    //获取网络连接状态
                    //icon_greenhand_error  icon_greenhand_head
                    //icon_greenhand_success  icon_greenhand_warning
                    check_object.text_lable = @"请检查网络设置，保持网络畅通";
                    check_object.head_type_image = @"icon_greenhand_error";
                    check_object.status_image = @"icon_greenhand_warning";
                    [check_list_arry addObject:check_object];
                    //取消检测
                    [self out_check_cancle];

                }
            }
                break;
            case 3:
            {
                if ([TYZ_AFNet_Client sharedInstance].status_AFNetwork == 1)
                {
                    //获取吸烟记录信息
                    //icon_greenhand_error  icon_greenhand_head
                    //icon_greenhand_success  icon_greenhand_warning
                    check_object.text_lable = @"获取吸烟记录信息";
                    check_object.head_type_image = @"icon_greenhand_head";
                    check_object.status_image = @"icon_greenhand_success";
                    [check_list_arry addObject:check_object];
                }
                else
                {
                    //获取吸烟记录信息
                    //icon_greenhand_error  icon_greenhand_head
                    //icon_greenhand_success  icon_greenhand_warning
                    check_object.text_lable = @"获取吸烟记录信息出错";
                    check_object.head_type_image = @"icon_greenhand_error";
                    check_object.status_image = @"icon_greenhand_warning";
                    [check_list_arry addObject:check_object];
                }
            }
                break;
            case 4:
            {
                if ([TYZ_AFNet_Client sharedInstance].status_AFNetwork == 1)
                {
                    //获取吸烟习惯信息
                    //icon_greenhand_error  icon_greenhand_head
                    //icon_greenhand_success  icon_greenhand_warning
                    check_object.text_lable = @"获取吸烟习惯信息";
                    check_object.head_type_image = @"icon_greenhand_head";
                    check_object.status_image = @"icon_greenhand_success";
                    [check_list_arry addObject:check_object];
                }
                else
                {
                    //获取吸烟记录信息
                    //icon_greenhand_error  icon_greenhand_head
                    //icon_greenhand_success  icon_greenhand_warning
                    check_object.text_lable = @"获取吸烟习惯信息出错";
                    check_object.head_type_image = @"icon_greenhand_error";
                    check_object.status_image = @"icon_greenhand_warning";
                    [check_list_arry addObject:check_object];
                }
            }
                break;
            case 5:
            {
                if ([TYZ_AFNet_Client sharedInstance].status_AFNetwork == 1)
                {
                    //获取设备信息
                    //icon_greenhand_error  icon_greenhand_head
                    //icon_greenhand_success  icon_greenhand_warning
                    check_object.text_lable = @"获取设备信息";
                    check_object.head_type_image = @"icon_greenhand_head";
                    check_object.status_image = @"icon_greenhand_success";
                    [check_list_arry addObject:check_object];
                }
                else
                {
                    //获取吸烟记录信息
                    //icon_greenhand_error  icon_greenhand_head
                    //icon_greenhand_success  icon_greenhand_warning
                    check_object.text_lable = @"获取设备信息出错";
                    check_object.head_type_image = @"icon_greenhand_error";
                    check_object.status_image = @"icon_greenhand_warning";
                    [check_list_arry addObject:check_object];
                }
            }
                break;
            case 6:
            {
                num_atomizer = [STW_BLE_SDK STW_SDK].atomizer;
                if(num_atomizer > 100 && num_atomizer < 5000)
                {
                    //获取雾化器信息
                    //icon_greenhand_error  icon_greenhand_head
                    //icon_greenhand_success  icon_greenhand_warning
                    check_object.text_lable = @"获取雾化器信息";
                    check_object.head_type_image = @"icon_greenhand_head";
                    check_object.status_image = @"icon_greenhand_success";
                    [check_list_arry addObject:check_object];
                    
                    //计算出推荐功率
                    float min_power = (17000.0f/num_atomizer) - 2.5f;
                    float max_power = (17000.0f/num_atomizer) + 2.5f;
                    
                    int num_atomizer_value = num_atomizer/10;
                    
                    result_check_str = [NSString stringWithFormat:@"%@%@%.2fΩ\n%@%.1fW - %.1fW",result_check_str,@"雾化器阻值:",(num_atomizer_value/100.0f),@"推荐功率:",min_power,max_power];
                }
                else
                {
                    //获取雾化器信息
                    //icon_greenhand_error  icon_greenhand_head
                    //icon_greenhand_success  icon_greenhand_warning
                    check_object.text_lable = @"获取雾化器信息出现错误";
                    check_object.head_type_image = @"icon_greenhand_error";
                    check_object.status_image = @"icon_greenhand_warning";
                    [check_list_arry addObject:check_object];
                    
                    //取消检测
                    [self out_check_cancle];
                }
            }
                break;
            case 7:
            {
                //分析吸烟记录
                //icon_greenhand_error  icon_greenhand_head
                //icon_greenhand_success  icon_greenhand_warning
                check_object.text_lable = @"分析吸烟记录";
                check_object.head_type_image = @"icon_greenhand_head";
                check_object.status_image = @"icon_greenhand_success";
                [check_list_arry addObject:check_object];
            }
                break;
            case 8:
            {
                //分析吸烟习惯
                //icon_greenhand_error  icon_greenhand_head
                //icon_greenhand_success  icon_greenhand_warning
                check_object.text_lable = @"分析吸烟习惯";
                check_object.head_type_image = @"icon_greenhand_head";
                check_object.status_image = @"icon_greenhand_success";
                [check_list_arry addObject:check_object];
            }
                break;
            case 9:
            {
                //分析设备信息
                //icon_greenhand_error  icon_greenhand_head
                //icon_greenhand_success  icon_greenhand_warning
                check_object.text_lable = @"分析设备信息";
                check_object.head_type_image = @"icon_greenhand_head";
                check_object.status_image = @"icon_greenhand_success";
                [check_list_arry addObject:check_object];
            }
                break;
            case 10:
            {
                //分析雾化器信息
                //icon_greenhand_error  icon_greenhand_head
                //icon_greenhand_success  icon_greenhand_warning
                check_object.text_lable = @"分析雾化器信息";
                check_object.head_type_image = @"icon_greenhand_head";
                check_object.status_image = @"icon_greenhand_success";
                [check_list_arry addObject:check_object];
            }
                break;
            case 11:
            {
                //调节电子烟到参考值
                //icon_greenhand_error  icon_greenhand_head
                //icon_greenhand_success  icon_greenhand_warning
                check_object.text_lable = @"调节电子烟到参考值";
                check_object.head_type_image = @"icon_greenhand_head";
                check_object.status_image = @"icon_greenhand_success";
                [check_list_arry addObject:check_object];
                
                if(num_atomizer > 100 && num_atomizer < 5000)
                {
                    int result_power = (17000.0f/num_atomizer) * 10;
                    
                    if(result_power > ([STW_BLE_SDK STW_SDK].max_power * 10))
                    {
                        result_power = [STW_BLE_SDK STW_SDK].max_power * 10;
                        
                    }
                    else if(result_power < 10)
                    {
                        result_power = 10;
                    }
                    
                    [STW_BLE_Protocol the_work_mode_power:result_power :0x03];
                }
            }
                break;
            case 12:
            {
                //正在生成检测结果
                //icon_greenhand_error  icon_greenhand_head
                //icon_greenhand_success  icon_greenhand_warning
                check_object.text_lable = @"正在生成检测结果";
                check_object.head_type_image = @"icon_greenhand_head";
                check_object.status_image = @"icon_greenhand_success";
                [check_list_arry addObject:check_object];
            }
                break;
                
            default:
            {
                check_object.text_lable = @"Error!";
                check_object.head_type_image = @"icon_greenhand_error";
                check_object.status_image = @"icon_greenhand_warning";
                [check_list_arry addObject:check_object];
            }
                break;
        }
        
        //数据插入列表
        [self addRows:check_list_steps];
        
        check_list_steps = check_list_steps + 1;
    }
    else
    {
        //结束动画计时
        [scan_timer invalidate];
        scan_timer = nil;
        
        //结束体检计时
        [check_list_timer invalidate];
        check_list_timer = nil;
        
        //结束体检，跳转结果
        [UIView animateWithDuration:1 animations:^{
            hand_view.transform = CGAffineTransformMakeTranslation(-SCREEN_WIDTH,0);
            hand_view.alpha = 0;
        }
        completion:^(BOOL finished)
        {
             [hand_view removeFromSuperview];
             //显示体检结果视图
            [self addViewPage_03:result_check_str];
        }];
    }
}

-(void)out_check_cancle
{
    //结束动画计时
    [scan_timer invalidate];
    scan_timer = nil;
    
    //结束体检计时
    [check_list_timer invalidate];
    check_list_timer = nil;
}

-(void)addRows:(int)row_num
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row_num inSection:0];
    [indexPaths addObject: indexPath];
    //这个位置应该在修改tableView之前将数据源先进行修改,否则会崩溃........必须向tableView的数据源数组中相应的添加一条数据
    [tableview beginUpdates];
    [tableview insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [tableview endUpdates];
    
    //滚动到最后一行
    [tableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:row_num inSection:0]
                                animated:YES
                          scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma tyz - Table View
//设置一共有多少个Sessiion，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//设置每个Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

//设置一共有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return check_list_arry.count;
}

//TableView数据加载执行的方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cell = @"GreenHandTableViewCell";
    GreenHandTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
    if (cell == nil)
    {
        //从xlb加载内容
        cell = [[[NSBundle mainBundle] loadNibNamed:Cell owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    Check_List_Object *check_object = [check_list_arry objectAtIndex:indexPath.row];
    
    cell.headImage.image = [UIImage imageNamed:check_object.head_type_image];//[UIImage imageNamed:@"icon_greenhand_head"]; //icon_greenhand_error  icon_greenhand_head
    cell.status_image.image = [UIImage imageNamed:check_object.status_image];//[UIImage imageNamed:@"icon_greenhand_success"]; //icon_greenhand_success  icon_greenhand_warning
    cell.text_lable.text = check_object.text_lable;
    
    return cell;
}

-(void)page2_onclick_01
{
    ShopViewController *view = [[ShopViewController alloc] init];
    view.url_string = @"http://www.uvapour.com/uvapor_tools/ohmslaw_cn.html";
    view.title = @"功率计算";
    [self.navigationController pushViewController:view animated:YES];
}

-(void)page2_onclick_02
{
    ShopViewController *view = [[ShopViewController alloc] init];
    view.url_string = @"http://www.uvapour.com/uvapor_tools/coil_cn.html";
    view.title = @"绕圈计算";
    [self.navigationController pushViewController:view animated:YES];
}

-(void)page2_onclick_03
{
    ShopViewController *view = [[ShopViewController alloc] init];
    view.url_string = @"http://www.uvapour.com/uvapor_tools/mod_cn.html";
    view.title = @"阻值计算";
    [self.navigationController pushViewController:view animated:YES];
}

-(void)page2_onclick_04
{
    ShopViewController *view = [[ShopViewController alloc] init];
    view.url_string = @"http://www.uvapour.com/uvapor_tools/batt_cn.html";
    view.title = @"电池性能";
    [self.navigationController pushViewController:view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
