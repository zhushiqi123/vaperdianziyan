//
//  RegisteredViewController_02.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "RegisteredViewController_02.h"
#import "RegisteredView02.h"
#import "LoginViewController.h"
#import "ProgressHUD.h"
#import "User.h"
#import "TYZFileData.h"
#import "InternationalControl.h"

@interface RegisteredViewController_02 ()
{
    RegisteredView02 *registeredView;
}

@end

@implementation RegisteredViewController_02

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.title = @"注册 2/2";
    self.title = [NSString stringWithFormat:@"%@ 2/2",[InternationalControl return_string:@"My_registered"]];
    
    [self addPasswordView];
    [self addNextButton];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

//退出键盘
-(void)keyboardHide:(UITapGestureRecognizer*)tap
{
    [registeredView.edit_nickName resignFirstResponder];
    [registeredView.edit_pwd resignFirstResponder];
    [registeredView.edit_pwd_again resignFirstResponder];
}


//添加输入密码和昵称对话框
-(void)addPasswordView
{
    registeredView = [[[NSBundle mainBundle]loadNibNamed:@"RegisteredView02" owner:self options:nil] lastObject];
    
    CGRect frame = registeredView.frame;
    
    frame.origin.x = 10.0f;
    frame.origin.y =  84.0f;
    
    frame.size.width = SCREEN_WIDTH - 20.0f;
    frame.size.height = 200.0f;
    
    registeredView.frame = frame;
    
    registeredView.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
    registeredView.backgroundView.layer.cornerRadius = 10.0f;
    
    registeredView.lable_title.text = [InternationalControl return_string:@"My_registered_2_setTitle"];
    registeredView.lable_nickName.text = [InternationalControl return_string:@"My_registered_2_setNickName_lable"];
    registeredView.lable_pwd.text = [InternationalControl return_string:@"My_registered_2_setpassword_lable"];
    registeredView.lable_pwd_again.text = [InternationalControl return_string:@"My_registered_2_setagain_lable"];
    
    registeredView.edit_nickName.placeholder = [InternationalControl return_string:@"My_registered_2_setNickName_text"];
    registeredView.edit_pwd.placeholder = [InternationalControl return_string:@"My_registered_2_setpassword_text"];
    registeredView.edit_pwd_again.placeholder = [InternationalControl return_string:@"My_registered_2_setagain_text"];
    
    [registeredView.edit_nickName addTarget:self action:@selector(tfChange:) forControlEvents:UIControlEventEditingChanged];
    [registeredView.edit_nickName addTarget:self action:@selector(tfEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    [registeredView.edit_pwd addTarget:self action:@selector(tfChange:) forControlEvents:UIControlEventEditingChanged];
    [registeredView.edit_pwd addTarget:self action:@selector(tfEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    [registeredView.edit_pwd_again addTarget:self action:@selector(tfChange:) forControlEvents:UIControlEventEditingChanged];
    [registeredView.edit_pwd_again addTarget:self action:@selector(tfEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    [self.view addSubview:registeredView];
}

//正在输入
- (void)tfChange:(UITextField *)sender
{
    if ([sender isEqual:registeredView.edit_nickName])
    {
        if (sender.text.length > 32)
        {
//            [ProgressHUD showError:@"昵称设置过长"];
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_nickToLong"]];
            registeredView.edit_nickName.text = @"";
        }
    }
    else if([sender isEqual:registeredView.edit_pwd])
    {
        if (sender.text.length > 20)
        {
//            [ProgressHUD showError:@"密码设置过长"];
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_pwdToLong"]];
            registeredView.edit_pwd.text = @"";
        }
    }
    else if([sender isEqual:registeredView.edit_pwd_again])
    {
        if (sender.text.length > registeredView.edit_pwd.text.length)
        {
            registeredView.edit_pwd_again.text = @"";
//            [ProgressHUD showError:@"两次密码是输入不一致"];
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_pwdError"]];
        }
    }
}

//停止输入
- (void)tfEnd:(UITextField *)sender
{
    if ([sender isEqual:registeredView.edit_nickName])
    {
        if (sender.text.length == 0)
        {
            registeredView.edit_nickName.text = @"";
//            [ProgressHUD showError:@"请输入昵称"];
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_inputuseName"]];
        }
    }
    else if([sender isEqual:registeredView.edit_pwd])
    {
        if (sender.text.length < 6 || sender.text.length > 20)
        {
            registeredView.edit_pwd.text = @"";
//            [ProgressHUD showError:@"密码长度错误"];
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_pwd_error"]];
        }
    }
    else if([sender isEqual:registeredView.edit_pwd_again])
    {
        if (![sender.text isEqualToString:registeredView.edit_pwd.text])
        {
            registeredView.edit_pwd_again.text = @"";
//            [ProgressHUD showError:@"两次密码是输入不一致"];
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_pwdError"]];
        }
    }
}


//下一页按钮视图
-(void)addNextButton
{
    UIButton *btn_next=[self createButtonFrame:CGRectMake(10.0f, 190.0f + 64.0f + 50.0f, SCREEN_WIDTH - 20.0f, 37.0f) backImageName:nil title:[InternationalControl return_string:@"My_registered_02_Complete"] titleColor:[UIColor whiteColor]  font:[UIFont systemFontOfSize:17] target:self action:@selector(onclick_btn_next)];
    
    btn_next.backgroundColor = [UIColor darkGrayColor];
    btn_next.layer.cornerRadius=5.0f;
    
    [self.view addSubview:btn_next];
}

//下一页按钮事件
-(void)onclick_btn_next
{
    NSLog(@"注册");
    if(registeredView.edit_nickName.text.length > 0)
    {
        if(registeredView.edit_pwd.text.length >= 6 &&[registeredView.edit_pwd.text isEqualToString: registeredView.edit_pwd_again.text])
        {
            [User regist:_user_phone password:registeredView.edit_pwd_again.text nickname:registeredView.edit_nickName.text success:^(NSString *arr)
             {
//                 [ProgressHUD showSuccess:@"注册成功"];
                 [ProgressHUD showSuccess:[InternationalControl return_string:@"My_registered_02_success"]];
                 
                 
                 User *user = [[User alloc]init];
                 
                 user.cellphone = _user_phone;
                 user.password = registeredView.edit_pwd_again.text;
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
                 [ProgressHUD dismiss];
                 [ProgressHUD showError:@"注册失败"];
                 
                 [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_failure"]];
             }];
        }
        else
        {
//            [ProgressHUD showError:@"请输正确格式的密码"];
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_pwd_error"]];
        }
    }
    else
    {
//        [ProgressHUD showError:@"请输入昵称"];
        [ProgressHUD showError:[InternationalControl return_string:@"My_registered_02_inputuseName"]];
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
