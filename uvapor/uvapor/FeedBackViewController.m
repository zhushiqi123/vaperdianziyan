//
//  FeedBackViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "FeedBackViewController.h"
#import "Session.h"
#import "ProgressHUD.h"
#import "InternationalControl.h"
#import "Session.h"

@interface FeedBackViewController ()
{
    NSMutableData *webData;
    NSInteger n;
}

@end

@implementation FeedBackViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [ProgressHUD dismiss];
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.title = @"反馈信息";
    self.title = [InternationalControl return_string:@"My_feedback"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _uiwebview = [[UIWebView alloc]initWithFrame:CGRectMake(0.0f, 64.0f, self.view.frame.size.width, self.view.frame.size.height - 64.0f)];

    _uiwebview.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_uiwebview];
    
    NSString *phone = @"0755-29020821";
    NSString *email = @"uVapor@stw-ecig.com";
    NSString *languages = @"1";    //判断语言类型
    
    if ([Session sharedInstance].isLanguage == 0)
    {
        languages = @"2";
    }
    
    if ([Session sharedInstance].user.cellphone.length > 0)
    {
        phone = [Session sharedInstance].user.cellphone;
    }
    
    if([Session sharedInstance].user.email.length > 0)
    {
        email = [Session sharedInstance].user.email;
    }

    _uiwebview.delegate = self;

    NSString *str = @"http://120.24.175.35/feedback/feedback.php";
    NSURL *url = [NSURL URLWithString:str];
    NSString *body = [NSString stringWithFormat: @"phone=%@&email=%@&language=%@",phone,email,languages];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [request setHTTPMethod: @"POST"];
    [_uiwebview loadRequest: request];
    //    [self.webview loadRequest:[NSURLRequest requestWithURL:url]];
    [_uiwebview loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [ProgressHUD show:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)web
{
    [ProgressHUD dismiss];
}

-(void)webView:(UIWebView*)webView  DidFailLoadWithError:(NSError*)error
{
    [ProgressHUD showError:@"网络错误"];
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
