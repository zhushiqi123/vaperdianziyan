//
//  TCRSetDataViewController.m
//  uvapor
//
//  Created by 田阳柱 on 16/6/29.
//  Copyright © 2016年 tyz. All rights reserved.
//

#import "TCRSetDataViewController.h"
#import "STW_BLE_SDK.h"
#import "ProgressHUD.h"
#import "InternationalControl.h"

@implementation TCRSetDataViewController
{
    NSArray *arry_name;
    NSArray *arry_power;
    NSArray *arry_gradient;
    int power_max;
   
    UIButton *saveButton;
    
    int BLEAtomizerStatus;
    
    int bianhualv_1;
    
    NSTimer *powerTimerAdd;
    NSTimer *powerTimerLow;
    
    NSTimer *bianhuaTimerAdd;
    NSTimer *bianhuaTimerLow;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    BLEAtomizerStatus = 0;
    
    arry_name = [NSArray arrayWithObjects:@"Ni200",@"Ti01",@"Ss316",@"Nicr",@"M1",@"M2",@"M3",nil];
    
    if ([STW_BLE_SDK STW_SDK].max_power >= 60)
    {
        arry_power = [NSArray arrayWithObjects:@"60",@"60",@"60",@"60",@"60",@"60",@"60",nil];
    }
    else
    {
        arry_power = [NSArray arrayWithObjects:@"35",@"35",@"35",@"35",@"35",@"35",@"35",nil];
    }
    
    arry_gradient = [NSArray arrayWithObjects:@"50",@"30",@"10",@"10",@"30",@"30",@"30",nil];
    
    if([STW_BLE_SDK STW_SDK].atomizerMold)
    {
        switch ([STW_BLE_SDK STW_SDK].atomizerMold)
        {
            case BLEAtomizerA1:
                BLEAtomizerStatus = 0;
                break;
            case BLEAtomizerA2:
                BLEAtomizerStatus = 1;
                break;
            case BLEAtomizerA4:
                BLEAtomizerStatus = 2;
                break;
            case BLEAtomizerA5:
                BLEAtomizerStatus = 3;
                break;
            case BLEAtomizersM1:
                BLEAtomizerStatus = 4;
                break;
            case BLEAtomizersM2:
                BLEAtomizerStatus = 5;
                break;
            case BLEAtomizersM3:
                BLEAtomizerStatus = 6;
                break;
                
            default:
                break;
        }
    }
    
    self.lable1.text = [InternationalControl return_string:@"Custom_TCR_choose_Atomizer"];
    self.lable2.text = [InternationalControl return_string:@"Custom_TCR_choose_Power_Message"];
    self.lable3.text = [InternationalControl return_string:@"Custom_TCR_choose_Power"];
    self.lable4.text = [InternationalControl return_string:@"Custom_TCR_choose_Rate_Message"];
    self.lable5.text = [InternationalControl return_string:@"Custom_TCR_choose_Rate"];
    
    self.lable1_1.text = [NSString stringWithFormat:@"%@",arry_name[BLEAtomizerStatus]];
    self.lable2_2.text = [NSString stringWithFormat:@"%@W",arry_power[BLEAtomizerStatus]];
    float nums = 1.0 * [arry_gradient[BLEAtomizerStatus] intValue];
    self.lable4_4.text = [NSString stringWithFormat:@"%.3f",nums/1000];
    
    self.title = [NSString stringWithFormat:@"%@",arry_name[BLEAtomizerStatus]];;
    
    _check_slider_status = 1;
    
//    self.lable1.text = [[InternationalControl bundle] localizedStringForKey:@"SetingNew_06" value:nil table:@"Localizable"];
//    self.lable2.text = [[InternationalControl bundle] localizedStringForKey:@"SetingNew_07" value:nil table:@"Localizable"];
//    self.lable3.text = [[InternationalControl bundle] localizedStringForKey:@"SetingNew_08" value:nil table:@"Localizable"];
//    self.lable4.text = [[InternationalControl bundle] localizedStringForKey:@"SetingNew_09" value:nil table:@"Localizable"];
//    self.lable5.text = [[InternationalControl bundle] localizedStringForKey:@"SetingNew_10" value:nil table:@"Localizable"];
//    
//    if ([BLEService sharedInstance].device.devicesModel == BLEDerviceModelSTW06)
//    {
//        power_max = 200;
//    }
//    else if ([BLEService sharedInstance].device.devicesModel == BLEDerviceModelSTW05)
//    {
//      power_max = 80;
        power_max = [STW_BLE_SDK STW_SDK].max_power;
//    }
    
    [self performSelector:@selector(get_data_device) withObject:nil afterDelay:0.5f];

    //不显示分割线
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor darkGrayColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.powerAdd addTarget:self action:@selector(powerAdd01) forControlEvents:UIControlEventTouchDown];
    [self.powerAdd addTarget:self action:@selector(powerAdd02) forControlEvents:UIControlEventTouchDragOutside];
    
    [self.powerLow addTarget:self action:@selector(powerLow01) forControlEvents:UIControlEventTouchDown];
    [self.powerLow addTarget:self action:@selector(powerLow02) forControlEvents:UIControlEventTouchDragOutside];
    
    [self.bianhuaAdd addTarget:self action:@selector(bianhuaAdd01) forControlEvents:UIControlEventTouchDown];
     [self.bianhuaAdd addTarget:self action:@selector(bianhuaAdd02) forControlEvents:UIControlEventTouchDragOutside];
    
    [self.bianhuaLow addTarget:self action:@selector(bianhuaLow01) forControlEvents:UIControlEventTouchDown];
    [self.bianhuaLow addTarget:self action:@selector(bianhuaLow02) forControlEvents:UIControlEventTouchDragOutside];
}

-(void)powerAdd02
{

    [powerTimerAdd invalidate];
    powerTimerAdd = nil;
}

-(void)powerLow02
{
    [powerTimerLow invalidate];
    powerTimerLow = nil;
};

-(void)bianhuaAdd02
{
    [bianhuaTimerAdd invalidate];
    bianhuaTimerAdd = nil;
};

-(void)bianhuaLow02
{
    [bianhuaTimerLow invalidate];
    bianhuaTimerLow = nil;
};

-(void)powerAdd01
{
    if (powerTimerAdd)
    {
        [powerTimerAdd invalidate];
        powerTimerAdd = nil;
    }
    
    [self powerAddFunction];
    powerTimerAdd = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(powerAddFunction) userInfo:nil repeats:YES];
}

-(void)powerLow01
{
    if (powerTimerLow)
    {
        [powerTimerLow invalidate];
        powerTimerLow = nil;
    }
    
    [self powerLowFunction];
    powerTimerLow = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(powerLowFunction) userInfo:nil repeats:YES];
}

-(void)bianhuaAdd01
{
    if (bianhuaTimerAdd)
    {
        [bianhuaTimerAdd invalidate];
        bianhuaTimerAdd = nil;
    }
    
    if (_check_slider_status == 1)
    {
        [self bianhuaAddFunction];
         bianhuaTimerAdd = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(bianhuaAddFunction) userInfo:nil repeats:YES];
    }
}

-(void)bianhuaLow01
{
    if (bianhuaTimerLow)
    {
        [bianhuaTimerLow invalidate];
        bianhuaTimerLow = nil;
    }
    
    if (_check_slider_status == 1)
    {
        [self bianhauLowFunction];
        bianhuaTimerLow = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(bianhauLowFunction) userInfo:nil repeats:YES];
    }
}

-(void)get_data_device
{
    if ([STW_BLE_SDK STW_SDK].atomizerMold)
    {
        [self findAtomizerTCR:[STW_BLE_SDK STW_SDK].atomizerMold];
    }
    else
    {
        [self findAtomizerTCR:BLEAtomizerA1];
    }
    
    //注册查询TCR信息的回调  Service_Atomizer
    [STW_BLEService sharedInstance].Service_Atomizer = ^(int resistance,int atomizerMold,int TCR,int change_rate,int power)
    {
        if (resistance == 0x00 && atomizerMold == 0x00 && TCR == 0x00 && change_rate == 50 && power == 0x00)
        {
            [ProgressHUD showSuccess:nil];
            //切换到温度模式
            [self performSelector:@selector(send_temp_modeType) withObject:nil afterDelay:0.2f];
        }
        else
        {
            switch (atomizerMold)
            {
                case BLEAtomizerA1:
                    self.title = @"Ni200";
                    BLEAtomizerStatus = 0;
                    [self set_data:0];
                    break;
                case BLEAtomizerA2:
                    self.title = @"Ti01";
                    BLEAtomizerStatus = 1;
                    [self set_data:1];
                    break;
                case BLEAtomizerA4:
                    self.title = @"Ss316";
                    BLEAtomizerStatus = 2;
                    [self set_data:2];
                    break;
                case BLEAtomizerA5:
                    self.title = @"Nicr";
                    BLEAtomizerStatus = 3;
                    [self set_data:3];
                    break;
                case BLEAtomizersM1:
                    self.title = @"M1";
                    BLEAtomizerStatus = 4;
                    [self set_data:4];
                    break;
                case BLEAtomizersM2:
                    self.title = @"M2";
                    BLEAtomizerStatus = 5;
                    [self set_data:5];
                    break;
                case BLEAtomizersM3:
                    self.title = @"M3";
                    BLEAtomizerStatus = 6;
                    [self set_data:6];
                    break;
                default:
                    NSLog(@"error!");
                    break;
            }
            
            if (TCR == 0x01)
            {
                _check_slider_status = 1;
                self.slider_bianhua.enabled = YES;
            }
            else
            {
                _check_slider_status = 0;
                self.slider_bianhua.enabled = NO;
            }
            
            //设置功率
            
            [_slider_power setValue:(power/[STW_BLE_SDK STW_SDK].max_power) * 10];
            _lable3_3.text = [NSString stringWithFormat:@"%dW",(power/10)];
            
            //设置变化率
            [_slider_bianhua setValue:change_rate];
            _lable5_5.text = [NSString stringWithFormat:@"%.3f",change_rate/1000.0f];
        }
    };
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.tableView.opaque = NO;
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [imageview setImage:[UIImage imageNamed:@"icon_background"]];
    [self.tableView setBackgroundView:imageview];
    
    //设置右边button 刷新按钮
    UIButton *setButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-20, 5, 20, 20)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:setButton];
    
    [setButton setBackgroundImage:[UIImage imageNamed:@"icon_set_save_TCR"] forState:UIControlStateNormal];
    
    [setButton addTarget:self action:@selector(clickSetBtn) forControlEvents:UIControlEventTouchDown];
}

-(void)clickSetBtn
{
    NSLog(@"Save");
    //最大功率
    NSString *str_power = self.lable3_3.text;
    NSArray *array_power = [str_power componentsSeparatedByString:@"W"];
    int max_power = [array_power[0] intValue] * 10;
    //变化率
    NSString *str_rateRange = self.lable5_5.text;
    NSArray *array_rsteRange = [str_rateRange componentsSeparatedByString:@"."];
    int rateChange = [array_rsteRange[1] intValue];
    
//    NSLog(@"取得的值为  %d-> %d ->%d",BLEAtomizerStatus,max_power,rateChange);
    
    int AtomizerModel = 0;
    
    switch(BLEAtomizerStatus)
    {
        case 0:
            AtomizerModel = BLEAtomizerA1;
            break;
        case 1:
            AtomizerModel = BLEAtomizerA2;
            break;
        case 2:
            AtomizerModel = BLEAtomizerA4;
            break;
        case 3:
            AtomizerModel = BLEAtomizerA5;
            break;
        case 4:
            AtomizerModel = BLEAtomizersM1;
            break;
        case 5:
            AtomizerModel = BLEAtomizersM2;
            break;
        case 6:
            AtomizerModel = BLEAtomizersM3;
            break;
        default:
            NSLog(@"error!");
            break;
    }
    
    //记录发送的雾化器类型
    _Atomizer_status_temp = AtomizerModel;
    
    //向设备同步信息
    [STW_BLE_Protocol the_atomizer:AtomizerModel :_check_slider_status :rateChange :max_power];
}

//减小按钮 - power
- (IBAction)btn_min_power:(id)sender
{
    [powerTimerLow invalidate];
    powerTimerLow = nil;
}

//增加按钮 - power
- (IBAction)btn_max_power:(id)sender
{
    [powerTimerAdd invalidate];
    powerTimerAdd = nil;
}

//减少按钮 - 变化率
- (IBAction)btn_min_binahua:(id)sender
{
    [bianhuaTimerLow invalidate];
    bianhuaTimerLow = nil;
}

//增加按钮 - 变化率
- (IBAction)btn_max_binahua:(id)sender
{
    [bianhuaTimerAdd invalidate];
    bianhuaTimerAdd = nil;
}

//功率增加
-(void)powerAddFunction
{
//    NSLog(@"抬起");
    
    float a = [self.slider_power value];
    int b = 0;
    if (a == 0)
    {
        b = 1;
        [self.slider_power setValue:a+1];
    }
    else
    {
        if (a < 100)
        {
            b = (int)(power_max * (a/100)) + 1;
            [self.slider_power setValue:(a + (100.0f / power_max))];
        }
        else
        {
            b = power_max;
            [self.slider_power setValue:100];
        }
    }
    
    self.lable3_3.text = [NSString stringWithFormat:@"%dW",b];
}

//功率减小
-(void)powerLowFunction
{
    float a = [self.slider_power value];
    int b = 0;
    if (a == 0)
    {
        b = 1;
        [self.slider_power setValue:a];
    }
    else
    {
        b = (int)(power_max * (a/100)) - 1;
        if (b >= 1)
        {
            [self.slider_power setValue:(a - (100.0f / power_max))];
        }
        else
        {
            b = 1;
            [self.slider_power setValue:0];
        }
    }
    
    self.lable3_3.text = [NSString stringWithFormat:@"%dW",b];
}

//变化率增加
-(void)bianhuaAddFunction
{
    if (_check_slider_status == 1)
    {
        bianhualv_1 = [self.slider_bianhua value];
        
        int nums1 = bianhualv_1;
        
        if (nums1 >= 10 && nums1 < 999)
        {
            self.lable5_5.text = [NSString stringWithFormat:@"%.3f",(((nums1 + 1) * 1.0)/1000)];
            [self.slider_bianhua setValue:(nums1 + 1)];
        }
    }
}

//变化率减小
-(void)bianhauLowFunction
{
    if (_check_slider_status == 1)
    {
        bianhualv_1 = [self.slider_bianhua value];
        
        int nums1 = bianhualv_1;
        
        if (nums1 > 10 && nums1 <= 999)
        {
            self.lable5_5.text = [NSString stringWithFormat:@"%.3f",(((nums1 - 1) * 1.0)/1000)];
            [self.slider_bianhua setValue:(nums1 - 1)];
        }
    }
}

- (IBAction)power_slider:(id)sender
{
    float a = [self.slider_power value];
    int b = 0;
    if (a == 0)
    {
        b = 1;
    }
    else
    {
        b = (int)(power_max * (a/100));
    }
 
    self.lable3_3.text = [NSString stringWithFormat:@"%dW",b];
}

- (IBAction)bianhua_slider:(id)sender
{
    bianhualv_1 = [self.slider_bianhua value];

    int nums1 = bianhualv_1;
    
    self.lable5_5.text = [NSString stringWithFormat:@"%.3f",((nums1 * 1.0)/1000)];
}

//点击某个CEll执行的方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        [self showAlert:@"message"];
    }
}

/******************分割线对齐左右两端*****************/
-(void)viewDidLayoutSubviews {
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
/*************************************************/

-(void)showAlert:(NSString *)string
{
    if ([string isEqualToString:@"message"])
    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TCR" message:@"选择雾化器" delegate:self cancelButtonTitle:@"Cancle" otherButtonTitles:@"Ni200",@"Ti01",@"Ss316",@"Nicr",@"M1",@"M2",@"M3", nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TCR" message:[InternationalControl return_string:@"Custom_TCR_choose_Atomizer"] delegate:self cancelButtonTitle:@"Cancle" otherButtonTitles:@"Ni200",@"Ti01",@"Ss316",@"Nicr",@"M1",@"M2",@"M3", nil];
            [alert show]; //InternationalControl
    }
}

//弹出选择框
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(buttonIndex > 0)
    {
        switch (buttonIndex)
        {
            case 1:
                BLEAtomizerStatus = 0;
                [self send_data:0];
                break;
            case 2:
                BLEAtomizerStatus = 1;
                [self send_data:1];
                break;
            case 3:
                BLEAtomizerStatus = 2;
                [self send_data:2];
                break;
            case 4:
                BLEAtomizerStatus = 3;
                [self send_data:3];
                break;
            case 5:
                BLEAtomizerStatus = 4;
                [self send_data:4];
                break;
            case 6:
                BLEAtomizerStatus = 5;
                [self send_data:5];
                break;
            case 7:
                BLEAtomizerStatus = 6;
                [self send_data:6];
                break;
            default:
                NSLog(@"error!");
                break;
        }
    }
}

-(void)send_data:(int)nums
{
    //查询选择雾化器信息
    switch (nums)
    {
        case 0:
            [self findAtomizerTCR:BLEAtomizerA1];
            break;
        case 1:
            [self findAtomizerTCR:BLEAtomizerA2];
            break;
        case 2:
            [self findAtomizerTCR:BLEAtomizerA4];
            break;
        case 3:
            [self findAtomizerTCR:BLEAtomizerA5];
            break;
        case 4:
            [self findAtomizerTCR:BLEAtomizersM1];
            break;
        case 5:
            [self findAtomizerTCR:BLEAtomizersM2];
            break;
        case 6:
            [self findAtomizerTCR:BLEAtomizersM3];
            break;
            
        default:
            break;
    }
}

-(void)set_data:(int)nums
{
    self.lable1_1.text = [NSString stringWithFormat:@"%@",arry_name[nums]];
    self.lable2_2.text = [NSString stringWithFormat:@"%@W",arry_power[nums]];
    float nums_bianhua = 1.0 * [arry_gradient[nums] intValue];
    self.lable4_4.text = [NSString stringWithFormat:@"%.3f",nums_bianhua/1000];
    
    switch (nums) {
        case 0:
            self.title = @"Ni200";
            break;
        case 1:
            self.title = @"Ti01";
            break;
        case 2:
            self.title = @"Ss316";
            break;
        case 3:
            self.title = @"Nicr";
            break;
        case 4:
            self.title = @"M1";
            break;
        case 5:
            self.title = @"M2";
            break;
        case 6:
            self.title = @"M3";
            break;
            
        default:
            break;
    }
}

-(void)findAtomizerTCR:(int)atomizerType
{
    [STW_BLE_Protocol the_atomizer:atomizerType :0xFF :0 :0];
}

-(void)send_temp_modeType
{
    [STW_BLE_Protocol the_work_mode_temp:[STW_BLE_SDK STW_SDK].temperatureMold :[STW_BLE_SDK STW_SDK].temperature :_Atomizer_status_temp :0x00];
}


@end
