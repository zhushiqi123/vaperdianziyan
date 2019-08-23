//
//  Session.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/21.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "Session.h"

@implementation Session

static Session *shareInstance = nil;

+(Session *)sharedInstance
{
    if (!shareInstance)
    {
        shareInstance = [[Session alloc] init];
        shareInstance.user = [[User alloc] init];
        shareInstance.deviceArrys = [NSMutableArray array];
        shareInstance.friendsArrys = [NSMutableArray array];
        shareInstance.recordMouthArrys = [NSMutableArray array];
    }
    return shareInstance;
}

@end
