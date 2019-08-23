//
//  STW_BLEService.h
//  STW_BLE_SDK
//
//  Created by 田阳柱 on 16/4/18.
//  Copyright © 2016年 tyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "STW_BLEDevice.h"
#import "STW_BLEservice.h"

@interface STW_BLEService : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

/*-------------------------------------     全局变量     ----------------------------------*/
//数据包头
typedef NS_ENUM(NSInteger, BLEProtocolHeader)
{
    BLEProtocolHeader01 = 0xa8
};

//设备型号
typedef NS_ENUM(NSInteger, BLEDerviceModel)
{
    BLEDerviceModelSTW01 = 0x01,       //40W
    BLEDerviceModelSTW02 = 0x02,       //50W
    BLEDerviceModelSTW03 = 0x03,       //60W
    BLEDerviceModelSTW04 = 0x04,       //70W
    BLEDerviceModelSTW05 = 0x05,       //80W
    BLEDerviceModelSTW06 = 0x06,       //90W
    BLEDerviceModelSTW07 = 0x07,       //100W
    BLEDerviceModelSTW08 = 0x08,       //150W
    BLEDerviceModelSTW09 = 0x09,       //200W
    BLEDerviceModelSTW10 = 0x10,       //213W
};

//雾化器材料
typedef NS_ENUM(NSInteger, BLEAtomizerModel)
{
    BLEAtomizerA1 = 0x01,     //Ni
    BLEAtomizerA2 = 0x02,     //Ti
    BLEAtomizerA3 = 0x03,     //Fe
    BLEAtomizerA4 = 0x04,     //SS
    BLEAtomizerA5 = 0x05      //Nicr
};

//宏定义TCR雾化器材料类型
typedef NS_ENUM(NSInteger, BLEAtomizersModel)
{
    BLEAtomizersM1 = 0x81,     //自定义1
    BLEAtomizersM2 = 0x82,     //自定义2
    BLEAtomizersM3 = 0x83,     //自定义3
};

//宏定义Custom曲线选择集合
typedef NS_ENUM(NSInteger,BLEProtocolCustomLineCommand)
{
    BLEProtocolCustomLineCommand01 = 0x01,  //曲线1
    BLEProtocolCustomLineCommand02 = 0x02,  //曲线2
    BLEProtocolCustomLineCommand03 = 0x03,  //曲线3
};

//是否禁止抽烟
typedef NS_ENUM(NSInteger, BLEProtocolStatusType){
    BLEProtocolStatusTypeEnable = 0x00,      //禁止吸烟
    BLEProtocolStatusTypeDisable = 0x01      //不禁止吸烟
};

//是否禁止抽烟
typedef NS_ENUM(NSInteger, BLEProtocolVaporeStatus){
    BLEProtocolVaporeStatusYES = 0x01,    //1 - 开始吸烟
    BLEProtocolVaporeStatusNO = 0x00      //0 - 停止吸烟
};

//调节模式0功率调节1电压调节2温度调节
//宏定义Custom 温度曲线选择集合
typedef NS_ENUM(NSInteger,BLEProtocolTempLineCommand)
{
    BLEProtocolCustomLineTemp01 = 0x01,  //温度曲线1
    BLEProtocolCustomLineTemp02 = 0x02,  //温度曲线2
    BLEProtocolCustomLineTemp03 = 0x03,  //温度曲线3
};

//温度类型
typedef NS_ENUM(NSInteger, BLEProtocolTemperatureUnit)
{
    BLEProtocolTemperatureUnitCelsius = 0x00,      //摄氏度
    BLEProtocolTemperatureUnitFahrenheit = 0x01    //华氏度
};

typedef NS_ENUM(NSInteger, BLEProtocolModeType){
    BLEProtocolModeTypePower = 0x00,            //功率模式
    BLEProtocolModeTypeVoltage = 0x01,          //电压模式
    BLEProtocolModeTypeTemperature = 0x02,      //温度模式 _ Temp
    BLEProtocolModeTypeBypas = 0x03,            //直接输出模式 - ByPass
    BLEProtocolModeTypeCustom = 0x04,           //自定义模式 - Custom
};

//设备是否处于休眠状态
typedef NS_ENUM(NSInteger, BLEProtocolSleep)
{
    BLEProtocolDriveActivity = 0x00,    //活跃
    BLEProtocolDriveSleep = 0x01,       //睡眠
};

//TCR
typedef NS_ENUM(NSInteger, BLETCRBool)
{
    BLETCRBoolNO = 0x00,    //不支持TCR
    BLETCRBoolYES = 0x01,   //支持TCR
};

typedef NS_ENUM(NSInteger, STW_BLECommand)
{
    STW_BLECommand001 = 0x01,           //设置蓝牙连接状态
    STW_BLECommand002 = 0x02,           //查询电池电量
    STW_BLECommand003 = 0x03,           //查询、设置输出功率
    STW_BLECommand004 = 0x04,           //查询、设置输出电压
    STW_BLECommand005 = 0x05,           //查询、设置输出温度
    STW_BLECommand006 = 0x06,           //查询、设置输出电流
    STW_BLECommand007 = 0x07,           //查询、设置工作模式
    STW_BLECommand008 = 0x08,           //查询、设置雾化器
    STW_BLECommand009 = 0x09,           //查询所有配置信息
    STW_BLECommand00A = 0x0A,           //发送抽烟状态
    STW_BLECommand00B = 0x0B,           //查询离线信息
    STW_BLECommand00C = 0x0C,           //设置系统时间
    STW_BLECommand00D = 0x0D,           //查询MCU工作状态
    STW_BLECommand00E = 0x0E,           //激活设备
    STW_BLECommand00F = 0x0F,           //APP运行状态
    STW_BLECommand010 = 0x10,           //查询屏幕相关信息
    STW_BLECommand011 = 0x11,           //传输图片
    STW_BLECommand012 = 0x12,           //设置抽烟输出曲线
    STW_BLECommand013 = 0x13,           //选择抽烟输出曲线
    STW_BLECommand014 = 0x14,           //查询、设置操作方式
    STW_BLECommand015 = 0x15,           //设置计划口数
    STW_BLECommand016 = 0x16,           //禁止抽烟、锁机
    STW_BLECommand017 = 0x17,           //关机
    STW_BLECommand018 = 0x18,           //查询电池状态
    STW_BLECommand019 = 0x19,           //查询实时输出信息
    STW_BLECommand01A = 0x1A,           //设置从机名字
    STW_BLECommand01B = 0x1B,           //选择自定义温控模式
    STW_BLECommand01C = 0x1C,           //设置查询温控模式下最大输出功率
    STW_BLECommand01D = 0x1D,           //传输PCB温度
    STW_BLECommand01E = 0x1E,           //查询硬件设备信息
    STW_BLECommand01F = 0x1F,           //传输当前升级包数
};

typedef NS_ENUM(NSInteger, STW_isBLEType)
{
    STW_BLE_IsBLETypeOff = 0x01,   //断开
    STW_BLE_IsBLETypeOn = 0x02,   //连接
    STW_BLE_IsBLETypeLoding = 0x03,   //等待重连
};

/*---------------------------------------   判定数据   ------------------------------------*/
/**
 *  蓝牙是否正在连接
 */
@property(nonatomic,assign) BOOL isBLEStatus;

/**
 *  蓝牙连接状态
 */
@property(nonatomic,assign) STW_isBLEType isBLEType;

/**
 *  扫描到的设备列表
 */
@property(nonatomic,retain) NSMutableArray *scanedDevices;

/**
 *  蓝牙是否可用
 */
@property(nonatomic,assign) BOOL isReadyScan;

/**
 *  是否正在吸烟
 */
@property(nonatomic,assign) BOOL isVaporNow;

/*----------------------------------   蓝牙 Manager连接数据   -----------------------------*/
/**
 *  错误处理
 *
 *  @param message 错误信息
 */
typedef void (^BLEServiceErrorHandler)(NSString *message);
@property(nonatomic,copy) BLEServiceErrorHandler Service_errorHandler;

/**
 *  蓝牙信号回调
 *
 *  @param message 蓝牙信号
 */
typedef void (^BLEServiceRSSIHandler)(NSNumber *rssi);
@property(nonatomic,copy) BLEServiceRSSIHandler Service_RSSIHandler;

/**
 *  扫描到了蓝牙设备
 *
 *  @param device 蓝牙设备广播信息 STW_BLEDevice 对象
 */
typedef void (^BLEServiceScanHandler)(STW_BLEDevice *device);
@property(nonatomic,copy) BLEServiceScanHandler Service_scanHandler;

/**
 *  连接蓝牙之后执行的方法
 */
typedef void (^BLEServiceConnectedHandler)(void);
@property(nonatomic,copy) BLEServiceConnectedHandler Service_connectedHandler;

/**
 *  断开连接
 */
typedef void (^BLEServiceDisconnectHandler)(void);
@property(nonatomic,copy) BLEServiceDisconnectHandler Service_disconnectHandler;

/**
 *  调用该方法进行初始查询
 */
typedef void (^BLEServiceDiscoverCharacteristicsForServiceHandler)(void);
@property(nonatomic,copy) BLEServiceDiscoverCharacteristicsForServiceHandler Service_discoverCharacteristicsForServiceHandler;

/*-------------------------------------   获取从机数据   ----------------------------------*/
/**
 *  获取从机-名字
 *
 *  @param message 从机名字
 */
typedef void (^BLEServiceDeviceName)(NSString *message);
@property(nonatomic,copy) BLEServiceDeviceName BLEServiceDeviceName;

/**
 *  从机数据-电池电量
 *
 *  @param battery 电池电量 0 - 100
 */
typedef void (^BLEServiceDeviceBattery)(int battery);
@property(nonatomic,copy) BLEServiceDeviceBattery Service_Battery;

/**
 *  从机数据-功率
 *
 *  @param power 功率值
 */
typedef void (^BLEServiceDevicePower)(int power);
@property(nonatomic,copy) BLEServiceDevicePower Service_Power;

/**
 *  从机数据-电压
 *
 *  @param voltage 电压值
 */
typedef void (^BLEServiceDeviceVoltage)(int voltage);
@property(nonatomic,copy) BLEServiceDeviceVoltage Service_Voltage;

/**
 *  从机数据-温度/温度单位
 *
 *  @param temp      温度值
 *  @param tempModel 温度单位
 */
typedef void (^BLEServiceDeviceTemp)(int temp,int tempModel);
@property(nonatomic,copy) BLEServiceDeviceTemp Service_Temp;

/**
 *  从机数据-电流
 *
 *  @param electricity 电流值
 */
typedef void (^BLEServiceDeviceElectricity)(int electricity);
@property(nonatomic,copy) BLEServiceDeviceElectricity Service_Electricity;

/**
 *  从机数据-ByPass模式
 *
 */
typedef void (^BLEServiceDeviceWorkMold_ByPass)(void);
@property(nonatomic,copy) BLEServiceDeviceWorkMold_ByPass Service_WorkMold_ByPass;

/**
 *  从机数据-Custom模式
 *
 *  @param CustomMold   曲线模式 1 - Custom01 ,2 - Custom02 ,3 - Custom03
 *  @param atomizerMold 雾化器类型 1 - Ni , 2 - Ti , 3 - Fe , 4 - Ss , 5 - NiCr , 81 - M1 , 82 - M2 , 83 - M3
 */
typedef void (^BLEServiceDeviceWorkMold_Custom)(int CustomMold);
@property(nonatomic,copy) BLEServiceDeviceWorkMold_Custom Service_WorkMold_Custom;

/**
 *  从机数据-雾化器负载和大小
 *
 *  @param resistance   负载大小
 *  @param atomizerMold 负载类型
 */
typedef void (^BLEServiceDeviceAtomizerData)(int resistance,int atomizerMold);
@property(nonatomic,copy) BLEServiceDeviceAtomizerData Service_AtomizerData;

/**
 *  从机数据-雾化器数据
 *
 *  @param resistance   雾化器阻值 0 短路  999 开路
 *  @param atomizerMold 雾化器类型 1 - Ni , 2 - Ti , 3 - Fe , 4 - Ss , 5 - NiCr , 81 - M1 , 82 - M2 , 83 - M3
 *  @param TCR          是否支持TCR
 *  @param change_rate  变化率
 *  @param power        TCR模式下最大功率
 */
typedef void (^BLEServiceDeviceAtomizerMold)(int resistance,int atomizerMold,int TCR,int change_rate,int power);
@property(nonatomic,copy) BLEServiceDeviceAtomizerMold Service_Atomizer;

/**
 *  从机数据-吸烟状态
 *
 *  @param vapor_status 0 - 停止吸烟  1 - 开始吸烟
 */
typedef void (^BLEServiceDeviceVaporStatus)(int vapor_status);
@property(nonatomic,copy) BLEServiceDeviceVaporStatus Service_VaporStatus;

/**
 *  从机数据-设置时间
 *
 *  @param time_status 应答值 0x00 - 接收成功  0x01 校验错误 0xEE 其他错误
 */
typedef void (^BLEServiceDeviceSetTime)(int time_status);
@property(nonatomic,copy) BLEServiceDeviceSetTime Service_SetTime;

/**
 *  从机数据-设备运行状态是否进行休眠
 *
 *  @param MCUStatus 应答值 0x00 - 接收成功  0x01 校验错误 0xEE 其他错误
 */
typedef void (^BLEServiceDeviceMCUStatus)(int MCUStatus);
@property(nonatomic,copy) BLEServiceDeviceMCUStatus Service_MCUStatus;

/**
 *  从机数据-激活设备
 *
 *  @param ActivateDevice 应答值 0x00 - 接收成功  0x01 校验错误 0xEE 其他错误
 */
typedef void (^BLEServiceDeviceActivateDevice)(int ActivateDevice);
@property(nonatomic,copy) BLEServiceDeviceActivateDevice Service_ActivateDevice;

/**
 *  从机数据-APP进入后台
 *
 *  @param background 应答值 0x00 - 接收成功  0x01 校验错误 0xEE 其他错误
 */
typedef void (^BLEServiceDeviceBackground)(int background);
@property(nonatomic,copy) BLEServiceDeviceBackground Service_Background;

/**
 *  从机数据-屏幕相关信息
 *
 *  @param material 屏幕材质 0 - OLED 1 - LCD
 *  @param color    屏幕类型 0 - 单色 1 - 彩色
 *  @param weight   屏幕宽
 *  @param height   屏幕高
 *  @param type     取模方式 0 - 纵向取模  1 - 横向取模
 */
typedef void (^BLEServiceDeviceOLEDData)(int material,int color,int weight,int height,int type);
@property(nonatomic,copy) BLEServiceDeviceOLEDData Service_OLED_data;

/**
 *  从机数据-下载图片
 *
 *  @param page_num 当前包数
 */
typedef void (^BLEServiceDeviceDownloadImage)(int page_num);
@property(nonatomic,copy) BLEServiceDeviceDownloadImage Service_DownloadImage;

/**
 *  从机数据-下载Power曲线
 *
 *  @param lineNum 当前曲线编号
 *  @param pageNum 当前包数
 */
typedef void (^BLEServiceDeviceDownloadPowerLine)(int lineNum,int pageNum);
@property(nonatomic,copy) BLEServiceDeviceDownloadPowerLine Service_DownloadPowerLine;

/**
 *  从机数据-获取Power曲线
 *
 *  @param lineNum 当前曲线编号
 *  @param pageNum 当前包数
 */
typedef void (^BLEServiceDeviceGetPowerLine)(int lineNum,int pageNum,NSMutableArray *get_arry);
@property(nonatomic,copy) BLEServiceDeviceGetPowerLine Service_GetPowerLine;

/**
 *  从机数据-设置计划口数
 *
 *  @param planStatus 应答值 0x00 - 接收成功  0x01 校验错误 0xEE 其他错误
 */
typedef void (^BLEServiceDeviceSetPlan)(int planStatus);
@property(nonatomic,copy) BLEServiceDeviceSetPlan Service_SetPlan;

/**
 *  从机数据-开、锁机设置
 *
 *  @param lock 应答值 0x00 - 接收成功  0x01 校验错误 0xEE 其他错误
 */
typedef void (^BLEServiceDeviceLockDevice)(int lock);
@property(nonatomic,copy) BLEServiceDeviceLockDevice Service_LockDevice;

/**
 *  从机数据-开、关机设置
 *
 *  @param Root 应答值 0x00 - 接收成功  0x01 校验错误 0xEE 其他错误
 */
typedef void (^BLEServiceDeviceRoot)(int Root);
@property(nonatomic,copy) BLEServiceDeviceRoot Service_Root;

/**
 *  从机数据-电池状态
 *
 *  @param battery_num             电池节数
 *  @param battery_status          是否在充电 0 - 正常  1 - 充电
 *  @param battery_chargingVoltage 充电电压
 *  @param battery_chargingCurrent 充电电流
 *  @param battery_Voltage01       1#电池电压
 *  @param battery_Voltage02       2#电池电压
 *  @param battery_Voltage03       3#电池电压
 *
 *  没有数据的部分为补0x00 可以忽略
 */
typedef void (^BLEServiceBatteryStatus)(int battery_num,int battery_status,int battery_chargingVoltage,int battery_chargingCurrent,int battery_Voltage01,int battery_Voltage02,int battery_Voltage03);
@property(nonatomic,copy) BLEServiceBatteryStatus Service_BatteryStatus;

/**
 *  从机数据-实时输出信息
 *
 *  @param RealTime_Atomizer 实时负载大小
 *  @param RealTime_Power    实时功率值
 *  @param RealTime_Voltage  实时电压值
 *  @param RealTime_Temp     实时温度值
 */
typedef void (^BLEServiceRealTimeOutput)(int RealTime_Atomizer,int RealTime_Power,int RealTime_Voltage,int RealTime_Temp);
@property(nonatomic,copy) BLEServiceRealTimeOutput Service_RealTimeOutput;

/**
 *  设置电子烟广播名称
 *
 *  @param checkNum 应答值 0x00 - 接收成功  0x01 校验错误 0xEE 其他错误
 */
typedef void (^BLEServiceSetDeviceName)(int checkNum);
@property(nonatomic,copy) BLEServiceSetDeviceName Service_SetDeviceName;

/**
 *  从机数据-选择自定义温度曲线模式
 *
 *  @param CustomTempBool 应答值 0x00 - 接收成功  0x01 校验错误 0xEE 其他错误
 */
typedef void (^BLEServiceCustomTempModel)(int CustomTempBool);
@property(nonatomic,copy) BLEServiceCustomTempModel Service_CustomTempModel;

/**
 *  从机数据-PCB板板载温度
 *
 *  @param PCB_TempModel 温度单位
 *  @param PCB_Temp      设备当前机身温度值
 */
typedef void (^BLEServicePCB_Temp)(int PCB_TempModel,int PCB_Temp);
@property(nonatomic,copy) BLEServicePCB_Temp Service_PCB_Temp;

/**
 *  从机数据-设备硬件信息
 *
 *  @param Device_Version 硬件版本编号
 *  @param Soft_Version   软件版本编号
 */
typedef void (^BLEServiceFine_DeviceData)(int Device_Version,int Soft_Version);
@property(nonatomic,copy) BLEServiceFine_DeviceData Service_Find_DeviceData;

/**
 *  从机数据-升级程序
 *
 *  @param pageNum 当前传输包数
 */
typedef void (^BLEServiceSoftUpdate)(int pageNum);
@property(nonatomic,copy) BLEServiceSoftUpdate Service_Soft_Update;


/**
 *  从机数据-选择曲线返回
 *
 *  @param curveBool 应答值 0x00 - 接收成功  0x01 校验错误 0xEE 其他错误
 */
typedef void (^BLEServiceDeviceChoseCurve)(int curveBool);
@property(nonatomic,copy) BLEServiceDeviceChoseCurve Service_ChoseCurve;

typedef void (^BLEServiceDeviceCurvePoint)(int curvePoint);         //从机数据-抽烟曲线点
@property(nonatomic,copy) BLEServiceDeviceCurvePoint Service_CurvePoint;

typedef void (^BLEServiceDeviceMold)(int deviceMold);               //从机数据-设备类型
@property(nonatomic,copy) BLEServiceDeviceMold Service_DeviceMold;

/********************************************测试数据正版发布需要删除******************************************************/
//typedef void (^BLEServiceDeviceSendData)(NSData *data);               //发送的数据
//@property(nonatomic,copy) BLEServiceDeviceSendData Service_SendData;
//
//typedef void (^BLEServiceDeviceGetData)(NSData *data);               //接收的数据
//@property(nonatomic,copy) BLEServiceDeviceGetData Service_GetData;

/**
 *  中心角色
 */
@property (strong,nonatomic) CBCentralManager *centralManager;

/**
 *  设备数据
 */
@property(nonatomic,retain) STW_BLEDevice *device;

/**
 *  蓝牙全局方法
 *
 *  @return 静态方法
 */
+(STW_BLEService *)sharedInstance;

/**
 *  开始扫描蓝牙
 */
-(void)scanStart;

/**
 *  停止扫描蓝牙
 */
-(void)scanStop;

/**
 *  连接设备
 *
 *  @param device 需要连接设备信息
 */
-(void)connect:(STW_BLEDevice *)device;

/**
 *  主动断开当前连接的蓝牙设备
 */
-(void)disconnect;

/**
 *  向从机发送数据
 *
 *  @param data 需要发送的数据
 */
-(void)sendData:(NSData *)data;

/**
 *  向从机发送大数据
 *
 *  @param data 需要发送的数据
 */
-(void)sendBigData:(NSData *)data :(int)type;

/**
 *  设置设备名字方法
 *
 *  @param namedata 名字数据
 */
-(void)setDeviceNname:(NSData *)namedata;
@end
