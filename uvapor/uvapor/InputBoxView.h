//
//  InputBoxView.h
//  uVapour
//
//  Created by 田阳柱 on 16/10/6.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputBoxView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lable_title;
@property (weak, nonatomic) IBOutlet UITextField *lable_input;
@property (weak, nonatomic) IBOutlet UIButton *btn_cancle;
@property (weak, nonatomic) IBOutlet UIButton *btn_confim;

@end
