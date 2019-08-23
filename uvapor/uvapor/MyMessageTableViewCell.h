//
//  MyMessageTableViewCell.h
//  uvapor
//
//  Created by TYZ on 16/12/23.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lable_title;
@property (weak, nonatomic) IBOutlet UILabel *lable_message;
@property (weak, nonatomic) IBOutlet UIImageView *image_message;
//@property (weak, nonatomic) IBOutlet UILabel *lable_time;

@end
