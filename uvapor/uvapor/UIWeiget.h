//
//  UIWeiget.h
//  uvapor
//
//  Created by BCT06 on 15/3/20.
//  Copyright (c) 2015年 BCT06. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Session.h"

@interface UIWeiget : UIView

@property(nonatomic,retain) IBOutlet UILabel *WeigetLabel;
@property(nonatomic,retain) IBOutlet UIButton *WeigetButton;

-(void)updateUI:(int)workModel;

@end
