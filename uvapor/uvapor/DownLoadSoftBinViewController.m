//
//  DownLoadSoftBinViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/10/8.
//  Copyright © 2016年 TYZ. All rights reserved.
//
#define STSRTDRESS 0xA0
#define PAGE01BIN 0x60

#import "DownLoadSoftBinViewController.h"
#import "STW_BLE_SDK.h"
#import "ProgressHUD.h"
#import "CustomViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "InternationalControl.h"

@interface DownLoadSoftBinViewController ()<UINavigationControllerDelegate>
{
    //CRC校验和
    uint16_t check_all;  //加密
    uint16_t checkAllNum_decryption;  //解密
    
    //网络获取的数据包
    NSData *soft_data;
    //升级数据总字节数
    int data_all_byte_bin;
    //升级包数
    int text_n;
    //固件是否需要添加0发送，取得余数
    int data_all_remainder;
    //固件数据包数
    int data_n;
    //正在升级的包数
    int data_n_now;
    //将要发送的总包数
    int data_nums;
    
    //分段
    int check01;
    int check02;
    int check03;
    int check04;
    
    //检测蓝牙是否重启
    int checkRefsh;
    //检测下载是否成功
    int checkDownloadSuccess;
    //检测下载过程是否出错
    int checkDownLoadError;
    //检测下载程序是否可以应答
    int checkReplyAllPage;
    //检测安装程序是否可以启动
    int checkStartDownLoad;

    NSData *device_datas_soft;
    NSData *device_check_crc16;
    
    //第一包数据文件
    NSData *soft_update_page01_bin;
    
    //扫描蓝牙信号
    NSTimer *timerRSSI;
    
    //是否按按钮离开页面
    int our_btn;  //0 - 取消升级  1 - 主动退出
}
@end

@implementation DownLoadSoftBinViewController

//返回按钮
-(BOOL)navigationShouldPopOnBackButton ///在这个方法里写返回按钮的事件处理
{
    if(our_btn == 0)
    {
        our_btn = 1;
        //遍历UIViewController返回到相应的UIViewController
        for (UIViewController *controller in self.navigationController.viewControllers)
        {
            if ([controller isKindOfClass:[CustomViewController class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
                
                return NO;
            }
        }
    }
    
    return YES;//返回NO 不会执行
}

//页面即将出现
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [STW_BLE_SDK STW_SDK].Update_Now = 1;
}

//页面即将消失
-(void)viewWillDisappear:(BOOL)animated
{
//    NSLog(@"消失");
    
    [super viewWillDisappear:animated];
    [STW_BLE_SDK STW_SDK].Update_Now = 0;
    checkDownLoadError = -1;
    
    if (data_n != data_n_now)
    {
        //取消升级
        [ProgressHUD showError:[InternationalControl return_string:@"Custom_Update_status_UndoUpdate"]];
    }
    
    if(our_btn == 0)
    {
        our_btn = 1;
        
        for (UIViewController *controller in self.navigationController.viewControllers)
        {
            if ([controller isKindOfClass:[CustomViewController class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
}

//-(void)viewDidDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [STW_BLE_SDK STW_SDK].Update_Now = 0;
//    checkDownLoadError = -1;
//    if (data_n != data_n_now)
//    {
//        [ProgressHUD showError:@"取消升级"];
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    our_btn = 0;
    
//    timerRSSI = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(readRSSIBLE) userInfo:nil repeats:YES];
    
    //注册蓝牙信号的回调
//    [self readRSSIBLE_back];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    // Do any additional setup after loading the view.
    self.title = [STW_BLE_SDK STW_SDK].softUpdate_bean.softName;

//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(onBackBtn)];

    //进行数据分段初始化
    check01 = 0;
    check02 = 0;
    check03 = 0;
    check04 = 0;
    
    //拼装升级链接
    _soft_pash = [NSString stringWithFormat:@"http://www.uvapour.com:8080%@",[STW_BLE_SDK STW_SDK].softUpdate_bean.updatePath];
    
//    _soft_pash = [NSString stringWithFormat:@""];
    
//    NSLog(@"_soft_pash - %@",_soft_pash);

    //添加下载进度的指示
    [self addProgressView];
    
    //添加发送总包数数据提示
    [self addLableToPageNumView];
    
    //添加打印日志信息
    [self addLableToLogView];
    
    //升级按钮
    [self addUpdateBtnSubView];
    
    //信息文本
    [self addTextView];
    
    self.progressUIView01.hidden = YES;
    self.progressUIView02.hidden = YES;
    self.progressUIView03.hidden = YES;
    self.progressUIView04.hidden = YES;
    self.progressUIView05.hidden = YES;
    self.progressUIView06.hidden = YES;
    
    self.pageNumLableView.hidden = YES;
    self.LogLableView.hidden = YES;
}

//添加下载进度的指示
-(void)addProgressView
{
    int lengs = 0;
    
    int image_weight = (SCREEN_WIDTH - 150) / 6;
    
    int image_height = 30 - 4;
    
    if ((image_weight - 4) > image_height)
    {
        lengs = image_height;
    }
    else
    {
        lengs = image_weight - 4;
    }
    
    UIView *progressView01 = [[UIView alloc]initWithFrame:CGRectMake(130, 94, lengs, lengs)];
    UIView *progressView02 = [[UIView alloc]initWithFrame:CGRectMake(130 + image_weight, 94, lengs, lengs)];
    UIView *progressView03 = [[UIView alloc]initWithFrame:CGRectMake(130 + (image_weight * 2), 94, lengs, lengs)];
    UIView *progressView04 = [[UIView alloc]initWithFrame:CGRectMake(130 + (image_weight * 3), 94, lengs, lengs)];
    UIView *progressView05 = [[UIView alloc]initWithFrame:CGRectMake(130 + (image_weight * 4), 94, lengs, lengs)];
    UIView *progressView06 = [[UIView alloc]initWithFrame:CGRectMake(130 + (image_weight * 5), 94, lengs, lengs)];
    
    progressView01.backgroundColor = [UIColor darkGrayColor];
    progressView02.backgroundColor = [UIColor darkGrayColor];
    progressView03.backgroundColor = [UIColor darkGrayColor];
    progressView04.backgroundColor = [UIColor darkGrayColor];
    progressView05.backgroundColor = [UIColor darkGrayColor];
    progressView06.backgroundColor = [UIColor darkGrayColor];
    
    //设置圆角
    progressView01.layer.cornerRadius = (lengs/2.0f);
    progressView02.layer.cornerRadius = (lengs/2.0f);
    progressView03.layer.cornerRadius = (lengs/2.0f);
    progressView04.layer.cornerRadius = (lengs/2.0f);
    progressView05.layer.cornerRadius = (lengs/2.0f);
    progressView06.layer.cornerRadius = (lengs/2.0f);
    
    progressView01.layer.borderWidth = 2;
    progressView02.layer.borderWidth = 2;
    progressView03.layer.borderWidth = 2;
    progressView04.layer.borderWidth = 2;
    progressView05.layer.borderWidth = 2;
    progressView06.layer.borderWidth = 2;
    
    progressView01.layer.borderColor = [UIColor lightGrayColor].CGColor;
    progressView02.layer.borderColor = [UIColor lightGrayColor].CGColor;
    progressView03.layer.borderColor = [UIColor lightGrayColor].CGColor;
    progressView04.layer.borderColor = [UIColor lightGrayColor].CGColor;
    progressView05.layer.borderColor = [UIColor lightGrayColor].CGColor;
    progressView06.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.view addSubview:progressView01];
    [self.view addSubview:progressView02];
    [self.view addSubview:progressView03];
    [self.view addSubview:progressView04];
    [self.view addSubview:progressView05];
    [self.view addSubview:progressView06];
    
    self.progressUIView01 = progressView01;
    self.progressUIView02 = progressView02;
    self.progressUIView03 = progressView03;
    self.progressUIView04 = progressView04;
    self.progressUIView05 = progressView05;
    self.progressUIView06 = progressView06;
}

//添加发送总包数数据提示
-(void)addLableToPageNumView
{
    UILabel *pageNumLable = [[UILabel alloc]initWithFrame:CGRectMake(130, 94 + 30, SCREEN_WIDTH - 20 - 130, 30)];
    
    pageNumLable.backgroundColor = [UIColor clearColor];
    
    pageNumLable.textColor = [UIColor whiteColor];
    
//    pageNumLable.text = @"升级进度:";
    pageNumLable.text = [InternationalControl return_string:@"Custom_Update_status_progress"];
    
    [self.view addSubview:pageNumLable];
    
    self.pageNumLableView = pageNumLable;
}

//添加打印日志信息
-(void)addLableToLogView
{
    UILabel *LogLable = [[UILabel alloc]initWithFrame:CGRectMake(130, 94 + 60, SCREEN_WIDTH - 20 - 130, 30)];
    
    LogLable.backgroundColor = [UIColor clearColor];
    
    LogLable.textColor = [UIColor whiteColor];
    
    LogLable.text = [InternationalControl return_string:@"Custom_Update_status_checkFile"];
//    LogLable.text = @"校验文件";
    
    LogLable.font = [UIFont systemFontOfSize:12.0f];
    
    [self.view addSubview:LogLable];
    
    self.LogLableView = LogLable;
}

//添加展示信息的文本view
-(void)addTextView
{
    UITextView *textViews = [[UITextView alloc]initWithFrame:CGRectMake(10, 200, SCREEN_WIDTH - 20, SCREEN_HEIGHT - 200 - 64) textContainer:nil];
    
    //设置背景
    textViews.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
    
    //设置文字对齐方式
    textViews.textAlignment = NSTextAlignmentLeft;
    
    //设置文字颜色
    textViews.textColor = [UIColor whiteColor];
    
    //设置文字属性
    textViews.font = [UIFont systemFontOfSize:14.0f];
    
    //设置不可编辑
    textViews.editable = NO;
    textViews.selectable = NO;
    
    //设置圆角
    textViews.layer.cornerRadius = 10.0f;
    
    textViews.layer.borderWidth = 2;
    
    textViews.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    NSString *str_lable_text = [NSString stringWithFormat:
                                @"1.%@：%@\n\n2.%@：%@\n\n3.%@：%@\n\n %@ \n\n1.%@\n\n2.%@\n\n3.%@\n\n4.%@",
                                    [InternationalControl return_string:@"Custom_Update_softName"],
                                    [STW_BLE_SDK STW_SDK].softUpdate_bean.softName,
                                    [InternationalControl return_string:@"Custom_Update_deviceName"],
                                    [STW_BLE_SDK STW_SDK].softUpdate_bean.devieName,
                                    [InternationalControl return_string:@"Custom_Update_fileName"],
                                    [STW_BLE_SDK STW_SDK].softUpdate_bean.binname,
                                    [InternationalControl return_string:@"Custom_Update_message"],
                                    [InternationalControl return_string:@"Custom_Update_warning01"],
                                    [InternationalControl return_string:@"Custom_Update_warning02"],
                                    [InternationalControl return_string:@"Custom_Update_warning03"],
                                    [InternationalControl return_string:@"Custom_Update_warning04"]
                                ];
    
    textViews.text = str_lable_text;
    
    [self.view addSubview:textViews];
    
    self.textView = textViews;
}

- (void)addUpdateBtnSubView
{
    [self.view addSubview:({
        JSDownloadView *downloadView = [[JSDownloadView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2-50, 84, 100, 100)];
        downloadView.delegate = self;
        downloadView.progressWidth = 4;
        self.downloadView = downloadView;
    })];
}

- (JSDownLoadManager *)manager
{
    if (!_manager)
    {
        _manager = [[JSDownLoadManager alloc] init];
    }
    return _manager;
}


- (void)downTask
{
    NSString*url = _soft_pash;
    
    [self.manager downloadWithURL:url
                         progress:^(NSProgress *downloadProgress) {
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 NSString *progressString  = [NSString stringWithFormat:@"%.2f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount];
                                 self.downloadView.progress = progressString.floatValue;
                             });
                             
                         }
                             path:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                 //
                                 NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                                 NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
                                 return [NSURL fileURLWithPath:path];
                             }
                       completion:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                           //此时已在主线程
                           if (filePath)
                           {
                               self.downloadView.isSuccess = YES;
                               NSString *softpath = [filePath path];
  
                               //如果下载成功不再重复下载
                               if (self.downloadView.isSuccess)
                               {
                                   self.downloadView.userInteractionEnabled = NO;
                                   
                                   double delayInSeconds = 0.5f;
                                   dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                   dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                                                  {
                                                      //开始动画
                                                      [self DownLoadEndAnimation:softpath];
                                                  });
                               }
                           }
                           else
                           {
                               NSLog(@"下载失败");
                               [STW_BLE_SDK STW_SDK].Update_Now = 0;
                               self.downloadView.isSuccess = NO;
//                               [self.downloadView showErrorAnimation];
                           }
                       }];
}

//下载完成之后的动画
-(void)DownLoadEndAnimation:(NSString *)filepath
{
//    [self.downloadView showDownSoftAnimation];
    
    CABasicAnimation *anima1 = [CABasicAnimation animationWithKeyPath:@"position"];
    anima1.fromValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.view.frame)/2, 84 + 50)];
    anima1.toValue = [NSValue valueWithCGPoint:CGPointMake(20 + 50,84 + 50)];
    anima1.duration = 1.0f;
    //如果fillMode=kCAFillModeForwards和removedOnComletion=NO，那么在动画执行完毕后，图层会保持显示动画执行后的状态。但在实质上，图层的属性值还是动画执行前的初始值，并没有真正被改变。
    anima1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    //缩放动画
    CABasicAnimation *anima2 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anima2.fromValue = [NSNumber numberWithFloat:1.0f];
    anima2.toValue = [NSNumber numberWithFloat:0.8f];
    
    //组动画
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = [NSArray arrayWithObjects:anima1,anima2, nil];
    groupAnimation.duration = 1.0f;
    
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.removedOnCompletion = NO;
    
    [_downloadView.layer addAnimation:groupAnimation forKey:@"groupAnimation"];
    
    //指示布局可以出现
    double delayInSeconds = 1.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       //延时方法
                       [self showProgressAnimation:filepath];
                   });
}

//显示指示布局的动画
-(void)showProgressAnimation:(NSString *)filepath
{
    _progressUIView01.hidden = NO;
    _progressUIView02.hidden = NO;
    _progressUIView03.hidden = NO;
    _progressUIView04.hidden = NO;
    _progressUIView05.hidden = NO;
    _progressUIView06.hidden = NO;
    
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anima.fromValue = [NSNumber numberWithFloat:0.4f];
    anima.toValue = [NSNumber numberWithFloat:0.8f];
    anima.duration = 0.5f;
    
    [_progressUIView01.layer addAnimation:anima forKey:@"opacityAniamtion"];
    [_progressUIView02.layer addAnimation:anima forKey:@"opacityAniamtion"];
    [_progressUIView03.layer addAnimation:anima forKey:@"opacityAniamtion"];
    [_progressUIView04.layer addAnimation:anima forKey:@"opacityAniamtion"];
    [_progressUIView05.layer addAnimation:anima forKey:@"opacityAniamtion"];
    [_progressUIView06.layer addAnimation:anima forKey:@"opacityAniamtion"];
    
    double delayInSeconds = 0.5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       //延时方法
                       _pageNumLableView.hidden = NO;
                       [_pageNumLableView.layer addAnimation:anima forKey:@"opacityAniamtion"];
                   });
    
    double delayInSeconds2 = 1.0f;
    dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
    dispatch_after(popTime2, dispatch_get_main_queue(), ^(void)
                   {
                       //延时方法
                       _LogLableView.hidden = NO;
                       [_LogLableView.layer addAnimation:anima forKey:@"opacityAniamtion"];
                   });

    [self performSelector:@selector(startUpdateSoft01:) withObject:filepath afterDelay:1.5f];
}

//开始第一步进行无限升级准备
-(void)startUpdateSoft01:(NSString *)filepath
{
    //初始化
    soft_data = [[NSData alloc] init];

    _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_checkFile_start"];//@"开始校验文件";
    
    //获取文件数据
    soft_data = [[NSData alloc]init];
    soft_data = [NSData dataWithContentsOfFile:filepath];
    
//    NSLog(@"softData - %@",soft_data);
    
    int lengs = (int)soft_data.length;
    
    //获取bin文件头部信息
    soft_update_page01_bin = [[NSData alloc] init];
    
    soft_update_page01_bin = [soft_data subdataWithRange:NSMakeRange(PAGE01BIN,16)];
    
//    NSLog(@"soft_update_page01_bin - %@",soft_update_page01_bin);
    
    device_datas_soft = [soft_data subdataWithRange:NSMakeRange(STSRTDRESS,lengs - STSRTDRESS)];
    
    device_check_crc16 = [STW_BLE_Protocol check_data_68K:device_datas_soft];
    
//    NSLog(@"device_datas_soft - %@",device_datas_soft);
//
//    NSLog(@"device_check_crc16 - %@",device_check_crc16);
//    Byte c[] = {0xcc , 0xab , 0x55 , 0x32};
    
//    Byte c[] = {0x32 , 0x55 , 0xab , 0xcc};
//    NSData *textdata = [NSData dataWithBytes:c length:4];
//    
//    uint16_t Crc_num01 = [STW_BLE_Protocol CRC16_1:textdata];
//    
//    NSLog(@"Crc_num01 - %d",Crc_num01);
    
    //解密
    NSMutableData *A5_datas = [STW_BLE_Protocol decryption_A5_NsData:device_check_crc16];

    //校验
//    check_all = [STW_BLE_Protocol CRC16_1:device_check_crc16];  //加密校验
    
    check_all = 0;  //加密校验
    
    checkAllNum_decryption = [STW_BLE_Protocol CRC16_1:A5_datas];   //解密校验

//    NSLog(@"校验和 - %d - %d",check_all,checkAllNum_decryption);
    
    data_all_byte_bin = (int)device_check_crc16.length;
    
    //NSLog(@"%d * %d - %@ - %@",check_all01,check_all02,device_check_all01,device_check_all02);
    const unsigned char* bytes_datas_check_bin = [soft_update_page01_bin bytes];
    uint16_t checkCrc16_bin = bytes_datas_check_bin[1] * 256 +  bytes_datas_check_bin[0];
    
    NSLog(@"计算校验和 - %d - 获取bin校验和 - %d",checkAllNum_decryption,checkCrc16_bin);
    
    //判断文件是否有误
    if (checkAllNum_decryption == checkCrc16_bin)
    {
        _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_checkFileOK"];//@"文件校验通过!";
        
        NSLog(@"文件校验通过!开始进行数据封装! - %d",check_all);
        
        //数据封装
        text_n = 0;
        data_n_now = 0;
        
        data_all_remainder = data_all_byte_bin%16;
        
        data_n = data_all_byte_bin/16;
        
        _pageNumLableView.text = [NSString stringWithFormat:@"%d/%d",data_n_now,data_n];
        
        if (data_all_remainder > 0)
        {
            data_nums = data_n + 1;
        }
        
        check01 = (data_n * 1)/5;
        check02 = (data_n * 2)/5;
        check03 = (data_n * 3)/5;
        check04 = (data_n * 4)/5;
        
        checkStartDownLoad = 0;
        _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_checkBin"];//@"验证安装包!";
        
        double delayInSeconds = 5.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           if (checkStartDownLoad == 0)
                           {
                               _LogLableView.textColor = [UIColor redColor];
                               _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_checkBinOutTime"];//@"安装包验证超时!";
                               [STW_BLE_SDK STW_SDK].Update_Now = 0;
                           }
                       });
        
        //点亮屏幕
        [STW_BLE_Protocol the_activate_device];
        
        //发送第一包沟通数据
        Byte byte[4];
        
        NSMutableData *datas_c1 = [[NSMutableData alloc] init];
        
        byte[0] = 0x00;
        byte[1] = 0x00;
        byte[2] = 0x04;
        byte[3] = 0x00;
        
        [datas_c1 appendBytes:byte length:4];
        
        [[STW_BLEService sharedInstance] sendBigData:datas_c1 :0];
        
        //注册升级软件的回调
        [self update_back];
        
    }
    else
    {
        NSLog(@"文件校验-->出错!");
        _LogLableView.textColor = [UIColor redColor];
        _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_checkBinError"];//@"安装包校验出错!";
        [STW_BLE_SDK STW_SDK].Update_Now = 0;
    }
}

-(void)update_back
{
    [STW_BLEService sharedInstance].Service_Soft_Update = ^(int pageNum)
    {
//        NSLog(@"pageNum - %d",pageNum);
        
        switch (pageNum)
        {
            case 0:
            //发送产品名称
            {
                checkStartDownLoad = 1;
                _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_checkBinName"];//@"检测文件名称!";
                NSMutableData *sendData = [self head_data_send:0 :16 :1 :18];
                [[STW_BLEService sharedInstance] sendBigData:sendData :0];
            }
                
                break;
            case 1:
            //发送软件版本
            {
                _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_CheckSoftVersion"];//@"检测软件版本!";
                NSMutableData *sendData = [self head_data_send:16 :16 :2 :18];
                [[STW_BLEService sharedInstance] sendBigData:sendData :0];
            }
                break;
            case 2:
            //发送硬件版本
            {
                _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_CheckDeviceVersion"];//@"检测硬件!";
                NSMutableData *sendData = [self head_data_send:32 :16 :3 :18];
                [[STW_BLEService sharedInstance] sendBigData:sendData :0];
            }
                break;
            case 3:
            //发送文件名称
            {
                _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_CheckBinFiel"];//@"检测文件!";
                NSMutableData *sendData = [self head_data_send:48 :16 :4 :18];
                [[STW_BLEService sharedInstance] sendBigData:sendData :0];
            }
                break;
            case 4:
            {
                //设置标志
                _progressUIView01.backgroundColor = [UIColor greenColor];
                
                [STW_BLE_SDK STW_SDK].Update_Now = 1;
                
                //开始发送升级文件
                _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_UpdateFiel"];//@"下载安装包";

                //发送第一包数据
                [STW_BLE_Protocol the_soft_update_page01_bin:soft_update_page01_bin];
//                [STW_BLE_Protocol the_soft_update_page01:check_all :checkAllNum_decryption];
                
                //开始下载
                checkDownloadSuccess = 0;
                //下载开始
                checkDownLoadError = 0;
                //初始化掉包设置
                [STW_BLE_SDK STW_SDK].softUpdate_lostPage = [NSMutableArray array];
                
                //延时开始发送接下来的数据
                [self performSelector:@selector(send_device_datas) withObject:nil afterDelay:0.01f];
            }
                break;
            case 0x87:
            {
                checkReplyAllPage = 1;
                _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_downOk"];//@"数据接收完成，等待写入!";
            }
                break;
            case 0x88:
            {
                checkReplyAllPage = 1;
                _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_device_restart"];//@"设备正在重启,等待重连!";
                checkDownloadSuccess = -1;
            }
                break;
            case 0xE0:
            {
                checkDownLoadError = 1;
                _LogLableView.textColor = [UIColor redColor];
                _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_checkFileError"];//@"文件不匹配,请重新下载!";
                [STW_BLE_SDK STW_SDK].Update_Now = 0;
            }
                break;
            case 0xE1:
            {
                checkDownLoadError = 1;
                _LogLableView.textColor = [UIColor redColor];
                _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_softVisionError"];//@"软件版本过低,请重新下载!";
                [STW_BLE_SDK STW_SDK].Update_Now = 0;
            }
                break;
            case 0xE2:
            {
                checkDownLoadError = 1;
                _LogLableView.textColor = [UIColor redColor];
                _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_BleError"];//@"蓝牙信号不稳定,请重新下载!";
                [STW_BLE_SDK STW_SDK].Update_Now = 0;
            }
                break;
            case 0xE8:
            {
                checkReplyAllPage = 1;
                
                checkRefsh = 1;
                
                //补发所掉的数据包
                int low_page_nums = (int)[STW_BLE_SDK STW_SDK].softUpdate_lostPage.count;
                
                for (int i = 0; i < low_page_nums; i++)
                {
                    NSString *str_nums = [[STW_BLE_SDK STW_SDK].softUpdate_lostPage objectAtIndex:i];
                    int now_loePages = [str_nums intValue];
                    
                    double delayInSeconds = 0.01f;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                                   {
                                       //数据发送函数 frame_start->开始截取位置  frame_len->截取长度 frame_nums->帧序列 frame_length->帧长度  add_0->是否需要添加0
                                       [self send_data_add:(now_loePages * 16) :16 :now_loePages :18 :false];
                                   });
                }
                
                _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_writeNow"];//@"设备正在写入程序";
                
                double delayInSeconds = 10.0f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   //延时方法
                                   if (checkRefsh == 1)
                                   {
                                       _LogLableView.textColor = [UIColor redColor];
                                       _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_writeNowError"];//@"设备写入程序失败！";
                                       [STW_BLE_SDK STW_SDK].Update_Now = 0;
                                   }
                               });
            }
                break;
            case 0xEE:
            {
                checkDownLoadError = 1;
                
                NSLog(@"checkDownloadSuccess - %d",checkDownloadSuccess);
                
                if(checkDownloadSuccess > 0)
                {
                    if (data_n_now == data_n)
                    {
                        checkRefsh = -1;
                        
                        _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_device_restart_now"];//@"设备重启等待重连";
                        
                        //需要指定为已经断开
                        [STW_BLEService sharedInstance].isBLEType = STW_BLE_IsBLETypeOff;
                        
                        [[STW_BLEService sharedInstance] scanStart];
                        
                        double delayInSeconds = 10.0f;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                                       {
                                           //延时方法
                                           [[STW_BLEService sharedInstance] scanStop];
                                           
                                           if([STW_BLEService sharedInstance].isBLEStatus && checkDownloadSuccess == 1)
                                           {
                                               checkDownloadSuccess = -1;
                                               _LogLableView.textColor = [UIColor greenColor];
                                               _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_UpdateSuccess"];//@"升级成功！";
                                               [STW_BLE_SDK STW_SDK].Update_Now = 0;
                                           }
                                           else if(![STW_BLEService sharedInstance].isBLEStatus && checkDownloadSuccess == 1)
                                           {
                                               checkDownloadSuccess = -1;
                                               _LogLableView.textColor = [UIColor greenColor];
                                               _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_UpdateSuccess01"];//@"升级成功，请手动连接电子烟";
                                               [STW_BLE_SDK STW_SDK].Update_Now = 0;
                                           }
                                           else if(![STW_BLEService sharedInstance].isBLEStatus && checkDownloadSuccess == -1)
                                           {
                                               checkDownloadSuccess = -1;
                                               _LogLableView.textColor = [UIColor redColor];
                                               _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_updateSuccessError"];//@"连接失败，请手动连接电子烟";
                                               [STW_BLE_SDK STW_SDK].Update_Now = 0;
                                           }
                                       });
                    }
                    else
                    {
                        checkDownloadSuccess = -1;
                        _LogLableView.textColor = [UIColor redColor];
                        _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_BLEOutError"];//@"蓝牙断开，请重新下载！";
                        [STW_BLE_SDK STW_SDK].Update_Now = 0;
                    }
                }
                else if(checkDownloadSuccess == 0)
                {
                    checkDownloadSuccess = -1;
                    _LogLableView.textColor = [UIColor redColor];
                    _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_BLEOut"];//@"蓝牙断开，请保持设备距离!";
                    [STW_BLE_SDK STW_SDK].Update_Now = 0;
                }
            }
                break;
            default:
                break;
        }
    };
}

//循环发送固件部分数据
-(void)send_device_datas
{
    _pageNumLableView.text = [NSString stringWithFormat:@"%d/%d",data_n_now,data_n];
    
    if (checkDownLoadError == 0 && [STW_BLE_SDK STW_SDK].Update_Now == 1)
    {
        if (data_n_now < data_n)
        {
            //数据发送函数 frame_start->开始截取位置  frame_len->截取长度 frame_nums->帧序列 frame_length->帧长度  add_0->是否需要添加0
            [self send_data_add:(data_n_now * 16) :16 :data_n_now :18 :false];
            
            data_n_now++;
            
            if (data_n_now == check01)
            {
                _progressUIView02.backgroundColor = [UIColor greenColor];
            }
            else if(data_n_now == check02)
            {
                _progressUIView03.backgroundColor = [UIColor greenColor];
            }
            else if(data_n_now == check03)
            {
                _progressUIView04.backgroundColor = [UIColor greenColor];
            }
            else if(data_n_now == check04)
            {
                _progressUIView05.backgroundColor = [UIColor greenColor];
            }
            
            //延时10ms继续发送数据
//            if ((data_n_now%5) == 0)
//            {
                [self performSelector:@selector(send_device_datas) withObject:nil afterDelay:0.01f];
//            }
//            else
//            {
//                [self send_device_datas];
//            }
        }
        else
        {
            if (data_all_remainder > 0)
            {
                //计算最后一帧的长度
                int len_nums = (int)device_check_crc16.length - ((data_n_now - 1)*16);
                
                //需要补齐0xFF发送
                [self send_data_add:(data_n_now * 16) :len_nums :data_n_now :18 :TRUE];
                
                data_n_now++;
                
                //延时20ms继续发送数据
                [self performSelector:@selector(send_device_datas) withObject:nil afterDelay:0.01f];
            }
            else
            {
                _progressUIView06.backgroundColor = [UIColor greenColor];
                _pageNumLableView.text = [NSString stringWithFormat:@"%d/%d",data_n_now,data_n];
                //            [ProgressHUD showSuccess:@"发送成功"];
                
                checkRefsh = 0;
                
                checkDownloadSuccess = 1;
                
                _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_AllCheckNow"];//@"正在进行程序总校验";
                
                checkReplyAllPage = 0;
                double delayInSecondsReply = 0.5f;
                dispatch_time_t popTimeReply = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSecondsReply * NSEC_PER_SEC));
                dispatch_after(popTimeReply, dispatch_get_main_queue(), ^(void)
                               {
                                   if (checkReplyAllPage == 0)
                                   {
                                       //发送重新激活命令
                                       [STW_BLE_Protocol the_update_update_Reply];
                                   }
                               });
                
                double delayInSeconds = 15.0f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   //延时方法
                                   if (checkRefsh == 0)
                                   {
                                       _LogLableView.textColor = [UIColor redColor];
                                       _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_WriteError"];//@"设备写入程序失败！";
                                   }
                               });
            }
        }
    }
    else
    {
        _LogLableView.textColor = [UIColor redColor];
        _LogLableView.text = [InternationalControl return_string:@"Custom_Update_status_UpdateError"];//@"升级失败！";
    }
}

//头信息数据发送函数 frame_start->开始截取位置  frame_len->截取长度 frame_nums->帧序列 frame_length->帧长度
-(NSMutableData *)head_data_send:(int)frame_start :(int)frame_len :(int)frame_nums :(int)frame_length
{
    //发送数据部分数据
    NSData *device_version = [soft_data subdataWithRange:NSMakeRange(frame_start,frame_len)];
    
    const unsigned char* bytes = [device_version bytes];
    
    NSMutableData *datas = [[NSMutableData alloc] init];
    
    //本帧长度int frame_length = 18;
    Byte byte[frame_length];
    //将byte元素全置为0
    memset(byte,0x00,sizeof(byte));
    
    byte[0] = frame_nums;
    byte[1] = frame_nums >> 8;
    //从第3位数据开始进行添加数据
    int check_n = 2;
    
    //不需要添加零数据在后面
    for (int i = check_n; i < frame_length; i++)
    {
        byte[i] = bytes[i - check_n];
    }
    
    [datas appendBytes:byte length:frame_length];
    
    return datas;
}

//数据发送函数 frame_start->开始截取位置  frame_len->截取长度 frame_nums->帧序列 frame_length->帧长度  add_0->是否需要添加0
-(void)send_data_add:(int)frame_start :(int)frame_len :(int)frame_nums :(int)frame_length :(BOOL)add_0
{
//    NSLog(@"data_n - %d data_n_now - %d",data_n,frame_nums);
    
    //发送数据部分数据
    NSData *device_version = [device_check_crc16 subdataWithRange:NSMakeRange(frame_start,frame_len)];
    
    const unsigned char* bytes = [device_version bytes];
    
    NSMutableData *datas = [[NSMutableData alloc] init];
    
    //本帧长度int frame_length = 18;
    Byte byte[20];
    //将byte元素全置为0
    memset(byte,0x00,sizeof(byte));
    
    byte[0] = frame_nums;
    byte[1] = frame_nums >> 8;
    //从第3位数据开始进行添加数据
    int check_n = 2;
    
    if (add_0)
    {
        //需要添加 0xFF 据在后面
        for (int i = 0; i < frame_len; i++)
        {
            byte[i + check_n] = bytes[i];
        }
        
        for (int i = frame_len; i < frame_length; i++)
        {
            byte[1] = 0xFF;
        }
    }
    else
    {
        //不需要添加零数据在后面
        for (int i = check_n; i < frame_length; i++)
        {
            byte[i] = bytes[i - check_n];
        }
    }
    
    Byte check_byte[16];
    
    for (int i = 0; i < 16; i++)
    {
        check_byte[i] = byte[i + 2];
    }
    
    NSMutableData *check_datas = [[NSMutableData alloc] init];
    [check_datas appendBytes:check_byte length:16];
    
    uint16_t check_crc_page = [STW_BLE_Protocol CRC16_page:check_datas];  //加密校验
    
    byte[18] = check_crc_page;
    byte[19] = check_crc_page >> 8;
    
    [datas appendBytes:byte length:20];
    
    //数据发送接口
    [[STW_BLEService sharedInstance] sendBigData:datas :1];
}


#pragma mark -  animation delegate

- (void)animationStart
{
    
    [self downTask];
}

- (void)animationSuspend{
    
    [self.manager suspend];
}

- (void)animationEnd
{

}

-(void)readRSSIBLE_back
{
    [STW_BLEService sharedInstance].Service_RSSIHandler = ^(NSNumber *rssi_num)
    {
//        NSLog(@"读取设备信号 -- > %@",rssi_num);
    };
}

//读取蓝牙信号
-(void)readRSSIBLE
{
    if ([STW_BLEService sharedInstance].isBLEStatus)
    {
//        [STW_BLEService sharedInstance].device.peripheral.delegate = self;
        [[STW_BLEService sharedInstance].device.peripheral readRSSI];
    }
    else
    {
        //如果蓝牙断开结束信号检测
        if (timerRSSI && [timerRSSI isValid])
        {
            [timerRSSI invalidate];
        }
    }
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
