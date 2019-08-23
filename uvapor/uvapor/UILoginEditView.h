//
//  UILoginEditView.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILoginEditView : UIView
@property (weak, nonatomic) IBOutlet UIView *backgrondView;
@property (weak, nonatomic) IBOutlet UITextField *edit_userName;
@property (weak, nonatomic) IBOutlet UITextField *edit_pwd;

@end
