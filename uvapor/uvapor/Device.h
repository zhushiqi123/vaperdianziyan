//
//  Device.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/22.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

@property (assign,nonatomic) int id;
@property (retain,nonatomic) NSString *status_name;
@property (retain,nonatomic) NSString *update_time;
@property (retain,nonatomic) NSString *type_name;
@property (retain,nonatomic) NSString *type;
@property (retain,nonatomic) NSString *address;
@property (retain,nonatomic) NSString *password;
@property (retain,nonatomic) NSString *power;
@property (retain,nonatomic) NSString *customer_id;
@property (retain,nonatomic) NSString *create_time;
@property (retain,nonatomic) NSString *sn;
@property (retain,nonatomic) NSString *name;
@property (retain,nonatomic) NSString *status;

@end
