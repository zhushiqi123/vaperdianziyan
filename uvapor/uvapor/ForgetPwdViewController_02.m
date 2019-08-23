//
//  ForgetPwdViewController_02.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "ForgetPwdViewController_02.h"
#import "ForgetPwdView.h"
#import "LoginViewController.h"
#import "ProgressHUD.h"
#import "User.h"
#import "TYZFileData.h"
#import "InternationalControl.h"

@interface ForgetPwdViewController_02 ()
{
    ForgetPwdView *registeredView;
}

@end

@implementation ForgetPwdViewController_02

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.title = @"密码 2/2";
    self.title = [NSString stringWithFormat:@"%@ 2/2 ",[InternationalControl return_string:@"My_findPassword"]];
    
    [self addEditView];
    [self addNextView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

//退出键盘
-(void)keyboardHide:(UITapGestureRecognizer*)tap
{
    [registeredView.edit_pwd resignFirstResponder];
    [registeredView.edit_pwd_again resignFirstResponder];
}

//加载注册账号Edit部分
-(void)addEditView
{
    registeredView = [[[NSBundle mainBundle]loadNibNamed:@"ForgetPwdView" owner:self options:nil] lastObject];
    
    CGRect frame = registeredView.frame;
    
    frame.origin.x = 10.0f;
    frame.origin.y =  84.0f;
    
    frame.size.width = SCREEN_WIDTH - 20.0f;
    frame.size.height = 150.0f;
    
    registeredView.frame = frame;
    
    registeredView.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
    registeredView.backgroundView.layer.cornerRadius = 10.0f;
    
    //请设置您的新密码 - My_findPassword_2_newPwd
    registeredView.lable_title.text = [InternationalControl return_string:@"My_findPassword_2_newPwd"];
    
    registeredView.lable_pwd.text = [InternationalControl return_string:@"My_registered_2_setpassword_lable"];
    registeredView.lable_pwd_again.text = [InternationalControl return_string:@"My_registered_2_setagain_lable"];
    
    registeredView.edit_pwd.placeholder = [InternationalControl return_string:@"My_findPassword_2_newPwd"];
    registeredView.edit_pwd_again.placeholder = [InternationalControl return_string:@"My_findPassword_2_newPwdAgain"];
    
    [registeredView.edit_pwd addTarget:self action:@selector(tfChange:) forControlEvents:UIControlEventEditingChanged];
    [registeredView.edit_pwd addTarget:self action:@selector(tfEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    [registeredView.edit_pwd_again addTarget:self action:@selector(tfChange:) forControlEvents:UIControlEventEditingChanged];
    [registeredView.edit_pwd_again addTarget:self action:@selector(tfEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    [self.view addSubview:registeredView];
}

//正在输入
- (void)tfChange:(UITextField *)sender
{
    if([sender isEqual:registeredView.edit_pwd])
    {
        if (sender.text.length > 20)
        {
            //密码设置过长 - My_registered_02_pwdToLong
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_pwdToLong"]];
            registeredView.edit_pwd.text = @"";
        }
    }
    else if([sender isEqual:registeredView.edit_pwd_again])
    {
        if (sender.text.length > registeredView.edit_pwd.text.length)
        {
            registeredView.edit_pwd_again.text = @"";
            //My_registered_02_pwdError - 两次密码是输入不一致
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_pwdError"]];
        }
    }
}

//停止输入
- (void)tfEnd:(UITextField *)sender
{
    if([sender isEqual:registeredView.edit_pwd])
    {
        if (sender.text.length < 6 || sender.text.length > 20)
        {
            registeredView.edit_pwd.text = @"";
            //密码设置过长 - My_registered_02_pwdToLong
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_pwdToLong"]];
        }
    }
    else if([sender isEqual:registeredView.edit_pwd_again])
    {
        if (![sender.text isEqualToString:registeredView.edit_pwd.text])
        {
            registeredView.edit_pwd_again.text = @"";
            //My_registered_02_pwdError - 两次密码是输入不一致
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_pwdError"]];
        }
    }
}

//加载下一页按钮
-(void)addNextView
{
    //@"完成"
    UIButton *btn_next=[self createButtonFrame:CGRectMake(10.0f, 190.0f + 64.0f, SCREEN_WIDTH - 20.0f, 37.0f) backImageName:nil title:[InternationalControl return_string:@"My_registered_02_Complete"] titleColor:[UIColor whiteColor]  font:[UIFont systemFontOfSize:17] target:self action:@selector(onclick_btn_next)];
    
    btn_next.backgroundColor = [UIColor darkGrayColor];
    btn_next.layer.cornerRadius=5.0f;
    
    [self.view addSubview:btn_next];
}

//下一页按钮事件
-(void)onclick_btn_next
{
    if(registeredView.edit_pwd.text.length >= 6 &&[registeredView.edit_pwd.text isEqualToString: registeredView.edit_pwd_again.text])
    {
        [User resetPassword:_user_phone code:_user_code password:registeredView.edit_pwd.text success:^(id data)
        {
            NSLog(@"data - %@",data);
            //My_findPassword_2_success - 密码找回成功
            [ProgressHUD showSuccess:[InternationalControl return_string:@"My_findPassword_2_success"]];

             User *user = [User initdata:data];
             //保存账号密码到本地
             [TYZFileData SaveUserData:user];

             //遍历UIViewController返回到相应的UIViewController
             for (UIViewController *controller in self.navigationController.viewControllers)
             {
                 if ([controller isKindOfClass:[LoginViewController class]])
                 {
                     [self.navigationController popToViewController:controller animated:YES];
                 }
             }
        }
        failure:^(NSString *message)
        {
            //My_findPassword_2_error - @"密码找回失败"
            [ProgressHUD showError:[InternationalControl return_string:@"My_findPassword_2_error"]];
        }];
    }
    else
    {
        //My_registered_02_pwd_error - @"请输正确的密码"
        [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_pwd_error"]];
    }
}

-(UIButton *)createButtonFrame:(CGRect)frame backImageName:(NSString *)imageName title:(NSString *)title titleColor:(UIColor *)color font:(UIFont *)font target:(id)target action:(SEL)action
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=frame;
    if (imageName)
    {
        [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    
    if (font)
    {
        btn.titleLabel.font=font;
    }
    
    if (title)
    {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    if (color)
    {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
    if (target&&action)
    {
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return btn;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
