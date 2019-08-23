//
//  STW_BLE_Protocol.m
//  STW_BLE_SDK
//
//  Created by 田阳柱 on 16/8/29.
//  Copyright © 2016年 tyz. All rights reserved.
//

#import "STW_BLE_Protocol.h"
#import "STW_BLEService.h"
#import "LineCGPoint.h"
#import "STW_BLE_SDK.h"
#import "User.h"

#define BINLENG 0x11000

@implementation STW_BLE_Protocol

/**
 *  call Back - 应答
 *  call_model  命令
 *  call_status 状态
 */
+(void)the_call_back:(int)call_model :(int)call_status
{
    int checknum = call_status ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,call_model,0x05,call_status,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x01 - 设置蓝牙连接状态
 *  0 - 断开  1 - 连接
 */
+(void)the_BLE_state:(int)state
{
    int checknum = state^0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand001,0x05,state,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x02 - 查询电池电量
 *  固定命令 A8 02 06 00 00 A6
 */
+(void)the_find_battery
{
    int checknum = 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand002,0x06,0x00,0x00,checknum};
    NSData *datas = [NSData dataWithBytes:c length:6];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x03 设置/查询 - 输出功率
 *  数据部分为  D1 = 0x00,D2 = 0x00 查询
 *  数据部分不为 00 00 是设置输出功率
 */
+(void)the_power:(int)power
{
    int checknum = (power >> 8) ^ (Byte)power ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand003,0x06,(power >> 8),power,checknum};
    NSData *datas = [NSData dataWithBytes:c length:6];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x04 查询/设置 - 输出电压
 *  数据部分为  D1 = 0x00,D2 = 0x00 查询
 *  数据部分不为 00 00 是设置输出电压
 */
+(void)the_voltage:(int)voltage
{
    int checknum = (voltage >> 8) ^ (Byte)voltage ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand004,0x06,(voltage >> 8),voltage,checknum};
    NSData *datas = [NSData dataWithBytes:c length:6];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x05 查询/设置输出温度
 *  D1 代表温度单位 0 - 摄氏度  1 - 华氏度
 *  数据部分为  D1 = 0x00,D2 = 0x00,D3 = 0x00 查询
 *  数据部分不为 00 00 00 是设置输出温度
 */
+(void)the_temperature:(int)mode :(int)temp
{
    int checknum = mode ^ (temp >> 8) ^ (Byte)temp ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand005,0x07,mode,(temp >> 8),temp,checknum};
    NSData *datas = [NSData dataWithBytes:c length:7];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x06 查询/设置输出电流
 *  数据部分为  D1 = 0x00,D2 = 0x00 查询
 *  数据部分不为 00 00 是设置输出电流
 */
+(void)the_electricity:(int)elect
{
    int checknum = (elect >> 8) ^ (Byte)elect ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand006,0x06,(elect >> 8),elect,checknum};
    NSData *datas = [NSData dataWithBytes:c length:6];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x07 查询/设置工作模式
 *  D1 代表当前工作模式
 *  D2 代表数值位 Data1
 *  D3 代表数值位 Data2
 *  D4 代表数值位 Data3
 *  D5 代表负载类型
 *  D6 代表是否支持TCR
 *  数据部分为  D1 = 0x00,D2 = 0x00,D3 = 0x00 查询
 *  数据部分不为 00 00 00 是设置输出模式
 */
//查询工作模式
+(void)the_work_mode
{
    int checknum = 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand007,0x0A,0x00,0x00,0x00,0x00,0x00,0x00,checknum};
    NSData *datas = [NSData dataWithBytes:c length:10];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

//设置功率模式 -> power - 功率值  Atomizer_mode - 雾化器类型
+(void)the_work_mode_power:(int)power :(int)Atomizer_mode
{
    int checknum = BLEProtocolModeTypePower ^ (power >> 8) ^ power ^ 0x00 ^ Atomizer_mode ^ BLETCRBoolNO ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand007,0x0A,BLEProtocolModeTypePower,(power >> 8),power,0x00,Atomizer_mode,BLETCRBoolNO,checknum};
    NSData *datas = [NSData dataWithBytes:c length:10];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

//设置电压模式 -> voltage - 电压值  Atomizer_mode - 雾化器类型
+(void)the_work_mode_voltage:(int)voltage :(int)Atomizer_mode
{
    int checknum = BLEProtocolModeTypeVoltage ^ (voltage >> 8) ^ voltage ^ 0x00 ^ Atomizer_mode ^ BLETCRBoolNO ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand007,0x0A,BLEProtocolModeTypeVoltage,(voltage >> 8),voltage,0x00,Atomizer_mode,BLETCRBoolNO,checknum};
    NSData *datas = [NSData dataWithBytes:c length:10];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

//设置温度模式 -> temp_mode - 温度类型  temp - 温度值  Atomizer_mode - 雾化器类型  TCR - 是否是TCR模式
+(void)the_work_mode_temp:(int)temp_mode :(int)temp :(int)Atomizer_mode :(int)TCR
{
    int checknum = BLEProtocolModeTypeTemperature ^ (temp >> 8) ^ temp ^ temp_mode ^ Atomizer_mode ^ TCR ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand007,0x0A,BLEProtocolModeTypeTemperature,(temp >> 8),temp,temp_mode,Atomizer_mode,TCR,checknum};
    NSData *datas = [NSData dataWithBytes:c length:10];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

//设置ByPass模式
+(void)the_work_mode_bypass
{
    int checknum = BLEProtocolModeTypeBypas ^ 0x00 ^ 0x00 ^ 0x00 ^ 0x00 ^ 0x00 ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand007,0x0A,BLEProtocolModeTypeBypas,0x00,0x00,0x00,0x00,0x00,checknum};
    NSData *datas = [NSData dataWithBytes:c length:10];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

//设置Custom模式 ->  custom_number - 曲线编号
+(void)the_work_mode_custom:(int)custom_number
{
    int checknum = BLEProtocolModeTypeCustom ^ custom_number ^ 0x00 ^ 0x00 ^ 0x00 ^ 0x00 ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand007,0x0A,BLEProtocolModeTypeCustom,custom_number,0x00,0x00,0x00,0x00,checknum};
    NSData *datas = [NSData dataWithBytes:c length:10];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x08 查询/设置雾化器
 *  D1 代表负载类型
 *  D2 代表是否支持TCR - 0xFF 代表查询
 *  D3 代表数值位 变化率高位
 *  D4 代表数值位 变化率低位
 *  D5 代表数值位 功率高位
 *  D6 代表数值位 功率低位
 *  数据部分为  D3 ~ D6 = 0x00查询
 *  数据部分不为 0x00 是设置雾化器
 */
+(void)the_atomizer:(int)Atomizer_mode :(int)TCR :(int)change_rate :(int)power
{
    int checknum = Atomizer_mode ^ TCR ^ (change_rate >> 8) ^ change_rate ^ (power >> 8) ^ power ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand008,0x0A,Atomizer_mode,TCR,(change_rate >> 8),change_rate,(power >> 8),power,checknum};
    NSData *datas = [NSData dataWithBytes:c length:10];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x09 查询所有配置信息
 */
+(void)the_find_all_data
{
    int checknum = 0x00 ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand009,0x05,0x00,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x0A 查询抽烟状态
 *  check_num -> 0x00 - 接收成功  0x01 - 校验错误  0xEE 其他错误
 */
+(void)the_smoking_status:(int)check_num
{
    int checknum = check_num ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand00A,0x05,check_num,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x0B 查询离线信息
 */
+(void)the_find_record_data
{
    int checknum = 0x00 ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand00B,0x05,0x00,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x0C 设置系统时间
 */
+(void)the_set_time
{
    //获取当前系统的时间
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *timeString = [dateformatter stringFromDate:senddate];
    
    int year = [[timeString substringToIndex:4] intValue];
    int mouth = [[timeString substringWithRange:NSMakeRange(4,2)] intValue];
    int day = [[timeString substringWithRange:NSMakeRange(6,2)] intValue];
    int h = [[timeString substringWithRange:NSMakeRange(8,2)] intValue];
    int m = [[timeString substringWithRange:NSMakeRange(10,2)] intValue];
    int s = [[timeString substringWithRange:NSMakeRange(12,2)] intValue];
    
    int checknum = (year >> 8) ^ year ^ mouth ^ day ^ h ^  m ^ s;
    
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand00C,0x0B,year >> 8,(Byte)year,(Byte)mouth,(Byte)day,(Byte)h,(Byte)m,(Byte)s,(Byte)checknum};
    //发送系统的时间给电子烟
    NSData *datas = [NSData dataWithBytes:c length:11];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x0D 查询MCU工作状态
 *  check_num -> 0x00 - 接收成功  0x01 - 校验错误  0xEE 其他错误
 */
+(void)the_MCU_status:(int)check_num
{
    int checknum = check_num ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand00D,0x05,check_num,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x0E 激活设备
 */
+(void)the_activate_device
{
    int checknum = 0x00 ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand00E,0x05,0x00,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x0F app 运行状态
 *  app -> 0x00 前台运行  0x01 后台运行
 */
+(void)the_app_state:(int)app
{
    int checknum = app ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand00F,0x05,app,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x10 查询屏幕相关信息
 */
+(void)the_find_LED_data
{
    int checknum = 0x00 ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand010,0x05,0x00,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x11 传输图片
 *  arry_datas - 图片数据
 *  num - 发送第几包
 */
+(void)the_down_logo:(NSMutableArray *)arry_datas :(int)num
{
    if(num == 0)
    {
        //帧序列
        Byte D1 = num >> 8;
        Byte D2 = (Byte)num;
        //图片用途 0 - 开机LOGO  1 - 无负载提示  2 - 短路提示  3 - 负载过大提示
        Byte D3 = [arry_datas[0] intValue];
        //图片宽高
        Byte D4 = ([arry_datas[1] intValue]);
        Byte D5 = [arry_datas[2] intValue];
        //图片发送总包数
        Byte D6 = ([arry_datas[3] intValue] >> 8);
        Byte D7 = [arry_datas[3] intValue];
        //图片颜色
        Byte D8 = ([arry_datas[4] intValue] >> 8);
        Byte D9 = [arry_datas[4] intValue];
        //背景颜色
        Byte D10 = ([arry_datas[5] intValue] >> 8);
        Byte D11 = [arry_datas[5] intValue];
        //左上角坐标点
        Byte D12 = ([arry_datas[6] intValue]);
        Byte D13 = [arry_datas[7] intValue];
        
        int checknum = D1 ^ D2 ^ D3 ^ D4 ^ D5 ^ D6 ^ D7 ^ D8 ^ D9 ^ D10 ^ D11 ^ D12 ^ D13 ^ 0xA6;
        
        Byte c[] = {BLEProtocolHeader01,STW_BLECommand011,0x11,D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,D11,D12,D13,checknum};
        NSData *datas = [NSData dataWithBytes:c length:17];
        
        //激活设备
        [self the_check_BLE_activity];
        
        [[STW_BLEService sharedInstance] sendData:datas];
    }
    else
    {
        int arry_len = (int)arry_datas.count;
        
        int start_num01 = num * 14;
        
        int start_num02 = (num - 1) * 14;
        
        if (start_num01 <= arry_len)
        {
            unsigned char buf[20];
            
            //帧头
            buf[0] = BLEProtocolHeader01;
            //命令
            buf[1] = STW_BLECommand011;
            //本帧长度
            buf[2] = 0x14;
            //帧序列
            buf[3] = num >> 8;
            buf[4] = num;
            
            //数据部分14字节
            for (int i = 0; i < 14; i++)
            {
                buf[i + 5] = [arry_datas[start_num02 + i] intValue];
            }
            
            //校验位
            Byte check_num = 0;
            
            for (int i = 3; i < 19; i++)
            {
                check_num +=  buf[i];
            }
            
            buf[19] = check_num;
            
            //向设备发送数据
            NSMutableData *datas = [[NSMutableData alloc] init];
            [datas appendBytes:buf length:20];
            
            //激活设备
            [self the_check_BLE_activity];
            
            [[STW_BLEService sharedInstance] sendData:datas];
        }
        else
        {
            //最后一帧数据
            int num_len = arry_len - start_num02;
            
            unsigned char buf[num_len + 6];
            
            //帧头
            buf[0] = BLEProtocolHeader01;
            //命令
            buf[1] = STW_BLECommand011;
            //本帧长度
            buf[2] = (num_len + 6);
            //帧序列
            buf[3] = num >> 8;
            buf[4] = num;
            
            //数据部分14字节
            for (int i = 0; i < num_len; i++)
            {
                buf[i + 5] = [arry_datas[start_num02 + i] intValue];
            }
            
            //校验位
            Byte check_num = 0;
            
            for (int i = 3; i < num_len + 5; i++)
            {
                check_num +=  buf[i];
            }
            
            buf[num_len + 5] = check_num;
            
            //向设备发送数据
            NSMutableData *datas = [[NSMutableData alloc] init];
            [datas appendBytes:buf length:(num_len + 6)];
            
            //激活设备
            [self the_check_BLE_activity];
            
            [[STW_BLEService sharedInstance] sendData:datas];
        }
    }
}

/**
 *  0x12 查询/设置抽烟输出曲线 - 功率曲线
 */
//设置抽烟输出曲线 - 功率曲线  arry_datas - 曲线数据  num - 发送第几包
+(void)the_set_Power_line:(NSMutableArray *)arry_datas :(int)num
{
    if (num == 0)
    {
        //包序列
        Byte D1 = num;
        //曲线序号
        Byte D2 = [arry_datas[0] intValue];
        //曲线要发送的总包数
        Byte D3 = [arry_datas[1] intValue];
        //曲线总数据个数
        Byte D4 = [arry_datas[2] intValue];
        
        int checknum = D1 ^ D2 ^ D3 ^ D4 ^ 0xA6;
        
        Byte c[] = {BLEProtocolHeader01,STW_BLECommand012,0x08,D1,D2,D3,D4,checknum};
        NSData *datas = [NSData dataWithBytes:c length:8];
        
        //激活设备
        [self the_check_BLE_activity];
        
        [[STW_BLEService sharedInstance] sendData:datas];
    }
    else
    {
        int arry_len = (int)arry_datas.count;
        
        int start_num01 = num * 15;
        
        int start_num02 = (num - 1) * 15;
        
        if (start_num01 <= arry_len)
        {
            unsigned char buf[20];
            
            //帧头
            buf[0] = BLEProtocolHeader01;
            //命令
            buf[1] = STW_BLECommand012;
            //本帧长度
            buf[2] = 0x14;
            //帧序列
            buf[3] = num;

            //数据部分14字节
            for (int i = 0; i < 15; i++)
            {
                buf[i + 4] = [arry_datas[start_num02 + i] intValue];
            }
            
            //校验位
            Byte check_num = 0;
            
            for (int i = 3; i < 19; i++)
            {
                check_num +=  buf[i];
            }
            
            buf[19] = check_num;
            
            //向设备发送数据
            NSMutableData *datas = [[NSMutableData alloc] init];
            [datas appendBytes:buf length:20];
            
            //激活设备
            [self the_check_BLE_activity];
            
            [[STW_BLEService sharedInstance] sendData:datas];
        }
        else
        {
            //最后一帧数据
            int num_len = arry_len - start_num02;
            
            unsigned char buf[num_len + 5];
            
            //帧头
            buf[0] = BLEProtocolHeader01;
            //命令
            buf[1] = STW_BLECommand012;
            //本帧长度
            buf[2] = (num_len + 5);
            //帧序列
            buf[3] = num;
            
            //数据部分14字节
            for (int i = 0; i < num_len; i++)
            {
                buf[i + 4] = [arry_datas[start_num02 + i] intValue];
            }
            
            //校验位
            Byte check_num = 0;
            
            for (int i = 3; i < num_len + 4; i++)
            {
                check_num +=  buf[i];
            }
            
            buf[num_len + 4] = check_num;
            
            //向设备发送数据
            NSMutableData *datas = [[NSMutableData alloc] init];
            [datas appendBytes:buf length:(num_len + 5)];
            
            //激活设备
            [self the_check_BLE_activity];
            
            [[STW_BLEService sharedInstance] sendData:datas];
        }
    }
}

//查询抽烟输出曲线 - 功率曲线
+(void)the_find_Power_line:(int)answerNum :(int)lineNum :(int)pageNum
{
    //D1 命令类型 D2 应答值 - answerNum D3 曲线序号 - lineNum  D4 包序列 - pageNum
    int checknum = 0xA2 ^ answerNum ^ lineNum ^ pageNum ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand012,0x08,0xA2,answerNum,lineNum,pageNum,checknum};
    NSData *datas = [NSData dataWithBytes:c length:8];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x13 选择抽烟输出曲线
 *  custom_num - 要选择曲线的序号
 */
//选择曲线/应答从机
+(void)the_choose_custom:(int)custom_num
{
    int checknum = custom_num ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand013,0x05,custom_num,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x14 查询/设置操作方式
 *  operation_mode - 模式类型
 *  01 - 更改待机时长  02 - 更改屏幕亮度  03 - 更改锁机按键次数  04 - 更改调节步进值
 *  05 - 更改抽烟时长  06 - 加温功率设置  07 - 更改屏幕翻转     08 - 加减按键翻转
 *  operation_num - 修改的数值
 */
+(void)the_mode_of_operation:(int)operation_mode :(int)operation_num
{
    int checknum = operation_mode ^ (operation_num >> 8) ^ (Byte)operation_num ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand014,0x07,operation_mode,(operation_num >> 8),(Byte)operation_num,checknum};
    NSData *datas = [NSData dataWithBytes:c length:7];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x15 设置计划口数
 *  record_num 计划口数
 */
+(void)the_record_num:(int)record_num
{
    int checknum = (record_num >> 8) ^ (Byte)record_num ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand015,0x06,(record_num >> 8),(Byte)record_num,checknum};
    NSData *datas = [NSData dataWithBytes:c length:6];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x16 设置禁止抽烟
 *  smoking_bool 0 - 否  1 - 是
 */
+(void)the_smoking_bool:(int)smoking_bool
{
    int checknum = (Byte)smoking_bool ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand016,0x05,(Byte)smoking_bool,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x17 开关机
 *  boot 0 - 关机  1 - 开机
 */
+(void)the_boot_bool:(int)boot
{
    int checknum = (Byte)boot ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand017,0x05,(Byte)boot,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x18 查询电池状态
 *  battery_status 0 - 所有电池  1 - 1#电池  2 - 2#电池  3 - 3#电池
 */
+(void)the_find_battery_status:(int)battery_status
{
    int checknum = (Byte)battery_status ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand018,0x05,(Byte)battery_status,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x19 查询实时输出状态
 *  output_status 0 - 查询输出状态  1 - 停止查询
 */
+(void)the_find_output_status:(int)output_status
{
    int checknum = (Byte)output_status ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand019,0x05,(Byte)output_status,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x1A 设置从机广播名称
 */
+(void)the_set_device_name:(NSString *)deviceName
{
    //    //将文字转换成UTF-8
    //     NSString *utf_string = [NSString stringWithString:[string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //将字符转换成ASII码
    NSData *nameData = [STW_BLE_Protocol getDatastr:deviceName];
    
    Byte *NumeStrs = (Byte *)[nameData bytes];
    //组装数据发送给电子烟
    int len_num = NumeStrs[0];
    
    NSLog(@"len_num - %d",len_num);
    
    unsigned char buf[20];
    
    //帧头
    buf[0] = BLEProtocolHeader01;
    
    //命令
    buf[1] = STW_BLECommand01A;
    
    //长度
    buf[2] = 20;
    
    if(len_num > 16)
    {
        len_num = 16;
    }
    
    for (int i = 3; i < len_num + 3; i++)
    {
        buf[i] = NumeStrs[(i-3)+1];
    }
    
    //不足16位补全空格
    for (int i = len_num + 3 ; i < 16 + 3; i++)
    {
        buf[i] = 0x00;
    }
    
    //校验位
    Byte check_num = 0;
    
    for (int i = 3; i < 19; i++)
    {
        check_num =  check_num ^ buf[i];
    }
    
    //校验位
    buf[19] = check_num ^ 0xA6;
    
    NSMutableData *datas = [[NSMutableData alloc] init];
    [datas appendBytes:buf length:20];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

//组装设备名字的数据
+(NSData *)getDatastr:(NSString *)str
{
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    int length = (int)data.length;
    NSMutableData *newData = [NSMutableData data];
    Byte byte[] = {length};
    NSData *sizeData = [[NSData alloc] initWithBytes:byte length:1];
    [newData appendData:sizeData];
    [newData appendData:data];
    return newData;
}

//查询温度曲线
+(void)the_find_TCR_line:(int)num
{
    int checknum = 0x00 ^ 0x00 ^ num ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand01A,0x07,0x00,0x00,num,checknum};
    NSData *datas = [NSData dataWithBytes:c length:7];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x1B 选择自定义温控模式 -  温度曲线模式
 *  temp_mode_num 0x00 ~ 0x03
 */
+(void)the_choose_temp_mode:(int)temp_mode_num
{
    int checknum = (Byte)temp_mode_num ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand01B,0x05,(Byte)temp_mode_num,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  0x1D 查询PCB板温度
 */
+(void)the_PCB_temp
{
    int checknum = 0x00 ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand01D,0x05,0x00,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  自定义命令
 */
+(void)the_Custom_command:(NSArray *)arrys
{
    int leng = [arrys[2] intValue];   //总长度
    int data_leng = leng - 4;    //数据部分长度
    
    unsigned char buf[leng];
    
    //帧头
    buf[0] = [arrys[0] intValue];
    //命令
    buf[1] = [arrys[1] intValue];
    //本帧长度
    buf[2] = leng;

    //数据部分字节
    for (int i = 0; i < data_leng; i++)
    {
        buf[i + 3] = [arrys[3 + i] intValue];
    }
    
    //计算校验和
    Byte checknum = 0x00;
    
    for (int i = 0; i < data_leng; i++)
    {
        checknum = checknum ^ [arrys[3 + i] intValue];
    }
    
    checknum = checknum ^ 0xA6;
    
    buf[leng -1] = checknum;
    
    //向设备发送数据
    NSMutableData *datas = [[NSMutableData alloc] init];
    [datas appendBytes:buf length:(leng)];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  查询设备硬件设备信息
 */
+(void)the_Find_deviceData
{
    int checknum = 0xFD ^ 0xA6;
    Byte c[] = {BLEProtocolHeader01,STW_BLECommand01E,0x05,0xFD,checknum};
    NSData *datas = [NSData dataWithBytes:c length:5];
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
    
    NSLog(@"获取硬件编号:%@",datas);
}

/**
 *  NSString 转换成十六进制数据
 */
+(NSString *)the_nsstring_16:(NSString *)strs
{
    NSArray *send_data_arry = [strs componentsSeparatedByString:@","];
    
    NSString *data_str = [STW_BLE_Protocol nsstring_16:send_data_arry[0]];
    
    for (int i = 1; i < send_data_arry.count; i++)
    {
        data_str = [NSString stringWithFormat:@"%@,%@",data_str,[STW_BLE_Protocol nsstring_16:send_data_arry[i]]];
    }
    
    return data_str;
}

//双个转换
+(NSString *)nsstring_16:(NSString *)strs
{
    int num_01 = 0;
    int num_02 = 0;
    int nums = 0;
    
    if(strs.length >= 2)
    {
        num_01 = [STW_BLE_Protocol str_16:[strs substringWithRange:NSMakeRange(0,1)]];
        num_02 = [STW_BLE_Protocol str_16:[strs substringWithRange:NSMakeRange(1,1)]];
        
        nums = (num_01 << 4) + num_02;
    }
    else
    {
        num_01 = [STW_BLE_Protocol str_16:[strs substringWithRange:NSMakeRange(0,1)]];
        nums = num_01;
    }
    
    strs = [NSString stringWithFormat:@"%d",nums];

    return strs;
}

//单个转换
+(int)str_16:(NSString *)strs
{
    int str_num = 0;
    
    if ([strs isEqualToString:@"0"])
    {
        str_num = 0x00;
    }
    else if ([strs isEqualToString:@"1"])
    {
        str_num = 0x01;
    }
    else if ([strs isEqualToString:@"2"])
    {
        str_num = 0x02;
    }
    else if ([strs isEqualToString:@"3"])
    {
        str_num = 0x03;
    }
    else if ([strs isEqualToString:@"4"])
    {
        str_num = 0x04;
    }
    else if ([strs isEqualToString:@"5"])
    {
        str_num = 0x05;
    }
    else if ([strs isEqualToString:@"6"])
    {
        str_num = 0x06;
    }
    else if ([strs isEqualToString:@"7"])
    {
        str_num = 0x07;
    }
    else if ([strs isEqualToString:@"8"])
    {
        str_num = 0x08;
    }
    else if ([strs isEqualToString:@"9"])
    {
        str_num = 0x09;
    }
    else if ([strs isEqualToString:@"A"])
    {
        str_num = 0x0A;
    }
    else if ([strs isEqualToString:@"B"])
    {
        str_num = 0x0B;
    }
    else if ([strs isEqualToString:@"C"])
    {
        str_num = 0x0C;
    }
    else if ([strs isEqualToString:@"D"])
    {
        str_num = 0x0D;
    }
    else if ([strs isEqualToString:@"E"])
    {
        str_num = 0x0E;
    }
    else if ([strs isEqualToString:@"F"])
    {
        str_num = 0x0F;
    }
    
    return str_num;
}

+(int)temperatureUnitCelsiusToFahrenheit:(int)celsius
{
    float cel = celsius * 9.0f/5.0f + 32.0f;       //摄氏度转换为华氏度
    return cel;
}

+(int)temperatureUnitFahrenheitToCelsius:(int)fahrenheit
{
    float cel =5.0f/9.0f*(fahrenheit - 32.0f);    //华氏度转摄氏度
    return cel;
}

//封装数据 - 将数据点 分成曲线数据所用的格式 曲线数据 - 曲线编号 - 曲线总点数 - 最大功率值
+(NSMutableArray *)encapsulatePowerLineData:(int)lineNum :(int)allPowerLinePoint :(int)maxPower :(NSMutableArray *)lineArrysData
{
    NSMutableArray *backLinePointArry = [NSMutableArray array];
    
    //赋值第零个点
    LineCGPoint *startLinePoint = [[LineCGPoint alloc] init];
    startLinePoint.line_x_w = 0;
    startLinePoint.line_y_h = 0;
    [backLinePointArry addObject:startLinePoint];
    
    //赋值曲线数据点
    for (int i = 0; i < allPowerLinePoint; i++)
    {
        //高低位置变换一下 2016-10-05 tyz
//        int powerLineData = [[lineArrysData objectAtIndex:(i * 2)] intValue] * 256 + [[lineArrysData objectAtIndex:((i * 2) + 1)] intValue];
        
        int powerLineData = [[lineArrysData objectAtIndex:(i * 2)] intValue] + [[lineArrysData objectAtIndex:((i * 2) + 1)] intValue]  * 256 ;
        
        float powerData = powerLineData / (maxPower * 10.0f);
        
        LineCGPoint *linePoint = [[LineCGPoint alloc] init];
        linePoint.line_x_w = i + 1;
//        linePoint.line_y_h = 1 - powerData;
        linePoint.line_y_h = powerData;
        
        [backLinePointArry addObject:linePoint];
    }
    
    //赋值曲线数据点最后一个点 - 保存曲线信息
    LineCGPoint *linePoint_return_last = [[LineCGPoint alloc] init];
    linePoint_return_last.line_x_w = (allPowerLinePoint + 1);
    linePoint_return_last.line_y_h = lineNum;
    
    [backLinePointArry addObject:linePoint_return_last];
    
    return backLinePointArry;
}

/**
 *  曲线发送第一包的方法
 *
 *  @param lineNum    当前下载的曲线编号
 *  @param pageNum    当前下载的曲线包数
 *  @param allPageNum 当前下载的曲线所有包数
 *  @param pointNum   当前下载的曲线总的点数
 *  @param lineArrys  当前下载的曲线数据
 */
+(void)sendLinePowerData01:(int)lineNum :(int)pageNum :(int)allPageNum :(int)pointNum :(NSMutableArray *)linePowerArrys
{
    //初始化
    [STW_BLE_SDK STW_SDK].downloadPowerLineArrys = [NSMutableArray array];
    
    [STW_BLE_SDK STW_SDK].downloadPowerLineNum = lineNum;          //当前下载的曲线编号
    [STW_BLE_SDK STW_SDK].downloadPowerLinePageNum = pageNum;      //当前下载的曲线包数
    [STW_BLE_SDK STW_SDK].downloadPowerLineAllPageNum = allPageNum;   //当前下载的曲线所有包数
    [STW_BLE_SDK STW_SDK].downloadPowerLineAllPointNum = pointNum;   //当前下载的曲线总的点数
    [STW_BLE_SDK STW_SDK].downloadPowerLineArrys = linePowerArrys;   //当前下载的曲线数据

    //发送第一包数据
    unsigned char buf[20];
    
    //帧头
    buf[0] = BLEProtocolHeader01;
    //命令
    buf[1] = STW_BLECommand012;
    //本帧长度
    buf[2] = 0x14;
    //命令
    buf[3] = 0xA1;
    //应答值
    buf[4] = 0x00;
    //曲线编号
    buf[5] = [STW_BLE_SDK STW_SDK].downloadPowerLineNum;
    //帧序列
    buf[6] = [STW_BLE_SDK STW_SDK].downloadPowerLinePageNum;
    //总包数
    buf[7] = [STW_BLE_SDK STW_SDK].downloadPowerLineAllPageNum;
    //总长度
    buf[8] = [STW_BLE_SDK STW_SDK].downloadPowerLineAllPointNum;
    
    //数据部分14字节
    for (int i = 9; i < 19; i++)
    {
        buf[i] = 0x00;
    }
    
    //校验位
    Byte check_num = 0;
    
    for (int i = 3; i < 19; i++)
    {
        check_num =  check_num ^ buf[i];
    }

    buf[19] = check_num ^ 0xA6;
    
    //向设备发送数据
    NSMutableData *datas = [[NSMutableData alloc] init];
    [datas appendBytes:buf length:20];
    
    //激活设备
    [self the_check_BLE_activity];
    
    [[STW_BLEService sharedInstance] sendData:datas];
}

/**
 *  曲线发送数据包的方法
 *
 *  @param lineNum    当前下载的曲线编号
 *  @param pageNum    当前下载的曲线包数
 */
+(void)sendLinePowerData:(int)lineNum :(int)pageNum
{
    if ([STW_BLE_SDK STW_SDK].downloadPowerLineNum == lineNum)
    {
        //传输下一包数据
        [STW_BLE_SDK STW_SDK].downloadPowerLinePageNum = pageNum;    //当前下载的曲线包数
        //整理数据
        if ([STW_BLE_SDK STW_SDK].downloadPowerLinePageNum <= [STW_BLE_SDK STW_SDK].downloadPowerLineAllPageNum)
        {
            //发送中间数据包
            unsigned char buf[20];
            
            //帧头
            buf[0] = BLEProtocolHeader01;
            //命令
            buf[1] = STW_BLECommand012;
            //本帧长度
            buf[2] = 0x14;
            //命令
            buf[3] = 0xA1;
            //应答值
            buf[4] = 0x00;
            //曲线编号
            buf[5] = [STW_BLE_SDK STW_SDK].downloadPowerLineNum;
            //帧序列
            buf[6] = [STW_BLE_SDK STW_SDK].downloadPowerLinePageNum;
            
            //返回封装的数据
            NSMutableArray *back_line_data = [STW_BLE_Protocol back_SendLinePowerData:[STW_BLE_SDK STW_SDK].downloadPowerLineNum :[STW_BLE_SDK STW_SDK].downloadPowerLinePageNum];
            
            //数据部分12字节
            for (int i = 0; i < back_line_data.count; i++)
            {
                buf[i + 7] = [[back_line_data objectAtIndex:i] intValue];
            }
            
            int check_lineNum = 7 + (int)back_line_data.count;
            
            if (check_lineNum < 19)
            {
                for (int j = check_lineNum;j < 19 ;j++)
                {
                    buf[j] = 0x00;
                }
            }
 
            //校验位
            Byte check_num = 0;
            
            for (int i = 3; i < 19; i++)
            {
                check_num =  check_num ^ buf[i];
            }
            
            buf[19] = check_num ^ 0xA6;
            
            //向设备发送数据
            NSMutableData *datas = [[NSMutableData alloc] init];
            [datas appendBytes:buf length:20];
            
            //激活设备
            [self the_check_BLE_activity];
            
            [[STW_BLEService sharedInstance] sendData:datas];
        }
    }
    else
    {
        NSLog(@"传输数据错误");
    }
}

//封装发送的数据
+(NSMutableArray *)back_SendLinePowerData:(int)lineNum :(int)pageNum
{
    NSMutableArray *back_arrys = [NSMutableArray array];
    
    if ([STW_BLE_SDK STW_SDK].downloadPowerLineNum == lineNum)
    {
//        NSLog(@"------------- pageNum------------- - %d",pageNum);
        if ((pageNum * 6) < [STW_BLE_SDK STW_SDK].downloadPowerLineAllPointNum)
        {
            for (int i = 1; i <= 6; i++)
            {
                LineCGPoint *linePoint = [[STW_BLE_SDK STW_SDK].downloadPowerLineArrys objectAtIndex:(i + ((pageNum - 1) * 6))];
                
                int lineDatas = linePoint.line_y_h * [STW_BLE_SDK STW_SDK].max_power * 10;
                
//                NSLog(@"lineDatas - %d",lineDatas);
                
                [back_arrys addObject:[NSString stringWithFormat:@"%d",lineDatas]];
                [back_arrys addObject:[NSString stringWithFormat:@"%d",lineDatas >> 8]];
            }
        }
        else
        {
            int nums = [STW_BLE_SDK STW_SDK].downloadPowerLineAllPointNum - ((pageNum - 1) * 6);
            
            for (int i = 1; i <= nums; i++)
            {
                LineCGPoint *linePoint = [[STW_BLE_SDK STW_SDK].downloadPowerLineArrys objectAtIndex:(i + ((pageNum - 1) * 6))];
                
                int lineDatas = linePoint.line_y_h * [STW_BLE_SDK STW_SDK].max_power * 10;
                
                [back_arrys addObject:[NSString stringWithFormat:@"%d",lineDatas]];
                [back_arrys addObject:[NSString stringWithFormat:@"%d",lineDatas >> 8]];
            }
        }
    }
    else
    {
        NSLog(@"错误的数据");
    }

    return back_arrys;
}

/**
 *  无线升级第一包数据
 */
+(void)the_soft_update_page01:(uint16_t)checkAllNum :(uint16_t)checkAllNum_decryption
{
//    Byte c[] = {0x6D,0x4B,0xff,0xff,0x00,0x00,0x00,0x44,0x45,0x45,0x45,0x45,0x0,0x04,0x01,0xff,0xce,0x2c};
    
    Byte c[] = {checkAllNum_decryption,checkAllNum_decryption>>8,0xff,0xff,0x00,0x00,0x00,0x44,0x45,0x45,0x45,0x45,0x0,0x04,0x01,0xff,0xce,0x2c};
    
//    Byte c[] = {checkAllNum,checkAllNum>>8,0xff,0xff,0x00,0x00,0x00,0x44,checkAllNum_decryption,checkAllNum_decryption >> 8,0x45,0x45,0x0,0x04,0x01,0xff,0xce,0x2c};

    NSData *datas = [NSData dataWithBytes:c length:18];
    
    [[STW_BLEService sharedInstance] sendBigData:datas :0];
}

//直接从bin文件中获取数据发送
+(void)the_soft_update_page01_bin:(NSData *)datas
{
    [[STW_BLEService sharedInstance] sendBigData:datas :0];
}

//升级过程激活命令
+(void)the_update_update_Reply
{
    Byte c1[] = {0x88,0x88,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};
    
    NSData *datas1 = [NSData dataWithBytes:c1 length:20];
    
    Byte c2[] = {0x88,0x88,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};

    NSData *datas2 = [NSData dataWithBytes:c2 length:20];
    
    [[STW_BLEService sharedInstance] sendBigData:datas1 :0];
    
    double delayInSeconds = 0.01f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [[STW_BLEService sharedInstance] sendBigData:datas2 :1];
                   });
}

//STM32--CRC32校验
+(uint32_t)check_crc32:(NSData*) data_data :(BOOL) check
{
    uint32_t len = (int)data_data.length/4;
    
    uint32_t crc[len];
    
    [data_data getBytes:&crc length: sizeof(crc)];
    
    uint32_t *ptr = crc;
    
    uint32_t xbit = 0;
    uint32_t data = 0;
    uint32_t CRC11 = 0xFFFFFFFF;    // init
    
    while(len--)
    {
        xbit = 1 << 31;
        
        if (check) {
            data = [STW_BLE_Protocol rev_data:*ptr++];
        }
        else
        {
            data = *ptr++;
        }
        
        for(int bits = 0; bits < 32; bits++)
        {
            if (CRC11 & 0x80000000)
            {
                CRC11 <<= 1;
                CRC11 ^= 0x04c11db7;
            }
            else
                CRC11 <<= 1;
            if (data & xbit)
                CRC11 ^= 0x04c11db7;
            
            xbit >>= 1;
        }
    }
    return CRC11;
}

//int类型数据按字节倒叙
+(uint32_t)rev_data:(uint32_t) dat
{
    uint32_t rev_dat = 0;
    
    rev_dat = BUILD_UINT32(BREAK_UINT32(dat,3),BREAK_UINT32(dat,2),BREAK_UINT32(dat,1),BREAK_UINT32(dat,0));
    
    return rev_dat;
}

//进行CRC16校验
+(uint16_t)CRC16_1:(NSData *)datas
{
    int wDataLen = (int)datas.length;

    uint16_t CRC_16 = 0;

    const unsigned char* bytes_datas = [datas bytes];
    
    for (int i = 4; i < wDataLen; i++)
    {
//        NSLog(@"bytes_datas - %d - %d - CRC_16 - %d",i,bytes_datas[i],CRC_16);
        CRC_16 = crc16(CRC_16, bytes_datas[i]);
    }

    CRC_16 = crc16(CRC_16,0);
    CRC_16 = crc16(CRC_16,0);
    
    return CRC_16;
}

//进行CRC16帧校验
+(uint16_t)CRC16_page:(NSData *)datas
{
    int wDataLen = (int)datas.length;
    
    uint16_t CRC_16 = 0;
    
    const unsigned char* bytes_datas = [datas bytes];
    
    for (int i = 0; i < wDataLen; i++)
    {
        //        NSLog(@"bytes_datas - %d - %d - CRC_16 - %d",i,bytes_datas[i],CRC_16);
        CRC_16 = crc16(CRC_16, bytes_datas[i]);
    }
    
    return CRC_16;
}

static uint16_t crc16(uint16_t crc, uint8_t val)
{
    const uint16_t poly = 0x1021;
    uint8_t cnt;
    
    for (cnt = 0; cnt < 8; cnt++, val <<= 1)
    {
        uint8_t msb = (crc & 0x8000) ? 1 : 0;
        
        crc <<= 1;
        
        if (val & 0x80)
        {
            crc |= 0x0001;
        }
        
        if (msb)
        {
            crc ^= poly;
        }
    }
    
    return crc;
}

//校验文件是否满足68K，补齐68K数据
+(NSData *)check_data_68K:(NSData *)datas
{
    int lengs = (int)datas.length;
    
    const unsigned char* bytes_datas = [datas bytes];
    
    Byte buf[BINLENG];
    
    for (int i = 0;i < lengs; i++)
    {
        buf[i] = bytes_datas[i];
    }
    
    if (lengs < BINLENG)
    {
        for (int i = lengs;i < BINLENG; i++)
        {
            buf[i] = 0xFF;
        }
    }
    
    NSMutableData *datas_ns = [[NSMutableData alloc] init];
    [datas_ns appendBytes:buf length:(BINLENG)];
    
    return datas_ns;
}

//解密A5
+(int)decryption_A5:(int)data_a5
{
    int num;
    if (data_a5 != 0xFF && data_a5 != 0x00 && data_a5 != 0xA5 && data_a5 != 0x5A)
    {
        num = data_a5 ^ 0xA5;
    }
    else
    {
        num = data_a5;
    }
    return num;
}

//解密A5
+(NSMutableData *)decryption_A5_NsData:(NSData *)a5_data
{
    int lengs = (int)a5_data.length;
    
    const unsigned char* bytes_datas = [a5_data bytes];
    
    Byte buf[lengs];
    
    for (int i = 0;i < lengs; i++)
    {
        buf[i] = [STW_BLE_Protocol decryption_A5:bytes_datas[i]];
    }
    
    NSMutableData *datas_ns = [[NSMutableData alloc] init];
    [datas_ns appendBytes:buf length:(lengs)];
    
    return datas_ns;
}

//检测是否休眠，休眠则激活
+(void)the_check_BLE_activity
{
    if ([STW_BLE_SDK STW_SDK].root_lock_status == 0)
    {
        //激活设备
        [STW_BLE_Protocol the_boot_bool:1];
    }
}


@end
