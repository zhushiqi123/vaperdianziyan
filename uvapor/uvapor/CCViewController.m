//
//  CCViewController.m
//  Created by 田阳柱 on 16/7/23.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "CCViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CCProgressView.h"
#import "CCUICountingLabel.h"
#import "UIDevice+ProcessesAdditions.h"
#import <CoreMotion/CoreMotion.h>
#import "STW_BLE_SDK.h"

#define EPSILON     1e-6
#define kDuration 1.0   // 动画持续时间(秒)
@interface CCViewController ()
{
    CCUICountingLabel *_titleLabel;
    
}
@property (nonatomic, strong) CMMotionManager* motionManager;
@property (nonatomic, strong) CADisplayLink* motionDisplayLink;
@property (nonatomic) float motionLastYaw;

@end

@implementation CCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.userInteractionEnabled=YES;
    //设置电池显示圆圈的大小
    float view_height = (SCREEN_HEIGHT * 2) / 3;
    float view_weight = SCREEN_WIDTH;
    
    float view_x = (view_weight - ((view_height * 2) / 3)) / 2;
    
//    int height_circleChart = (view_height/2) - ((view_weight/2)-30);
    _circleChart = [[CCProgressView alloc] initWithFrame:CGRectMake(view_x, 30.0f + 64.0f, ((view_height * 2) / 3),((view_height * 2) / 3))];
    
    _circleChart.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_circleChart];
    
    r=_circleChart.frame.size.height;
    
    _titleLabel=[[CCUICountingLabel alloc]initWithFrame:CGRectMake(_circleChart.frame.origin.y, _circleChart.frame.origin.x, _circleChart.frame.size.height, _circleChart.frame.size.width)];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:80.0f]];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    //    _titleLabel.backgroundColor = [UIColor redColor];  //用于测试
    _titleLabel.method = UILabelCountingMethodEaseInOut;
    [self.view addSubview:_titleLabel];
    [_titleLabel setHidden:YES];
    
//    [TYZ_BLE_Service sharedInstance].notifyHandlerD3 = ^(int battery,int battery_status)
//    {
//        NSLog(@"battery - %d,battery_status - %d",battery,battery_status);
//        [TYZ_Session sharedInstance].battery = battery;
//        [TYZ_Session sharedInstance].battery_status = battery_status;
    
//        [self batteryLevel];
//        [self startGravity];
//    };
    
    [self batteryLevel];
    
    [self startGravity];
    
    currentTransform=_circleChart.transform;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (double) batteryLevel
{
    double percent;

//    if ([TYZ_Session sharedInstance].battery && [TYZ_Session sharedInstance].battery_status != 2)
//    {
////        percent = (([TYZ_Session sharedInstance].battery * 1.0f)/42) * 100.0f;
//        percent = [TYZ_Session sharedInstance].battery * 1.0f;
//    }
//    else
//    {
//        percent = 80.0f;
    
          percent = [STW_BLE_SDK STW_SDK].battery;
//    }
    
    [_circleChart setProgress:percent/100 animated:YES];
    [_titleLabel setHidden:NO];
    _titleLabel.frame=CGRectMake(0, 0, r, r);
    _titleLabel.text=[NSString stringWithFormat:@"%.0f%%",percent];
    float lines = (_circleChart.frame.size.width)/2;
    [_titleLabel setCenter:CGPointMake(_circleChart.frame.origin.x + lines,_circleChart.frame.origin.y + lines)];
    //        return percent;
    //    }
    return -1.0f;
}
- (BOOL)isGravityActive
{
    return self.motionDisplayLink != nil;
}

- (void)startGravity
{
    if ( ! [self isGravityActive]) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.deviceMotionUpdateInterval =0.1;// 0.02; // 50 Hz
        
        self.motionLastYaw = 0;
        _theTimer= [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(motionRefresh:) userInfo:nil repeats:YES];
    }
    if ([self.motionManager isDeviceMotionAvailable]) {
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    }
}
- (void)motionRefresh:(id)sender
{
    CMQuaternion quat = self.motionManager.deviceMotion.attitude.quaternion;
    double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));
    
    yaw *= -1;
    
    if (self.motionLastYaw == 0)
    {
        self.motionLastYaw = yaw;
    }
    
    static float q = 0.1;   // process noise
    static float s = 0.1;   // sensor noise
    static float p = 0.1;   // estimated error
    static float k = 0.5;   // kalman filter gain
    
    float x = self.motionLastYaw;
    p = p + q;
    k = p / (p + s);
    x = x + k*(yaw - x);
    p = (1 - k)*p;
    
    newTransform=CGAffineTransformRotate(currentTransform,-x);
    _circleChart.transform=newTransform;
    // }
    
    self.motionLastYaw = x;
}

- (void)stopGravity
{
    if ([self isGravityActive]) {
        [self.motionDisplayLink invalidate];
        self.motionDisplayLink = nil;
        self.motionLastYaw = 0;
        [_theTimer invalidate];
        _theTimer=nil;
        
        self.motionManager = nil;
    }
    if ([self.motionManager isDeviceMotionActive])
        [self.motionManager stopDeviceMotionUpdates];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
}


@end
