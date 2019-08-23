//
//  VolumeBar.m
//  VolumeBar
//
//  Created by luyf on 13-2-28.
//  Copyright (c) 2013年 luyf. All rights reserved.
//

#import "VolumeBar.h"
#import "STW_BLE_Protocol.h"
#import "InternationalControl.h"

//#define CIRCLE_X                        (125.0f)//指针圆心点
//#define CIRCLE_Y                        (125.0f)

#define START_ANGLE                     (-30.0f)//旋转起始角度
#define END_ANGLE                       (210.0f)

//#define CONTROL_CIRCLE_RADIUS           (79.0f) //仪表指针长度
#define VOLUME_CIRCLE_RADIUS            (65.0f) //圆的半径

#define DEGREES_TO_RADIANS(_degrees)    ((M_PI * (_degrees))/180.0f)
#define RADIANS_TO_DEGREES(_radians)    ((_radians)*180.0f)/M_PI

#pragma mark - CircleSlideDelegate
@class CircleSlide;
@protocol CircleSlideDelegate <NSObject>

@optional
- (void)circleSlide:(CircleSlide *)circleSlide withProgress:(float)progress;
- (void)circleSlide:(CircleSlide *)circleSlide endProgress:(float)progress;
@end

#pragma mark - CircleSlide
@interface CircleSlide : UIImageView <CircleSlideDelegate>
{

    //id              _delegate;
    CGPoint         _rotatePoint;       //圆点
    float           _radius;            //指针的长度
    float           _startAngle;        //开始角度
    float           _endAngle;          //结束角度
    
    float           _progress;          //0~1
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) float progress;
@property (nonatomic,weak) EndProgressHandler endProgressHandler;

- (id)initWithImage:(UIImage *)image
        rotatePoint:(CGPoint)rotatePoint
             radius:(float)radius
         startAngle:(float)startAngle
           endAngle:(float)endAngle;
@end


@implementation CircleSlide
@synthesize delegate = _delegate;
@synthesize progress = _progress;

- (id)initWithImage:(UIImage *)image
        rotatePoint:(CGPoint)rotatePoint
             radius:(float)radius
         startAngle:(float)startAngle
           endAngle:(float)endAngle
{
    self = [super initWithImage:image];
    if (self) {
        [self setUserInteractionEnabled:YES];
        //self.backgroundColor= [UIColor blueColor];
        
        _rotatePoint = rotatePoint;    //指针圆心
        _radius = radius;              //指针长度

        _startAngle = startAngle;
        _endAngle = endAngle;
        _progress = 1;
        self.center = [self positionOfProgress:_progress];
    }
    return self;
}

- (void)setProgress:(float)progress
{
    if (progress >= 0 && progress <= 1.0f)
    {
        _progress = progress;
        self.center = [self positionOfProgress:_progress];
    }
}

- (float)progressOfAngle:(float)angle
{
    angle = MAX(angle, _startAngle);
    angle = MIN(angle, _endAngle);
    return (angle - _startAngle)/(_endAngle - _startAngle);
}

- (float)angleOfProgress:(float)progress
{
    progress = MAX(progress, 0);
    progress = MIN(progress, 1.0f);
    
    return _progress*(_endAngle - _startAngle)+_startAngle;
}

- (BOOL)samesign:(float)x y:(float)y
{
    return (x <= 0 && y <= 0) || (x >= 0 && y >= 0);
}

- (float)progressOfPosition:(CGPoint)position
{
    float x = position.x - _rotatePoint.x;
    float y = - (position.y - _rotatePoint.y);
    
    float angle = atanf(y/x);
    if (![self samesign:x y:cosf(angle)] || ![self samesign:y y:sinf(angle)]) {
        angle += M_PI;
    }
    
    return [self progressOfAngle:angle];
}

- (CGPoint)positionOfProgress:(float)progress
{
    float angle = [self angleOfProgress:_progress];
    
    CGPoint position = {_rotatePoint.x+cosf(angle)*_radius, _rotatePoint.y-sinf(angle)*_radius};
    return position;
}

//手指正在移动
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([STW_BLEService sharedInstance].isVaporNow)
    {
        NSLog(@"正在吸烟");
    }
    else
    {
        CGPoint ptCurr=[[touches anyObject] locationInView:self.delegate];
        float newProgress = [self progressOfPosition:ptCurr];
        
        /* 判断是否发生跳跃 */
        if ((newProgress > _progress && (newProgress - _progress) < 1.0)
            || (newProgress < _progress && (_progress - newProgress) < 1.0))
        {
            _progress = [self progressOfPosition:ptCurr];
            self.center = [self positionOfProgress:_progress];
            
            if (_delegate && [_delegate respondsToSelector:@selector(circleSlide:withProgress:)]) {
                [_delegate circleSlide:self withProgress:_progress];
            }
        }
        
    }
//    CGPoint ptCurr=[[touches anyObject] locationInView:self.delegate];
//    float newProgress = [self progressOfPosition:ptCurr];
//    
//    /* 判断是否发生跳跃 */
//    if ((newProgress > _progress && (newProgress - _progress) < 1.0)
//        || (newProgress < _progress && (_progress - newProgress) < 1.0))
//    {
//        _progress = [self progressOfPosition:ptCurr];
//        self.center = [self positionOfProgress:_progress];
//        
//        if (_delegate && [_delegate respondsToSelector:@selector(circleSlide:withProgress:)]) {
//            [_delegate circleSlide:self withProgress:_progress];
//        }
//    }
}

//手指抬起
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([STW_BLEService sharedInstance].isVaporNow)
    {
        NSLog(@"正在吸烟");
    }
    else
    {
        CGPoint ptCurr=[[touches anyObject] locationInView:self.delegate];
        float newProgress = [self progressOfPosition:ptCurr];
        if (_delegate && [_delegate respondsToSelector:@selector(circleSlide:endProgress:)])
        {
            [_delegate circleSlide:self endProgress:newProgress];
        }
    }
//    CGPoint ptCurr=[[touches anyObject] locationInView:self.delegate];
//    float newProgress = [self progressOfPosition:ptCurr];
//    if (_delegate && [_delegate respondsToSelector:@selector(circleSlide:endProgress:)])
//    {
//        [_delegate circleSlide:self endProgress:newProgress];
//    }
}

@end

#pragma mark - VolumeBar
@interface VolumeBar ()
{
    CircleSlide *       _circleSlide;
    UIImageView *       _contentView;
    UIImage *           _contentImage;
    float               _progress;     /* 1表示表盘最小值， 0表示表盘最大值 */
}
@end

@implementation VolumeBar
@dynamic currentVolume;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        [self setUserInteractionEnabled:YES];
        
        //默认为200W背景图片  icon_ByPass
        NSString *imageName = [NSString stringWithFormat:@"icon_P%d",[STW_BLE_SDK STW_SDK].max_power];
//        self._backgroundView = [[UIImageView alloc]  initWithImage:[UIImage imageNamed:@"icon_P80"]];
        self._backgroundView = [[UIImageView alloc]  initWithImage:[UIImage imageNamed:imageName]];
        
        [self setFrame:frame];
        [self setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self._backgroundView];
        
        _circleSlide = \
        [[CircleSlide alloc] initWithImage:[UIImage imageNamed:@"icon_pointer"]
                               rotatePoint:CGPointMake(_CIRCLE_X, _CIRCLE_Y)
                                    radius:_CONTROL_CIRCLE_RADIUS
                                startAngle:DEGREES_TO_RADIANS(START_ANGLE)
                                  endAngle:DEGREES_TO_RADIANS(END_ANGLE)];
        _circleSlide.delegate = self;

        [self addSubview:_circleSlide];
        
        //content
        _contentImage = [UIImage imageNamed:@"volumeBar.bundle/vol_full.png"];
        _contentView = [[UIImageView alloc] initWithFrame:self._backgroundView.bounds];
        [self addSubview:_contentView];
        _progress = 1;
        
        //数值lable
        self.instrumentDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0, 130, 30)];
        CGPoint center = self.instrumentDataLabel.center;
        center.x = _CIRCLE_X;
        center.y = _CIRCLE_Y;
        [self.instrumentDataLabel setCenter:center];
        
        self.instrumentDataLabel.text = @"0";
        self.instrumentDataLabel.textColor = [UIColor whiteColor];
        self.instrumentDataLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.instrumentDataLabel];
        
        //说明lable
        self.instrumentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,130,30)];
        
        CGPoint center02 = self.instrumentLabel.center;
        center02.x = _CIRCLE_X;
        if (iPadMini || iPadAir)
        {
            center02.y = _CIRCLE_Y + self._backgroundView.bounds.size.height/2 + 40.0f;
            self.instrumentDataLabel.font = [UIFont systemFontOfSize:35];
            self.instrumentLabel.font = [UIFont systemFontOfSize:27];
        }
        else if(iPhone4)
        {
            center02.y = _CIRCLE_Y + 80.0f;
            self.instrumentDataLabel.font = [UIFont systemFontOfSize:28];
            self.instrumentLabel.font = [UIFont systemFontOfSize:15];
        }
        else if(iPhone5)
        {
            center02.y = _CIRCLE_Y + self._backgroundView.bounds.size.height/2 - 20.0f;
            self.instrumentDataLabel.font = [UIFont systemFontOfSize:28];
            self.instrumentLabel.font = [UIFont systemFontOfSize:17];
        }
        else
        {
            center02.y = _CIRCLE_Y + self._backgroundView.bounds.size.height/2;
            self.instrumentDataLabel.font = [UIFont systemFontOfSize:32];
            self.instrumentLabel.font = [UIFont systemFontOfSize:20];
        }
        
        [self.instrumentLabel setCenter:center02];

//        self.instrumentLabel.text = @"功率W";
        self.instrumentLabel.text = [InternationalControl return_string:@"Vapor_Power"];
        self.instrumentLabel.textColor = [UIColor whiteColor];
        self.instrumentLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.instrumentLabel];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame :(float)cirt_x  :(float)cirt_y  :(float)control_circle_radius
{
    //仪表的圆心点
    _CIRCLE_X = cirt_x;
    _CIRCLE_Y = cirt_y;
    
    //仪表的长度
    _CONTROL_CIRCLE_RADIUS = control_circle_radius;
    
    self = [self initWithFrame:frame];
    
    if (self)
    {
        //初始化，表盘所表示的最大最小值
        _minimumVolume = 0;
        _maximumVolume = 1000;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{    
    CGContextRef context = CGBitmapContextCreate(NULL, self.bounds.size.width, self.bounds.size.height, 8, 4 * self.bounds.size.width, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedFirst);
    
    float endAngle = (END_ANGLE-START_ANGLE)*_progress+START_ANGLE;
    endAngle = (_progress == 0)?(endAngle+0.1):endAngle;
    
    //自定义选中角度
    CGAffineTransform cgaRotate = CGAffineTransformRotate(self.transform, (-endAngle-24)/53);
    [_circleSlide setTransform:cgaRotate];
    
    float CIRCLE_X_x = 0;
    float CIRCLE_Y_y = 0;
    
    CIRCLE_X_x = _CIRCLE_X;
    CIRCLE_Y_y = _CIRCLE_Y;
    
    CGContextAddArc(context, CIRCLE_X_x, CIRCLE_Y_y, VOLUME_CIRCLE_RADIUS, DEGREES_TO_RADIANS(START_ANGLE), DEGREES_TO_RADIANS(endAngle), YES);
    CGContextAddArc(context, CIRCLE_X_x, CIRCLE_Y_y, 0.0f, DEGREES_TO_RADIANS(0.0f), DEGREES_TO_RADIANS(0.0f), YES);
    CGContextClosePath(context);
    CGContextClip(context);
    
   // CGContextDrawImage(context, self.bounds, _contentImage.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);
    
    
    [_contentView setImage:newImage];
    
    [_circleSlide setProgress:_progress];
}

- (NSInteger)currentVolume
{
    return _currentVolume;
}

- (void)setCurrentVolume:(NSInteger)currentVolume
{
    if (currentVolume >= _minimumVolume && currentVolume <= _maximumVolume) {
        _progress = 1.0f - (float)(currentVolume - _minimumVolume)/(_maximumVolume - _minimumVolume);
        _currentVolume = currentVolume;
        [self setNeedsDisplay];
    }
}

#pragma mark - CircleSlideDelegate
- (void)circleSlide:(CircleSlide *)circleSlide withProgress:(float)progress
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    _progress = progress;
    
    //手指正在移动
    float num = [STW_BLE_SDK STW_SDK].voumebarMin + (([STW_BLE_SDK STW_SDK].voumebarMax - [STW_BLE_SDK STW_SDK].voumebarMin) * (1.0f - progress));

    switch ([STW_BLE_SDK STW_SDK].vaporModel)
    {
        case BLEProtocolModeTypePower:
        {
            self.instrumentDataLabel.text = [NSString stringWithFormat:@"%.1f",num];
        }
            break;
        case BLEProtocolModeTypeVoltage:
        {
            self.instrumentDataLabel.text = [NSString stringWithFormat:@"%.2f",num/10.0f];
        }
            break;
        case BLEProtocolModeTypeTemperature:
        {
            self.instrumentDataLabel.text = [NSString stringWithFormat:@"%d",(int)num];
        }
            break;
            
        default:
            break;
    }
    
    
    
    [self setNeedsDisplay];

    NSInteger volume = (_maximumVolume - _minimumVolume)*(1-_progress);
    
    if (_currentVolume != volume)
    {
        _currentVolume = volume;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)circleSlide:(CircleSlide *)circleSlide endProgress:(float)progress
{
    //手指抬起
    float num = [STW_BLE_SDK STW_SDK].voumebarMin + (([STW_BLE_SDK STW_SDK].voumebarMax - [STW_BLE_SDK STW_SDK].voumebarMin) * (1.0f - progress));
    
    int num01 = 0;
    
    switch ([STW_BLE_SDK STW_SDK].vaporModel)
    {
        case BLEProtocolModeTypePower:
        {
            num01 = (num * 10);
            
            self.instrumentDataLabel.text = [NSString stringWithFormat:@"%.1f",(num01/10.f)];
            
            [STW_BLE_Protocol the_work_mode_power:num01 :[STW_BLE_SDK STW_SDK].atomizerMold];
        }
            break;
        case BLEProtocolModeTypeVoltage:
        {
            num01 = (num * 10);
            
            self.instrumentDataLabel.text = [NSString stringWithFormat:@"%.2f",num01/100.0f];
            
            [STW_BLE_Protocol the_work_mode_voltage:num01 :[STW_BLE_SDK STW_SDK].atomizerMold];
        }
            break;
        case BLEProtocolModeTypeTemperature:
        {
            num01 = num;
            
            self.instrumentDataLabel.text = [NSString stringWithFormat:@"%d",(int)num];
            
            [STW_BLE_Protocol the_work_mode_temp:[STW_BLE_SDK STW_SDK].temperatureMold :num01 :[STW_BLE_SDK STW_SDK].atomizerMold :0];
        }
            break;
            
        default:
            break;
    }
    
    //发送数据
    NSLog(@"发送数据 - > %d",num01);
}

-(void)updateUI:(int)WorkType :(int)dataNum
{
    //刷新UI
    float check_mode_num = 10.0f;
    
    //角度
    int progress;
    
    float v = 0.0;
    
    /*****************************刷新背景***********************************/
    switch (WorkType)
    {
        case BLEProtocolModeTypePower:
        {
            _circleSlide.hidden = NO;
//            self._backgroundView.image = [UIImage imageNamed:@"icon_P80"];
            
            NSString *imageName = [NSString stringWithFormat:@"icon_P%d",[STW_BLE_SDK STW_SDK].max_power];
            //        self._backgroundView = [[UIImageView alloc]  initWithImage:[UIImage imageNamed:@"icon_P80"]];
            self._backgroundView.image = [UIImage imageNamed:imageName];
            
            check_mode_num = 10.0f;
            
            progress = (((dataNum/10) - [STW_BLE_SDK STW_SDK].voumebarMin)*1000 / ([STW_BLE_SDK STW_SDK].voumebarMax - [STW_BLE_SDK STW_SDK].voumebarMin));
            
//            NSLog(@"progress - %d",progress);
            
            [self setCurrentVolume:progress];
            
            v = (((dataNum/check_mode_num) - [STW_BLE_SDK STW_SDK].voumebarMin)*100 / ([STW_BLE_SDK STW_SDK].voumebarMax - [STW_BLE_SDK STW_SDK].voumebarMin));
            
            self.instrumentDataLabel.text = [NSString stringWithFormat:@"%.1f",(dataNum/check_mode_num)];
//            self.instrumentLabel.text = @"功率W";
            self.instrumentLabel.text = [InternationalControl return_string:@"Vapor_Power"];
        }
            break;
            
        case BLEProtocolModeTypeVoltage:
        {
            _circleSlide.hidden = NO;
            self._backgroundView.image = [UIImage imageNamed:@"icon_U85"];
            check_mode_num = 100.0f;
            
            progress = (((dataNum/10) - [STW_BLE_SDK STW_SDK].voumebarMin)*1000 / ([STW_BLE_SDK STW_SDK].voumebarMax - [STW_BLE_SDK STW_SDK].voumebarMin));
            
//            NSLog(@"progress - %d",progress);
            
            [self setCurrentVolume:progress];
            
            v = (((dataNum/check_mode_num) - [STW_BLE_SDK STW_SDK].voumebarMin)*100 / ([STW_BLE_SDK STW_SDK].voumebarMax - [STW_BLE_SDK STW_SDK].voumebarMin));
            
            self.instrumentDataLabel.text = [NSString stringWithFormat:@"%.2f",(dataNum/check_mode_num)];
//            self.instrumentLabel.text = @"电压V";
            self.instrumentLabel.text = [InternationalControl return_string:@"Vapor_Voltage"];
        }
            
            break;
            
        case BLEProtocolModeTypeTemperature:
        {
            _circleSlide.hidden = NO;
            if ([STW_BLE_SDK STW_SDK].temperatureMold == 0x00)
            {
                //摄氏度
                self._backgroundView.image = [UIImage imageNamed:@"icon_T315"];
                self.instrumentDataLabel.text = [NSString stringWithFormat:@"%d",dataNum];
//                self.instrumentLabel.text = @"温度℃";
                self.instrumentLabel.text = [InternationalControl return_string:@"Vapor_Temp_C"];
            }
            else
            {
                //华氏度
                self._backgroundView.image = [UIImage imageNamed:@"icon_T600"];
                self.instrumentDataLabel.text = [NSString stringWithFormat:@"%d",dataNum];
//                self.instrumentLabel.text = @"温度℉";
                
                self.instrumentLabel.text = [InternationalControl return_string:@"Vapor_Temp_F"];
            }
            
            progress = ((dataNum - [STW_BLE_SDK STW_SDK].voumebarMin)*1000 / ([STW_BLE_SDK STW_SDK].voumebarMax - [STW_BLE_SDK STW_SDK].voumebarMin));
            
//            NSLog(@"progress - %d",progress);
            
            [self setCurrentVolume:progress];
        }
            
            break;
            
        case BLEProtocolModeTypeBypas:
        {
            _circleSlide.hidden = YES;
            self._backgroundView.image = [UIImage imageNamed:@"icon_ByPass"];
            self.instrumentDataLabel.text = @"";
            self.instrumentLabel.text = @"ByPass";
        }
            
            break;
            
        case BLEProtocolModeTypeCustom:
        {
            _circleSlide.hidden = YES;
            self._backgroundView.image = [UIImage imageNamed:@"icon_BG"];
            self.instrumentDataLabel.text = [NSString stringWithFormat:@"C%d",[STW_BLE_SDK STW_SDK].curvePowerModel];
            self.instrumentLabel.text = [NSString stringWithFormat:@"Custom-%d",[STW_BLE_SDK STW_SDK].curvePowerModel];
        }
            
            break;
            
        default:
            break;
    }
}

-(void)checkDrivceActivity
{
//    if ([Session sharedInstance].bleData.activity == BLEProtocolDriveSleep)
//    {
//        NSLog(@"---------->激活设备状态");
//        //激活设备
//        [[BLEService sharedInstance] sendData:[BLEProtocol buildSetup:BLEProtocolSetupCommandB6 andValue:0]];
//        [[BLEService sharedInstance] sendData:[BLEProtocol buildSetup:BLEProtocolSetupCommandB6 andValue:0]];
//        [Session sharedInstance].bleData.activity = BLEProtocolDriveActivity;
//    }
}

@end
