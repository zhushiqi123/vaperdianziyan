//
//  PlanLineTableViewCell.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/19.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCChart.h"

@interface PlanLineTableViewCell : UITableViewCell

- (void)configUI:(SCChartStyle)withStyle;

@property (weak, nonatomic) IBOutlet UIImageView *record_imageView;

@property (weak, nonatomic) IBOutlet UILabel *lable_record;

@property (weak, nonatomic) IBOutlet UIView *record_view;

@property (weak, nonatomic) IBOutlet UIView *chart_view;

@end
