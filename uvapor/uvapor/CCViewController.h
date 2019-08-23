//
//  CCViewController.h
//
//
//  Created by 田阳柱 on 16/7/23.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCProgressView;
@interface CCViewController : UIViewController
{
    CGAffineTransform currentTransform;
    CGAffineTransform newTransform;
    double r;
}
@property (nonatomic , strong)  NSTimer *theTimer;
@property(nonatomic,strong)CCProgressView * circleChart;

@end
