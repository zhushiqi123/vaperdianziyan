//
//  MyFriends.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/22.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BThumbnail.h"

@interface MyFriends : NSObject

@property (retain,nonatomic) NSNumber *status;
@property (retain,nonatomic) NSNumber *friend_id;
@property (retain,nonatomic) NSNumber *id;
@property (retain,nonatomic) NSString *type_name;
@property (retain,nonatomic) NSString *status_name;
@property (retain,nonatomic) NSString *headimg;
@property (retain,nonatomic) NSString *realname;
@property (retain,nonatomic) NSNumber *type;
@property (retain,nonatomic) NSNumber *customer_id;
@property (retain,nonatomic) BThumbnail *thumbnail;

@end
