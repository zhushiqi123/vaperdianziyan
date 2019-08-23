//
//  LoginViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "LoginViewController.h"
#import "UILoginEditView.h"
#import "RegisteredViewController_01.h"
#import "ForgetPwdViewController_01.h"
#import "User.h"
#import "ProgressHUD.h"
#import "Session.h"
#import "TYZFileData.h"
#import "InternationalControl.h"

#import "TYZ_AFNet_Client.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏状态栏
//    self.navigationController.navigationBarHidden = YES;
    //检测是否缓存用户自动填充密码
    [self check_userData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.title = @"登录";
    self.title = [InternationalControl return_string:@"My_Login"];

    [self createButtons];
    [self moreLoginViewTitle];
    [self createTextFields];
    
    //为新加状态栏添加一个背景
//    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
//    imageView.image = [UIImage imageNamed:@"icon_navigationbar"];
//    [self.view addSubview:imageView];
    
    //返回按钮
//    UIButton *btn_back =[[UIButton alloc]initWithFrame:CGRectMake(5, 27, 35, 35)];
//    [btn_back setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
//    [btn_back addTarget:self action:@selector(click_btn_back:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn_back];
    
    //设置Title
//    UILabel *lanel=[[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 30)/2, 30, 50, 30)];
//    lanel.text=@"登录";
//    lanel.textColor=[UIColor whiteColor];
//    [self.view addSubview:lanel];
}

//如果有用户存在自动填充账号密码
-(void)check_userData
{
    User *userDit = [TYZFileData GetUserData];
    
    if (userDit.cellphone)
    {
        _textView_userName.text = userDit.cellphone;
        _textView_pwd.text = userDit.password;
    }
}
//返回按钮
-(void)click_btn_back:(UIButton *)button
{
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)createTextFields
{
    //放置一个View来包裹输入账号密码的框
    UILoginEditView *loginEditView = [[[NSBundle mainBundle]loadNibNamed:@"UILoginEditView" owner:self options:nil] lastObject];

    CGRect frame = loginEditView.frame;
    
    frame.origin.x = 10.0f;
    frame.origin.y = 15 + 64.0f;
    
    frame.size.width = SCREEN_WIDTH - 20.f;
    frame.size.height = 100.0f;
    
    loginEditView.frame = frame;
    
    loginEditView.backgrondView.layer.cornerRadius = 10.0f;
    
    //设置默认字体
    loginEditView.edit_userName.placeholder = [InternationalControl return_string:@"My_Login_input_userName"];
    loginEditView.edit_pwd.placeholder = [InternationalControl return_string:@"My_Login_input_password"];
    
    _textView_userName = loginEditView.edit_userName;
    _textView_pwd = loginEditView.edit_pwd;
    
    [self.view addSubview:loginEditView];
}

-(void)touchesEnded:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [_textView_userName resignFirstResponder];
    [_textView_pwd resignFirstResponder];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_textView_userName resignFirstResponder];
    [_textView_pwd resignFirstResponder];
}

-(void)moreLoginViewTitle
{
//    float line_height = (SCREEN_HEIGHT * 2) / 3;
//    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 140)/2,line_height,140,21)];
//    label.text=@"第三方账号快速登录";
//    label.textColor=[UIColor grayColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font=[UIFont systemFontOfSize:14];
//    [self.view addSubview:label];
//    
//    float textLine = (SCREEN_WIDTH - 180.0f) / 2 ;
//    UIImageView *line3=[self createImageViewFrame:CGRectMake(5.0f, line_height + 10, textLine, 1) imageName:nil color:[UIColor lightGrayColor]];
//    UIImageView *line4=[self createImageViewFrame:CGRectMake(SCREEN_WIDTH - textLine - 5.0f, line_height + 10, textLine, 1) imageName:nil color:[UIColor lightGrayColor]];
//    
//    [self.view addSubview:line3];
//    [self.view addSubview:line4];
}


-(void)createButtons
{
//    UIButton *btn_Login=[self createButtonFrame:CGRectMake(10.0f, 190.0f, SCREEN_WIDTH - 20.0f, 37.0f) backImageName:nil title:@"登录" titleColor:[UIColor whiteColor]  font:[UIFont systemFontOfSize:17] target:self action:@selector(onclick_btn_Login)];
    UIButton *btn_Login=[self createButtonFrame:CGRectMake(10.0f, 190.0f, SCREEN_WIDTH - 20.0f, 37.0f) backImageName:nil title:[InternationalControl return_string:@"My_Login"] titleColor:[UIColor whiteColor]  font:[UIFont systemFontOfSize:17] target:self action:@selector(onclick_btn_Login)];
    
    btn_Login.backgroundColor = [UIColor darkGrayColor];
    btn_Login.layer.cornerRadius=5.0f;
    
    [self.view addSubview:btn_Login];
    
    UIButton *btn_registered=[self createButtonFrame:CGRectMake(5, 235, 70, 30) backImageName:nil title:[InternationalControl return_string:@"My_Login_registered"] titleColor:[UIColor grayColor] font:[UIFont systemFontOfSize:13] target:self action:@selector(onclick_btn_registered)];
    [self.view addSubview:btn_registered];
    
    UIButton *btn_getPwd=[self createButtonFrame:CGRectMake(SCREEN_WIDTH - 75, 235, 60, 30) backImageName:nil title:[InternationalControl return_string:@"My_Login_findPassword"] titleColor:[UIColor grayColor] font:[UIFont systemFontOfSize:13] target:self action:@selector(onclick_btn_getPwd)];

    [self.view addSubview:btn_getPwd];
}

//按钮
-(UITextField *)createTextFielfFrame:(CGRect)frame font:(UIFont *)font placeholder:(NSString *)placeholder
{
    UITextField *textField=[[UITextField alloc]initWithFrame:frame];
    
    textField.font=font;
    
    textField.textColor=[UIColor grayColor];
    
    textField.borderStyle=UITextBorderStyleNone;
    
    textField.placeholder=placeholder;
    
    return textField;
}

-(UIImageView *)createImageViewFrame:(CGRect)frame imageName:(NSString *)imageName color:(UIColor *)color
{
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:frame];
    
    if (imageName)
    {
        imageView.image=[UIImage imageNamed:imageName];
    }
    if (color)
    {
        imageView.backgroundColor=color;
    }
    
    return imageView;
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


//登录
-(void)onclick_btn_Login
{
    if ([_textView_userName.text isEqualToString:@""])
    {
       NSLog(@"用户名不为空");
//       [ProgressHUD showError:@"请输入您的手机号码"];
        [ProgressHUD showError:[InternationalControl return_string:@"My_Login_input_userName"]];
        return;
    }
    else if (_textView_userName.text.length <11)
    {
        NSLog(@"手机号码格式错误");
//        [ProgressHUD showError:@"手机号码格式错误"];
        [ProgressHUD showError:[InternationalControl return_string:@"My_Login_username_error01"]];
        return;
    }
    else if ([_textView_pwd.text isEqualToString:@""])
    {
        NSLog(@"密码为空");
//        [ProgressHUD showError:@"请输入您的密码"];
        [ProgressHUD showError:[InternationalControl return_string:@"My_Login_password_error01"]];
        return;
    }
    else if (_textView_pwd.text.length <6)
    {
        NSLog(@"密码格式错误");
//        [ProgressHUD showError:@"密码格式错误"];
        [ProgressHUD showError:[InternationalControl return_string:@"My_Login_password_error02"]];
        return;
    }
    else
    {
        //返回
//        [[self navigationController] popViewControllerAnimated:YES];
        [ProgressHUD show:nil];
        
        NSString *username = _textView_userName.text;
        NSString *password = _textView_pwd.text;
        [User login:username password:password success:^(User *user)
        {
            [ProgressHUD dismiss];
            //登录成功
            [ProgressHUD showSuccess:nil];
            
            user.password = password;
            
            [Session sharedInstance].user = user;
            
            [[TYZ_AFNet_Client sharedInstance]setUserID:user.uid];

            //获取用户存储的各种信息 - 设备信息
            NSString *string = [NSString stringWithFormat:@"%d",[Session sharedInstance].user.uid];
            [User devicesList:string success:^(id data)
             {
                 //将字典数组转为Device模型数组
                 [Session sharedInstance].deviceArrys = [Device mj_objectArrayWithKeyValuesArray:data];
                 
                 //保存网络数据到本地
                 [TYZFileData SaveDeviceData:[Session sharedInstance].deviceArrys];
             }
                      failure:^(NSString *message)
             {
                 //没有绑定的设备
                 [Session sharedInstance].deviceArrys = [NSMutableArray array];
                 //保存网络数据到本地
                 [TYZFileData SaveDeviceData:[Session sharedInstance].deviceArrys];
             }];
            
            //保存账号密码到本地
            [TYZFileData SaveUserData:user];
            
            //返回上一目录
            [[self navigationController] popViewControllerAnimated:YES];
        }
        failure:^(NSString *error)
        {
//            [ProgressHUD showError:@""];
            if([error intValue] == 400)
            {
//                [ProgressHUD showError:@"网络不可用"];
                [ProgressHUD showError:[InternationalControl return_string:@"Custom_Update_netWork_Error"]];
                
                NSLog(@"网络不可用");
            }
            else
            {
//                [ProgressHUD showError:@"账户名或者密码错误"];
                [ProgressHUD showError:[InternationalControl return_string:@"My_Login_error"]];
                NSLog(@"账户名或者密码错误");
            }
        }];
    }
}

//注册
-(void)onclick_btn_registered
{
    RegisteredViewController_01 *view = [[RegisteredViewController_01 alloc]init];
    
    [self.navigationController pushViewController:view animated:true];
}

//忘记密码
-(void)onclick_btn_getPwd
{
    ForgetPwdViewController_01 *view = [[ForgetPwdViewController_01 alloc] init];
    //解决push跳转卡顿问题就是保证跳转的view是有背景颜色的
    [self.navigationController pushViewController: view animated:true];
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
