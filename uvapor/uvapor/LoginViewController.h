//
//  LoginViewController.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "delegateViewController.h"

@interface LoginViewController : delegateViewController

@property (nonatomic,retain) UITextField *textView_pwd;
@property (nonatomic,retain) UITextField *textView_userName;
@end
