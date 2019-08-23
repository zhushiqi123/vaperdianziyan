//
//  UpdatePhoneViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/11/15.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "UpdatePhoneViewController.h"
#import "RegisteredView01.h"
#import "ProgressHUD.h"
#import "User.h"
#import "TYZFileData.h"
#import "Session.h"
#import "InternationalControl.h"

@interface UpdatePhoneViewController ()
{
    RegisteredView01 *registeredView;
    NSString *codeText;
    NSString *user_phone;
    NSTimer *codeTimer;
    int s;
}

@end

@implementation UpdatePhoneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //My_change_phoneNum - 修改手机号码
    self.title = [InternationalControl return_string:@"My_change_phoneNum"];
    // Do any additional setup after loading the view.
    
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
    [registeredView.edit_phone resignFirstResponder];
    [registeredView.edit_checkNum resignFirstResponder];
}


//加载修改手机号码Edit部分
-(void)addEditView
{
    registeredView = [[[NSBundle mainBundle]loadNibNamed:@"RegisteredView01" owner:self options:nil] lastObject];
    
    CGRect frame = registeredView.frame;
    
    frame.origin.x = 10.0f;
    frame.origin.y =  84.0f;
    
    frame.size.width = SCREEN_WIDTH - 20.0f;
    frame.size.height = 150.0f;
    
    registeredView.frame = frame;
    
    //My_change_phoneNum_inputNewNum - 请输入您的新手机号码
    registeredView.lable_title.text = [InternationalControl return_string:@"My_change_phoneNum_inputNewNum"];
    
    registeredView.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
    registeredView.backgroundView.layer.cornerRadius = 10.0f;
    
    registeredView.lable_phone.text = [InternationalControl return_string:@"My_registered_phone"];
    registeredView.lable_checkNum.text = [InternationalControl return_string:@"My_registered_checknum"];
    
    registeredView.edit_phone.placeholder = [InternationalControl return_string:@"My_registered_phone11"];
    registeredView.edit_checkNum.placeholder = [InternationalControl return_string:@"My_registered_checknum4"];
    
    [registeredView.btn_checkNum setTitle:[InternationalControl return_string:@"My_registered_getCheckNum"] forState:UIControlStateNormal];
    
    [registeredView.edit_phone addTarget:self action:@selector(tfChange:) forControlEvents:UIControlEventEditingChanged];
    [registeredView.edit_phone addTarget:self action:@selector(tfEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    [registeredView.edit_checkNum addTarget:self action:@selector(tfChange:) forControlEvents:UIControlEventEditingChanged];
    [registeredView.edit_checkNum addTarget:self action:@selector(tfEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    [registeredView.btn_checkNum addTarget:self action:@selector(checkNum_btn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:registeredView];
}

//获取验证码
-(void)checkNum_btn
{
    if([registeredView.edit_phone.text isEqualToString:@""] && registeredView.edit_phone.text.length != 11)
    {
        //My_registered_phoneError - 请输入正确的手机号码
        [ProgressHUD showError:[InternationalControl return_string:@"My_registered_phoneError"]];
    }
    else
    {
        registeredView.btn_checkNum.enabled = NO;
        
        [ProgressHUD show:nil];
        
        s = 60;
        codeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(codeWait:) userInfo:nil repeats:YES];
        
        [User code:registeredView.edit_phone.text :^(NSString *code)
         {
//             NSLog(@"code - > %@",code);
             
             user_phone = registeredView.edit_phone.text;
             
             codeText = code;
             
             //My_registered_getCheckNum_success - 验证码获取成功
             [ProgressHUD showSuccess:[InternationalControl return_string:@"My_registered_getCheckNum_success"]];
         }
           failure:^(NSString *message)
         {
             //            NSLog(@"message - > %@",message);
             //My_registered_phone_use_error - 号码已经被注册
             [ProgressHUD showError:[InternationalControl return_string:@"My_registered_phone_use_error"]];;
         } ];
    }
}

//延时获取验证码
- (void)codeWait:(NSTimer *)sender
{
    if (s >= 0)
    {
        registeredView.btn_checkNum.titleLabel.text = [NSString stringWithFormat:@"%ds",s];
        [registeredView.btn_checkNum setTitle:[NSString stringWithFormat:@"%ds",s] forState:UIControlStateNormal];
        s--;
    }
    else
    {
        [sender invalidate];
        registeredView.btn_checkNum.enabled = YES;
        [registeredView.btn_checkNum setTitle:[InternationalControl return_string:@"My_registered_getCheckNum"] forState:UIControlStateNormal];
    }
}


//正在输入
- (void)tfChange:(UITextField *)sender
{
    if ([sender isEqual:registeredView.edit_phone])
    {
        if (sender.text.length > 0)
        {
            if ([sender.text characterAtIndex:(sender.text.length-1)] > '9'||[sender.text characterAtIndex:(sender.text.length-1)] < '0')
            {
                registeredView.edit_phone.text = @"";
//                [ProgressHUD showError:@"请输入正确的手机号码"];
                //My_registered_phoneError - 请输入正确的手机号码
                [ProgressHUD showError:[InternationalControl return_string:@"My_registered_phoneError"]];
            }
            if (sender.text.length > 11)
            {
                registeredView.edit_phone.text = @"";
                //My_registered_phoneError - 请输入正确的手机号码
                [ProgressHUD showError:[InternationalControl return_string:@"My_registered_phoneError"]];
            }
        }
    }
    else if([sender isEqual:registeredView.edit_checkNum])
    {
        if (sender.text.length > 4)
        {
            registeredView.edit_checkNum.text = @"";
            //My_registered_checkNumError - 请输入正确的验证码
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_checkNumError"]];
        }
    }
}

//停止输入
- (void)tfEnd:(UITextField *)sender
{
    if ([sender isEqual:registeredView.edit_phone])
    {
        if (sender.text.length != 11)
        {
            registeredView.edit_phone.text = @"";
            //My_registered_phoneError - 请输入正确的手机号码
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_phoneError"]];
        }
    }
    else if([sender isEqual:registeredView.edit_checkNum])
    {
        if (sender.text.length != 4)
        {
            registeredView.edit_checkNum.text = @"";
            //My_registered_checkNumError - 请输入正确的验证码
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_checkNumError"]];
        }
    }
}


//加载确认按钮
-(void)addNextView
{
    UIButton *btn_next=[self createButtonFrame:CGRectMake(10.0f, 190.0f + 64.0f, SCREEN_WIDTH - 20.0f, 37.0f) backImageName:nil title:[InternationalControl return_string:@"window_confirm"] titleColor:[UIColor whiteColor]  font:[UIFont systemFontOfSize:17] target:self action:@selector(onclick_btn_next)];
    
    btn_next.backgroundColor = [UIColor darkGrayColor];
    btn_next.layer.cornerRadius=5.0f;
    
    [self.view addSubview:btn_next];
}

//确认按钮事件
-(void)onclick_btn_next
{
    if (registeredView.edit_phone.text.length != 11 && ![user_phone isEqualToString:registeredView.edit_phone.text])
    {
        //My_registered_phoneError - 请输入正确的手机号码
        [ProgressHUD showError:[InternationalControl return_string:@"My_registered_phoneError"]];
    }
    else
    {
        if([registeredView.edit_checkNum.text isEqualToString:@""])
        {
            //My_registered_input_checkNum - 请输入验证码
            [ProgressHUD showError:[InternationalControl return_string:@"My_registered_input_checkNum"]];
        }
        else
        {
            if ([registeredView.edit_checkNum.text intValue] == [codeText intValue])
            {
                [User setCellphone:user_phone success:^(id data)
                {
                    //My_change_phoneNum_success - 手机号码修改成功
                    [ProgressHUD showSuccess:[InternationalControl return_string:@"My_change_phoneNum_success"]];
                    
                    User *user = [User initdata:data];
                    
                    [Session sharedInstance].user = user;
                    
                    //保存账号密码到本地
                    [TYZFileData SaveUserData:user];
                }
                failure:^(NSString *message)
                {
                    //My_change_phoneNum_failure - 手机号码修改失败
                    [ProgressHUD showError:[InternationalControl return_string:@"My_change_phoneNum_failure"]];
                }];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
//                [ProgressHUD dismiss];
                //My_registered_checkNumError - 验证码错误
                [ProgressHUD showError:[InternationalControl return_string:@"My_registered_checkNumError"]];
            }
        }
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
