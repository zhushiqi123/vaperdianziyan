//
//  UpdatePasswordViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/11/15.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "UpdatePasswordViewController.h"
#import "ProgressHUD.h"
#import "Session.h"
#import "User.h"
#import "TYZFileData.h"
#import "InternationalControl.h"

@interface UpdatePasswordViewController ()
{
    //确认按钮
    UIButton *comfimBUtton;
    //旧密码输入框
    UITextField *oldPassWordText;
    //新密码输入框
    UITextField *newPassWordText;
    //再次输入新密码输入框
    UITextField *newAgainPassWordText;
}

@end

@implementation UpdatePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //My_change_old_pwd_change - 修改密码
    self.title = [InternationalControl return_string:@"My_change_old_pwd_change"];
    // Do any additional setup after loading the view.
    //添加密码输入框
    [self addPasswordText];
    //添加确认按钮
    [self addComfimButton];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

//退出键盘
-(void)keyboardHide:(UITapGestureRecognizer*)tap
{
    [oldPassWordText resignFirstResponder];
    [newPassWordText resignFirstResponder];
    [newAgainPassWordText resignFirstResponder];
}

-(void)addPasswordText
{
    UITextField *textView1 = [[UITextField alloc]initWithFrame:CGRectMake(10,64 + 10, SCREEN_WIDTH - 20, 40)];
    UITextField *textView2 = [[UITextField alloc]initWithFrame:CGRectMake(10,64 + 10 + 40 + 10, SCREEN_WIDTH - 20, 40)];
    UITextField *textView3 = [[UITextField alloc]initWithFrame:CGRectMake(10,64 + 10 + 40 + 10 + 40 + 10, SCREEN_WIDTH - 20, 40)];
    
    textView1.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
    textView2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
    textView3.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
    
    textView1.layer.borderWidth = 1;
    textView2.layer.borderWidth = 1;
    textView3.layer.borderWidth = 1;
    
    textView1.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    textView2.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    textView3.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    textView1.layer.cornerRadius = 6.0;
    textView2.layer.cornerRadius = 6.0;
    textView3.layer.cornerRadius = 6.0;
    
    textView1.keyboardType = UIKeyboardTypeASCIICapable;
    textView2.keyboardType = UIKeyboardTypeASCIICapable;
    textView3.keyboardType = UIKeyboardTypeASCIICapable;
    
    textView1.secureTextEntry = YES;
    textView2.secureTextEntry = YES;
    textView3.secureTextEntry = YES;
    
    textView1.font = [UIFont fontWithName:@"Arial" size:17.0f];
    textView2.font = [UIFont fontWithName:@"Arial" size:17.0f];
    textView3.font = [UIFont fontWithName:@"Arial" size:17.0f];
    
    //请输入您的旧密码 - My_change_old_pwd_inputOld
    textView1.placeholder = [InternationalControl return_string:@"My_change_old_pwd_inputOld"];
    //请输入您的新密码 - My_change_old_pwd_inputNew
    textView2.placeholder = [InternationalControl return_string:@"My_change_old_pwd_inputNew"];
    //请再次输入您的新密码 - My_change_old_pwd_inputNewAgain
    textView3.placeholder = [InternationalControl return_string:@"My_change_old_pwd_inputNewAgain"];
    
    [textView1 setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [textView2 setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [textView3 setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    textView1.textColor = [UIColor whiteColor];
    textView2.textColor = [UIColor whiteColor];
    textView3.textColor = [UIColor whiteColor];
    
    [self.view addSubview:textView1];
    [self.view addSubview:textView2];
    [self.view addSubview:textView3];
    
    textView1.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    textView2.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    textView3.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    //设置显示模式为永远显示(默认不显示)
    textView1.leftViewMode = UITextFieldViewModeAlways;
    textView2.leftViewMode = UITextFieldViewModeAlways;
    textView3.leftViewMode = UITextFieldViewModeAlways;
    
    oldPassWordText = textView1;
    newPassWordText = textView2;
    newAgainPassWordText = textView3;
    
    [oldPassWordText addTarget:self action:@selector(tfChange:) forControlEvents:UIControlEventEditingChanged];
    [oldPassWordText addTarget:self action:@selector(tfEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    [newPassWordText addTarget:self action:@selector(tfChange:) forControlEvents:UIControlEventEditingChanged];
    [newPassWordText addTarget:self action:@selector(tfEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    [newAgainPassWordText addTarget:self action:@selector(tfChange:) forControlEvents:UIControlEventEditingChanged];
    [newAgainPassWordText addTarget:self action:@selector(tfEnd:) forControlEvents:UIControlEventEditingDidEnd];
}

//正在输入
- (void)tfChange:(UITextField *)sender
{
    if ([sender isEqual:oldPassWordText])
    {
        if (sender.text.length > 32)
        {
            oldPassWordText.text = @"";
            //My_change_old_pwd_error - 密码格式错误
            [ProgressHUD showError:[InternationalControl return_string:@"My_change_old_pwd_error"]];
        }
    }
    else if([sender isEqual:newPassWordText])
    {
        if (sender.text.length > 32)
        {
            newPassWordText.text = @"";
            //My_change_old_pwd_error - 密码格式错误
            [ProgressHUD showError:[InternationalControl return_string:@"My_change_old_pwd_error"]];
        }
    }
    else if([sender isEqual:newAgainPassWordText])
    {
        if (sender.text.length > newPassWordText.text.length)
        {
            newAgainPassWordText.text = @"";
            //My_change_old_pwd_pwdError - 两次密码输入不一致
            [ProgressHUD showError:[InternationalControl return_string:@"My_change_old_pwd_pwdError"]];
        }
    }
}

//停止输入
- (void)tfEnd:(UITextField *)sender
{
    if ([sender isEqual:oldPassWordText])
    {
        if (![oldPassWordText.text isEqualToString:[Session sharedInstance].user.password])
        {
            oldPassWordText.text = @"";
            //My_change_old_pwd_oldError - 旧密码错误
            [ProgressHUD showError:[InternationalControl return_string:@"My_change_old_pwd_oldError"]];
        }
    }
    else if([sender isEqual:newPassWordText])
    {
        if (newPassWordText.text.length < 6 || newPassWordText.text.length > 32)
        {
            newPassWordText.text = @"";
            //My_registered_02_pwd_error - 密码格式错误
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_pwd_error"]];
        }
    }
    else if([sender isEqual:newAgainPassWordText])
    {
        if (![newAgainPassWordText.text isEqualToString:newPassWordText.text])
        {
            newAgainPassWordText.text = @"";
            //My_change_old_pwd_pwdError - 两次密码输入不一致
            [ProgressHUD showError:[InternationalControl return_string:@"My_change_old_pwd_pwdError"]];
        }
    }
}

-(void)addComfimButton
{
    UIButton *button01 = [[UIButton alloc]initWithFrame:CGRectMake(10,64 + 10 + 40 + 10 + 40 + 10 + 40 + 10, SCREEN_WIDTH - 20, 40)];
    
    button01.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
    
    button01.layer.borderWidth = 1;
    
    button01.layer.cornerRadius = 6.0;
    
    button01.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    [button01 setTitle:[InternationalControl return_string:@"window_confirm"] forState:UIControlStateNormal];
    
    button01.tintColor = [UIColor whiteColor];
    
    [button01 addTarget:self action:@selector(confirm_btn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button01];
    
    comfimBUtton = button01;
}

//确认事件
-(void)confirm_btn
{
    NSLog(@"修改密码");
    if (oldPassWordText.text.length > 0)
    {
        if(newAgainPassWordText.text.length > 0)
        {
            [User UserResetPassword:newAgainPassWordText.text success:^(id data)
            {
//                NSLog(@"data -> %@",data);
                
                int num = [[data objectForKey:@"code"] intValue];
                
                if (num == 1)
                {
                    //My_change_old_pwd_success - 密码修改成功
                    [ProgressHUD showSuccess:[InternationalControl return_string:@"My_change_old_pwd_success"]];
                    
                    [Session sharedInstance].user.password = newAgainPassWordText.text;
                    
                    //保存账号密码到本地
                    [TYZFileData SaveUserData:[Session sharedInstance].user];
                }
                else
                {
                    //My_change_old_pwd_failure - 密码修改失败
                    [ProgressHUD showSuccess:[InternationalControl return_string:@"My_change_old_pwd_failure"]];
                }
            }
            failure:^(NSString *message)
            {
                //My_change_old_pwd_failure - 密码修改失败
                [ProgressHUD showSuccess:[InternationalControl return_string:@"My_change_old_pwd_failure"]];
            }];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            //My_change_old_pwd_messagenew - 请输入新密码
            [ProgressHUD showError:[InternationalControl return_string:@"My_change_old_pwd_messagenew"]];
        }
    }
    else
    {
        //My_change_old_pwd_messageold - 请先输入旧密码
        [ProgressHUD showError:[InternationalControl return_string:@"My_change_old_pwd_messageold"]];
    }
}

- (void)didReceiveMemoryWarning {
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
