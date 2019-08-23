//
//  STW_BLEDevice.h
//  STW_BLE_SDK
//
//  Created by TYZ on 16/4/18.
//  Copyright © 2016 tyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface STW_BLEDevice : NSObject

@property (nonatomic,retain) CBPeripheral *peripheral;           //外围设备
@property (nonatomic,assign) NSNumber *RSSI;                     //信号强度RSSI
@property (nonatomic,retain) NSDictionary *advertisementData;    //广播数据
@property (nonatomic,retain) NSString *deviceName;               //设备名字

@property (nonatomic,retain) CBCharacteristic *characteristic;   //特征UUID
@property (nonatomic,retain) NSString *deviceMac;                //设备mac地址
@property (nonatomic,assign) int deviceModel;                    //设备型号

@end
