//
//  CustomVolumeBar.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/28.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingCustomLineView.h"

@interface CustomVolumeBar : UIView

@property (weak, nonatomic) IBOutlet UILabel *instrumentLabel;

@property (weak, nonatomic) IBOutlet UILabel *instrumentDataLabel;


//@property(nonatomic,retain)UILabel *instrumentLabel;
//@property (nonatomic,retain) UILabel *instrumentDataLabel;
//
@property (nonatomic,retain) DrawingCustomLineView *CustomView;

@property (nonatomic,retain) UILabel *lable_line_H01;
@property (nonatomic,retain) UILabel *lable_line_H02;
@property (nonatomic,retain) UILabel *lable_line_H03;
@property (nonatomic,retain) UILabel *lable_line_H04;
@property (nonatomic,retain) UILabel *lable_line_H05;

- (id)initWithFrame:(CGRect)frame :(float)view_width  :(float)view_height :(int)arry_type :(NSMutableArray *)setArrys;

//选择曲线刷新UI
-(void)updateUI:(int)choseNum;

//吸烟实时更新UI
-(void)updateUI_vapor_refresh:(int)refreshNum;
@end
