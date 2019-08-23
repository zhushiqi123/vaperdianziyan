//
//  MessageUrlViewController.m
//  uvapor
//
//  Created by TYZ on 16/12/23.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "MessageUrlViewController.h"
#import "InternationalControl.h"
#import "JPushMessage.h"

@interface MessageUrlViewController ()

@end

@implementation MessageUrlViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [InternationalControl return_string:@"My_Message"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建进度条
    self.ProgressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.ProgressView.frame = CGRectMake(0, 64, self.view.bounds.size.width, 1);
    
    //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
    self.ProgressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    
    // 设置进度条的色彩
    [self.ProgressView setTrackTintColor:[UIColor clearColor]];
    self.ProgressView.progressTintColor = RGBCOLOR(0x00, 0xbe, 0xa4);//[UIColor magentaColor];
    [self.view addSubview:self.ProgressView];
    
    /*
     *3.添加KVO，WKWebView有一个属性estimatedProgress，就是当前网页加载的进度，所以监听这个属性。
     */
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    [self startLoad];
}

#pragma mark - start load web
- (void)startLoad
{
    NSString *url_str = _jpMsg.notice_url;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
    //超时时间
    request.timeoutInterval = 15.0f;
    
    [self.webView.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.webView.scrollView setShowsVerticalScrollIndicator:NO];
    
    [self.webView loadRequest:request];
}

/*
 *4.在监听方法中获取网页加载的进度，并将进度赋给progressView.progress
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        NSLog(@"self.ProgressView.progress - %f",self.ProgressView.progress);
        self.ProgressView.progress = self.webView.estimatedProgress;
        
        if (self.ProgressView.progress == 1)
        {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.ProgressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.ProgressView.hidden = YES;
                
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKWKNavigationDelegate Methods
/*
 *5.在WKWebViewd的代理中展示进度条，加载完成后隐藏进度条
 */
//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //        NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.ProgressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.ProgressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.ProgressView];
}

//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //        NSLog(@"加载完成");
    self.ProgressView.progress = 1;
    //加载完成后隐藏progressView
    double delayInSeconds = 0.1f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       //加载失败同样需要隐藏progressView
                       self.ProgressView.hidden = YES;
                   });
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    //        NSLog(@"加载失败");
    self.ProgressView.progress = 1;
    double delayInSeconds = 0.1f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       //加载失败同样需要隐藏progressView
                       self.ProgressView.hidden = YES;
                   });
}


- (WKWebView *)webView
{
    if (_webView == nil)
    {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0.0f, 64.0f, self.view.frame.size.width, self.view.frame.size.height - 64.0f)];
        
        //        _webView.center = self.view.center;
        
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
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
