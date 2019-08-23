//
//  DownLoadSoftBinViewController.h
//  uVapour
//
//  Created by 田阳柱 on 16/10/8.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "delegateViewController.h"
#import "JSDownloadView.h"
#import "JSDownLoadManager.h"

@interface DownLoadSoftBinViewController : delegateViewController<JSDownloadAnimationDelegate>

@property (nonatomic, strong) JSDownloadView *downloadView;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) JSDownLoadManager *manager;

@property (nonatomic, strong) NSString *soft_pash;

@property (nonatomic,retain) UIView *progressUIView01;
@property (nonatomic,retain) UIView *progressUIView02;
@property (nonatomic,retain) UIView *progressUIView03;
@property (nonatomic,retain) UIView *progressUIView04;
@property (nonatomic,retain) UIView *progressUIView05;
@property (nonatomic,retain) UIView *progressUIView06;

@property (nonatomic,retain) UILabel *pageNumLableView;

@property (nonatomic,retain) UILabel *LogLableView;

@end
