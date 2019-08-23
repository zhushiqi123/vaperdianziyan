//
//  CCProgressView.h
//  ProgressViewDemo
//
//  Created by 田阳柱 on 16/7/23.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface CCProgressView : UIView
@property (nonatomic) NSNumber *lineWidth;
@property (nonatomic) CAShapeLayer *circleBG;
@property (nonatomic, readonly) CAGradientLayer* gradientLayer;
@property (nonatomic , strong)  NSTimer *theTimer;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;


@end
