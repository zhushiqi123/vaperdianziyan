//
//  TCRSetDataViewController.h
//  uvapor
//
//  Created by 田阳柱 on 16/6/29.
//  Copyright © 2016年 tyz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCRSetDataViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *lable1;
@property (weak, nonatomic) IBOutlet UILabel *lable1_1;

@property (weak, nonatomic) IBOutlet UILabel *lable2;
@property (weak, nonatomic) IBOutlet UILabel *lable2_2;

@property (weak, nonatomic) IBOutlet UILabel *lable3;
@property (weak, nonatomic) IBOutlet UILabel *lable3_3;

@property (weak, nonatomic) IBOutlet UILabel *lable4;
@property (weak, nonatomic) IBOutlet UILabel *lable4_4;

@property (weak, nonatomic) IBOutlet UILabel *lable5;
@property (weak, nonatomic) IBOutlet UILabel *lable5_5;

@property (weak, nonatomic) IBOutlet UISlider *slider_power;
@property (weak, nonatomic) IBOutlet UISlider *slider_bianhua;


@property (weak, nonatomic) IBOutlet UIButton *powerAdd;
@property (weak, nonatomic) IBOutlet UIButton *powerLow;

@property (weak, nonatomic) IBOutlet UIButton *bianhuaAdd;
@property (weak, nonatomic) IBOutlet UIButton *bianhuaLow;

@property(assign,nonatomic)int check_slider_status;

@property(assign,nonatomic)int Atomizer_status_temp;

@end
