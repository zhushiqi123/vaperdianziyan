//
//  CustomViewController.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/14.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "delegateViewController.h"

@class CustomViewItem;

@interface CustomViewController : delegateViewController

@property (nonatomic,retain) CustomViewItem *_customView01;
@property (nonatomic,retain) CustomViewItem *_customView02;
@property (nonatomic,retain) CustomViewItem *_customView03;
@property (nonatomic,retain) CustomViewItem *_customView04;
@property (nonatomic,retain) CustomViewItem *_customView05;
@property (nonatomic,retain) CustomViewItem *_customView06;

@end
