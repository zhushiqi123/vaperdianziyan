//
//  ViewController.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/13.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "delegateViewController.h"

@class VolumeBar;
@class UIbattery;
@class UIthreecount;
@class UIWeiget;
@class CustomVolumeBar;

@interface MainViewController : delegateViewController

//视图
@property (nonatomic,retain) UIWeiget *weight;
@property (nonatomic,retain) UIWeiget *weight1;

@property (nonatomic,retain) VolumeBar *voumebar;
@property (nonatomic,retain) UIbattery *battery;
@property (nonatomic,retain) UIthreecount *threecount;
@property (nonatomic,retain) UIthreecount *threecount2;
@property (nonatomic,retain) UIthreecount *threecount3;

@property (nonatomic,retain) CustomVolumeBar *custombar;

@property (nonatomic,retain) UIAlertController *alertDialog;

@end

