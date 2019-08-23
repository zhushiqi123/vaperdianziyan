//
//  UIWeiget.m
//  uvapor
//
//  Created by BCT06 on 15/3/20.
//  Copyright (c) 2015年 BCT06. All rights reserved.
//

#import "UIWeiget.h"
#import "Session.h"
#import "STW_BLEService.h"
#import "STW_BLE_SDK.h"
#import "InternationalControl.h"

@implementation UIWeiget

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)updateUI:(int)workModel
{
    NSString *str_title;
    NSString *str_lable;
    
    switch (workModel)
    {
        case BLEProtocolModeTypePower:
        {
            str_title = [NSString stringWithFormat:@"%.1f",[STW_BLE_SDK STW_SDK].power/10.f];
//            str_lable = @"功率W";
            str_lable = [InternationalControl return_string:@"Vapor_Power"];
        }
            break;
        case BLEProtocolModeTypeVoltage:
        {
            str_title = [NSString stringWithFormat:@"%.2f",[STW_BLE_SDK STW_SDK].voltage/100.0f];
//            str_lable = @"电压V";
            str_lable = [InternationalControl return_string:@"Vapor_Voltage"];
        }
            break;
        case BLEProtocolModeTypeTemperature:
        {
            str_title = [NSString stringWithFormat:@"%d",[STW_BLE_SDK STW_SDK].temperature];
            
            if ([STW_BLE_SDK STW_SDK].temperatureMold == BLEProtocolTemperatureUnitCelsius)
            {
//                str_lable = @"温度℃";
                str_lable = [InternationalControl return_string:@"Vapor_Temp_C"];
            }
            else
            {
//                str_lable = @"温度℉";
                str_lable = [InternationalControl return_string:@"Vapor_Temp_F"];
            }
        }
            break;
        case BLEProtocolModeTypeBypas:
        {
            str_title = @"B";
            str_lable = @"ByPass";
        }
            break;
        case BLEProtocolModeTypeCustom:
        {
            str_title = [NSString stringWithFormat:@"C%d",[STW_BLE_SDK STW_SDK].curvePowerModel];
            str_lable = @"Custom";
        }
            break;
            
        default:
            break;
    }
    
    [self.WeigetButton setTitle:str_title forState:UIControlStateNormal];
    self.WeigetLabel.text = str_lable;
}

@end
