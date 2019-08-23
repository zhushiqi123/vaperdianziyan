//
//  AlertViewInputBoxView.h
//  uVapour
//
//  Created by 田阳柱 on 16/10/6.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputBoxView.h"

@interface AlertViewInputBoxView : UIView

@property(nonatomic,retain)InputBoxView *inpuBoxView;

- (void)showViewWith:(NSString*)string :(UIKeyboardType)keyBoardType;

- (void)remove;

//设置输入文字回调
typedef void (^AlertViewBack)(NSString *backString);
@property(nonatomic,copy) AlertViewBack AlertViewBackString;

@end
