//
//  FriendsTableViewCell.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/21.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView01;
@property (weak, nonatomic) IBOutlet UIImageView *imageView02;
@property (weak, nonatomic) IBOutlet UIImageView *imageView03;

@property (weak, nonatomic) IBOutlet UILabel *lableView01;
@property (weak, nonatomic) IBOutlet UILabel *lableView02;
@property (weak, nonatomic) IBOutlet UILabel *lableView03;

@property (weak, nonatomic) IBOutlet UIView *backView;

@end
