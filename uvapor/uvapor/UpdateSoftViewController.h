//
//  UpdateSoftViewController.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/18.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "delegateViewController.h"

@interface UpdateSoftViewController : delegateViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) UITableView *tableview;

@property (nonatomic,retain)UILabel *errorLableView;

@end
