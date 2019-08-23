//
//  SetViewController.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/13.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "delegateViewController.h"

@interface SetViewController : delegateViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) UITableView *tableview;

@end
