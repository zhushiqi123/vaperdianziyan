//
//  ViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/13.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "MainViewController.h"
#import "TitleView.h"
#import "VolumeBar.h"
#import "UIbattery.h"
#import "UIthreecount.h"
#import "UIWeiget.h"
#import "CustomVolumeBar.h"
#import "UIWeiget.h"
#import "TYZ_AFNet_Client.h"
#import "Session.h"
#import "TYZFileData.h"
#import "STW_BLE_SDK.h"
#import "ProgressHUD.h"
#import "Session.h"
#import "LoginViewController.h"
#import "MyVapeViewController.h"
#import "DrawingPowerLineView.h"
#import "CustomVolumeBar.h"
#import "SmockLog.h"
#import "DB_Sqlite3.h"
#import "JPUSHService.h"
#import "JPushMessage.h"
#import "InternationalControl.h"
#import <AudioToolbox/AudioToolbox.h>

@interface MainViewController ()
{
    //右边的按钮
    UIButton *deletebutton;
    
    //主界面的设备名称
    TitleView *title;
    
    //大仪表
    VolumeBar *bar;
    
    //大仪表坐标
    int bar_x;
    int bar_y;
    float bar_weight;
    float bar_hreght;
    
    //是否有蓝牙在请求电子烟连接 YES - 没有  NO - 有
    Boolean check_ble_status;
    
    //弹出选择视图类型
    int checkMessage;
    
    //吸烟开始时间，吸烟结束时间
    int vapor_start,vapor_over;
    
    //吸烟计时
    NSTimer *vapor_timer;
    
    //修改的设备名称
    NSString *str_change_deviceName;
    
    //按钮状态
    int btn_delete_type;
    
    int text_num;
}

@property(nonatomic,retain)NSArray *tabArrayLanguge;

@end

@implementation MainViewController

- (NSArray *)tabArrayLanguge
{
    if (_tabArrayLanguge == nil)
    {
        if ([[InternationalControl userLanguage] isEqualToString:@"zh-Hans"])
        {
            _tabArrayLanguge = [NSArray arrayWithObjects:@"电子烟",@"自定义",@"计划",@"我的", nil];
        }
        else
        {
            _tabArrayLanguge = [NSArray arrayWithObjects:@"Vapor",@"Custom",@"Plan",@"Setting", nil];
        }
    }
    return _tabArrayLanguge;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if([Session sharedInstance].user.cellphone)
    {
        //获取吸烟记录
        [self getSmokeCount];
    }
    else
    {
        double delayInSeconds = 1.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           if([Session sharedInstance].user.cellphone)
                           {
                               //获取吸烟记录
                               [self getSmokeCount];
                           }
                       });
    }
    
    //语言设置
    self.threecount.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Atomizer"];
    self.threecount2.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_number"];
    self.threecount3.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Times"];
    
    [self updateWeightUI];
    
    [self updateVBarUI];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //加载极光推送
//    [self addJPushNotify];

    text_num = 1;
    
    for (int i = 0; i<4; i++)
    {
        UIViewController *tabBar = self.tabBarController.viewControllers[i];
        tabBar.title = self.tabArrayLanguge[i];
    }
    
    //设置设备的名字的view
    title = [[[NSBundle mainBundle]loadNibNamed:@"TitleView" owner:self options:nil]lastObject];
    title.backgroundColor = [UIColor clearColor];
    [self.navigationItem setTitleView:title];
    
    title.userInteractionEnabled=YES;
    UITapGestureRecognizer *onClickTitleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickTitle)];
    [title addGestureRecognizer:onClickTitleTap];
    
    //显示设备名称
//    title.title.text = @"设备";
//    NSLog(@"[Session sharedInstance].isLanguage  - %d - %@",[Session sharedInstance].isLanguage,[InternationalControl bundle]);
    title.title.text = [InternationalControl return_string:@"Vapor_device"];
    
    //设置左边image
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, 51, 15)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:imageview];
    imageview.image = [UIImage imageNamed:@"icon_uvapor"];
    
    //设置左边image可以点击
    imageview.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage)];
    [imageview addGestureRecognizer:singleTap];
    
    //设置右边button
    deletebutton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-15, 5, 13, 13)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:deletebutton];

    [self refreshRightBtn:[STW_BLEService sharedInstance].isBLEStatus];
    
    [deletebutton addTarget:self action:@selector(clickDeleteBt) forControlEvents:UIControlEventTouchDown];
    
    
    /**
     *  设置 各个仪表的位置
     */
    if (iPhone5)
    {
        ////////////////////////////////////////////////////////////////////////////////////////
        /*---------------------------------- iPhone5 -----------------------------------------*/
        ////////////////////////////////////////////////////////////////////////////////////////
        //大仪表图
        bar_x = self.view.bounds.size.width/2 -125;
        bar_y = self.view.bounds.size.height - 490;
        bar_weight = 250;
        bar_hreght = 232;
        
        //自定义模式视图
        CustomVolumeBar *customVolumeBar = [[[NSBundle mainBundle]loadNibNamed:@"CustomVolumeBar" owner:self options:nil] lastObject];
        
        CGRect frameBar = customVolumeBar.frame;
        
        frameBar.origin.x = 10.0f;
        frameBar.origin.y = 64.0f;
        
        frameBar.size.width = SCREEN_WIDTH - 20;
        frameBar.size.height = 242;
        
        customVolumeBar.frame = frameBar;
        
        NSMutableArray *arrys = [NSMutableArray array];
        
        customVolumeBar = [customVolumeBar initWithFrame:frameBar :(frameBar.size.width)  :(frameBar.size.height) :1 :arrys];

        [self.view addSubview:customVolumeBar];
        

        //大仪表图窗口
        CGRect framebg = CGRectMake(bar_x,bar_y,bar_weight,bar_hreght);
        
        bar = [[VolumeBar alloc] initWithFrame:framebg :125.0f :125.0f :79.0f];
        
        bar._backgroundView.frame = CGRectMake(0, 0, bar_weight, bar_hreght);
        
//        bar.type = PanelTypePower;
        [self.view addSubview:bar];
        
        //小仪表图
        UIWeiget *weight = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        
        CGRect frame = weight.frame;
        
        frame.origin.x = 10.0f;
        frame.origin.y =  bar_hreght + 74.0f;
        
        frame.size.width = 100.0f;
        frame.size.height = 100.0f;
        
        weight.frame = frame;
        
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
//        weight.WeigetLabel.text = @"温度℃";
        weight.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Temp_C"];
        weight.WeigetButton.tag = 1;
        //        weight.type = PanelTypeTemperature;
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
        [self.view addSubview:weight];
        
        UIWeiget *weight1 = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        CGRect frame1 = weight1.frame;
        
        frame1.origin.x = self.view.bounds.size.width - 100.0f - 10.0f;
        frame1.origin.y =  bar_hreght + 74.0f;
        frame1.size.width = 100.0f;
        frame1.size.height = 100.0f;
        
        weight1.frame = frame1;
        [weight1.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
//        weight1.WeigetLabel.text = @"电压V";
        weight1.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Voltage"];
        //        weight1.WeigetImage.image = [UIImage imageNamed:@"icon_U"];
        weight1.WeigetButton.tag = 2;
        [self.view addSubview:weight1];
        
        //电池图
        UIbattery *battery = [[[NSBundle mainBundle]loadNibNamed:@"UIbattery" owner:self options:nil]lastObject];
        CGRect batteryframe = battery.frame;
        
        batteryframe.origin.x = 10.0f + 100.0f + 5.0f;
        batteryframe.origin.y = bar_hreght + 74.0f;
        batteryframe.size.width = 100.0f;
        batteryframe.size.height = 100.0f;
        
        battery.frame = batteryframe;
        [self.view addSubview:battery];
        
        //低下三个图组
        UIthreecount *threecount = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe = threecount.frame;
        
        threeframe.origin.x = 0;
        threeframe.origin.y = bar_hreght + 74.0f + 100.0f + 10.0f;
        
        threeframe.size.width = 100.0f;
        threeframe.size.height = 100.0f;
        
        threecount.frame = threeframe;
        threecount.threecountImage.image = [UIImage imageNamed:@"icon_whq"];
        threecount.threecountDataLabel.text = @"0Ω";
//        threecount.threecountNameLabel.text = @"雾化器";
        threecount.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Atomizer"];
        [self.view addSubview:threecount];
        
        //口数的视图
        UIthreecount *threecount2 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe2 = threecount2.frame;
        
        threeframe2.origin.x = 10.0f + 100.0f + 5.0f;
        threeframe2.origin.y = bar_hreght + 74.0f + 100.0f + 10.0f;
        
        threeframe2.size.width = 100.0f;
        threeframe2.size.height = 100.0f;
        
        threecount2.frame = threeframe2;
        threecount2.threecountImage.image = [UIImage imageNamed:@"icon_shape"];
//        threecount2.threecountDataLabel.text = @"0口";
        threecount2.threecountDataLabel.text = [NSString stringWithFormat:@"0%@",[InternationalControl return_string:@"Vapor_nums"]];
//        threecount2.threecountNameLabel.text = @"口数";
        threecount2.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_number"];
        [self.view addSubview:threecount2];
        
        
        UIthreecount *threecount3 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe3 = threecount3.frame;
        
        threeframe3.origin.x = self.view.bounds.size.width - 100.0f;
        threeframe3.origin.y =  bar_hreght + 74.0f + 100.0f + 10.0f;
        threeframe3.size.width = 100.0f;
        threeframe3.size.height = 100.0f;
        
        threecount3.frame = threeframe3;
        threecount3.threecountImage.image = [UIImage imageNamed:@"icon_clock"];
        threecount3.threecountDataLabel.text = @"0s";
//        threecount3.threecountNameLabel.text = @"时长";
        threecount3.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Times"];
        [self.view addSubview:threecount3];
        
        //变为可调用
        //self.instrument = instrument;
        self.voumebar = bar;
        self.weight = weight;
        self.weight1 = weight1;
        self.battery = battery;
        self.threecount = threecount;
        self.threecount2 = threecount2;
        self.threecount3 = threecount3;
        self.custombar = customVolumeBar;
    }
    else if(iPhone6)
    {
        ////////////////////////////////////////////////////////////////////////////////////////
        /*---------------------------------- iPhone6 -----------------------------------------*/
        ////////////////////////////////////////////////////////////////////////////////////////

        //大仪表图
        bar_weight = (250* 375)/320.0f;
        bar_hreght = (232* 375)/320.0f;
        
        bar_x = (self.view.bounds.size.width - bar_weight)/2;
        bar_y = self.view.bounds.size.height - 560;
        
        //自定义模式视图
        CustomVolumeBar *customVolumeBar = [[[NSBundle mainBundle]loadNibNamed:@"CustomVolumeBar" owner:self options:nil] lastObject];
        
        CGRect frameBar = customVolumeBar.frame;
        
        frameBar.origin.x = 10.0f;
        frameBar.origin.y = 64.0f;
        
        frameBar.size.width = SCREEN_WIDTH - 20;
        frameBar.size.height = (232* 375)/320.0f;
        
        customVolumeBar.frame = frameBar;
        
        NSMutableArray *arrys = [NSMutableArray array];
        
        customVolumeBar = [customVolumeBar initWithFrame:frameBar :(frameBar.size.width)  :(frameBar.size.height) :1 :arrys];
        
        [self.view addSubview:customVolumeBar];
        
        //大仪表图窗口
        CGRect framebg = CGRectMake(bar_x,bar_y,bar_weight,bar_hreght);
        
        bar = [[VolumeBar alloc] initWithFrame:framebg :(250 * 375)/640.0f :(250 * 375)/640.0f :(250 * 375)/640.0f * 0.65f];
        
        bar._backgroundView.frame = CGRectMake(0, 0, bar_weight, bar_hreght);
        
        //        bar.type = PanelTypePower;
        [self.view addSubview:bar];
        
        //小仪表图
        UIWeiget *weight = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        
        CGRect frame = weight.frame;
        
        frame.origin.x = 17.5f;
        frame.origin.y =  bar_hreght + 104.0f;
        
        frame.size.width = 100.0f;
        frame.size.height = 100.0f;
        
        weight.frame = frame;
        
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
//        weight.WeigetLabel.text = @"温度℃";
        weight.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Temp_C"];
        weight.WeigetButton.tag = 1;
        //        weight.type = PanelTypeTemperature;
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
        [self.view addSubview:weight];
        
        UIWeiget *weight1 = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        CGRect frame1 = weight1.frame;
        
        frame1.origin.x = self.view.bounds.size.width - 100.0f - 17.5f;
        frame1.origin.y =  bar_hreght + 104.0f;
        frame1.size.width = 100.0f;
        frame1.size.height = 100.0f;
        
        weight1.frame = frame1;
        [weight1.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
//        weight1.WeigetLabel.text = @"电压V";
        weight1.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Voltage"];
        //        weight1.WeigetImage.image = [UIImage imageNamed:@"icon_U"];
        weight1.WeigetButton.tag = 2;
        [self.view addSubview:weight1];
        
        //电池图
        UIbattery *battery = [[[NSBundle mainBundle]loadNibNamed:@"UIbattery" owner:self options:nil]lastObject];
        CGRect batteryframe = battery.frame;
        
        batteryframe.origin.x = 17.5f + 100.0f + 20.0f;
        batteryframe.origin.y = bar_hreght + 104.0f;
        batteryframe.size.width = 100.0f;
        batteryframe.size.height = 100.0f;
        
        battery.frame = batteryframe;
        [self.view addSubview:battery];
        
        //低下三个图组
        UIthreecount *threecount = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe = threecount.frame;
        
        threeframe.origin.x = 10.0f;
        threeframe.origin.y = bar_hreght + 104.0f + 100.0f + 17.5f;
        
        threeframe.size.width = 100.0f;
        threeframe.size.height = 100.0f;
        
        threecount.frame = threeframe;
        threecount.threecountImage.image = [UIImage imageNamed:@"icon_whq"];
        threecount.threecountDataLabel.text = @"0Ω";
//        threecount.threecountNameLabel.text = @"雾化器";
        threecount.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Atomizer"];
        [self.view addSubview:threecount];
#pragma mark  口数的获取
        //口数的视图
        UIthreecount *threecount2 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe2 = threecount2.frame;
        
        threeframe2.origin.x = 17.5f + 100.0f + 20.0f;
        threeframe2.origin.y = bar_hreght + 104.0f + 100.0f + 17.5f;
        
        threeframe2.size.width = 100.0f;
        threeframe2.size.height = 100.0f;
        
        threecount2.frame = threeframe2;
        threecount2.threecountImage.image = [UIImage imageNamed:@"icon_shape"];
//        threecount2.threecountDataLabel.text = @"0口";
        threecount2.threecountDataLabel.text = [NSString stringWithFormat:@"0%@",[InternationalControl return_string:@"Vapor_nums"]];
//        threecount2.threecountNameLabel.text = @"口数";
        threecount2.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_number"];
        [self.view addSubview:threecount2];
        
        
        UIthreecount *threecount3 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe3 = threecount3.frame;
        
        threeframe3.origin.x = self.view.bounds.size.width - 100.0f - 10.0f;
        threeframe3.origin.y =  bar_hreght + 104.0f + 100.0f + 17.5f;
        threeframe3.size.width = 100.0f;
        threeframe3.size.height = 100.0f;
        
        threecount3.frame = threeframe3;
        threecount3.threecountImage.image = [UIImage imageNamed:@"icon_clock"];
        threecount3.threecountDataLabel.text = @"0s";
//        threecount3.threecountNameLabel.text = @"时长";
        threecount3.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Times"];
        [self.view addSubview:threecount3];

        //变为可调用
        //self.instrument = instrument;
        self.voumebar = bar;
        self.weight = weight;
        self.weight1 = weight1;
        self.battery = battery;
        self.threecount = threecount;
        self.threecount2 = threecount2;
        self.threecount3 = threecount3;
        self.custombar = customVolumeBar;
    }
    else if(iPhone6Plus)
    {
        ////////////////////////////////////////////////////////////////////////////////////////
        /*-------------------------------- iPhone6Plus ---------------------------------------*/
        ////////////////////////////////////////////////////////////////////////////////////////

        //大仪表图
        bar_weight = (250 * 414)/320.0f;
        bar_hreght = (232 * 414)/320.0f;
        
        bar_x = (self.view.bounds.size.width - bar_weight)/2;
        bar_y = self.view.bounds.size.height - 640;
        
        //自定义模式视图
        CustomVolumeBar *customVolumeBar = [[[NSBundle mainBundle]loadNibNamed:@"CustomVolumeBar" owner:self options:nil] lastObject];
        
        CGRect frameBar = customVolumeBar.frame;
        
        frameBar.origin.x = 10.0f;
        frameBar.origin.y = 64.0f;
        
        frameBar.size.width = SCREEN_WIDTH - 20;
        frameBar.size.height = bar_hreght = (232 * 414)/320.0f;
        
        customVolumeBar.frame = frameBar;
        
        NSMutableArray *arrys = [NSMutableArray array];
        
        customVolumeBar = [customVolumeBar initWithFrame:frameBar :(frameBar.size.width)  :(frameBar.size.height) :1 :arrys];
        
        [self.view addSubview:customVolumeBar];
        
        //大仪表图窗口
        
        CGRect framebg = CGRectMake(bar_x,bar_y,bar_weight,bar_hreght);
        
        bar = [[VolumeBar alloc] initWithFrame:framebg :(250 * 414)/640.0f :(250 * 414)/640.0f :(250 * 414)/640.0f * 0.65f];
        
        bar._backgroundView.frame = CGRectMake(0, 0, bar_weight, bar_hreght);
        
        //        bar.type = PanelTypePower;
        [self.view addSubview:bar];
        
        //小仪表图
        UIWeiget *weight = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        
        CGRect frame = weight.frame;
        
        frame.origin.x = 17.5f;
        frame.origin.y =  bar_hreght + 104.0f;
        
        frame.size.width = 115.0f;
        frame.size.height = 115.0f;
        
        weight.frame = frame;
        
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
//        weight.WeigetLabel.text = @"温度℃";
        weight.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Temp_C"];
        weight.WeigetButton.tag = 1;
        //        weight.type = PanelTypeTemperature;
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
        [self.view addSubview:weight];
        
        UIWeiget *weight1 = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        CGRect frame1 = weight1.frame;
        
        frame1.origin.x = self.view.bounds.size.width - 115.0f - 17.5f;
        frame1.origin.y =  bar_hreght + 104.0f;
        frame1.size.width = 115.0f;
        frame1.size.height = 115.0f;
        
        weight1.frame = frame1;
        [weight1.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
//        weight1.WeigetLabel.text = @"电压V";
        weight1.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Voltage"];
        //        weight1.WeigetImage.image = [UIImage imageNamed:@"icon_U"];
        weight1.WeigetButton.tag = 2;
        [self.view addSubview:weight1];
        
        //电池图
        UIbattery *battery = [[[NSBundle mainBundle]loadNibNamed:@"UIbattery" owner:self options:nil]lastObject];
        CGRect batteryframe = battery.frame;
        
        batteryframe.origin.x = 17.5f + 115.0f + 20.0f;
        batteryframe.origin.y = bar_hreght + 104.0f;
        batteryframe.size.width = 115.0f;
        batteryframe.size.height = 115.0f;
        
        battery.frame = batteryframe;
        [self.view addSubview:battery];
        
        //低下三个图组
        UIthreecount *threecount = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe = threecount.frame;
        
        threeframe.origin.x = 10.0f;
        threeframe.origin.y = bar_hreght + 104.0f + 115.0f + 17.5f + 12.5f;
        
        threeframe.size.width = 115.0f;
        threeframe.size.height = 115.0f;
        
        threecount.frame = threeframe;
        threecount.threecountImage.image = [UIImage imageNamed:@"icon_whq"];
        threecount.threecountDataLabel.text = @"0Ω";
//        threecount.threecountNameLabel.text = @"雾化器";
        threecount.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Atomizer"];
        [self.view addSubview:threecount];
        
        //口数的视图
        UIthreecount *threecount2 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe2 = threecount2.frame;
        
        threeframe2.origin.x = 17.5f + 115.0f + 20.0f;
        threeframe2.origin.y = bar_hreght + 104.0f + 115.0f + 17.5f + 12.5f;
        
        threeframe2.size.width = 115.0f;
        threeframe2.size.height = 115.0f;
        
        threecount2.frame = threeframe2;
        threecount2.threecountImage.image = [UIImage imageNamed:@"icon_shape"];
//        threecount2.threecountDataLabel.text = @"0口";
        threecount2.threecountDataLabel.text = [NSString stringWithFormat:@"0%@",[InternationalControl return_string:@"Vapor_nums"]];
//        threecount2.threecountNameLabel.text = @"口数";
        threecount2.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_number"];
        [self.view addSubview:threecount2];
        
        
        UIthreecount *threecount3 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe3 = threecount3.frame;
        
        threeframe3.origin.x = self.view.bounds.size.width - 115.0f - 10.0f;
        threeframe3.origin.y =  bar_hreght + 104.0f + 115.0f + 17.5f + 12.5f;
        threeframe3.size.width = 115.0f;
        threeframe3.size.height = 115.0f;
        
        threecount3.frame = threeframe3;
        threecount3.threecountImage.image = [UIImage imageNamed:@"icon_clock"];
        threecount3.threecountDataLabel.text = @"0s";
//        threecount3.threecountNameLabel.text = @"时长";
        threecount3.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Times"];
        [self.view addSubview:threecount3];
        
        //变为可调用
        //self.instrument = instrument;
        self.voumebar = bar;
        self.weight = weight;
        self.weight1 = weight1;
        self.battery = battery;
        self.threecount = threecount;
        self.threecount2 = threecount2;
        self.threecount3 = threecount3;
        self.custombar = customVolumeBar;
    }
    else if(iPadAir)
    {
        ////////////////////////////////////////////////////////////////////////////////////////
        /*---------------------------------- iPadAir -----------------------------------------*/
        ////////////////////////////////////////////////////////////////////////////////////////

        //大仪表图
        bar_weight = (250 * 640)/320.0f;
        bar_hreght = (232 * 640)/320.0f;
        
        bar_x = (self.view.bounds.size.width - bar_weight)/2;
        bar_y = self.view.bounds.size.height - 920.0f;
        
        //自定义模式视图
        CustomVolumeBar *customVolumeBar = [[[NSBundle mainBundle]loadNibNamed:@"CustomVolumeBar" owner:self options:nil] lastObject];
        
        CGRect frameBar = customVolumeBar.frame;
        
        frameBar.origin.x = 10.0f;
        frameBar.origin.y = 64.0f;
        
        frameBar.size.width = SCREEN_WIDTH - 20;
        frameBar.size.height = (232 * 640)/320.0f;
        
        customVolumeBar.frame = frameBar;
        
        NSMutableArray *arrys = [NSMutableArray array];
        
        customVolumeBar = [customVolumeBar initWithFrame:frameBar :(frameBar.size.width)  :(frameBar.size.height) :1 :arrys];
        
        [self.view addSubview:customVolumeBar];
        
        //大仪表图窗口
        CGRect framebg = CGRectMake(bar_x,bar_y,bar_weight,bar_hreght);
        
        bar = [[VolumeBar alloc] initWithFrame:framebg :(250 * 640)/640.0f :(250 * 640)/640.0f :(250 * 640)/640.0f * 0.75f];
        
        bar._backgroundView.frame = CGRectMake(0, 0, bar_weight, bar_hreght);
        
        //        bar.type = PanelTypePower;
        [self.view addSubview:bar];
        
        //小仪表图
        UIWeiget *weight = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        
        CGRect frame = weight.frame;
        
        frame.origin.x = 57.0f;
        frame.origin.y =  bar_hreght + 104.0f;
        
        frame.size.width = 180.0f;
        frame.size.height = 180.0f;
        
        weight.frame = frame;
        
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
//        weight.WeigetLabel.text = @"温度℃";
        weight.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Temp_C"];
        weight.WeigetButton.tag = 1;
        //        weight.type = PanelTypeTemperature;
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
        [self.view addSubview:weight];
        
        UIWeiget *weight1 = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        CGRect frame1 = weight1.frame;
        
        frame1.origin.x = self.view.bounds.size.width - 180.0f - 57.0f;
        frame1.origin.y =  bar_hreght + 104.0f;
        frame1.size.width = 180.0f;
        frame1.size.height = 180.0f;
        
        weight1.frame = frame1;
        [weight1.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
//        weight1.WeigetLabel.text = @"电压V";
        weight1.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Voltage"];
        //        weight1.WeigetImage.image = [UIImage imageNamed:@"icon_U"];
        weight1.WeigetButton.tag = 2;
        [self.view addSubview:weight1];
        
        //电池图
        UIbattery *battery = [[[NSBundle mainBundle]loadNibNamed:@"UIbattery" owner:self options:nil]lastObject];
        CGRect batteryframe = battery.frame;
        
        batteryframe.origin.x = 57.0f + 180.0f + 57.0f;
        batteryframe.origin.y = bar_hreght + 104.0f;
        batteryframe.size.width = 180.0f;
        batteryframe.size.height = 180.0f;
        
        battery.frame = batteryframe;
        [self.view addSubview:battery];
        
        //低下三个图组
        UIthreecount *threecount = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe = threecount.frame;
        
        threeframe.origin.x = 57.0f;
        threeframe.origin.y = bar_hreght + 104.0f + 180.0f + 30.0f;
        
        threeframe.size.width = 180.0f;
        threeframe.size.height = 180.0f;
        
        threecount.frame = threeframe;
        threecount.threecountImage.image = [UIImage imageNamed:@"icon_whq"];
        threecount.threecountDataLabel.text = @"0Ω";
//        threecount.threecountNameLabel.text = @"雾化器";
        threecount.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Atomizer"];
        [self.view addSubview:threecount];
        
        //口数的视图
        UIthreecount *threecount2 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe2 = threecount2.frame;
        
        threeframe2.origin.x = 57.0f + 180.0f + 57.0f;
        threeframe2.origin.y = bar_hreght + 104.0f + 180.0f + 30.0f;
        
        threeframe2.size.width = 180.0f;
        threeframe2.size.height = 180.0f;
        
        threecount2.frame = threeframe2;
        threecount2.threecountImage.image = [UIImage imageNamed:@"icon_shape"];
//        threecount2.threecountDataLabel.text = @"0口";
        threecount2.threecountDataLabel.text = [NSString stringWithFormat:@"0%@",[InternationalControl return_string:@"Vapor_nums"]];
//        threecount2.threecountNameLabel.text = @"口数";
        threecount2.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_number"];
        [self.view addSubview:threecount2];
        
        
        UIthreecount *threecount3 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe3 = threecount3.frame;
        
        threeframe3.origin.x = self.view.bounds.size.width - 180.0f - 57.0f;
        threeframe3.origin.y = bar_hreght + 104.0f + 180.0f + 30.0f;
        
        threeframe3.size.width = 180.0f;
        threeframe3.size.height = 180.0f;
        
        threecount3.frame = threeframe3;
        threecount3.threecountImage.image = [UIImage imageNamed:@"icon_clock"];
        threecount3.threecountDataLabel.text = @"0s";
//        threecount3.threecountNameLabel.text = @"时长";
        threecount3.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Times"];
        [self.view addSubview:threecount3];
        
        //变为可调用
        //self.instrument = instrument;
        self.voumebar = bar;
        self.weight = weight;
        self.weight1 = weight1;
        self.battery = battery;
        self.threecount = threecount;
        self.threecount2 = threecount2;
        self.threecount3 = threecount3;
        self.custombar = customVolumeBar;
    }
    else if(iPadMini)
    {
        ////////////////////////////////////////////////////////////////////////////////////////
        /*---------------------------------- iPadMini ----------------------------------------*/
        ////////////////////////////////////////////////////////////////////////////////////////

        //大仪表图
        bar_weight = (250 * 640)/320.0f;
        bar_hreght = (232 * 640)/320.0f;
        
        bar_x = (self.view.bounds.size.width - bar_weight)/2;
        bar_y = self.view.bounds.size.height - 920.0f;
        
        //自定义模式视图
        CustomVolumeBar *customVolumeBar = [[[NSBundle mainBundle]loadNibNamed:@"CustomVolumeBar" owner:self options:nil] lastObject];
        
        CGRect frameBar = customVolumeBar.frame;
        
        frameBar.origin.x = 10.0f;
        frameBar.origin.y = 64.0f;
        
        frameBar.size.width = SCREEN_WIDTH - 20;
        frameBar.size.height = (232 * 640)/320.0f;
        
        customVolumeBar.frame = frameBar;
        
        NSMutableArray *arrys = [NSMutableArray array];
        
        customVolumeBar = [customVolumeBar initWithFrame:frameBar :(frameBar.size.width)  :(frameBar.size.height) :1 :arrys];
        
        [self.view addSubview:customVolumeBar];
        
        //大仪表图窗口
        CGRect framebg = CGRectMake(bar_x,bar_y,bar_weight,bar_hreght);
        
        bar = [[VolumeBar alloc] initWithFrame:framebg :(250 * 640)/640.0f :(250 * 640)/640.0f :(250 * 640)/640.0f * 0.75f];
        
        bar._backgroundView.frame = CGRectMake(0, 0, bar_weight, bar_hreght);
        
        //        bar.type = PanelTypePower;
        [self.view addSubview:bar];
        
        //小仪表图
        UIWeiget *weight = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        
        CGRect frame = weight.frame;
        
        frame.origin.x = 57.0f;
        frame.origin.y =  bar_hreght + 104.0f;
        
        frame.size.width = 180.0f;
        frame.size.height = 180.0f;
        
        weight.frame = frame;
        
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
//        weight.WeigetLabel.text = @"温度℃";
        weight.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Temp_C"];
        weight.WeigetButton.tag = 1;
        //        weight.type = PanelTypeTemperature;
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
        [self.view addSubview:weight];
        
        UIWeiget *weight1 = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        CGRect frame1 = weight1.frame;
        
        frame1.origin.x = self.view.bounds.size.width - 180.0f - 57.0f;
        frame1.origin.y =  bar_hreght + 104.0f;
        frame1.size.width = 180.0f;
        frame1.size.height = 180.0f;
        
        weight1.frame = frame1;
        [weight1.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
//        weight1.WeigetLabel.text = @"电压V";
        weight1.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Voltage"];
        //        weight1.WeigetImage.image = [UIImage imageNamed:@"icon_U"];
        weight1.WeigetButton.tag = 2;
        [self.view addSubview:weight1];
        
        //电池图
        UIbattery *battery = [[[NSBundle mainBundle]loadNibNamed:@"UIbattery" owner:self options:nil]lastObject];
        CGRect batteryframe = battery.frame;
        
        batteryframe.origin.x = 57.0f + 180.0f + 57.0f;
        batteryframe.origin.y = bar_hreght + 104.0f;
        batteryframe.size.width = 180.0f;
        batteryframe.size.height = 180.0f;
        
        battery.frame = batteryframe;
        [self.view addSubview:battery];
        
        //低下三个图组
        UIthreecount *threecount = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe = threecount.frame;
        
        threeframe.origin.x = 57.0f;
        threeframe.origin.y = bar_hreght + 104.0f + 180.0f + 30.0f;
        
        threeframe.size.width = 180.0f;
        threeframe.size.height = 180.0f;
        
        threecount.frame = threeframe;
        threecount.threecountImage.image = [UIImage imageNamed:@"icon_whq"];
        threecount.threecountDataLabel.text = @"0Ω";
//        threecount.threecountNameLabel.text = @"雾化器";
        threecount.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Atomizer"];
        [self.view addSubview:threecount];
        
        //口数的视图
        UIthreecount *threecount2 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe2 = threecount2.frame;
        
        threeframe2.origin.x = 57.0f + 180.0f + 57.0f;
        threeframe2.origin.y = bar_hreght + 104.0f + 180.0f + 30.0f;
        
        threeframe2.size.width = 180.0f;
        threeframe2.size.height = 180.0f;
        
        threecount2.frame = threeframe2;
        threecount2.threecountImage.image = [UIImage imageNamed:@"icon_shape"];
//        threecount2.threecountDataLabel.text = @"0口";
        threecount2.threecountDataLabel.text = [NSString stringWithFormat:@"0%@",[InternationalControl return_string:@"Vapor_nums"]];
//        threecount2.threecountNameLabel.text = @"口数";
        threecount2.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_number"];
        [self.view addSubview:threecount2];
        
        
        UIthreecount *threecount3 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe3 = threecount3.frame;
        
        threeframe3.origin.x = self.view.bounds.size.width - 180.0f - 57.0f;
        threeframe3.origin.y = bar_hreght + 104.0f + 180.0f + 30.0f;
        
        threeframe3.size.width = 180.0f;
        threeframe3.size.height = 180.0f;
        
        threecount3.frame = threeframe3;
        threecount3.threecountImage.image = [UIImage imageNamed:@"icon_clock"];
        threecount3.threecountDataLabel.text = @"0s";
//        threecount3.threecountNameLabel.text = @"时长";
        threecount3.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Times"];
        [self.view addSubview:threecount3];
        
        //变为可调用
        //self.instrument = instrument;
        self.voumebar = bar;
        self.weight = weight;
        self.weight1 = weight1;
        self.battery = battery;
        self.threecount = threecount;
        self.threecount2 = threecount2;
        self.threecount3 = threecount3;
        self.custombar = customVolumeBar;
    }
    else if(iPhone4)
    {
        ////////////////////////////////////////////////////////////////////////////////////////
        /*---------------------------------- iPhone4 -----------------------------------------*/
        ////////////////////////////////////////////////////////////////////////////////////////
        
        //大仪表图
        bar_weight = 200.0f;
        bar_hreght = 186.0f;
        
        //小仪表图
        UIWeiget *weight = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        
        CGRect frame = weight.frame;
        
        frame.origin.x = 10.0f;
        frame.origin.y =  bar_hreght + 54.0f;
        
        frame.size.width = 90.0f;
        frame.size.height = 90.0f;
        
        weight.frame = frame;
        
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
//        weight.WeigetLabel.text = @"温度℃";
        weight.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Temp_C"];
        weight.WeigetButton.tag = 1;
        //        weight.type = PanelTypeTemperature;
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
        [self.view addSubview:weight];
        
        UIWeiget *weight1 = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        CGRect frame1 = weight1.frame;
        
        frame1.origin.x = self.view.bounds.size.width - 90.0f - 10.0f;
        frame1.origin.y =  bar_hreght + 54.0f;
        frame1.size.width = 90.0f;
        frame1.size.height = 90.0f;
        
        weight1.frame = frame1;
        [weight1.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
//        weight1.WeigetLabel.text = @"电压V";
        weight1.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Voltage"];
        //        weight1.WeigetImage.image = [UIImage imageNamed:@"icon_U"];
        weight1.WeigetButton.tag = 2;
        [self.view addSubview:weight1];
        
        //电池图
        UIbattery *battery = [[[NSBundle mainBundle]loadNibNamed:@"UIbattery" owner:self options:nil]lastObject];
        CGRect batteryframe = battery.frame;
        
        batteryframe.origin.x = 10.0f + 90.0f + 20.0f;
        batteryframe.origin.y = bar_hreght + 54.0f;
        batteryframe.size.width = 90.0f;
        batteryframe.size.height = 90.0f;
        
        battery.frame = batteryframe;
        [self.view addSubview:battery];
        
        //低下三个图组
        UIthreecount *threecount = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe = threecount.frame;
        
        threeframe.origin.x = 0;
        threeframe.origin.y = bar_hreght + 100.0f + 44.0f + 10.0f;
        
        threeframe.size.width = 90.0f;
        threeframe.size.height = 90.0f;
        
        threecount.frame = threeframe;
        threecount.threecountImage.image = [UIImage imageNamed:@"icon_whq"];
        threecount.threecountDataLabel.text = @"0Ω";
//        threecount.threecountNameLabel.text = @"雾化器";
        threecount.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Atomizer"];

        [self.view addSubview:threecount];
        
        //口数的视图
        UIthreecount *threecount2 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe2 = threecount2.frame;
        
        threeframe2.origin.x = 10.0f + 90.0f + 20.0f;
        threeframe2.origin.y = bar_hreght + 100.0f + 44.0f + 10.0f;
        
        threeframe2.size.width = 90.0f;
        threeframe2.size.height = 90.0f;
        
        threecount2.frame = threeframe2;
        threecount2.threecountImage.image = [UIImage imageNamed:@"icon_shape"];
//        threecount2.threecountDataLabel.text = @"0口";
        threecount2.threecountDataLabel.text = [NSString stringWithFormat:@"0%@",[InternationalControl return_string:@"Vapor_nums"]];
//        threecount2.threecountNameLabel.text = @"口数";
        threecount2.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_number"];
        [self.view addSubview:threecount2];
        
        
        UIthreecount *threecount3 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe3 = threecount3.frame;
        
        threeframe3.origin.x = self.view.bounds.size.width - 90.0f;
        threeframe3.origin.y =  bar_hreght + 100.0f + 44.0f + 10.0f;
        threeframe3.size.width = 90.0f;
        threeframe3.size.height = 90.0f;
        
        threecount3.frame = threeframe3;
        threecount3.threecountImage.image = [UIImage imageNamed:@"icon_clock"];
        threecount3.threecountDataLabel.text = @"0s";
//        threecount3.threecountNameLabel.text = @"时长";
        threecount3.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Times"];
        [self.view addSubview:threecount3];
        
        //自定义模式视图
        CustomVolumeBar *customVolumeBar = [[[NSBundle mainBundle]loadNibNamed:@"CustomVolumeBar" owner:self options:nil] lastObject];
        
        CGRect frameBar = customVolumeBar.frame;
        
        frameBar.origin.x = 10.0f;
        frameBar.origin.y = 64.0f;
        
        frameBar.size.width = SCREEN_WIDTH - 20;
        frameBar.size.height = 186.0f;
        
        customVolumeBar.frame = frameBar;
        
        NSMutableArray *arrys = [NSMutableArray array];
        
        customVolumeBar = [customVolumeBar initWithFrame:frameBar :(frameBar.size.width)  :(frameBar.size.height) :1 :arrys];
        
        [self.view addSubview:customVolumeBar];
        
        //大仪表图窗口
        CGRect framebg = CGRectMake(self.view.bounds.size.width/2 -125, self.view.bounds.size.height - 440, 200, 186);
        bar = [[VolumeBar alloc] initWithFrame:framebg :125.0f :125.0f :55.0f];
        
        bar._backgroundView.frame = CGRectMake(25, 25, 200, 186);
        
        //        bar.type = PanelTypePower;
        [self.view addSubview:bar];
        
        //变为可调用
        //self.instrument = instrument;
        self.voumebar = bar;
        self.weight = weight;
        self.weight1 = weight1;
        self.battery = battery;
        self.threecount = threecount;
        self.threecount2 = threecount2;
        self.threecount3 = threecount3;
        self.custombar = customVolumeBar;
    }
    else
    {
        //如果识别不到此类的屏幕按照 iphone 6 进行布局，市面上大部分应该是iphone 6 屏幕比例布局 - by tyz 2017/02/10
        ////////////////////////////////////////////////////////////////////////////////////////
        /*---------------------------------- iPhone6 -----------------------------------------*/
        ////////////////////////////////////////////////////////////////////////////////////////
        
        //大仪表图
        bar_weight = (250* 375)/320.0f;
        bar_hreght = (232* 375)/320.0f;
        
        bar_x = (self.view.bounds.size.width - bar_weight)/2;
        bar_y = self.view.bounds.size.height - 560;
        
        //自定义模式视图
        CustomVolumeBar *customVolumeBar = [[[NSBundle mainBundle]loadNibNamed:@"CustomVolumeBar" owner:self options:nil] lastObject];
        
        CGRect frameBar = customVolumeBar.frame;
        
        frameBar.origin.x = 10.0f;
        frameBar.origin.y = 64.0f;
        
        frameBar.size.width = SCREEN_WIDTH - 20;
        frameBar.size.height = (232* 375)/320.0f;
        
        customVolumeBar.frame = frameBar;
        
        NSMutableArray *arrys = [NSMutableArray array];
        
        customVolumeBar = [customVolumeBar initWithFrame:frameBar :(frameBar.size.width)  :(frameBar.size.height) :1 :arrys];
        
        [self.view addSubview:customVolumeBar];
        
        //大仪表图窗口
        CGRect framebg = CGRectMake(bar_x,bar_y,bar_weight,bar_hreght);
        
        bar = [[VolumeBar alloc] initWithFrame:framebg :(250 * 375)/640.0f :(250 * 375)/640.0f :(250 * 375)/640.0f * 0.65f];
        
        bar._backgroundView.frame = CGRectMake(0, 0, bar_weight, bar_hreght);
        
        //        bar.type = PanelTypePower;
        [self.view addSubview:bar];
        
        //小仪表图
        UIWeiget *weight = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        
        CGRect frame = weight.frame;
        
        frame.origin.x = 17.5f;
        frame.origin.y =  bar_hreght + 104.0f;
        
        frame.size.width = 100.0f;
        frame.size.height = 100.0f;
        
        weight.frame = frame;
        
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
        //        weight.WeigetLabel.text = @"温度℃";
        weight.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Temp_C"];
        weight.WeigetButton.tag = 1;
        //        weight.type = PanelTypeTemperature;
        [weight.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
        [self.view addSubview:weight];
        
        UIWeiget *weight1 = [[[NSBundle mainBundle]loadNibNamed:@"UIWeiget" owner:self options:nil] lastObject];
        CGRect frame1 = weight1.frame;
        
        frame1.origin.x = self.view.bounds.size.width - 100.0f - 17.5f;
        frame1.origin.y =  bar_hreght + 104.0f;
        frame1.size.width = 100.0f;
        frame1.size.height = 100.0f;
        
        weight1.frame = frame1;
        [weight1.WeigetButton setTitle:@"0" forState:UIControlStateNormal];
        //        weight1.WeigetLabel.text = @"电压V";
        weight1.WeigetLabel.text = [InternationalControl return_string:@"Vapor_Voltage"];
        //        weight1.WeigetImage.image = [UIImage imageNamed:@"icon_U"];
        weight1.WeigetButton.tag = 2;
        [self.view addSubview:weight1];
        
        //电池图
        UIbattery *battery = [[[NSBundle mainBundle]loadNibNamed:@"UIbattery" owner:self options:nil]lastObject];
        CGRect batteryframe = battery.frame;
        
        batteryframe.origin.x = 17.5f + 100.0f + 20.0f;
        batteryframe.origin.y = bar_hreght + 104.0f;
        batteryframe.size.width = 100.0f;
        batteryframe.size.height = 100.0f;
        
        battery.frame = batteryframe;
        [self.view addSubview:battery];
        
        //低下三个图组
        UIthreecount *threecount = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe = threecount.frame;
        
        threeframe.origin.x = 10.0f;
        threeframe.origin.y = bar_hreght + 104.0f + 100.0f + 17.5f;
        
        threeframe.size.width = 100.0f;
        threeframe.size.height = 100.0f;
        
        threecount.frame = threeframe;
        threecount.threecountImage.image = [UIImage imageNamed:@"icon_whq"];
        threecount.threecountDataLabel.text = @"0Ω";
        //        threecount.threecountNameLabel.text = @"雾化器";
        threecount.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Atomizer"];
        [self.view addSubview:threecount];
        
        //口数的视图
        UIthreecount *threecount2 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe2 = threecount2.frame;
        
        threeframe2.origin.x = 17.5f + 100.0f + 20.0f;
        threeframe2.origin.y = bar_hreght + 104.0f + 100.0f + 17.5f;
        
        threeframe2.size.width = 100.0f;
        threeframe2.size.height = 100.0f;
        
        threecount2.frame = threeframe2;
        threecount2.threecountImage.image = [UIImage imageNamed:@"icon_shape"];
        //        threecount2.threecountDataLabel.text = @"0口";
        threecount2.threecountDataLabel.text = [NSString stringWithFormat:@"0%@",[InternationalControl return_string:@"Vapor_nums"]];
        //        threecount2.threecountNameLabel.text = @"口数";
        threecount2.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_number"];
        [self.view addSubview:threecount2];
        
        
        UIthreecount *threecount3 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
        CGRect threeframe3 = threecount3.frame;
        
        threeframe3.origin.x = self.view.bounds.size.width - 100.0f - 10.0f;
        threeframe3.origin.y =  bar_hreght + 104.0f + 100.0f + 17.5f;
        threeframe3.size.width = 100.0f;
        threeframe3.size.height = 100.0f;
        
        threecount3.frame = threeframe3;
        threecount3.threecountImage.image = [UIImage imageNamed:@"icon_clock"];
        threecount3.threecountDataLabel.text = @"0s";
        //        threecount3.threecountNameLabel.text = @"时长";
        threecount3.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Times"];
        [self.view addSubview:threecount3];
        
        //变为可调用
        //self.instrument = instrument;
        self.voumebar = bar;
        self.weight = weight;
        self.weight1 = weight1;
        self.battery = battery;
        self.threecount = threecount;
        self.threecount2 = threecount2;
        self.threecount3 = threecount3;
        self.custombar = customVolumeBar;
    }
    
    //初始化吸烟口数
    [Session sharedInstance].total = 0;
    self.threecount2.threecountDataLabel.text = [NSString stringWithFormat:@"%lu%@",(unsigned long)[Session sharedInstance].total,[InternationalControl return_string:@"Vapor_nums"]];
    
    //初始化扫描按钮状态
    btn_delete_type = 0;
    
    //设置电池为0
    self.battery.batteryImage.image = [UIImage imageNamed:@"icon_battery"];
    self.battery.batteryLabel.text = @"0%";
    
    //添加左右按钮点击事件
    //电压 主页面两个按钮点击执行的方法
    [self.weight.WeigetButton addTarget:self action:@selector(clickLeftBt) forControlEvents:UIControlEventTouchUpInside];
    
    [self.weight1.WeigetButton addTarget:self action:@selector(clickLeftBtn1) forControlEvents:UIControlEventTouchUpInside];
    
    //给雾化器按钮添加点击事件
    self.threecount.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap_threecount =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClick_threecount)];
    [self.threecount addGestureRecognizer:singleTap_threecount];
    
    //给voumebar的标签添加点击事件
    self.voumebar.instrumentLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap_voumebar_instrumentLabel =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickVoumebar_instrumentLabel)];
    [self.voumebar.instrumentLabel addGestureRecognizer:singleTap_voumebar_instrumentLabel];
    
    self.custombar.instrumentLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap_customLable =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickCustomLable)];
    [self.custombar.instrumentLabel addGestureRecognizer:singleTap_customLable];
    
    self.voumebar.hidden = NO;
    self.custombar.hidden = YES;
}

//雾化器按钮点击事件
-(void)onClick_threecount
{
    if ([STW_BLE_SDK STW_SDK].voumebarType == BLEProtocolModeTypeTemperature)
    {
//        [self showAlert:@"chooseTemp"];
        if (![STW_BLEService sharedInstance].isVaporNow)
        {
            [self showAlert:@"chooseTemp"];
        }
    }
}

//Custom的标签添加点击事件
-(void)onClickCustomLable
{
//    [self showAlert:@"Custom"];
    if (![STW_BLEService sharedInstance].isVaporNow)
    {
        [self showAlert:@"Custom"];
    }
}

//voumebar的标签添加点击事件
-(void)onClickVoumebar_instrumentLabel
{
    switch ([STW_BLE_SDK STW_SDK].voumebarType)
    {
        case BLEProtocolModeTypeTemperature:
        {
            if ([STW_BLE_SDK STW_SDK].temperatureMold == BLEProtocolTemperatureUnitCelsius)
            {
                [STW_BLE_Protocol the_work_mode_temp:BLEProtocolTemperatureUnitFahrenheit :[STW_BLE_Protocol temperatureUnitCelsiusToFahrenheit:[STW_BLE_SDK STW_SDK].temperature] :[STW_BLE_SDK STW_SDK].atomizerMold :0x00];
            }
            else
            {
                int temperature = [STW_BLE_Protocol temperatureUnitFahrenheitToCelsius:[STW_BLE_SDK STW_SDK].temperature];
                
                if (temperature < 100)
                {
                    temperature = 100;
                }
                
                [STW_BLE_Protocol the_work_mode_temp:BLEProtocolTemperatureUnitCelsius :temperature :[STW_BLE_SDK STW_SDK].atomizerMold :0x00];
            }
        }
            break;
        default:
            break;
    }
}

//修改设备名称
-(void)onClickTitle
{
    if ([STW_BLEService sharedInstance].isBLEStatus)
    {
        NSLog(@"修改设备名称");
//        [STW_BLE_Protocol the_set_device_name:@"STWTYZ"];
        [self showChangeDeviceName];
    }
}

-(void)showChangeDeviceName
{
//    NSString *str_title = @"修改设备名称";
//    NSString *message = @"修改设备名称最长为5个汉字!";
//    NSString *okButtonTitle = @"确认";
//    NSString *cancleButtonTitle = @"取消";
    
    NSString *str_title = [InternationalControl return_string:@"Vapor_change_DeviceName"];
    NSString *message = [InternationalControl return_string:@"Vapor_change_DeviceName_message"];
    NSString *okButtonTitle = [InternationalControl return_string:@"window_confirm"];
    NSString *cancleButtonTitle = [InternationalControl return_string:@"window_cancle"];
    
    // 初始化
    _alertDialog = [UIAlertController alertControllerWithTitle:str_title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // 创建文本框
    [_alertDialog addTextFieldWithConfigurationHandler:^(UITextField *textField){
//        textField.placeholder = @"请输入设备名称";
        textField.placeholder = [InternationalControl return_string:@"Vapor_change_DeviceName_warning"];
        textField.secureTextEntry = NO;
    }];
    
    // 创建操作
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                               {
                                   // 读取文本框的值显示出来
                                   UITextField *deviceNameText = _alertDialog.textFields.firstObject;

                                   str_change_deviceName = deviceNameText.text;
                                   
                                   NSData *nameData = [STW_BLE_Protocol getDatastr:str_change_deviceName];
                                   
                                   Byte *NumeStrs = (Byte *)[nameData bytes];
                                   //组装数据发送给电子烟
                                   int len_num = NumeStrs[0];

                                   if (len_num > 0 && len_num <= 16)
                                   {
                                       [STW_BLE_Protocol the_set_device_name:str_change_deviceName];
                                       
                                       [self setDeviceNameBack];
                                   }
                                   else
                                   {
//                                       [ProgressHUD showError:@"设备名称长度错误"];
                                       [ProgressHUD showError:[InternationalControl return_string:@"Vapor_change_DeviceName_error"]];
                                   }
                               }];
    
    // 创建操作
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:cancleButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"取消修改");
                               }];
    
    // 添加操作（顺序就是呈现的上下顺序）
    [_alertDialog addAction:cancleAction];
    // 添加操作（顺序就是呈现的上下顺序）
    [_alertDialog addAction:okAction];

    // 呈现警告视图
    [self presentViewController:_alertDialog animated:YES completion:nil];
}

//注册设置名字的回调
-(void)setDeviceNameBack
{
    [STW_BLEService sharedInstance].Service_SetDeviceName = ^(int checkNum)
    {
        if (checkNum == 0x00)
        {
            title.title.text = str_change_deviceName;
            [STW_BLEService sharedInstance].device.deviceName = str_change_deviceName;
//            [ProgressHUD showSuccess:@"设置名称成功"];
            [ProgressHUD showSuccess:[InternationalControl return_string:@"Vapor_change_DeviceName_failure"]];
            
            [self updateName:[STW_BLEService sharedInstance].device.deviceMac :str_change_deviceName];
        }
        else
        {
//            [ProgressHUD showError:@"设置名称失败"];
            [ProgressHUD showError:[InternationalControl return_string:@"Vapor_change_DeviceName_success"]];
        }
    };
}

//跟新网络名字
-(void)updateName:(NSString *)devices :(NSString *)name
{
    [User updateName:devices :name success:^(id data)
     {
         NSLog(@"success!");
     }
             failure:^(NSString *message)
     {
         NSLog(@"Error!");
     }];
}

//按钮
-(void)clickLeftBt
{
    NSLog(@"左边");
    switch ([STW_BLE_SDK STW_SDK].weightType_left)
    {
        case BLEProtocolModeTypePower:
        {
            if ([STW_BLE_SDK STW_SDK].power > 0)
            {
                [STW_BLE_Protocol the_work_mode_power:[STW_BLE_SDK STW_SDK].power :0x03];
            }
            else
            {
                [STW_BLE_Protocol the_work_mode_power:800 :0x03];
            }
        }
            break;
            
        case BLEProtocolModeTypeVoltage:
        {
            if ([STW_BLE_SDK STW_SDK].voltage > 0)
            {
                [STW_BLE_Protocol the_work_mode_voltage:[STW_BLE_SDK STW_SDK].voltage :0x03];
            }
            else
            {
                [STW_BLE_Protocol the_work_mode_voltage:850 :0x03];
            }
            NSLog(@"BLEProtocolModeTypeVoltage");
        }
            break;
            
        case BLEProtocolModeTypeTemperature:
        {
            NSLog(@"BLEProtocolModeTypeTemperature");
//            [self showAlert:@"chooseTemp"];
            if (![STW_BLEService sharedInstance].isVaporNow)
            {
                [self showAlert:@"chooseTemp"];
            }
        }
            break;
            
        case BLEProtocolModeTypeBypas:
        {
            NSLog(@"BLEProtocolModeTypeBypas");
            [STW_BLE_Protocol the_work_mode_bypass];
        }
            break;
            
        case BLEProtocolModeTypeCustom:
        {
            NSLog(@"BLEProtocolModeTypeCustom");
            
            if([STW_BLE_SDK STW_SDK].curvePowerModel > 0)
            {
                [STW_BLE_Protocol the_work_mode_custom:[STW_BLE_SDK STW_SDK].curvePowerModel];
            }
            else
            {
                [STW_BLE_Protocol the_work_mode_custom:1];
            }
        }
            break;
            
        default:
            break;
    }
}

//按钮
-(void)clickLeftBtn1
{
//    NSLog(@"右边");
    switch ([STW_BLE_SDK STW_SDK].weightType_right)
    {
        {
        case BLEProtocolModeTypePower:
            {
                if ([STW_BLE_SDK STW_SDK].power > 0)
                {
                    [STW_BLE_Protocol the_work_mode_power:[STW_BLE_SDK STW_SDK].power :0x03];
                }
                else
                {
                    [STW_BLE_Protocol the_work_mode_power:800 :0x03];
                }
            }
            break;
            
        case BLEProtocolModeTypeVoltage:
            {
                if ([STW_BLE_SDK STW_SDK].voltage > 0)
                {
                    [STW_BLE_Protocol the_work_mode_voltage:[STW_BLE_SDK STW_SDK].voltage :0x03];
                }
                else
                {
                    [STW_BLE_Protocol the_work_mode_voltage:850 :0x03];
                }
                NSLog(@"BLEProtocolModeTypeVoltage");
            }
            break;
            
        case BLEProtocolModeTypeTemperature:
            {
                NSLog(@"BLEProtocolModeTypeTemperature");
//                [self showAlert:@"chooseTemp"];
                if (![STW_BLEService sharedInstance].isVaporNow)
                {
                    [self showAlert:@"chooseTemp"];
                }
            }
            break;
            
        case BLEProtocolModeTypeBypas:
            {
                NSLog(@"BLEProtocolModeTypeBypas");
                [STW_BLE_Protocol the_work_mode_bypass];
            }
            break;
            
        case BLEProtocolModeTypeCustom:
            {
                NSLog(@"BLEProtocolModeTypeCustom");
                
                if([STW_BLE_SDK STW_SDK].curvePowerModel > 0)
                {
                    [STW_BLE_Protocol the_work_mode_custom:[STW_BLE_SDK STW_SDK].curvePowerModel];
                }
                else
                {
                    [STW_BLE_Protocol the_work_mode_custom:1];
                }
            }
            break;
            
        default:
            break;
        }
    }
}

//弹出选择框
-(void)showAlert:(NSString *)string
{
    if ([string isEqualToString:@"chooseTemp"])
    {
        checkMessage = 0;
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"选择雾化器" message:@"请保持雾化器为常温状态!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"Ni200",@"Ti01",@"Ss316",@"Nicr",@"M1",@"M2",@"M3", nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[InternationalControl return_string:@"Vapor_choose_Atomizer"] message:[InternationalControl return_string:@"Vapor_choose_Atomizer_message"] delegate:self cancelButtonTitle:[InternationalControl return_string:@"window_cancle"] otherButtonTitles:@"Ni200",@"Ti01",@"Ss316",@"Nicr",@"M1",@"M2",@"M3", nil];
        [alert show];
    }
    else if ([string isEqualToString:@"Custom"])
    {
        checkMessage = 1;
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"选择曲线" message:@"请选择功率控制曲线" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"C1",@"C2",@"C3", nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[InternationalControl return_string:@"Vapor_choose_Custom"] message:[InternationalControl return_string:@"Vapor_choose_Custom_message"] delegate:self cancelButtonTitle:[InternationalControl return_string:@"window_cancle"] otherButtonTitles:@"C1",@"C2",@"C3", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (checkMessage == 0)
    {
        if(buttonIndex > 0)
        {
            switch (buttonIndex)
            {
                case 1:
                {
                    if ([STW_BLE_SDK STW_SDK].temperature > 0)
                    {
                        [STW_BLE_Protocol the_work_mode_temp:[STW_BLE_SDK STW_SDK].temperatureMold :[STW_BLE_SDK STW_SDK].temperature :BLEAtomizerA1 :0x00];
                    }
                    else
                    {
                        [STW_BLE_Protocol the_work_mode_temp:BLEProtocolTemperatureUnitFahrenheit :600 :BLEAtomizerA1 :0x00];
                    }
                    NSLog(@"Ni");
                }
                    break;
                case 2:
                {
                    NSLog(@"Ti01");
                    if ([STW_BLE_SDK STW_SDK].temperature > 0)
                    {
                        [STW_BLE_Protocol the_work_mode_temp:[STW_BLE_SDK STW_SDK].temperatureMold :[STW_BLE_SDK STW_SDK].temperature :BLEAtomizerA2 :0x00];
                    }
                    else
                    {
                        [STW_BLE_Protocol the_work_mode_temp:BLEProtocolTemperatureUnitFahrenheit :600 :BLEAtomizerA2 :0x00];
                    }
                }
                    break;
                case 3:
                {
                    NSLog(@"Ss316");
                    if ([STW_BLE_SDK STW_SDK].temperature > 0)
                    {
                        [STW_BLE_Protocol the_work_mode_temp:[STW_BLE_SDK STW_SDK].temperatureMold :[STW_BLE_SDK STW_SDK].temperature :BLEAtomizerA4 :0x00];
                    }
                    else
                    {
                        [STW_BLE_Protocol the_work_mode_temp:BLEProtocolTemperatureUnitFahrenheit :600 :BLEAtomizerA4 :0x00];
                    }
                }
                    break;
                case 4:
                {
                    NSLog(@"Nicr");
                    if ([STW_BLE_SDK STW_SDK].temperature > 0)
                    {
                        [STW_BLE_Protocol the_work_mode_temp:[STW_BLE_SDK STW_SDK].temperatureMold :[STW_BLE_SDK STW_SDK].temperature :BLEAtomizerA5 :0x00];
                    }
                    else
                    {
                        [STW_BLE_Protocol the_work_mode_temp:BLEProtocolTemperatureUnitFahrenheit :600 :BLEAtomizerA5 :0x00];
                    }
                }
                    break;
                case 5:
                {
                    NSLog(@"M1");
                    if ([STW_BLE_SDK STW_SDK].temperature > 0)
                    {
                        [STW_BLE_Protocol the_work_mode_temp:[STW_BLE_SDK STW_SDK].temperatureMold :[STW_BLE_SDK STW_SDK].temperature :BLEAtomizersM1 :0x00];
                    }
                    else
                    {
                        [STW_BLE_Protocol the_work_mode_temp:BLEProtocolTemperatureUnitFahrenheit :600 :BLEAtomizersM1 :0x00];
                    }
                }
                    break;
                case 6:
                {
                    NSLog(@"M2");
                    if ([STW_BLE_SDK STW_SDK].temperature > 0)
                    {
                        [STW_BLE_Protocol the_work_mode_temp:[STW_BLE_SDK STW_SDK].temperatureMold :[STW_BLE_SDK STW_SDK].temperature :BLEAtomizersM2 :0x00];
                    }
                    else
                    {
                        [STW_BLE_Protocol the_work_mode_temp:BLEProtocolTemperatureUnitFahrenheit :600 :BLEAtomizersM2 :0x00];
                    }
                }
                    break;
                case 7:
                {
                    NSLog(@"M3");
                    if ([STW_BLE_SDK STW_SDK].temperature > 0)
                    {
                        [STW_BLE_Protocol the_work_mode_temp:[STW_BLE_SDK STW_SDK].temperatureMold :[STW_BLE_SDK STW_SDK].temperature :BLEAtomizersM3 :0x00];
                    }
                    else
                    {
                        [STW_BLE_Protocol the_work_mode_temp:BLEProtocolTemperatureUnitFahrenheit :600 :BLEAtomizersM3 :0x00];
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }
    else  if (checkMessage == 1)
    {
        if(buttonIndex > 0)
        {
            switch (buttonIndex)
            {
                case 1:
                {
                    [STW_BLE_Protocol the_work_mode_custom:BLEProtocolCustomLineCommand01];
                }
                    break;
                case 2:
                {
                    [STW_BLE_Protocol the_work_mode_custom:BLEProtocolCustomLineCommand02];
                }
                    break;
                case 3:
                {
                    [STW_BLE_Protocol the_work_mode_custom:BLEProtocolCustomLineCommand03];
                }
                    break;
                default:
                    break;
            }
        }
    }
}

//扫描到设备的回调
-(void)Service_scanHandler
{
    [STW_BLEService sharedInstance].Service_scanHandler = ^(STW_BLEDevice *device)
    {
        //判定是否有设备已经连接
        if ([STW_BLEService sharedInstance].isBLEStatus)
        {
            //有设备连接 - 不作出任何反应
        }
        else
        {
            /**
             *  还没有设备进行连接 调用蓝牙连接
             *  1.判定是否是绑定的设备
             *  2.调取蓝牙连接
             */
            for (Device *devices in [Session sharedInstance].deviceArrys)
            {
                if ([devices.address isEqualToString:device.deviceMac])
                {
                    if ([STW_BLEService sharedInstance].isBLEType == STW_BLE_IsBLETypeOff)
                    {
//                        NSLog(@"成功");
                        [STW_BLEService sharedInstance].isBLEType = STW_BLE_IsBLETypeLoding;
                        //弹出连接成功的弹窗
                        [ProgressHUD showSuccess:nil];
                    }
                    
                    //表示当前没有蓝牙正在请求连接 check_ble_status = YES;
                    if(check_ble_status)
                    {
                        check_ble_status = NO;
                        //注册连接成功的回调
                        [self Service_connectedHandler];
                        //有符合对象调用连接 -(void)connect:(STW_BLEDevice *)device;
                        [[STW_BLEService sharedInstance] connect:device];
                        //延时设置为没有请求
                        [self performSelector:@selector(check_ble_status_delay) withObject:nil afterDelay:2.0f];
                    }
                }
            }
        }
    };
}

//让其他设备可以再次请求
-(void)check_ble_status_delay
{
    check_ble_status = YES;
}

//连接成功的回调
-(void)Service_connectedHandler
{
    [STW_BLEService sharedInstance].Service_connectedHandler = ^(void)
    {
        [STW_BLEService sharedInstance].isBLEStatus = YES;
    
        //让其他设备还可以连接
        check_ble_status = YES;
        
        [STW_BLE_SDK STW_SDK].max_power = 80;
        
//        NSLog(@"[STW_BLEService sharedInstance].device.deviceModel - %d",[STW_BLEService sharedInstance].device.deviceModel);
        
        switch ([STW_BLEService sharedInstance].device.deviceModel)
        {
            case BLEDerviceModelSTW01:
                [STW_BLE_SDK STW_SDK].max_power = 40;
                break;
            case BLEDerviceModelSTW02:
                [STW_BLE_SDK STW_SDK].max_power = 50;
                break;
            case BLEDerviceModelSTW03:
                [STW_BLE_SDK STW_SDK].max_power = 60;
                break;
            case BLEDerviceModelSTW04:
                [STW_BLE_SDK STW_SDK].max_power = 70;
                break;
            case BLEDerviceModelSTW05:
                [STW_BLE_SDK STW_SDK].max_power = 80;
                break;
            case BLEDerviceModelSTW06:
                [STW_BLE_SDK STW_SDK].max_power = 90;
                break;
            case BLEDerviceModelSTW07:
                [STW_BLE_SDK STW_SDK].max_power = 100;
                break;
            case BLEDerviceModelSTW08:
                [STW_BLE_SDK STW_SDK].max_power = 150;
                break;
            case BLEDerviceModelSTW09:
                [STW_BLE_SDK STW_SDK].max_power = 200;
                break;
            case BLEDerviceModelSTW10:
                [STW_BLE_SDK STW_SDK].max_power = 213;
                break;
            default:
                [STW_BLE_SDK STW_SDK].max_power = 80;
                break;
        }
        
        [self refreshRightBtn:[STW_BLEService sharedInstance].isBLEStatus];
        
        [STW_BLEService sharedInstance].isBLEType = STW_BLE_IsBLETypeLoding;
        
        //注册断开连接回调
        [self Ble_disconnectHandler];
        
        //注册开始服务的回调
        [self start_service];
    };
}

//刷新右侧小按钮UI
-(void)refreshRightBtn:(int)btnCheck_num
{
    if(btnCheck_num)
    {
        [deletebutton setBackgroundImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
    }
    else
    {
        [deletebutton setBackgroundImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    }
}

//注册断开连接的回调
-(void)Ble_disconnectHandler
{
    [STW_BLEService sharedInstance].Service_disconnectHandler = ^(void)
    {
        NSLog(@"断开");
    
        //初始化
//        [STW_BLEService initInstance];
        
        [STW_BLEService sharedInstance].isBLEStatus = NO;
        
        if ([STW_BLEService sharedInstance].isBLEType == STW_BLE_IsBLETypeLoding)
        {
            NSLog(@"等待重连 - Loding");
            [[STW_BLEService sharedInstance] scanStart];
            
            [self performSelector:@selector(addLodingDevice) withObject:nil afterDelay:2.0f];
        }
        else if ([STW_BLEService sharedInstance].isBLEType == STW_BLE_IsBLETypeOff)
        {
            NSLog(@"清除UI - OFF");
            [self refreshRightBtn:[STW_BLEService sharedInstance].isBLEStatus];
            
            [self cleanMainUI];
        }
    };
}

//延时执行断线重连
-(void)addLodingDevice
{
    if (![STW_BLEService sharedInstance].isBLEStatus)
    {
        [[STW_BLEService sharedInstance] scanStop];
        
        [self refreshRightBtn:[STW_BLEService sharedInstance].isBLEStatus];
        
        [self cleanMainUI];
    }
}

//注册开始设备服务的回调
-(void)start_service
{
    [STW_BLEService sharedInstance].Service_discoverCharacteristicsForServiceHandler = ^()
    {
        NSLog(@"设备连接成功 - 进行初始查询");
        
        title.title.text = [STW_BLEService sharedInstance].device.deviceName;
        
        [STW_BLE_SDK STW_SDK].root_lock_status = 1;
        
        //注册所有用到数据的BLE回调
        [self BleReceiveData];
        //查询所有配置信息
        [self find_all_data];
    };
}

//查询所有配置信息
-(void)find_all_data
{
    //查询
    [STW_BLE_Protocol the_find_all_data];
    //延时设置设备时间
    [self performSelector:@selector(setDeviceTime) withObject:nil afterDelay:0.2f];
}

//设置设备系统时间
-(void)setDeviceTime
{
    NSLog(@"进行时间设置");
    //设置
    [STW_BLE_Protocol the_set_time];
}

//蓝牙信息接收
-(void)BleReceiveData
{
    //注册返回所有信息的回调
    
    //注册功率模式回调
    [STW_BLEService sharedInstance].Service_Power = ^(int power)
    {
        self.voumebar.hidden = NO;
        self.custombar.hidden = YES;
        
        [STW_BLE_SDK STW_SDK].power = power;
        
        [STW_BLE_SDK STW_SDK].vaporModel = BLEProtocolModeTypePower;
        
        //功率模式最大最小值  1W  80W
        [STW_BLE_SDK STW_SDK].voumebarMax = [STW_BLE_SDK STW_SDK].max_power;
        [STW_BLE_SDK STW_SDK].voumebarMin = 1;
        
        [STW_BLE_SDK STW_SDK].weightType_left = BLEProtocolModeTypeTemperature;  //左边
        [STW_BLE_SDK STW_SDK].voumebarType = BLEProtocolModeTypePower;     //中间
        [STW_BLE_SDK STW_SDK].weightType_right = BLEProtocolModeTypeVoltage; //右边
        
        [self updateWeightUI];
        
        [self.voumebar updateUI:BLEProtocolModeTypePower :power];
    };
    
    //注册电压模式回调
    [STW_BLEService sharedInstance].Service_Voltage = ^(int voltage)
    {
        self.voumebar.hidden = NO;
        self.custombar.hidden = YES;
        
        //电压模式最大最小值  0.0V  8.5V
        
        [STW_BLE_SDK STW_SDK].voltage = voltage;
        
        [STW_BLE_SDK STW_SDK].vaporModel = BLEProtocolModeTypeVoltage;
        
        [STW_BLE_SDK STW_SDK].voumebarMax = 85;  //8.5V
        [STW_BLE_SDK STW_SDK].voumebarMin = 0;   //0V
        
        [STW_BLE_SDK STW_SDK].weightType_left = BLEProtocolModeTypePower;  //左边
        [STW_BLE_SDK STW_SDK].voumebarType = BLEProtocolModeTypeVoltage;   //中间
        [STW_BLE_SDK STW_SDK].weightType_right = BLEProtocolModeTypeBypas; //右边
        
        [self updateWeightUI];
        
        [self.voumebar updateUI:BLEProtocolModeTypeVoltage :voltage];
    };
    
    //注册温度模式回调
    [STW_BLEService sharedInstance].Service_Temp = ^(int temp,int tempModel)
    {
        self.voumebar.hidden = NO;
        self.custombar.hidden = YES;
        
        //电压模式最大最小值  200F  600F   100℃  315℃
        
        [STW_BLE_SDK STW_SDK].temperature = temp;
        
        [STW_BLE_SDK STW_SDK].temperatureMold = tempModel;
        
        [STW_BLE_SDK STW_SDK].vaporModel = BLEProtocolModeTypeTemperature;
        
        if (tempModel == BLEProtocolTemperatureUnitCelsius)
        {
            [STW_BLE_SDK STW_SDK].voumebarMax = 315;
            [STW_BLE_SDK STW_SDK].voumebarMin = 100;
        }
        else
        {
            [STW_BLE_SDK STW_SDK].voumebarMax = 600;
            [STW_BLE_SDK STW_SDK].voumebarMin = 200;
        }
        
        [STW_BLE_SDK STW_SDK].weightType_left = BLEProtocolModeTypeCustom;  //左边
        [STW_BLE_SDK STW_SDK].voumebarType = BLEProtocolModeTypeTemperature;    //中间
        [STW_BLE_SDK STW_SDK].weightType_right = BLEProtocolModeTypePower;  //右边
        
        [self updateWeightUI];
        
//        NSLog(@"Max %d,min %d,temp %d,tempModel %d",[STW_BLE_SDK STW_SDK].voumebarMax,[STW_BLE_SDK STW_SDK].voumebarMin,temp,tempModel);
        
        [self.voumebar updateUI:BLEProtocolModeTypeTemperature :temp];
    };
    
    //注册ByPass模式回调
    [STW_BLEService sharedInstance].Service_WorkMold_ByPass = ^()
    {
        self.voumebar.hidden = NO;
        self.custombar.hidden = YES;
        
        [STW_BLE_SDK STW_SDK].vaporModel = BLEProtocolModeTypeBypas;
        
        [STW_BLE_SDK STW_SDK].weightType_left = BLEProtocolModeTypeVoltage;  //左边
        [STW_BLE_SDK STW_SDK].voumebarType = BLEProtocolModeTypeBypas;    //中间
        [STW_BLE_SDK STW_SDK].weightType_right = BLEProtocolModeTypeCustom;  //右边
        
        [self updateWeightUI];
        
        [self.voumebar updateUI:BLEProtocolModeTypeBypas :0];
    };
    
    //注册Custom模式回调
    [STW_BLEService sharedInstance].Service_WorkMold_Custom = ^(int CustomMold)
    {
        self.voumebar.hidden = YES;
        self.custombar.hidden = NO;
        
        [STW_BLE_SDK STW_SDK].curvePowerModel = CustomMold;
        
        [STW_BLE_SDK STW_SDK].vaporModel = BLEProtocolModeTypeCustom;
        
        [STW_BLE_SDK STW_SDK].weightType_left = BLEProtocolModeTypeBypas;  //左边
        [STW_BLE_SDK STW_SDK].voumebarType = BLEProtocolModeTypeCustom;    //中间
        [STW_BLE_SDK STW_SDK].weightType_right = BLEProtocolModeTypeTemperature;  //右边
        
        //立即查询曲线数据
        [STW_BLE_Protocol the_find_Power_line:0x00 :CustomMold :0x00];
        
        //注册查询Custom 曲线的回调
        [self find_custom_back];
        
        //延时实行刷新
        [ProgressHUD show:nil];
        
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           //延时方法
                           [ProgressHUD dismiss];
                           
                           NSLog(@"刷新 Custom UI");
                           
                           [self updateWeightUI];
                   
                           //[STW_BLE_SDK STW_SDK].curvePowerModel
                           [self.custombar updateUI:CustomMold];
                       });
        
//        [self updateWeightUI];
//        
//        //[STW_BLE_SDK STW_SDK].curvePowerModel
//        [self.custombar updateUI:CustomMold];
    };
    
    //注册雾化器大小的回调
    [STW_BLEService sharedInstance].Service_AtomizerData = ^(int resistance,int atomizerMold)
    {
        //调用检测新手函数
//        [self GreenHandModelCheck:resistance];
        
        [STW_BLE_SDK STW_SDK].atomizerMold = atomizerMold;     //雾化器类型
        [STW_BLE_SDK STW_SDK].atomizer = resistance;         //雾化器阻值
    
        int atomizernum = [STW_BLE_SDK STW_SDK].atomizer / 10;
        
        self.threecount.threecountDataLabel.text = [NSString stringWithFormat:@"%.2fΩ",atomizernum/100.0f];
        
//        NSString *str_atomizerMold = @"雾化器";
        NSString *str_atomizerMold = [InternationalControl return_string:@"Vapor_Atomizer"];
        switch ([STW_BLE_SDK STW_SDK].atomizerMold)
        {
            case BLEAtomizerA1:
                str_atomizerMold = @"Ni";
                break;
            case BLEAtomizerA2:
                str_atomizerMold = @"Ti";
                break;
            case BLEAtomizerA3:
                str_atomizerMold = @"Fe";
                break;
            case BLEAtomizerA4:
                str_atomizerMold = @"Ss";
                break;
            case BLEAtomizerA5:
                str_atomizerMold = @"Nicr";
                break;
            case BLEAtomizersM1:
                str_atomizerMold = @"M1";
                break;
            case BLEAtomizersM2:
                str_atomizerMold = @"M2";
                break;
            case BLEAtomizersM3:
                str_atomizerMold = @"M3";
                break;
                
            default:
                break;
        }
        self.threecount.threecountNameLabel.text = str_atomizerMold;
    };
    
    //注册主页面电池电量回调
    [STW_BLEService sharedInstance].Service_Battery = ^(int battery)
    {
//        batteryImage
//        batteryLabel
        [STW_BLE_SDK STW_SDK].battery = battery;
        
        if (battery < 11)
        {
            self.battery.batteryImage.image = [UIImage imageNamed:@"icon_bettery_1"];
        }
        else if(battery < 31)
        {
            self.battery.batteryImage.image = [UIImage imageNamed:@"icon_bettery_2"];
        }
        else if(battery < 51)
        {
            self.battery.batteryImage.image = [UIImage imageNamed:@"icon_bettery_3"];
        }
        else if(battery < 71)
        {
            self.battery.batteryImage.image = [UIImage imageNamed:@"icon_bettery_4"];
        }
        else if(battery < 98)
        {
            self.battery.batteryImage.image = [UIImage imageNamed:@"icon_bettery_5"];
        }
        else
        {
            self.battery.batteryImage.image = [UIImage imageNamed:@"icon_bettery_6"];
        }

        self.battery.batteryLabel.text = [NSString stringWithFormat:@"%d%%",battery];
    };
    
    //吸烟回调  Service_VaporStatus
    [STW_BLEService sharedInstance].Service_VaporStatus = ^(int vapor_status)
    {
        [STW_BLE_SDK STW_SDK].vaporStatus = vapor_status;
        
        if (vapor_status == BLEProtocolVaporeStatusYES)
        {
            //开始吸烟
            [STW_BLEService sharedInstance].isVaporNow = YES;
//            NSLog(@"开始吸烟");
            NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
            NSString *strdate = [formatter stringFromDate:[NSDate date]];
            NSDate *date1 = [formatter dateFromString:strdate];
            vapor_start = [date1 timeIntervalSince1970];
            
            [STW_BLE_SDK STW_SDK].vaporTime = 0;
            if ([STW_BLE_SDK STW_SDK].voumebarType == BLEProtocolModeTypeCustom)
            {
                NSLog(@"time - %d",[STW_BLE_SDK STW_SDK].vaporTime);
                [self.custombar updateUI_vapor_refresh:[STW_BLE_SDK STW_SDK].vaporTime];
            }
            
            self.threecount3.threecountDataLabel.text = [NSString stringWithFormat:@"%ds",[STW_BLE_SDK STW_SDK].vaporTime];
            
            if (vapor_timer)
            {
                [vapor_timer invalidate];
            }
            
            vapor_timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
        }
        else if(vapor_status == BLEProtocolVaporeStatusNO)
        {
            //结束吸烟
            [STW_BLEService sharedInstance].isVaporNow = NO;
//            NSLog(@"停止吸烟");
            //计时停止
            [vapor_timer invalidate];
            vapor_timer = nil;
            
            NSDateFormatter* formatter1 = [[NSDateFormatter alloc]init];
            [formatter1 setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
            NSString *strdate1 = [formatter1 stringFromDate:[NSDate date]];
            NSDate *date2 = [formatter1 dateFromString:strdate1];
            vapor_over = [date2 timeIntervalSince1970];
            
            int vapor_times = vapor_over - vapor_start;
            
            if (vapor_times > 10)    //控制吸烟时间在10秒
            {
                vapor_times = 10;
            }
            else if (vapor_times == 0)   //当吸烟不足一秒按一秒计算
            {
                vapor_times = 1;
            }
            

            if(vapor_times >= 2)
            {
                [Session sharedInstance].total++;
                self.threecount2.threecountDataLabel.text = [NSString stringWithFormat:@"%lu%@",(unsigned long)[Session sharedInstance].total,[InternationalControl return_string:@"Vapor_nums"]];
                
                //上传吸烟数据
                [self uploadRecord:vapor_start :vapor_over :vapor_times];
            }
//            NSLog(@"吸烟时间 - %d",vapor_times);
            
            self.threecount3.threecountDataLabel.text = [NSString stringWithFormat:@"%ds",vapor_times];
        }
    };
}

//查询Custom - 回调
-(void)find_custom_back
{
    [STW_BLEService sharedInstance].Service_GetPowerLine = ^(int lineNum,int pageNum,NSMutableArray *get_arry)
    {
        NSLog(@"lineNum - %d,pageNum - %d,get_arry.count - %d",lineNum,pageNum,(int)get_arry.count);
        if (pageNum == 0x00)
        {
            //当前包数第0包
            [STW_BLE_SDK STW_SDK].getPowerLinePageNum = pageNum;
            //获取当前传输曲线编号
            [STW_BLE_SDK STW_SDK].getPowerLineNum = lineNum;
            //获取总包数
            [STW_BLE_SDK STW_SDK].getPowerLineAllPageNum = [[get_arry objectAtIndex:0] intValue];
            //获取数据点总个数
            [STW_BLE_SDK STW_SDK].getPowerLineAllPointNum = [[get_arry objectAtIndex:1] intValue];
            //清空当前缓存的数组
            [STW_BLE_SDK STW_SDK].getPowerLineArrys = [NSMutableArray array];
            
            //给数组初始化数据赋值
            for (int i = 0; i < ([STW_BLE_SDK STW_SDK].getPowerLineAllPointNum * 2); i++)
            {
                [[STW_BLE_SDK STW_SDK].getPowerLineArrys addObject:@"0"];
            }
            
            //发送查询下一包数据
            [STW_BLE_Protocol the_find_Power_line:0x00 :lineNum :(pageNum + 1)];
        }
        else
        {
            //对比之前的数据以免发生数据错乱 - 是否曲线是一致的
            if(lineNum == [STW_BLE_SDK STW_SDK].getPowerLineNum)
            {
                //曲线保持一致 - 判断是否是最后一包数据
                if (pageNum < [STW_BLE_SDK STW_SDK].getPowerLineAllPageNum)
                {
                    //不是最后一包正常按照六位截取数据
                    [STW_BLE_SDK STW_SDK].getPowerLinePageNum = pageNum;
                    for (int i = 0; i < 12; i++)
                    {
                        NSString *str_num = [get_arry objectAtIndex:i];
                        
                        [[STW_BLE_SDK STW_SDK].getPowerLineArrys replaceObjectAtIndex:(((pageNum - 1)*12) + i) withObject:str_num];
                    }
                    
                    //发送查询下一包数据
                    [STW_BLE_Protocol the_find_Power_line:0x00 :lineNum :(pageNum + 1)];
                }
                else if(pageNum == [STW_BLE_SDK STW_SDK].getPowerLineAllPageNum)
                {
                    //最后一包数据 - 按总包数减去数据截取数据
                    [STW_BLE_SDK STW_SDK].getPowerLinePageNum = pageNum;
                    
                    int page_leng = ([STW_BLE_SDK STW_SDK].getPowerLineAllPointNum * 2) - ((pageNum - 1) * 12);
                     
                    for (int i = 0; i < page_leng; i++)
                    {
                        NSString *str_num = [get_arry objectAtIndex:i];
                        
                        [[STW_BLE_SDK STW_SDK].getPowerLineArrys replaceObjectAtIndex:(((pageNum - 1)*12) + i) withObject:str_num];
                    }
                    
                    /**
                     *  封装数据 - 将数据点 分成曲线数据所用的格式
                     *  曲线数据 - 曲线编号 - 曲线总点数 - 最大功率值
                     *  将数据保存到本地
                     */
                    //封装数据
                    NSMutableArray *saveArrys = [STW_BLE_Protocol encapsulatePowerLineData:[STW_BLE_SDK STW_SDK].getPowerLineNum :[STW_BLE_SDK STW_SDK].getPowerLineAllPointNum :[STW_BLE_SDK STW_SDK].max_power :[STW_BLE_SDK STW_SDK].getPowerLineArrys];
                    
                    //保存到本地
                    [TYZFileData SavePowerLineData:saveArrys :[STW_BLE_SDK STW_SDK].getPowerLineNum];
                    
                    //发送0xFF
                    [STW_BLE_Protocol the_find_Power_line:0x00 :lineNum :0xFF];
                }
            }
        }
    };
}

//吸烟计时
- (void)timerFire:(NSTimer *)timer
{
//    NSLog(@"STW_BLE_SDK STW_SDK].vaporTime - %d",[STW_BLE_SDK STW_SDK].vaporTime);
    
    if ([STW_BLE_SDK STW_SDK].vaporTime < 20)
    {
        [STW_BLE_SDK STW_SDK].vaporTime++;
        self.threecount3.threecountDataLabel.text = [NSString stringWithFormat:@"%ds",[STW_BLE_SDK STW_SDK].vaporTime/2];
        
        if ([STW_BLE_SDK STW_SDK].voumebarType == BLEProtocolModeTypeCustom)
        {
            NSLog(@"time - %d",[STW_BLE_SDK STW_SDK].vaporTime);
            [self.custombar updateUI_vapor_refresh:[STW_BLE_SDK STW_SDK].vaporTime];
        }
    }
    else
    {
        //结束吸烟
        [STW_BLEService sharedInstance].isVaporNow = NO;
        
        [STW_BLE_SDK STW_SDK].vaporStatus = 0x00;
        //计时停止
        [vapor_timer invalidate];
        vapor_timer = nil;
    }
}

-(void)updateWeightUI
{
    [self.weight updateUI:[STW_BLE_SDK STW_SDK].weightType_left];
    [self.weight1 updateUI:[STW_BLE_SDK STW_SDK].weightType_right];
}

-(void)updateVBarUI
{
    if ([STW_BLEService sharedInstance].isBLEStatus)
    {
        title.title.text = [STW_BLEService sharedInstance].device.deviceName;
    }
    else
    {
        title.title.text = [InternationalControl return_string:@"Vapor_device"];
    }
    
    switch ([STW_BLE_SDK STW_SDK].voumebarType)
    {
        case BLEProtocolModeTypePower:
        {
            self.voumebar.instrumentLabel.text = [InternationalControl return_string:@"Vapor_Power"];
        }
            break;
        case BLEProtocolModeTypeVoltage:
        {
            self.voumebar.instrumentLabel.text = [InternationalControl return_string:@"Vapor_Voltage"];
        }
            
            break;
        case BLEProtocolModeTypeTemperature:
        {
            if ([STW_BLE_SDK STW_SDK].temperatureMold == BLEProtocolTemperatureUnitCelsius)
            {
                //                str_lable = @"温度℃";
                self.voumebar.instrumentLabel.text = [InternationalControl return_string:@"Vapor_Temp_C"];
            }
            else
            {
                //                str_lable = @"温度℉";
                self.voumebar.instrumentLabel.text = [InternationalControl return_string:@"Vapor_Temp_F"];
            }
        }
            
            break;
        default:
            break;
    }
}

//左边 - 功能按钮
-(void)onClickImage
{
    NSLog(@"左边图片按钮");
    
    
    
//    //分页查询 - text_num 页数
//    NSMutableArray *arrays = [NSMutableArray array];
//    arrays = [DB_Sqlite3 FindData_JPushMsg:text_num];
//    
//    if (arrays.count > 0)
//    {
//        for (int i = 0; i < arrays.count; i++)
//        {
//            JPushMessage *jpushMessage = arrays[i];
//            
//            NSLog(@"jpushMessage - %@",jpushMessage.notice_text);
//        }
//    }
}

//连接-断开 图片按钮
-(void)clickDeleteBt
{
    //根据状态判定蓝牙连接
    if ([STW_BLEService sharedInstance].isBLEStatus)
    {
        NSLog(@"调用断开");
        
        [STW_BLEService sharedInstance].isBLEType = STW_BLE_IsBLETypeOff;
        
        [self refreshRightBtn:[STW_BLEService sharedInstance].isBLEStatus];
        
        [self cleanMainUI];
        
        //断开正在连接的设备
        [[STW_BLEService sharedInstance] disconnect];
    }
    else
    {
        //判断是否有设备绑定
        if ([Session sharedInstance].user.uid > 0 &&[Session sharedInstance].deviceArrys.count > 0)
        {
            NSLog(@"开始扫描");
            [ProgressHUD show:nil];

            if (btn_delete_type == 0)
            {
                btn_delete_type = 1;
                
                //表示当前没有蓝牙正在请求连接
                check_ble_status = YES;
                
                [STW_BLEService sharedInstance].isBLEType = STW_BLE_IsBLETypeOff;
                
                //注册扫描到设备的回调
                [self Service_scanHandler];
                
                //没有蓝牙连接开始扫描蓝牙设备
                [STW_BLEService sharedInstance].scanedDevices = [NSMutableArray array];
                
                [ProgressHUD show:nil];
                
                [[STW_BLEService sharedInstance] scanStart];
                
                //5秒钟没有扫描到设备判定扫描失败
                [self performSelector:@selector(stop_scan) withObject:nil afterDelay:5.0f];
            }
        }
        else
        {
            if ([[Session sharedInstance].user.cellphone isEqualToString:@""] || [Session sharedInstance].user.cellphone == NULL)
            {
//                [ProgressHUD showError:@"请先登录并绑定设备"];
                [ProgressHUD showError:[InternationalControl return_string:@"Vapor_login_warning"]];
                //跳转登录界面
                LoginViewController *view = [[LoginViewController alloc] init];
                [self.navigationController pushViewController:view animated:YES];
            }
            else
            {
//                [ProgressHUD showError:@"请先绑定设备"];
                [ProgressHUD showError:[InternationalControl return_string:@"Vapor_binding_warning"]];
                //我的设备 MyVapeViewController
                MyVapeViewController *view = [[MyVapeViewController alloc] init];
                [self.navigationController pushViewController:view animated:YES];
            }
        }
    }
}

////结束扫描蓝牙
- (void)stop_scan
{
    [ProgressHUD dismiss];
    
    btn_delete_type = 0;
    
    if(![STW_BLEService sharedInstance].isBLEStatus)
    {
//        [ProgressHUD showWarning:@"没有扫描到设备"];
        [ProgressHUD showWarning:[InternationalControl return_string:@"Vapor_NoDevice_warning"]];
    }
    
    //结束扫描蓝牙
    [[STW_BLEService sharedInstance] scanStop];
}

//清除所有UI
-(void)cleanMainUI
{
    [STW_BLEService sharedInstance].isBLEStatus = NO;
    
    [self refreshRightBtn:[STW_BLEService sharedInstance].isBLEStatus];
    
//    title.title.text = @"设备";
    title.title.text = [InternationalControl return_string:@"Vapor_device"];
    
    self.voumebar.hidden = NO;
    self.custombar.hidden = YES;
    
    if (vapor_timer)
    {
        [vapor_timer invalidate];
    }
    
    //初始化初始界面
    //初始化初始界面
    [STW_BLE_SDK STW_SDK].voumebarType = BLEProtocolModeTypePower;
    [STW_BLE_SDK STW_SDK].weightType_left = BLEProtocolModeTypeTemperature;
    [STW_BLE_SDK STW_SDK].weightType_right = BLEProtocolModeTypeVoltage;
    
    [STW_BLE_SDK STW_SDK].power = 10;
    [STW_BLE_SDK STW_SDK].voltage = 0;
    [STW_BLE_SDK STW_SDK].temperature = 200;
    [STW_BLE_SDK STW_SDK].temperatureMold = BLEProtocolTemperatureUnitFahrenheit;
    [STW_BLE_SDK STW_SDK].vaporModel = BLEProtocolModeTypePower;
    [STW_BLE_SDK STW_SDK].curvePowerModel = BLEProtocolCustomLineCommand01;
    
    [STW_BLE_SDK STW_SDK].vaporStatus = 0x00;  //开始并没有吸烟
    
    [STW_BLE_SDK STW_SDK].max_power = 80;   //当前的设备最大功率值
    
    [STW_BLE_SDK STW_SDK].voumebarMax = 80;
    [STW_BLE_SDK STW_SDK].voumebarMin = 1;
    
    [STW_BLE_SDK STW_SDK].battery = 0;  //电池电量数值
    
    //刷新右侧两个列表
    [self updateWeightUI];
    
    self.battery.batteryImage.image = [UIImage imageNamed:@"icon_battery"];
    self.battery.batteryLabel.text = [NSString stringWithFormat:@"%d%%",[STW_BLE_SDK STW_SDK].battery];
    
    self.threecount.threecountDataLabel.text = @"0Ω";
//    self.threecount.threecountNameLabel.text = @"雾化器";
    self.threecount.threecountNameLabel.text = [InternationalControl return_string:@"Vapor_Atomizer"];
    
    self.threecount3.threecountDataLabel.text = @"0s";
    
    [self.voumebar updateUI:BLEProtocolModeTypePower :[STW_BLE_SDK STW_SDK].power];
}

//获取吸烟口数
-(void)getSmokeCount
{
    [User daySmockCount:^(id data)
     {
//        NSLog(@"吸烟口数：%@",data);
        [Session sharedInstance].total = [[data objectForKey:@"mouth"]intValue];
        self.threecount2.threecountDataLabel.text = [NSString stringWithFormat:@"%lu%@",(unsigned long)[Session sharedInstance].total,[InternationalControl return_string:@"Vapor_nums"]];
        
    } failure:^(NSString *message) {
        //        [ProgressHUD show:nil];
    }];
}

//上传吸烟记录
-(void)uploadRecord:(int)sta :(int)over :(int)d
{
    if([Session sharedInstance].user)
    {
        SmockLog *log = [[SmockLog alloc] init];
        
        log.uid = [Session sharedInstance].user.uid;
        [User recordData:[[STW_BLEService sharedInstance].device.deviceMac intValue
                          ] startime:sta endtime:over day:[NSDate date] time:d longitude:0 latitude:0 success:^(id data) {
//            NSLog(@"%@,%@",data,[NSDate date]);
            //                            [[Session sharedInstance].mapData addObject:data];
        } failure:^(NSString *message) {
//            NSLog(@"%@",message);
            //[ProgressHUD showError:message];
        }];
    }
}

////监控JPush消息
//-(void)addJPushNotify
//{
//    //更新消息条数提示
//    [self CheckMessageNumValue];
//    
//    //注册消息观察者
//    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
//    //自定义消息接受者
//    [defaultCenter addObserver:self
//                      selector:@selector(networkDidReceiveMessage:)
//                          name:kJPFNetworkDidReceiveMessageNotification
//                        object:nil];
//    
//    //登录推送服务器成功的消息
//    [defaultCenter addObserver:self
//                      selector:@selector(networkDidLogin:)
//                          name:kJPFNetworkDidLoginNotification
//                        object:nil];
//    
//    
//    [defaultCenter addObserver:self selector:@selector(checkNotity:) name:@"freshJPushMessage" object:nil];
//
//}

/*********************************** 极光推送配置 *****************************************/
////自定义消息接口
//-(void)networkDidReceiveMessage:(NSNotification *)notification
//{
//    //    NSLog(@"接收自定义消息 : %@",notification.userInfo[@"content"]);
//    //    NSLog(@"接收自定义消息 : %@",notification.userInfo[@"extras"]);
//    //写到本地我的消息
//    NSDictionary *extras = notification.userInfo[@"extras"];
//    JPushMessage *jpushMessage = [JPushMessage mj_objectWithKeyValues:extras];
//    //    NSLog(@"jpushMessage - %@ - %d",jpushMessage.notice_url,jpushMessage.notice_status);
//    //将收到的消息写到本地数据库
//    if ([DB_Sqlite3 writeData_JPushMsg:jpushMessage])
//    {
//        NSLog(@"将收到的JPush消息 - 写入数据库成功");
//        //消息通知声音 - 暂时取消声音 by tyz 2017-02-08
////        AudioServicesPlaySystemSound(1307);
//        //更新消息条数提示
//        [self CheckMessageNumValue];
//    }
//    else
//    {
//        NSLog(@"将收到的JPush消息 - 写入数据库失败");
//    }
//}
//
////登录服务器成功的消息接口
//-(void)networkDidLogin:(NSNotification *)notification
//{
//    NSLog(@"登录JPush成功 : %@",notification);
//    
//    double delayInSeconds = 1.0f;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                   {
//                       //设置标签 - 用语言进行分类
//                       [self setJPushTags];
//                   });
//}
//
////设置别名
//-(void)setJPushTags
//{
//    //获取registrationID
//    //    NSString *registrationID = [JPUSHService registrationID];
//    
//    NSSet * tags = [[NSSet alloc] initWithObjects:@"uvapor_V2.7",nil];
//    
//    NSString *languageStr;
//    
//    if ([Session sharedInstance].isLanguage == 0)
//    {
//        languageStr = @"English";
//    }
//    else
//    {
//        languageStr = @"Chinese";
//    }
//    
//    __autoreleasing NSString *alias = languageStr;
//    
//    //新版本直接使用回调方法
//    [JPUSHService setTags:tags alias:alias fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias)
//    {
//         if (iResCode == 0)
//         {
//             [Session sharedInstance].isJPush = 1;
//             NSLog(@"设置别名成功 : %@ - %@",iAlias,iTags);
//         }
//         else
//         {
//             [Session sharedInstance].isJPush = 0;
//             NSLog(@"设置别名失败 : %@ - %@",iAlias,iTags);
//             
//             NSString *iResCodeStr;
//             
//             switch (iResCode)
//             {
//                 case 1005:
//                     iResCodeStr = @"AppKey不存在";
//                     break;
//                 case 1008:
//                     iResCodeStr = @"AppKey非法";
//                     break;
//                 case 1009:
//                     iResCodeStr = @"当前appkey无对应应用";
//                     break;
//                 case 6001:
//                     iResCodeStr = @"无效的设置，tag/alias 不应参数都为 null";
//                     break;
//                 case 6002:
//                     iResCodeStr = @"设置超时";
//                     break;
//                 case 6003:
//                     iResCodeStr = @"alias 字符串不合法";
//                     break;
//                 case 6004:
//                     iResCodeStr = @"alias超长。最多 40个字节";
//                     break;
//                 case 6005:
//                     iResCodeStr = @"某一个 tag 字符串不合法";
//                     break;
//                 case 6006:
//                     iResCodeStr = @"某一个 tag 超长。一个 tag 最多 40个字节";
//                     break;
//                 case 6007:
//                     iResCodeStr = @"tags 数量超出限制。最多 1000个";
//                     break;
//                 case 6008:
//                     iResCodeStr = @"tag 超出总长度限制";
//                     break;
//                 case 6011:
//                     iResCodeStr = @"10s内设置tag或alias大于10次";
//                     break;
//                     
//                 default:
//                     break;
//             }
//             
//             NSLog(@"错误信息 - %@",iResCodeStr);
//             
//             double delayInSeconds = 1.0f;
//             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//             dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                            {
//                                //重新设置标签 - 用语言进行分类
//                                [self setJPushTags];
//                            });
//         }
//     }];
//}
//
//-(void)checkNotity:(NSNotification *)notification
//{
//    NSLog(@"接收到刷新列表的消息");
//    [self CheckMessageNumValue];
//}
//
//-(void)CheckMessageNumValue
//{
//    int jpMsgmum = 0;
//    //查询数据库数据
//    NSMutableArray *table_arrays = [DB_Sqlite3 FindAllData_JPushMsg];
//    
//    for (int i = 0; i < table_arrays.count; i++)
//    {
//        JPushMessage *jpMsg = table_arrays[i];
//        
//        //判断信息是否在可用时间 - 需要删除多余的数据
//        
//        if (jpMsg.notice_status == 0)
//        {
//            NSLog(@"jpMsg - %@",jpMsg.notice_text);
//            jpMsgmum++;
//        }
//    }
//    
//    if (jpMsgmum > 0)
//    {
//        if (jpMsgmum > 99)
//        {
//            UIViewController *vc = self.tabBarController.viewControllers[3];
//            UITabBarItem *item = vc.tabBarItem;
//            [item setBadgeValue:@"99+"];
//        }
//        else
//        {
//            UIViewController *vc = self.tabBarController.viewControllers[3];
//            UITabBarItem *item = vc.tabBarItem;
//            [item setBadgeValue:[NSString stringWithFormat:@"%d",jpMsgmum]];
//        }
//    }
//    else
//    {
//        UIViewController *vc = self.tabBarController.viewControllers[3];
//        UITabBarItem *item = vc.tabBarItem;
//        [item setBadgeValue:nil];
//    }
//}

/*********************************** 极光推送配置完成 *****************************************/

//新手模式
//-(void)GreenHandModelCheck:(int)atom
//{
//    if ([STW_BLE_SDK STW_SDK].vaporModel == BLEProtocolModeTypePower)
//    {
//        if ([STW_BLE_SDK STW_SDK].atomizer != atom)
//        {
//            atom = atom/10;
//            
//            if (atom < 20)
//            {
//                NSLog(@"推荐功率 - 70W");
//                //设置功率
//                [STW_BLE_Protocol the_work_mode_power:700 :0x03];
//            }
//            else if(atom < 30)
//            {
//                NSLog(@"推荐功率 - 60W");
//                //设置功率
//                [STW_BLE_Protocol the_work_mode_power:600 :0x03];
//            }
//            else if(atom < 40)
//            {
//                NSLog(@"推荐功率 - 50W");
//                //设置功率
//                [STW_BLE_Protocol the_work_mode_power:500 :0x03];
//            }
//            else if(atom < 50)
//            {
//                NSLog(@"推荐功率 - 40W");
//                //设置功率
//                [STW_BLE_Protocol the_work_mode_power:400 :0x03];
//            }
//            else if(atom < 60)
//            {
//                NSLog(@"推荐功率 - 35W");
//                //设置功率
//                [STW_BLE_Protocol the_work_mode_power:350 :0x03];
//            }
//            else if(atom < 80)
//            {
//                NSLog(@"推荐功率 - 30W");
//                //设置功率
//                [STW_BLE_Protocol the_work_mode_power:300 :0x03];
//            }
//            else if(atom < 100)
//            {
//                NSLog(@"推荐功率  - 28W");
//                //设置功率
//                [STW_BLE_Protocol the_work_mode_power:280 :0x03];
//            }
//            else if(atom < 120)
//            {
//                NSLog(@"推荐功率 - 25W");
//                //设置功率
//                [STW_BLE_Protocol the_work_mode_power:250 :0x03];
//            }
//            else if(atom < 150)
//            {
//                NSLog(@"推荐功率 - 20W");
//                //设置功率
//                [STW_BLE_Protocol the_work_mode_power:200 :0x03];
//            }
//            else if(atom < 200)
//            {
//                NSLog(@"推荐功率 - 18W");
//                //设置功率
//                [STW_BLE_Protocol the_work_mode_power:180 :0x03];
//            }
//            else if(atom < 500)
//            {
//                NSLog(@"推荐功率  - 10W");
//                //设置功率
//                [STW_BLE_Protocol the_work_mode_power:100 :0x03];
//            }
//        }
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
