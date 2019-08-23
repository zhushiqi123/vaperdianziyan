//
//  LogoTableViewCell.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/19.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lable_name;

@property (weak, nonatomic) IBOutlet UIImageView *logo_image;

@property (weak, nonatomic) IBOutlet UIButton *btn_edit;
@property (weak, nonatomic) IBOutlet UIButton *btn_delete;
@property (weak, nonatomic) IBOutlet UIButton *btn_use;

@property (weak, nonatomic) IBOutlet UIView *logo_View;

@end
