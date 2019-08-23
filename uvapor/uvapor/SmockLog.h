//
//  User.h
//  uvapor
//
//  Created by stw01 on 14-2-24.
//  Copyright (c) 2014年 stw01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BThumbnail.h"

@interface SmockLog : NSObject

@property(nonatomic,assign) int uid;
@property(nonatomic,assign) double latitude;
@property(nonatomic,assign) double longitude;
@property(nonatomic,assign) int time;
@property(nonatomic,assign) int seconds;

+(SmockLog *)initdata:(id)data;

@end
