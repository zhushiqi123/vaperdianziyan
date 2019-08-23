//
//  PowerLineCell.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/19.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PowerLineCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image_logo;

@property (weak, nonatomic) IBOutlet UILabel *lable_line_name;

@property (weak, nonatomic) IBOutlet UIImageView *image_power_line;

@property (weak, nonatomic) IBOutlet UIButton *btn_edit;

@property (weak, nonatomic) IBOutlet UIButton *btn_use;

@property (weak, nonatomic) IBOutlet UIView *powerLineView;  // 屏幕 宽度 减去 70 再减去 16  高度 150

@end
