//
//  MyVapeViewController.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "delegateViewController.h"

@class MLTableAlert;

@interface MyVapeViewController : delegateViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) UITableView *tableview;

@property (nonatomic,strong) MLTableAlert *alert;

@end
