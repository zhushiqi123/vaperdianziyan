//
//  softUpdateBean.h
//  uVapour
//
//  Created by 田阳柱 on 16/10/8.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface softUpdateBean : NSObject

@property (assign,nonatomic) int id;

@property (retain,nonatomic) NSString *softId;
@property (retain,nonatomic) NSString *mainId;
@property (retain,nonatomic) NSString *deviceId;
@property (retain,nonatomic) NSString *updatePath;
@property (retain,nonatomic) NSString *devieName;
@property (retain,nonatomic) NSString *softName;
@property (retain,nonatomic) NSString *vendor;
@property (retain,nonatomic) NSString *binname;
@property (retain,nonatomic) NSString *md5;

@property (retain,nonatomic) NSNumber *updateTime;

@end