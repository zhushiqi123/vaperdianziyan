//
//  VolumeBar.h
//  VolumeBar
//
//  Created by luyf on 13-2-28.
//  Copyright (c) 2013年 luyf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STW_BLE_SDK.h"

@interface VolumeBar : UIControl
{
@private
    NSInteger _minimumVolume;
    NSInteger _maximumVolume;
    
    NSInteger _currentVolume;
    
    float  _CIRCLE_X;
    float  _CIRCLE_Y;
    float  _CONTROL_CIRCLE_RADIUS;
}
@property (nonatomic,assign) NSInteger currentVolume;

//移动角度
typedef void (^MoveProgressHandler)(float progress);
@property (nonatomic,copy) MoveProgressHandler moveProgressHandler;

//回调当前角度
typedef void (^EndProgressHandler)(float progress);
@property (nonatomic,copy) EndProgressHandler endProgressHandler;


@property (nonatomic,retain) UIImageView *_backgroundView;

@property (nonatomic,retain) UILabel *instrumentDataLabel;
@property (nonatomic,retain) UILabel *instrumentLabel;
@property (nonatomic,assign) int min;
@property (nonatomic,assign) int max;

//@property(nonatomic,assign) PanelType type;

- (id)initWithFrame:(CGRect)frame :(float)cirt_x  :(float)cirt_y  :(float)control_circle_radius;

-(void)updateUI:(int)WorkType :(int)dataNum;

@end
