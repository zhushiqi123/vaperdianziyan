//
//  FeedBackViewController.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "delegateViewController.h"

@interface FeedBackViewController : delegateViewController<UIWebViewDelegate>

@property (nonatomic,retain)UIWebView *uiwebview;

@end
