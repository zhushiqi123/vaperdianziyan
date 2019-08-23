/*************************************************/
/*******   STW ECIG uVapor BLE Framework   *******/
/******************** V1.0.1 *********************/
/*************************************************/

//****************   V1.0.1    ********************/
// V1.0.1
// 2016/04/18
// Author-STW_TYZ
// **************    所用变量说明     **************/
// *1.电压 - Voltage
// *2.电流 - Electricity
// *3.功率 - Power
// *4.温度 - Temp(temperature 简写)
// *5.类型 - Type
// *6.种类 - Mode
// *7.电池 - Battery
// *8.雾化器 - Atomizer
// *9.状态 - Status
// 如传值方式修改，可以使用KVO block响应KVO直接刷新界面，但是封装SDK不好用没有采取
//*************************************************/


//  STW_BLE_SDK.h
//  STW_BLE_SDK
//
//  Created by TYZ on 16/4/18.
//  Copyright © 2016 tyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "STW_BLEService.h"
#import "STW_BLEDevice.h"
#import "STW_BLE_Protocol.h"
#import "softUpdateBean.h"

@interface STW_BLE_SDK : NSObject

+(STW_BLE_SDK *)STW_SDK;

/*-------------      全局需要使用的变量    ---------------*/
@property (nonatomic,assign) int root_lock_status; //开关机状态 0 - 关机  1 - 开机

@property (nonatomic,assign) int power;            //功率

@property (nonatomic,assign) int max_power;        //最大功率

@property (nonatomic,assign) int voltage;          //电压

@property (nonatomic,assign) int temperature;      //温度
@property (nonatomic,assign) int temperatureMold;  //温度类型

@property (nonatomic,assign) int battery;          //电池电量

@property (nonatomic,assign) int atomizerMold;     //雾化器类型
@property (nonatomic,assign) int atomizer;         //雾化器阻值

@property (nonatomic,assign) int vaporTime;        //吸烟时长

@property (nonatomic,assign) int vaporStatus;      //吸烟状态

@property(nonatomic,assign) int devicesModel;      //设备型号

@property(nonatomic,assign) int vaporModel;        //工作类型（温度模式,功率模式,电压模式,手动温控模式）

@property(nonatomic,assign) int deviceVersion;      //硬件版本
@property(nonatomic,assign) int softVersion;        //软件版本

//当前曲线编号
@property(nonatomic,assign) int curvePowerModel;   //功率曲线类型

//指针调节的最大最小值
@property(nonatomic,assign) int voumebarMax;       //调节最大值
@property(nonatomic,assign) int voumebarMin;       //调节最小值

//判断主窗口逻辑
@property(nonatomic,assign) int voumebarType;      //主调节窗口类型
@property(nonatomic,assign) int weightType_left;   //左边窗口类型
@property(nonatomic,assign) int weightType_right;  //右边窗口类型

//获取功率曲线传输数据
@property(nonatomic,assign) int getPowerLineNum;          //当前传输的曲线编号
@property(nonatomic,assign) int getPowerLinePageNum;      //当前传输的曲线包数
@property(nonatomic,assign) int getPowerLineAllPageNum;   //当前传输的曲线所有包数
@property(nonatomic,assign) int getPowerLineAllPointNum;   //当前传输的曲线总的点数
@property(nonatomic,retain) NSMutableArray *getPowerLineArrys;   //当前传输的曲线数据

//传输功率曲线
@property(nonatomic,assign) int downloadPowerLineNum;          //当前下载的曲线编号
@property(nonatomic,assign) int downloadPowerLinePageNum;      //当前下载的曲线包数
@property(nonatomic,assign) int downloadPowerLineAllPageNum;   //当前下载的曲线所有包数
@property(nonatomic,assign) int downloadPowerLineAllPointNum;   //当前下载的曲线总的点数
@property(nonatomic,retain) NSMutableArray *downloadPowerLineArrys;   //当前下载的曲线数据

//升级数据信息
@property(nonatomic,assign) int Update_Now;          //是否正在升级 0 - 否 1 - 是
@property(nonatomic,retain) softUpdateBean *softUpdate_bean;   //当前选择的升级数据信息
@property(nonatomic,retain) NSMutableArray *softUpdate_lostPage;   //当前传输的曲线数据

////新手模式开关
//@property(nonatomic,assign) NSString *greenhand_on_off;     //新手模式 开 ： on  关 ： 0ff

@end
