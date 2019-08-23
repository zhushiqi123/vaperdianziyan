//
//  ForgetPwdView.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetPwdView : UIView

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UILabel *lable_title;

@property (weak, nonatomic) IBOutlet UILabel *lable_pwd;
@property (weak, nonatomic) IBOutlet UITextField *edit_pwd;

@property (weak, nonatomic) IBOutlet UILabel *lable_pwd_again;
@property (weak, nonatomic) IBOutlet UITextField *edit_pwd_again;

@end
