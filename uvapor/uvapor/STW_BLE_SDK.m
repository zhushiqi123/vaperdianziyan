//
//  STW_BLE_SDK.m
//  STW_BLE_SDK
//
//  Created by TYZ on 16/4/18.
//  Copyright © 2016 tyz. All rights reserved.
//

#import "STW_BLE_SDK.h"
#import "STW_BLEService.h"
#import "STW_BLEDevice.h"

@implementation STW_BLE_SDK

static STW_BLE_SDK *STW_SDK = nil;

+(STW_BLE_SDK *)STW_SDK
{
    if (!STW_SDK)
    {
        STW_SDK = [[STW_BLE_SDK alloc] init];
        STW_SDK.getPowerLineArrys = [NSMutableArray array];
        STW_SDK.downloadPowerLineArrys = [NSMutableArray array];
        STW_SDK.softUpdate_bean = [[softUpdateBean alloc]init];
        STW_SDK.softUpdate_lostPage = [NSMutableArray array];
    }
    return STW_SDK;
}

@end
