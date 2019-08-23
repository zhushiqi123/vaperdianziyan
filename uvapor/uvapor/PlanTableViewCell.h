//
//  PlanTableViewCell.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/19.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *plan_image_view;

@property (weak, nonatomic) IBOutlet UILabel *lable_plan_name;
@property (weak, nonatomic) IBOutlet UILabel *lable_plan_title;

@property (weak, nonatomic) IBOutlet UIButton *btn_plan_nums;
@property (weak, nonatomic) IBOutlet UIButton *btn_plan_onOff;

@property (weak, nonatomic) IBOutlet UIView *plan_view;

@end
