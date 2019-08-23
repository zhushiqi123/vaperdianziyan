//
//  BatteryDataViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/18.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "BatteryDataViewController.h"
#import "STW_BLE_SDK.h"
#import "InternationalControl.h"
#import "UIthreecount.h"

@interface BatteryDataViewController ()

@end

@implementation BatteryDataViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [InternationalControl return_string:@"Custom_bar_powerBattery"];
    
    _threecount.threecountNameLabel.text = [InternationalControl return_string:@"Custom_powerBattery_voltage"];
    _threecount2.threecountNameLabel.text = [InternationalControl return_string:@"Custom_powerBattery_current"];
    _threecount3.threecountNameLabel.text = [NSString stringWithFormat:@"1#%@",[InternationalControl return_string:@"Custom_powerBattery_battery"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [InternationalControl return_string:@"Custom_bar_powerBattery"];
    
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,SCREEN_HEIGHT)];
    imageview.image = [UIImage imageNamed:@"icon_background"];
    
    [self.view addSubview:imageview];
    
    //放到最底层
    [self.view sendSubviewToBack:imageview];
    
    //设置背景颜色防止卡顿
    self.view.backgroundColor = [UIColor whiteColor];
    
    float bar_hreght = (SCREEN_HEIGHT * 2) / 3;
    float UIthreecount_height = 100.0f;
    float UIthreecount_weight = SCREEN_WIDTH  / 3;
    //低下三个图组
    UIthreecount *threecount = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
    CGRect threeframe = threecount.frame;
    
    threeframe.origin.x = 0;
    threeframe.origin.y = bar_hreght;
    
    threeframe.size.width = UIthreecount_weight;
    threeframe.size.height = UIthreecount_height;
    
    threecount.frame = threeframe;
    threecount.threecountImage.image = [UIImage imageNamed:@"icon_voltage"];
    threecount.threecountDataLabel.text = @"5V";
//    threecount.threecountNameLabel.text = @"充电电压";
    threecount.threecountNameLabel.text = [InternationalControl return_string:@"Custom_powerBattery_voltage"];
    [self.view addSubview:threecount];
    
    //口数的视图
    UIthreecount *threecount2 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
    CGRect threeframe2 = threecount2.frame;
    
    threeframe2.origin.x = UIthreecount_weight;
    threeframe2.origin.y = bar_hreght;
    
    threeframe2.size.width = UIthreecount_weight;
    threeframe2.size.height = UIthreecount_height;
    
    threecount2.frame = threeframe2;
    threecount2.threecountImage.image = [UIImage imageNamed:@"icon_current"];
    threecount2.threecountDataLabel.text = @"800mA";
    threecount2.threecountNameLabel.text = [InternationalControl return_string:@"Custom_powerBattery_current"];
    [self.view addSubview:threecount2];
    
    //口数的视图
    UIthreecount *threecount3 = [[[NSBundle mainBundle]loadNibNamed:@"UIthreecount" owner:self options:nil]lastObject];
    CGRect threeframe3 = threecount3.frame;
    
    threeframe3.origin.x = self.view.bounds.size.width - UIthreecount_weight;
    threeframe3.origin.y = bar_hreght;
    
    threeframe3.size.width = UIthreecount_weight;
    threeframe3.size.height = UIthreecount_height;
    
    threecount3.frame = threeframe3;
    threecount3.threecountImage.image = [UIImage imageNamed:@"icon_battery_logo"];
//    threecount3.threecountDataLabel.text = @"3.6V";
    threecount3.threecountDataLabel.text = [NSString stringWithFormat:@"%.1fV",3.20f + ([STW_BLE_SDK STW_SDK].battery/100.00f)];
    threecount3.threecountNameLabel.text = [NSString stringWithFormat:@"1#%@",[InternationalControl return_string:@"Custom_powerBattery_battery"]];
    [self.view addSubview:threecount3];
    
    //变为可调用
    self.threecount = threecount;
    self.threecount2 = threecount2;
    self.threecount3 = threecount3;
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
