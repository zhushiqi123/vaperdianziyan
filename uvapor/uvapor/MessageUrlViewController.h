//
//  MessageUrlViewController.h
//  uvapor
//
//  Created by TYZ on 16/12/23.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <WebKit/WKWebView.h>

@class JPushMessage;

@interface MessageUrlViewController : UIViewController<WKNavigationDelegate,WKUIDelegate>

@property(nonatomic,strong)WKWebView *webView;

// 加载type
@property(nonatomic,assign) NSInteger  IntegerType;
// 设置加载进度条
@property(nonatomic,strong) UIProgressView *ProgressView;

@property(nonatomic,retain) JPushMessage *jpMsg;

@end
