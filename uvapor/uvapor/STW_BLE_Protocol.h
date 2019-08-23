//
//  STW_BLE_Protocol.h
//  STW_BLE_SDK
//
//  Created by 田阳柱 on 16/8/29.
//  Copyright © 2016年 tyz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STW_BLE_Protocol : NSObject

/**
 *  call Back - 应答
 *  call_model  命令
 *  call_status 状态
 */
+(void)the_call_back:(int)call_model :(int)call_status;

/**
 *  0x01 - 设置蓝牙连接状态
 *  0 - 断开  1 - 连接
 */
+(void)the_BLE_state:(int)state;

/**
 *  0x02 - 查询电池电量
 *  固定命令 A8 02 06 00 00 A6
 */
+(void)the_find_battery;

/**
 *  0x03 设置/查询 - 输出功率
 *  数据部分为  D1 = 0x00,D2 = 0x00 查询
 *  数据部分不为 00 00 是设置输出功率
 */
+(void)the_power:(int)power;

/**
 *  0x04 查询/设置 - 输出电压
 *  数据部分为  D1 = 0x00,D2 = 0x00 查询
 *  数据部分不为 00 00 是设置输出电压
 */
+(void)the_voltage:(int)voltage;

/**
 *  0x05 查询/设置输出温度
 *  温度单位 0 - 摄氏度  1 - 华氏度
 *  数据部分为  D1 = 0x00,D2 = 0x00,D3 = 0x00 查询
 *  数据部分不为 00 00 00 是设置输出温度
 */
+(void)the_temperature:(int)mode :(int)temp;

/**
 *  0x06 查询/设置输出电流
 *  数据部分为  D1 = 0x00,D2 = 0x00 查询
 *  数据部分不为 00 00 是设置输出电流
 */
+(void)the_electricity:(int)elect;

/**
 *  0x07 查询/设置工作模式
 *  数据部分为  D1 = 0x00,D2 = 0x00,D3 = 0x00 查询
 *  数据部分不为 00 00 00 是设置输出模式
 */
//查询工作模式
+(void)the_work_mode;
//设置功率模式 -> power - 功率值  Atomizer_mode - 雾化器类型
+(void)the_work_mode_power:(int)power :(int)Atomizer_mode;
//设置电压模式 -> voltage - 电压值  Atomizer_mode - 雾化器类型
+(void)the_work_mode_voltage:(int)voltage :(int)Atomizer_mode;
//设置温度模式 -> temp_mode - 温度类型  temp - 温度值  Atomizer_mode - 雾化器类型  TCR - 是否是TCR模式
+(void)the_work_mode_temp:(int)temp_mode :(int)temp :(int)Atomizer_mode :(int)TCR;
//设置ByPass模式
+(void)the_work_mode_bypass;
//设置Custom模式 ->  custom_number - 曲线编号
+(void)the_work_mode_custom:(int)custom_number;

/**
 *  0x08 查询/设置雾化器
 *
 *  @param Atomizer_mode 负载类型
 *  @param TCR           代表是否支持TCR
 *  @param change_rate   变化率
 *  @param power         功率值
 */
+(void)the_atomizer:(int)Atomizer_mode :(int)TCR :(int)change_rate :(int)power;

/**
 *  0x09 查询所有配置信息
 */
+(void)the_find_all_data;

/**
 *  0x0A 查询抽烟状态
 *  check_num -> 0x00 - 接收成功  0x01 - 校验错误  0xEE 其他错误
 */
+(void)the_smoking_status:(int)check_num;

/**
 *  0x0B 查询离线信息
 */
+(void)the_find_record_data;

/**
 *  0x0C 设置系统时间
 */
+(void)the_set_time;

/**
 *  0x0D 查询MCU工作状态
 *  check_num -> 0x00 - 接收成功  0x01 - 校验错误  0xEE 其他错误
 */
+(void)the_MCU_status:(int)check_num;

/**
 *  0x0E 激活设备
 */
+(void)the_activate_device;

/**
 *  app 运行状态
 *  app -> 0x00 前台运行  0x01 后台运行
 */
+(void)the_app_state:(int)app;

/**
 *  0x10 查询屏幕相关信息
 */
+(void)the_find_LED_data;

/**
 *  0x11 传输图片
 *  arry_datas - 图片数据
 *  num - 发送第几包
 */
+(void)the_down_logo:(NSMutableArray *)arry_datas :(int)num;

/**
 *  0x12 查询/设置抽烟输出曲线 - 功率曲线
 */
//设置抽烟输出曲线 - 功率曲线  arry_datas - 曲线数据  num - 发送第几包
+(void)the_set_Power_line:(NSMutableArray *)arry_datas :(int)num;

/**
 *  查询抽烟输出曲线 - 功率曲线
 *
 *  @param lineNum 曲线编号
 *  @param dataNum 数据个数
 *  @param allPage 数据总包数
 */
+(void)the_find_Power_line:(int)answerNum :(int)lineNum :(int)pageNum;

/**
 *  0x13 选择抽烟输出曲线
 *  custom_num - 要选择曲线的序号
 */
//选择曲线
+(void)the_choose_custom:(int)custom_num;

/**
 *  0x14 查询/设置操作方式
 *  operation_mode - 模式类型
 *  01 - 更改待机时长  02 - 更改屏幕亮度  03 - 更改锁机按键次数  04 - 更改调节步进值
 *  05 - 更改抽烟时长  06 - 加温功率设置  07 - 更改屏幕翻转     08 - 加减按键翻转
 *  operation_num - 修改的数值
 */
+(void)the_mode_of_operation:(int)operation_mode :(int)operation_num;

/**
 *  0x15 设置计划口数
 *  record_num 计划口数
 */
+(void)the_record_num:(int)record_num;

/**
 *  0x16 设置禁止抽烟
 *  smoking_bool 0 - 否  1 - 是
 */
+(void)the_smoking_bool:(int)smoking_bool;

/**
 *  0x17 开关机
 *  boot 0 - 关机  1 - 开机
 */
+(void)the_boot_bool:(int)boot;

/**
 *  0x18 查询电池状态
 *  battery_status 0 - 所有电池  1 - 1#电池  2 - 2#电池  3 - 3#电池
 */
+(void)the_find_battery_status:(int)battery_status;

/**
 *  0x19 查询实时输出状态
 *  output_status 0 - 查询输出状态  1 - 停止查询
 */
+(void)the_find_output_status:(int)output_status;

/**
 *  0x1A 设置从机广播名称
 */
+(void)the_set_device_name:(NSString *)deviceName;

//组装设备名字的数据
+(NSData *)getDatastr:(NSString *)str;

/**
 *  查询温度曲线
 *
 *  @param num 第几条曲线数据
 */
+(void)the_find_TCR_line:(int)num;

/**
 *  0x21 选择自定义温控模式 -  温度曲线模式
 *  temp_mode_num 0x00 ~ 0x03
 */
+(void)the_choose_temp_mode:(int)temp_mode_num;

/**
 *  0x1D 查询PCB板温度
 */
+(void)the_PCB_temp;

/**
 *  自定义命令
 *
 *  @param arrys 自定义命令数据
 */
+(void)the_Custom_command:(NSArray *)arrys;

/**
 *  查询设备硬件设备信息
 */
+(void)the_Find_deviceData;

/**
 *  NSString - 转换成十六进制数据
 */
+(NSString *)the_nsstring_16:(NSString *)strs;
/**
 *  双个转换 - 转换成十六进制数据
 *
 *  @param strs 需要转换的字符串
 */
+(NSString *)nsstring_16:(NSString *)strs;
/**
 *  单个转换 - 转换成十六进制数据
 *
 *  @param strs 需要转换的字符串
 */
+(int)str_16:(NSString *)strs;

//摄氏度转换为华氏度
+(int)temperatureUnitCelsiusToFahrenheit:(int)celsius;
//华氏度转摄氏度
+(int)temperatureUnitFahrenheitToCelsius:(int)fahrenheit;

//封装数据 - 将数据点 分成曲线数据所用的格式 曲线数据 - 曲线编号 - 曲线总点数 - 最大功率值
+(NSMutableArray *)encapsulatePowerLineData:(int)lineNum :(int)allPowerLinePoint :(int)maxPower :(NSMutableArray *)lineArrysData;

/**
 *  曲线发送的方法
 *
 *  @param lineNum    当前下载的曲线编号
 *  @param pageNum    当前下载的曲线包数
 *  @param allPageNum 当前下载的曲线所有包数
 *  @param pointNum   当前下载的曲线总的点数
 *  @param lineArrys  当前下载的曲线数据
 */
+(void)sendLinePowerData01:(int)lineNum :(int)pageNum :(int)allPageNum :(int)pointNum :(NSMutableArray *)linePowerArrys;

/**
 *  曲线发送数据包的方法
 *
 *  @param lineNum    当前下载的曲线编号
 *  @param pageNum    当前下载的曲线包数
 */
+(void)sendLinePowerData:(int)lineNum :(int)pageNum;

// *  曲线发送数据包 - 封装返回数据
+(NSMutableArray *)back_SendLinePowerData:(int)lineNum :(int)pageNum;

/**
 *  无线升级第一包数据
 */
+(void)the_soft_update_page01:(uint16_t)checkAllNum :(uint16_t)checkAllNum_decryption;
//直接从bin文件中获取数据发送
+(void)the_soft_update_page01_bin:(NSData *)datas;

//升级过程激活命令
+(void)the_update_update_Reply;

//STM32--CRC32校验
+(uint32_t)check_crc32:(NSData*)data_data :(BOOL)check;
//int类型数据按字节倒叙
+(uint32_t)rev_data:(uint32_t) dat;

//进行CRC16校验
+(uint16_t)CRC16_1:(NSData *)datas;

//进行CRC16帧校验
+(uint16_t)CRC16_page:(NSData *)datas;

//校验文件是否满足68K，补齐68K数据
+(NSData *)check_data_68K:(NSData *)datas;

//解密A5
+(int)decryption_A5:(int)data_a5;

//解密A5
+(NSMutableData *)decryption_A5_NsData:(NSData *)a5_data;

//检测是否休眠，休眠则激活
+(void)the_check_BLE_activity;

@end
