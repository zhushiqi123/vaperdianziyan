//
//  RegisteredView01.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisteredView01 : UIView
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UILabel *lable_title;

@property (weak, nonatomic) IBOutlet UILabel *lable_phone;
@property (weak, nonatomic) IBOutlet UITextField *edit_phone;
@property (weak, nonatomic) IBOutlet UILabel *lable_checkNum;
@property (weak, nonatomic) IBOutlet UITextField *edit_checkNum;
@property (weak, nonatomic) IBOutlet UIButton *btn_checkNum;

@end
