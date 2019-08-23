//  Created by 田阳柱 on 16/7/23.
//  Copyright © 2016年 TYZ. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    UILabelCountingMethodEaseInOut,
    UILabelCountingMethodEaseIn,
    UILabelCountingMethodEaseOut,
    UILabelCountingMethodLinear
} UILabelCountingMethod;

typedef NSString* (^UICountingLabelFormatBlock)(float value);


@interface CCUICountingLabel : UILabel

@property (nonatomic, strong) NSString *format;
@property (nonatomic, assign) UILabelCountingMethod method;

@property (nonatomic, copy) UICountingLabelFormatBlock formatBlock;
@property (nonatomic, copy) void (^completionBlock)();


-(void)countFrom:(float)startValue to:(float)endValue;
-(void)countFrom:(float)startValue to:(float)endValue withDuration:(NSTimeInterval)duration;

@end

