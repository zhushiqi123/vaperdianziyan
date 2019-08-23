//
//  CustomViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/14.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "CustomViewController.h"
#import "CustomViewItem.h"
#import "PowerLineViewController.h"
#import "LOGOViewController.h"
#import "UpdateSoftViewController.h"
#import "BatteryDataViewController.h"
#import "AlertView.h"
#import "STW_BLE_Protocol.h"
#import "STW_BLEService.h"
#import "STW_BLE_SDK.h"
#import "ProgressHUD.h"
#import "InternationalControl.h"

#import "TCRSetDataViewController.h"

@interface CustomViewController ()
{
    CustomViewItem *customView01;
    CustomViewItem *customView02;
    CustomViewItem *customView03;
    CustomViewItem *customView04;
    CustomViewItem *customView05;
    CustomViewItem *customView06;
    
    //防止连续点击  0 - 空闲  1 - 繁忙状态
    int  check_btn_type;
}

@end

@implementation CustomViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ProgressHUD dismiss];
    
    self.title = [InternationalControl return_string:@"Custom_title"];
    
    check_btn_type = 0;
    
    customView02.lable.text = [InternationalControl return_string:@"Custom_bar_powerLine"];
    customView04.lable.text = [InternationalControl return_string:@"Custom_bar_Update"];
    customView05.lable.text = [InternationalControl return_string:@"Custom_bar_TurnOrOff"];
    customView06.lable.text = [InternationalControl return_string:@"Custom_bar_powerBattery"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [InternationalControl return_string:@"Custom_title"];
    //第1个自定义按钮
    customView01 = [[[NSBundle mainBundle]loadNibNamed:@"CustomViewItem" owner:self options:nil]lastObject];
    CGRect customViewframe01 = customView01.frame;
    
    customViewframe01.origin.x = 0.0f;
    customViewframe01.origin.y = 74.0f;
    
    customViewframe01.size.width = SCREEN_WIDTH / 2;
    customViewframe01.size.height = 100.0f;
    
    customView01.frame = customViewframe01;
    
    customView01.backgroundColor = [UIColor clearColor];
    
    //按钮图片
    [customView01.cusButton setBackgroundImage:[UIImage imageNamed:@"cus01"] forState:UIControlStateNormal];
    //按钮点击事件
    [customView01.cusButton addTarget:self
                               action:@selector(onClickcustomView01) forControlEvents:UIControlEventTouchUpInside];
    
    customView01.lable.text = @"TCR";
    
    [self.view addSubview:customView01];
    
    //第2个自定义按钮
    customView02 = [[[NSBundle mainBundle]loadNibNamed:@"CustomViewItem" owner:self options:nil]lastObject];
    CGRect customViewframe02 = customView02.frame;
    
    customViewframe02.origin.x = SCREEN_WIDTH / 2;
    customViewframe02.origin.y = 74.0f;
    
    customViewframe02.size.width = SCREEN_WIDTH / 2;
    customViewframe02.size.height = 100.0f;
    
    customView02.frame = customViewframe02;
    
    customView02.backgroundColor = [UIColor clearColor];
    
    //    customView02.cusButton.imageView.image = [UIImage imageNamed:@"cus02"];
    [customView02.cusButton setBackgroundImage:[UIImage imageNamed:@"cus02"] forState:UIControlStateNormal];
    [customView02.cusButton addTarget:self
                               action:@selector(onClickcustomView02) forControlEvents:UIControlEventTouchUpInside];
//    customView02.lable.text = @"功率曲线";
    customView02.lable.text = [InternationalControl return_string:@"Custom_bar_powerLine"];
    
    [self.view addSubview:customView02];
    
    //第3个自定义按钮
    customView03 = [[[NSBundle mainBundle]loadNibNamed:@"CustomViewItem" owner:self options:nil]lastObject];
    CGRect customViewframe03 = customView03.frame;
    
    customViewframe03.origin.x = 0.0f;
    customViewframe03.origin.y = 74.0f + 100.0f;
    
    customViewframe03.size.width = SCREEN_WIDTH / 2;
    customViewframe03.size.height = 100.0f;
    
    customView03.frame = customViewframe03;
    
    customView03.backgroundColor = [UIColor clearColor];
    
    //    customView03.cusButton.imageView.image = [UIImage imageNamed:@"cus03"];
    [customView03.cusButton setBackgroundImage:[UIImage imageNamed:@"cus03"] forState:UIControlStateNormal];
    [customView03.cusButton addTarget:self
                               action:@selector(onClickcustomView03) forControlEvents:UIControlEventTouchUpInside];
    customView03.lable.text = @"LOGO";
    
    [self.view addSubview:customView03];
    
    //第4个自定义按钮
    customView04 = [[[NSBundle mainBundle]loadNibNamed:@"CustomViewItem" owner:self options:nil]lastObject];
    CGRect customViewframe04 = customView04.frame;
    
    customViewframe04.origin.x = SCREEN_WIDTH / 2;
    customViewframe04.origin.y = 74.0f + 100.0f;
    
    customViewframe04.size.width = SCREEN_WIDTH / 2;
    customViewframe04.size.height = 100.0f;
    
    customView04.frame = customViewframe04;
    
    customView04.backgroundColor = [UIColor clearColor];
    
    //    customView04.cusButton.imageView.image = [UIImage imageNamed:@"cus04"];
    [customView04.cusButton setBackgroundImage:[UIImage imageNamed:@"cus04"] forState:UIControlStateNormal];
    [customView04.cusButton addTarget:self
                               action:@selector(onClickcustomView04) forControlEvents:UIControlEventTouchUpInside];
//    customView04.lable.text = @"程序升级";
    customView04.lable.text = [InternationalControl return_string:@"Custom_bar_Update"];
    
    [self.view addSubview:customView04];
    
    //第5个自定义按钮
    customView05 = [[[NSBundle mainBundle]loadNibNamed:@"CustomViewItem" owner:self options:nil]lastObject];
    CGRect customViewframe05 = customView05.frame;
    
    customViewframe05.origin.x = 0.0f;
    customViewframe05.origin.y = 74.0f + 100.0f * 2;
    
    customViewframe05.size.width = SCREEN_WIDTH / 2;
    customViewframe05.size.height = 100.0f;
    
    customView05.frame = customViewframe05;
    
    customView05.backgroundColor = [UIColor clearColor];
    
    //    customView05.cusButton.imageView.image = [UIImage imageNamed:@"cus05on"];
    
    [customView05.cusButton setBackgroundImage:[UIImage imageNamed:@"cus05on"] forState:UIControlStateNormal];
    [customView05.cusButton addTarget:self
                               action:@selector(onClickcustomView05) forControlEvents:UIControlEventTouchUpInside];
//    customView05.lable.text = @"开关机";
    customView05.lable.text = [InternationalControl return_string:@"Custom_bar_TurnOrOff"];
    
    //注册开关机回调  Service_Root
    [self rootOpenDown];
    
    [self.view addSubview:customView05];
    
    //第6个自定义按钮
    customView06 = [[[NSBundle mainBundle]loadNibNamed:@"CustomViewItem" owner:self options:nil]lastObject];
    CGRect customViewframe06 = customView06.frame;
    
    customViewframe06.origin.x = SCREEN_WIDTH - (SCREEN_WIDTH / 2);
    customViewframe06.origin.y = 74.0f + 100.0f * 2;
    
    customViewframe06.size.width = SCREEN_WIDTH / 2;
    customViewframe06.size.height = 100.0f;
    
    customView06.frame = customViewframe06;
    
    customView06.backgroundColor = [UIColor clearColor];
    
    //    customView06.cusButton.imageView.image = [UIImage imageNamed:@"cus06"];
    [customView06.cusButton setBackgroundImage:[UIImage imageNamed:@"cus06"] forState:UIControlStateNormal];
    [customView06.cusButton addTarget:self
                               action:@selector(onClickcustomView06) forControlEvents:UIControlEventTouchUpInside];
//    customView06.lable.text = @"电池信息";
    customView06.lable.text = [InternationalControl return_string:@"Custom_bar_powerBattery"];
    
    [self.view addSubview:customView06];
    
    //    //第7个自定义按钮
    //    CustomViewItem *customView07 = [[[NSBundle mainBundle]loadNibNamed:@"CustomViewItem" owner:self options:nil]lastObject];
    //    CGRect customViewframe07 = customView07.frame;
    //
    //    customViewframe07.origin.x = 0.0f;
    //    customViewframe07.origin.y = 74.0f + 200.0f;
    //
    //    customViewframe07.size.width = SCREEN_WIDTH / 3;
    //    customViewframe07.size.height = 100.0f;
    //
    //    customView07.frame = customViewframe07;
    //
    //    customView07.backgroundColor = [UIColor clearColor];
    //
    //    customView07.imageView.image = [UIImage imageNamed:@"cus001"];
    //    customView07.lable.text = @"测试01";
    //
    //    [self.view addSubview:customView07];
    //
    //    //第8个自定义按钮
    //    CustomViewItem *customView08 = [[[NSBundle mainBundle]loadNibNamed:@"CustomViewItem" owner:self options:nil]lastObject];
    //    CGRect customViewframe08 = customView08.frame;
    //
    //    customViewframe08.origin.x = SCREEN_WIDTH / 3;
    //    customViewframe08.origin.y = 74.0f+ 200.0f;
    //
    //    customViewframe08.size.width = SCREEN_WIDTH / 3;
    //    customViewframe08.size.height = 100.0f;
    //
    //    customView08.frame = customViewframe08;
    //
    //    customView08.backgroundColor = [UIColor clearColor];
    //
    //    customView08.imageView.image = [UIImage imageNamed:@"cus001"];
    //    customView08.lable.text = @"测试01";
    //
    //    [self.view addSubview:customView08];
    //
    //    //第9个自定义按钮
    //    CustomViewItem *customView09 = [[[NSBundle mainBundle]loadNibNamed:@"CustomViewItem" owner:self options:nil]lastObject];
    //    CGRect customViewframe09 = customView09.frame;
    //
    //    customViewframe09.origin.x = SCREEN_WIDTH - (SCREEN_WIDTH / 3);
    //    customViewframe09.origin.y = 74.0f+ 200.0f;
    //
    //    customViewframe09.size.width = SCREEN_WIDTH / 3;
    //    customViewframe09.size.height = 100.0f;
    //
    //    customView09.frame = customViewframe09;
    //
    //    customView09.backgroundColor = [UIColor clearColor];
    //
    //    customView09.imageView.image = [UIImage imageNamed:@"cus001"];
    //    customView09.lable.text = @"测试01";
    //
    //    [self.view addSubview:customView09];
    
    //变为可以调用
    __customView01 = customView01;
    __customView02 = customView02;
    __customView03 = customView03;
    __customView04 = customView04;
    __customView05 = customView05;
    __customView06 = customView06;
}

//注册开关机回调
-(void)rootOpenDown
{
    [STW_BLEService sharedInstance].Service_Root = ^(int Root)
    {
        switch (Root) {
            case 0x00:
            {
                AlertView* view = [[[NSBundle mainBundle] loadNibNamed:@"AlertView" owner:self options:nil] lastObject];
//                [view showViewWith:@"关机"];
                [view showViewWith:[InternationalControl return_string:@"Custom_TurnOrOff_Lock"]];
                
                [STW_BLE_SDK STW_SDK].root_lock_status = 0;
                [__customView05.cusButton setBackgroundImage:[UIImage imageNamed:@"cus05"] forState:UIControlStateNormal];
            }
                break;
            case 0x01:
            {
                AlertView* view = [[[NSBundle mainBundle] loadNibNamed:@"AlertView" owner:self options:nil] lastObject];
//                [view showViewWith:@"开机"];
                [view showViewWith:[InternationalControl return_string:@"Custom_TurnOrOff_unlock"]];
                
                [STW_BLE_SDK STW_SDK].root_lock_status = 1;
                [__customView05.cusButton setBackgroundImage:[UIImage imageNamed:@"cus05on"] forState:UIControlStateNormal];
            }
                break;
            case 0xEE:
                NSLog(@"出现错误");
                break;
                
            default:
                break;
        }
    };
}

//按钮1事件
-(void)onClickcustomView01
{
    //跳转TCR设置界面
//    TCRViewController *view = [[TCRViewController alloc] init];
//    [self.navigationController pushViewController:view animated:YES];
    
    //storyboard跳转
    TCRSetDataViewController *view = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"TCRSetDataViewController"];
    [self.navigationController pushViewController:view animated:YES];
}

//按钮2事件
-(void)onClickcustomView02
{
    //跳转功率曲线界面
    PowerLineViewController *view = [[PowerLineViewController alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

//按钮3事件
-(void)onClickcustomView03
{
    if([STW_BLEService sharedInstance].isBLEStatus)
    {
//        [ProgressHUD showError:@"此设备暂不支持"];
        [ProgressHUD showError:[InternationalControl return_string:@"Custom_LOGO_warning"]];
    }
    
    //LOGO设置界面
//    LOGOViewController *view = [[LOGOViewController alloc] init];
//    [self.navigationController pushViewController:view animated:YES];
}

//按钮4事件
-(void)onClickcustomView04
{
    //获取软件版本硬件版本
    [STW_BLE_Protocol the_Find_deviceData];
    
    //注册查询硬件信息的回调
    [self find_device_data_back];
    
//    [STW_BLE_SDK STW_SDK].deviceVersion = 8658;
//    [STW_BLE_SDK STW_SDK].softVersion = 2;
//    //程序升级界面
//    UpdateSoftViewController *view = [[UpdateSoftViewController alloc] init];
//    [self.navigationController pushViewController:view animated:YES];
}

-(void)find_device_data_back
{
    [STW_BLEService sharedInstance].Service_Find_DeviceData = ^(int Device_Version,int Soft_Version)
    {
        //获得硬件版本软件版本
        [STW_BLE_SDK STW_SDK].deviceVersion = Device_Version;
        [STW_BLE_SDK STW_SDK].softVersion = Soft_Version;
        
        //程序升级界面
        UpdateSoftViewController *view = [[UpdateSoftViewController alloc] init];
        [self.navigationController pushViewController:view animated:YES];
    };
}

//按钮5事件
-(void)onClickcustomView05
{
    if([self check_btn_type_function])
    {
        if ([STW_BLE_SDK STW_SDK].root_lock_status == 1)
        {
            //发送关机命令
            [STW_BLE_Protocol the_boot_bool:0];
    //        AlertView* view = [[[NSBundle mainBundle] loadNibNamed:@"AlertView" owner:self options:nil] lastObject];
    //        [view showViewWith:@"关机"];
    //        
    //        lock_status = 0;
    //        [__customView05.cusButton setBackgroundImage:[UIImage imageNamed:@"cus05"] forState:UIControlStateNormal];
        }
        else
        {
            //发送开机命令
            [STW_BLE_Protocol the_boot_bool:1];
    //        AlertView* view = [[[NSBundle mainBundle] loadNibNamed:@"AlertView" owner:self options:nil] lastObject];
    //        [view showViewWith:@"开机"];
    //        
    //        lock_status = 1;
    //        [__customView05.cusButton setBackgroundImage:[UIImage imageNamed:@"cus05on"] forState:UIControlStateNormal];
        
        }
    }
}

//按钮6事件
-(void)onClickcustomView06
{
    //获得电池电量
    [STW_BLE_Protocol the_find_battery_status:1];
    
    //注册查询硬件信息的回调
    [self find_BatteryData_back];
}

-(void)find_BatteryData_back
{
    [STW_BLEService sharedInstance].Service_BatteryStatus = ^(int battery_num,int battery_status,int battery_chargingVoltage,int battery_chargingCurrent,int battery_Voltage01,int battery_Voltage02,int battery_Voltage03)
    {
        //获得电池电压电流
        NSLog(@"");
        
        //电池信息界面
        BatteryDataViewController *view = [[BatteryDataViewController alloc] init];
        [self.navigationController pushViewController:view animated:YES];
    };
}

-(BOOL)check_btn_type_function
{
    if (check_btn_type == 0)
    {
        //check_btn_type 不可点击状态
        check_btn_type = 1;
        
        double delayInSeconds = 2.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [ProgressHUD dismiss];
                           //check_btn_type 退回可点击状态
                           check_btn_type = 0;
                       });
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning
{
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
