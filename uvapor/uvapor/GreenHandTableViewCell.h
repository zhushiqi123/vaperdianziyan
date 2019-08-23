//
//  GreenHandTableViewCell.h
//  uvapor
//
//  Created by tyz on 17/3/22.
//  Copyright © 2017年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GreenHandTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *text_lable;
@property (weak, nonatomic) IBOutlet UIImageView *status_image;

@end
