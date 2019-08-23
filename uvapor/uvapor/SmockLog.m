//
//  User.m
//  uvapor
//
//  Created by stw01 on 14-2-24.
//  Copyright (c) 2014年 stw01. All rights reserved.
//

#import "SmockLog.h"
#import "NSDictionary_STW.h"

@implementation SmockLog

+(SmockLog *)initdata:(id)data{
    SmockLog * obj = [[SmockLog alloc]init];
    obj.uid = [data intForKey:@"uid"];
    obj.latitude = [[data stringForKey:@"latitude"] doubleValue];
    obj.longitude = [[data stringForKey:@"longitude"] doubleValue];
    obj.time = [[data stringForKey:@"time"] intValue];
    obj.seconds = [data intForKey:@"seconds"];
    return obj;
}

@end
