//
//  OfflineInfo.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/21.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OfflineInfo : NSObject

@property(nonatomic,assign)int second;
@property(nonatomic,assign)NSDate *dates;

@property(nonatomic,assign)int deviceid;
@property(nonatomic,assign)float longitude;
@property(nonatomic,assign)float latitude;

@end
