//
//  UpdateSoftCell.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/19.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateSoftCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *update_image;

@property (weak, nonatomic) IBOutlet UILabel *lable_name;

@property (weak, nonatomic) IBOutlet UIView *update_view;

@property (weak, nonatomic) IBOutlet UITextView *lable_data_title;


@end
