//
//  AlertView.h
//  new_HY_BLE
//
//  Created by LJ on 16/2/19.
//  Copyright © 2016年 LJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertView : UIView

@property (weak, nonatomic) IBOutlet UILabel *alertLabel;


- (void)showViewWith:(NSString*)string;

@end
