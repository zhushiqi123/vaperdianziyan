//
//  STW_BLEService.m
//  STW_BLE_SDK
//
//  Created by 田阳柱 on 16/4/18.
//  Copyright © 2016年 tyz. All rights reserved.

#define VendorId 0x01   //STW

#import "STW_BLEService.h"
#import "STW_BLE_Protocol.h"
#import "STW_BLE_SDK.h"
#import "ProgressHUD.h"
#import "InternationalControl.h"

//service的UUID
NSString * const UUIDDeviceService = @"7AAC6AC0-AFCA-11E1-9FEB-0002A5D5C51B";
//update_service的UUID
NSString * const UUIDDeviceUpdateSoftService = @"F000FFC0-0451-4000-B000-000000000000";

//设备名称UUID（只用于修改设备名称）
NSString * const UUIDDeviceName = @"51e6e800-afc9-11e1-9103-0002a5d5c51b";
//从机发送命令UUID
NSString * const UUIDDeviceData = @"aed04e80-afc9-11e1-a484-0002a5d5c51b";
//主机发送命令UUID
NSString * const UUIDDeviceSetup = @"19575ba0-b20d-11e1-b0a5-0002a5d5c51b";

//发送soft Update第一包数据
NSString * const UUIDDeviceSoftUpdatePage01 = @"F000FFC1-0451-4000-B000-000000000000";
//发送soft Update bin文件数据
NSString * const UUIDDeviceSoftUpdateBinPage = @"F000FFC2-0451-4000-B000-000000000000";

@interface STW_BLEService()
{
    CBCharacteristic *characateristicDeviename;
    CBCharacteristic *characateristicSoftUpdatePage01;
    CBCharacteristic *characateristicSoftUpdateBinPage;
}
@end

@implementation STW_BLEService

static STW_BLEService *shareInstance = nil;
//STW秘钥
static uint8_t KEY_COMMAND[20] = {13,140,200,162,44,248,94,142,175,214,130,205,6,91,228,184,166,208,48,186};

+(STW_BLEService *)sharedInstance
{
    if (!shareInstance)
    {
        shareInstance = [[STW_BLEService alloc] init];
        shareInstance.centralManager = [[CBCentralManager alloc] initWithDelegate:shareInstance queue:nil];
        shareInstance.scanedDevices = [NSMutableArray array];
    }
    return shareInstance;
}

//主动扫描蓝牙
-(void)scanStart
{
    if(self.isReadyScan)
    {
        [self.scanedDevices removeAllObjects];      //初始化设备数组变量
        //检测所有信道
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],CBCentralManagerScanOptionAllowDuplicatesKey ,nil];
        
        [self.centralManager scanForPeripheralsWithServices:nil options:options];
    }
    else
    {
        if(self.Service_errorHandler)
        {
            self.Service_errorHandler(@"蓝牙设备无法访问，请确认蓝牙已经开启？");
        }
    }
}

//主动停止扫描蓝牙
-(void)scanStop
{
    [self.centralManager stopScan];
}

//主动连接设备
-(void)connect:(STW_BLEDevice *)device
{
    self.device = device;
    device.peripheral.delegate = self;
    [self.centralManager connectPeripheral:device.peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
}

//主动断开连接
-(void)disconnect
{
    if (self.device)
    {
        [self.centralManager cancelPeripheralConnection:self.device.peripheral];
        self.device = nil;
    }
}

//发送少量的数据
-(void)sendData:(NSData *)data
{
    if(self.device.characteristic && self.isBLEStatus)
    {
        if(self.isVaporNow)
        {
            NSLog(@"正在吸烟");
        }
        else
        {
            NSLog(@"向设备发送的信息--->%@",data);
            //数据加密
//            NSMutableData *datas = [self command_lock:data];
//            
//            NSLog(@"向设备发送的加密信息--->%@",datas);
            
            //模式一  读写
            [self.device.peripheral writeValue:data forCharacteristic:self.device.characteristic type:CBCharacteristicWriteWithResponse];
        }
    }
    else
    {
        NSLog(@"没有连接设备");
        if ([STW_BLEService sharedInstance].isBLEType != STW_BLE_IsBLETypeLoding)
        {
//            [ProgressHUD showError:@"请先连接设备"];
            [ProgressHUD showError:[InternationalControl return_string:@"window_warning_addDevice"]];
        }
    }
}

//发送大量的数据
-(void)sendBigData:(NSData *)data :(int)type
{
    if (type == 0  && self.isBLEStatus)
    {
//        NSLog(@"向设备发送的信息--->%@\n%@",data,characateristicSoftUpdatePage01);
        //模式二  只写不读 - 发送第一包数据
        NSLog(@"升级向设备发送的信息--->%@",data);
        //数据加密
//        NSMutableData *datas = [self command_lock:data];
//        NSLog(@"升级向设备发送的加密信息--->%@",datas);
        
        [self.device.peripheral writeValue:data forCharacteristic:characateristicSoftUpdatePage01 type:CBCharacteristicWriteWithoutResponse];
    }
    else if (type == 1 && self.isBLEStatus)
    {
        NSLog(@"向设备发送的信息--->%@\n%@",data,characateristicSoftUpdateBinPage);
        //模式二  只写不读 - 发送bin文件数据
        [self.device.peripheral writeValue:data forCharacteristic:characateristicSoftUpdateBinPage type:CBCharacteristicWriteWithoutResponse];
    }
    else
    {
//        [ProgressHUD showError:@"请先连接设备"];
        [ProgressHUD showError:[InternationalControl return_string:@"window_warning_addDevice"]];
    }
}

#pragma mark CBCentralManagerDelegate     -- >  实现蓝牙代理方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
                        NSLog(@"蓝牙设备设备不支持的状态");
            //蓝牙断开连接回调
            [self deleteBLE];
            self.isReadyScan = NO;
            break;
        case CBCentralManagerStateUnauthorized:
                        NSLog(@"蓝牙设备未授权状态");
            self.isReadyScan = NO;
            break;
        case CBCentralManagerStatePoweredOff:
                        NSLog(@"-- > 蓝牙关闭状态");
            //蓝牙断开连接回调
            [self deleteBLE];
            
            //            self.errorHandler(@"-- > 蓝牙关闭状态");
            self.isReadyScan = NO;
            break;
        case CBCentralManagerStatePoweredOn:
                        NSLog(@"-- > 蓝牙可用状态");
            self.isReadyScan = YES;
            [self.scanedDevices removeAllObjects];
            [central scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBCentralManagerStateUnknown:
                        NSLog(@"手机蓝牙设备未知错误");
            //蓝牙断开连接回调
            [self deleteBLE];
            self.isReadyScan = NO;
            break;
        default:
                        NSLog(@"手机蓝牙设备未知错误");
            //蓝牙断开连接回调
            [self deleteBLE];
            self.isReadyScan = NO;
            break;
    }
}

/*!
 *  @method centralManager:willRestoreState:
 *
 *  @param central      The central manager providing this information.
 *  @param dict			A dictionary containing information about <i>central</i> that was preserved by the system at the time the app was terminated.
 *
 *  @discussion			For apps that opt-in to state preservation and restoration, this is the first method invoked when your app is relaunched into
 *						the background to complete some Bluetooth-related task. Use this method to synchronize your app's state with the state of the
 *						Bluetooth system.
 *
 *  @seealso            CBCentralManagerRestoredStatePeripheralsKey;
 *  @seealso            CBCentralManagerRestoredStateScanServicesKey;
 *  @seealso            CBCentralManagerRestoredStateScanOptionsKey;
 *
 */

//central提供信息，dict包含了应用程序关闭是系统保存的central的信息，用dic去恢复central
//app状态的保存或者恢复，这是第一个被调用的方法当APP进入后台去完成一些蓝牙有关的工作设置，使用这个方法同步app状态通过蓝牙系统

//- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
//{
    //    NSLog(@"willRestoreState");
//}

/*!
 *  @method centralManager:didRetrievePeripherals:
 *
 *  @param central      The central manager providing this information.
 *  @param peripherals  A list of <code>CBPeripheral</code> objects.
 *
 *  @discussion         This method returns the result of a {@link retrievePeripherals} call, with the peripheral(s) that the central manager was
 *                      able to match to the provided UUID(s).
 *
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    //    NSLog(@"didRetrievePeripherals");
}

/*!
 *  @method centralManager:didRetrieveConnectedPeripherals:
 *
 *  @param central      The central manager providing this information.
 *  @param peripherals  A list of <code>CBPeripheral</code> objects representing all peripherals currently connected to the system.
 *
 *  @discussion         This method returns the result of a {@link retrieveConnectedPeripherals} call.
 *
 */
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    //    NSLog(@"didRetrieveConnectedPeripherals");
}

/*!
 *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 *
 *  @param central              The central manager providing this update.
 *  @param peripheral           A <code>CBPeripheral</code> object.
 *  @param advertisementData    A dictionary containing any advertisement and scan response data.
 *  @param RSSI                 The current RSSI of <i>peripheral</i>, in dBm. A value of <code>127</code> is reserved and indicates the RSSI
 *								was not available.
 *
 *  @discussion                 This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. A discovered peripheral must
 *                              be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager. For
 *                              a list of <i>advertisementData</i> keys, see {@link CBAdvertisementDataLocalNameKey} and other similar constants.
 *
 *  @seealso                    CBAdvertisementData.h
 *
 */

//扫描到了设备执行此方法
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //过滤规则
    NSLog(@"advertisementData - > %@ ->%@",advertisementData,RSSI);
    
    NSString *name = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    
    name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSData *BLEId = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    
    Byte *BLEStrs = (Byte *)[BLEId bytes];
    
    int Ble = 0;
    
    if (BLEStrs != nil)
    {
        if (BLEStrs[0] == 'S' && BLEStrs[1] == 'T' && BLEStrs[2] == 'W')
        {
            //检测到来自MAD的电子烟
            Ble = 1;
        }
        else
        {
            Ble = 0;
        }
    }
    
    if (Ble == 1 && name != nil)
    {
        //将获取所有外围蓝牙设备数据封装到扫描列表
        STW_BLEDevice *BLEDevice = [[STW_BLEDevice alloc]init];
        BLEDevice.peripheral = peripheral;
        BLEDevice.RSSI = RSSI;
        BLEDevice.advertisementData = advertisementData;
        BLEDevice.deviceName = name;
        BLEDevice.deviceMac = [NSString stringWithFormat:@"%d%d%d%d%d%d%d",BLEStrs[3],BLEStrs[4],BLEStrs[5],BLEStrs[6],BLEStrs[7],BLEStrs[8],VendorId];
        
        BLEDevice.deviceModel = BLEStrs[9];
        
        NSLog(@"BLEDevice.deviceModel - %d -%@",BLEDevice.deviceModel,BLEDevice.deviceMac);
        int n = 0;
        
        if(self.scanedDevices.count > 0)
        {
            for (int i = 0; i < self.scanedDevices.count; i++)
            {
                STW_BLEDevice *BLEDevice_arrrys = [self.scanedDevices objectAtIndex:i];
                if ([BLEDevice.deviceMac isEqualToString:BLEDevice_arrrys.deviceMac])
                {
                    n += 1;
                    break;
                }
            }
        }
        
        if(n == 0)
        {
            [self.scanedDevices addObject:BLEDevice];
            
            //延时发送扫描到了设备数据
            if(self.Service_scanHandler)
            {
                self.Service_scanHandler(BLEDevice);
            }
        }
    }
}
/*!
 *  @method centralManager:didConnectPeripheral:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has connected.
 *
 *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has succeeded.
 *
 */

//连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //结束蓝牙扫描
    [self scanStop];
    
    //开始发现服务
    [peripheral discoverServices:nil];
    
    //设置连接成功回调
    if(self.Service_connectedHandler)
    {
        self.isBLEStatus = YES;
        self.Service_connectedHandler();
    }
}

/*!
 *  @method centralManager:didFailToConnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has failed to connect.
 *  @param error        The cause of the failure.
 *
 *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has failed to complete. As connection attempts do not
 *                      timeout, the failure of a connection is atypical and usually indicative of a transient issue.
 *
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //    NSLog(@"didFailToConnectPeripheral");
}

/*!
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has disconnected.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method is invoked upon the disconnection of a peripheral that was connected by {@link connectPeripheral:options:}. If the disconnection
 *                      was not initiated by {@link cancelPeripheralConnection}, the cause will be detailed in the <i>error</i> parameter. Once this method has been
 *                      called, no more methods will be invoked on <i>peripheral</i>'s <code>CBPeripheralDelegate</code>.
 *
 */

//设备断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //设置蓝牙状态为断开
    //[TYZ_Session sharedInstance].check_BLE_status = 1;
    NSLog(@"断开的设备: %@-->\n%@", peripheral.name,peripheral);
    //蓝牙断开连接回调
    [self deleteBLE];
//    if(self.Service_disconnectHandler)
//    {
//        self.isBLEStatus = NO;
//        self.Service_disconnectHandler();
//    }
//    
//    if([STW_BLE_SDK STW_SDK].Update_Now == 1)
//    {
//        if (self.Service_Soft_Update)
//        {
//            self.Service_Soft_Update(0xEE);
//        }
//    }
}

-(void)deleteBLE
{
    if([STW_BLE_SDK STW_SDK].Update_Now == 1)
    {
        //设置为主动断开连接不重新连接
        [STW_BLEService sharedInstance].isBLEType = STW_BLE_IsBLETypeOff;
        
        if (self.Service_Soft_Update)
        {
            self.Service_Soft_Update(0xEE);
        }
    }
    
    //蓝牙断开连接回调
    if(self.Service_disconnectHandler)
    {
        self.isBLEStatus = NO;
        self.Service_disconnectHandler();
    }
}

#pragma mark  CBPeripheralDelegate
/*!
 *  @method peripheralDidUpdateName:
 *
 *  @param peripheral	The peripheral providing this update.
 *
 *  @discussion			This method is invoked when the @link name @/link of <i>peripheral</i> changes.
 */
//- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0);

/*!
 *  @method peripheralDidInvalidateServices:
 *
 *  @param peripheral	The peripheral providing this update.
 *
 *  @discussion			This method is invoked when the @link services @/link of <i>peripheral</i> have been changed. At this point,
 *						all existing <code>CBService</code> objects are invalidated. Services can be re-discovered via @link discoverServices: @/link.
 *
 *	@deprecated			Use {@link peripheral:didModifyServices:} instead.
 */
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral NS_DEPRECATED(NA, NA, 6_0, 7_0)
{
    //    NSLog(@"peripheralDidInvalidateServices");
}

/*!
 *  @method peripheral:didModifyServices:
 *
 *  @param peripheral			The peripheral providing this update.
 *  @param invalidatedServices	The services that have been invalidated
 *
 *  @discussion			This method is invoked when the @link services @/link of <i>peripheral</i> have been changed.
 *						At this point, the designated <code>CBService</code> objects have been invalidated.
 *						Services can be re-discovered via @link discoverServices: @/link.
 */
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices NS_AVAILABLE(NA, 7_0)
{
    //    NSLog(@"didModifyServices");
}

/*!
 *  @method peripheralDidUpdateRSSI:error:
 *
 *  @param peripheral	The peripheral providing this update.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link readRSSI: @/link call.
 *
 *  @deprecated			Use {@link peripheral:didReadRSSI:error:} instead.
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error NS_DEPRECATED(NA, NA, 5_0, 8_0)
{
//    NSLog(@"peripheralDidUpdateRSSI");
}

/*!
 *  @method peripheral:didReadRSSI:error:
 *
 *  @param peripheral	The peripheral providing this update.
 *  @param RSSI			The current RSSI of the link.
 *  @param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link readRSSI: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error NS_AVAILABLE(NA, 8_0)
{
    NSLog(@"didReadRSSI--读取设备信号 -- > %@ ->%@",RSSI,error);
    if(self.Service_RSSIHandler)
    {
        self.Service_RSSIHandler(RSSI);
    }
}

/*!
 *  @method peripheral:didDiscoverServices:
 *
 *  @param peripheral	The peripheral providing this information.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverServices: @/link call. If the service(s) were read successfully, they can be retrieved via
 *						<i>peripheral</i>'s @link services @/link property.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //蓝牙连接上之后执行的方法
    NSLog(@"开始设备服务！！！");
    
    int ChickUUID = 1;
    
    if (error)
    {
        NSLog(@"设备->%@ 出现错误->%@", peripheral.name, [error localizedDescription]);
        return;
    }
    for (CBService *service in peripheral.services)
    {
        //设备服务
        if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDDeviceService]])
        {
            [peripheral discoverCharacteristics:nil forService:service];
            
            ChickUUID = ChickUUID + 1;
        }
        if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDDeviceUpdateSoftService]])
        {
            [peripheral discoverCharacteristics:nil forService:service];
            
            ChickUUID = ChickUUID + 1;
        }
    }
    
    if(ChickUUID < 3)
    {
        NSLog(@"UUID出现错误--->拒绝服务，断开连接！");
        [self disconnect];
    }
    else
    {
        [STW_BLEService sharedInstance].isBLEStatus = YES;
    }
}

/*!
 *  @method peripheral:didDiscoverIncludedServicesForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the included services.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverIncludedServices:forService: @/link call. If the included service(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>includedServices</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    //    NSLog(@"didDiscoverIncludedServicesForService");
}

/*!
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the characteristic(s).
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
 */
//开始服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    //蓝牙对接成功 蓝牙状态改为已经连接
    [STW_BLEService sharedInstance].isBLEStatus = YES;
    
    if (error)
    {
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
//        NSLog(@"characteristic.UUID - %@",characteristic.UUID);
        
        //接收数据
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDDeviceData]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        //发送数据
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDDeviceSetup]])
        {
            [peripheral readValueForCharacteristic:characteristic];
            self.device.characteristic = characteristic;
        }
        //设置设备名字
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDDeviceName]])
        {
            characateristicDeviename = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
        }
        //发送soft Update第一包数据
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDDeviceSoftUpdatePage01]])
        {
            characateristicSoftUpdatePage01 = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
        }
        //发送soft Update bin文件数据
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDDeviceSoftUpdateBinPage]])
        {
            characateristicSoftUpdateBinPage = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
    
    double delayInSeconds = 0.2f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       //延时方法
                       if(self.Service_discoverCharacteristicsForServiceHandler)
                       {
                           //设备刚刚连接设备可以进行初始化查询等操作
                           self.Service_discoverCharacteristicsForServiceHandler();
                       }
                   });
}

/*!
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //蓝牙数据接收
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDDeviceData]])
    {
        NSLog(@"接收的数据 - > %@",characteristic.value);
        NSData *data = characteristic.value;
        
//        //解密
//        NSMutableData *datas = [self command_unlock:data];
        
//        NSLog(@"接收解密的数据 - > %@",datas);
        
        [self  build_bleData:data];
    }
}

//开始解析数据
- (void)build_bleData:(NSData*)ble_data
{
    //接收到的数据部分，数据加密在此解密
    NSMutableData *mdata = [NSMutableData dataWithData:ble_data];
    
    const unsigned char* bytes = [mdata bytes];
    
    if (bytes[0] == BLEProtocolHeader01)
    {
        //命令解析
        switch (bytes[1])
        {
            case STW_BLECommand001:           //设置蓝牙连接状态
            {
                //蓝牙状态
                NSLog(@"蓝牙状态更新");
            }
            break;
                
            case STW_BLECommand002:           //查询电池电量
            {
                if (bytes[3] == 0x00)
                {
                    if (self.Service_Battery)
                    {
                        self.Service_Battery(bytes[4]);
                    }
                }
            }
            break;
                
            case STW_BLECommand003:           //查询、设置输出功率
            {
                if (bytes[3] == 0x00)
                {
                    if (self.Service_Power)
                    {
                        self.Service_Power(bytes[4]*256 + bytes[5]);
                    }
                }
            }
            break;
                
            case STW_BLECommand004:           //查询、设置输出电压
            {
                if (bytes[3] == 0x00)
                {
                    if (self.Service_Voltage)
                    {
                        self.Service_Voltage(bytes[4]*256 + bytes[5]);
                    }
                }
            }
            break;
                
            case STW_BLECommand005:           //查询、设置输出温度
            {
                if (bytes[3] == 0x00)
                {
                    //温度值、温度单位
                    if (self.Service_Temp)
                    {
                        self.Service_Temp(bytes[5]*256 + bytes[6],bytes[4]);
                    }
                }
            }
            break;
                
            case STW_BLECommand006:           //雾化器信息
            {
                if (bytes[3] == 0x00)
                {
                    if(self.Service_AtomizerData)
                    {
                        int atomizerNum = bytes[4] * 256 + bytes[5];
                        int atomizerMold = bytes[6];
                        self.Service_AtomizerData(atomizerNum,atomizerMold);
                    }
//                    if (self.Service_Electricity)
//                    {
//                        self.Service_Electricity(bytes[4]*256 + bytes[5]);
//                    }
                }
            }
            break;
                
            case STW_BLECommand007:           //查询、设置工作模式
            {
                if (bytes[3] == 0x00 && bytes[10] != 0xA6)
                {
                    if(self.Service_AtomizerData)
                    {
                        int atomizerNum = [STW_BLE_SDK STW_SDK].atomizer;
                        int atomizerMold = bytes[8];
                        self.Service_AtomizerData(atomizerNum,atomizerMold);
                    }

                    switch (bytes[4])  
                    {
                        case BLEProtocolModeTypePower:
                        {
                            int power = bytes[5] * 256 + bytes[6];
                            
                            if (self.Service_Power)
                            {
                                self.Service_Power(power);
                            }
                        }
                            break;
                            
                        case BLEProtocolModeTypeVoltage:
                        {
                            int Voltage = bytes[5] * 256 + bytes[6];

                            if (self.Service_Voltage)
                            {
                                self.Service_Voltage(Voltage);
                            }
                        }
                            break;
                            
                        case BLEProtocolModeTypeTemperature:
                        {
                            int tempNum = bytes[5] * 256 + bytes[6];
                            int tempMold = bytes[7];
                            
                            if (self.Service_Temp)
                            {
                                self.Service_Temp(tempNum,tempMold);
                            }
                        }
                            break;
                            
                        case BLEProtocolModeTypeBypas:
                        {
                            if (self.Service_WorkMold_ByPass)
                            {
                                self.Service_WorkMold_ByPass();
                            }
                        }
                            break;
                            
                        case BLEProtocolModeTypeCustom:
                        {
                            int CustomMold = bytes[5];
                            
                            if (self.Service_WorkMold_Custom)
                            {
                                self.Service_WorkMold_Custom(CustomMold);
                            }
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                else if(bytes[3] == 0x00 && bytes[4] == 0x00 && bytes[10] == 0xA6)
                {
                    [STW_BLE_Protocol the_work_mode];
                }
            }
            break;
                
            case STW_BLECommand008:           //查询、设置雾化器
            {
                if (bytes[3] == 0x00)
                {
                    int resistance = bytes[4] * 256 + bytes[5];
                    int atomizerMold =  bytes[6];
                    int TCR = bytes[7];
                    int change_rate = bytes[8] * 256 + bytes[9];
                    int power = bytes[10] * 256 + bytes[11];
                    
                    if(TCR == 0x00)
                    {
                        change_rate = 50;
                    }
                    
                    if (self.Service_Atomizer)
                    {
                        self.Service_Atomizer(resistance,atomizerMold,TCR,change_rate,power);
                    }
                }
            }
            break;
                
            case STW_BLECommand009:           //查询所有配置信息
            {
                if (bytes[3] == 0x00)
                {
                    //返回所有配置信息
                    
                    //电池电量 bytes[4] - 返回电池信息回调
                    if (self.Service_Battery)
                    {
                        self.Service_Battery(bytes[4]);
                    }
                    
                    if(self.Service_AtomizerData)
                    {
                        int atomizerNum = bytes[9] * 256 + bytes[10];
                        int atomizerMold = bytes[11];
                        self.Service_AtomizerData(atomizerNum,atomizerMold);
                    }
                    
                    //工作模式
                    switch (bytes[5])
                    {
                        case BLEProtocolModeTypePower:
                        {
                            int power = bytes[6] * 256 + bytes[7];
                            
                            if (self.Service_Power)
                            {
                                self.Service_Power(power);
                            }
                        }
                            break;
                            
                        case BLEProtocolModeTypeVoltage:
                        {
                            int Voltage = bytes[6] * 256 + bytes[7];

                            if (self.Service_Voltage)
                            {
                                self.Service_Voltage(Voltage);
                            }
                        }
                            break;
                            
                        case BLEProtocolModeTypeTemperature:
                        {
                            int tempNum = bytes[6] * 256 + bytes[7];
                            int tempMold = bytes[8];
                            
                            if (self.Service_Temp)
                            {
                                self.Service_Temp(tempNum,tempMold);
                            }
                        }
                            break;
                            
                        case BLEProtocolModeTypeBypas:
                        {
                            if (self.Service_WorkMold_ByPass)
                            {
                                self.Service_WorkMold_ByPass();
                            }
                        }
                            break;
                            
                        case BLEProtocolModeTypeCustom:
                        {
                            int CustomMold = bytes[6];
                            if (self.Service_WorkMold_Custom)
                            {
                                self.Service_WorkMold_Custom(CustomMold);
                            }
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
            }
            break;
                
            case STW_BLECommand00A:           //发送抽烟状态
            {
                int vapor_status = bytes[3];
                
                [STW_BLE_Protocol the_smoking_status:0x00];
                
                if (self.Service_VaporStatus)
                {
                    self.Service_VaporStatus(vapor_status);
                }
            }
            break;
                
            case STW_BLECommand00B:           //查询离线信息
            {
                //暂时未实现
            }
            break;
                
            case STW_BLECommand00C:           //设置系统时间
            {
                int time_status = bytes[3];
                
                if (self.Service_SetTime)
                {
                    self.Service_SetTime(time_status);
                }
            }
            break;
                
            case STW_BLECommand00D:           //查询MCU工作状态
            {
                int MCUStatus = bytes[3];
                
                [STW_BLE_Protocol the_MCU_status:0x00];
                
                if (self.Service_MCUStatus)
                {
                    self.Service_MCUStatus(MCUStatus);
                }
            }
            break;
                
            case STW_BLECommand00E:           //激活设备
            {
                int ActivateDevice = bytes[3];
                
                if (self.Service_ActivateDevice)
                {
                    self.Service_ActivateDevice(ActivateDevice);
                }
            }
            break;
                
            case STW_BLECommand00F:           //APP运行状态
            {
                int background = bytes[3];
                
                if (self.Service_Background)
                {
                    self.Service_Background(background);
                }
            }
            break;
                
            case STW_BLECommand010:           //查询屏幕相关信息
            {
                if (bytes[3] == 0x00)
                {
                    int material = bytes[4];  //屏幕材质 0 - OLED  1 - LCD
                    int color = bytes[5];     //屏幕类型 0 - 单色   1 - 彩色
                    int weight = bytes[6];    //屏幕宽
                    int height = bytes[7];    //屏幕高
                    int type = bytes[8];      //取模类型
                    
                    if (self.Service_OLED_data)
                    {
                        self.Service_OLED_data(material,color,weight,height,type);
                    }
                }
            }
            break;
                
            case STW_BLECommand011:           //传输图片
            {
                if (bytes[3] == 0x00)
                {
                    int page_num = bytes[4] * 256 + bytes[5];
                    
                    if (self.Service_DownloadImage)
                    {
                        self.Service_DownloadImage(page_num);
                    }
                }
            }
            break;
                
            case STW_BLECommand012:           //设置抽烟输出曲线
            {
                /**
                 *  0xA1 代表正在设置电子烟
                 *  0xA2 代表正在查询电子烟
                 */
                if (bytes[3] == 0xA1)
                {
                    //设置电子烟
                    if(bytes[4] == 0x00)
                    {
                        int lineNum = bytes[5];
                        int pageNum = bytes[6];
                        
                        [STW_BLE_Protocol sendLinePowerData:lineNum :pageNum];
                    }
                    else if((bytes[4] == 0xFF))
                    {
                        NSLog(@"成功发送数据 - 回复最后一包");
                        
                    }
                }
                else if(bytes[3] == 0xA2)
                {
                    //查询电子烟
                    int arry_leng = bytes[2] - 8;
                    
                    int lineNum = bytes[5];
                    int pageNum = bytes[6];
                    
                    if(bytes[4] == 0x00)
                    {
                        NSMutableArray *A2_arrys = [NSMutableArray array];
                        
                        for (int i = 0; i < arry_leng; i++)
                        {
                            [A2_arrys addObject:[NSString stringWithFormat:@"%d",bytes[i + 7]]];
                        }
                        
                        if (self.Service_GetPowerLine)
                        {
                            self.Service_GetPowerLine(lineNum,pageNum,A2_arrys);
                        }
                    }
                    else if((bytes[4] == 0xFF))
                    {
                        NSLog(@"成功接收数据");
                    }
                }
            }
            break;
                
            case STW_BLECommand013:           //选择抽烟输出曲线
            {
                int curveBool = bytes[3];
                
                if (self.Service_ChoseCurve)
                {
                    self.Service_ChoseCurve(curveBool);
                }
            }
            break;
                
            case STW_BLECommand014:           //查询、设置操作方式
            {
                //存在歧义等待讨论
            }
            break;
                
            case STW_BLECommand015:           //设置计划口数
            {
                int planStatus = bytes[3];
                
                if (self.Service_SetPlan)
                {
                    self.Service_SetPlan(planStatus);
                }
            }
            break;
                
            case STW_BLECommand016:           //禁止抽烟、锁机
            {
                int lock = bytes[3];
                
                if (self.Service_LockDevice)
                {
                    self.Service_LockDevice(lock);
                }
            }
            break;
                
            case STW_BLECommand017:           // 开/关机
            {
                int root = bytes[3];
                
                if (self.Service_Root)
                {
                    self.Service_Root(root);
                }
            }
            break;
                
            case STW_BLECommand018:           //查询电池状态
            {
                if (bytes[3] == 0x00)
                {
                    int battery_num = bytes[4];                                 //电池节数
                    int battery_status = bytes[5];                              //电池状态  0 - 不在充电  1 - 在充电
                    int battery_chargingVoltage = bytes[6] * 256 + bytes[7];    //充电电压
                    int battery_chargingCurrent = bytes[8] * 256 + bytes[9];    //充电电流
                    int battery_Voltage01 = bytes[10] * 256 + bytes[11];        //第1节电池电压
                    int battery_Voltage02 = bytes[12] * 256 + bytes[13];        //第2节电池电压
                    int battery_Voltage03 = bytes[14] * 256 + bytes[15];        //第3节电池电压
                    
                    if (self.Service_BatteryStatus)
                    {
                        self.Service_BatteryStatus(battery_num, battery_status, battery_chargingVoltage, battery_chargingCurrent, battery_Voltage01, battery_Voltage02, battery_Voltage03);
                    }
                }
            }
            break;
                
            case STW_BLECommand019:           //查询实时输出信息 Real-time output
            {
                if (bytes[3] == 0x00)
                {
                    int RealTime_Atomizer = bytes[4] * 256 + bytes[5];
                    int RealTime_Power = bytes[6] * 256 + bytes[7];
                    int RealTime_Voltage = bytes[8] * 256 + bytes[9];
                    int RealTime_Temp = bytes[10] * 256 + bytes[11];
                    
                    if (self.Service_RealTimeOutput)
                    {
                        self.Service_RealTimeOutput(RealTime_Atomizer,RealTime_Power,RealTime_Voltage,RealTime_Temp);
                    }
                }
            }
            break;
                
            case STW_BLECommand01A:           //设置从机广播名字
            {
                if (bytes[2] == 0x05)
                {
                    int checkNum = bytes[3];
                    if (self.Service_SetDeviceName)
                    {
                        self.Service_SetDeviceName(checkNum);
                    }
                }
            }
            break;
                
            case STW_BLECommand01B:           //选择自定义温控模式  CustomTempModel
            {
                int CustomTempBool = bytes[3];
                if (self.Service_CustomTempModel)
                {
                    self.Service_CustomTempModel(CustomTempBool);
                }
            }
            break;
                
            case STW_BLECommand01C:           //设置查询温控模式下最大输出功率
            {
                //待讨论
            }
            break;
                
            case STW_BLECommand01D:           //传输PCB温度
            {
                if (bytes[3] == 0)
                {
                    int PCB_TempModel = bytes[4];
                    int PCB_Temp = bytes[5] * 256 + bytes[6];
                    
                    if (self.Service_PCB_Temp)
                    {
                        self.Service_PCB_Temp(PCB_TempModel,PCB_Temp);
                    }
                }
            }
            break;
                
            case STW_BLECommand01E:           //查询硬件设备信息
            {
                if (bytes[3] == 0)
                {
                    int Device_Version = bytes[4] * 256 + bytes[5];
                    int Soft_Version = bytes[6] * 256 + bytes[7];
                    
                    if (self.Service_Find_DeviceData)
                    {
                        self.Service_Find_DeviceData(Device_Version,Soft_Version);
                        NSLog(@"返回硬件版本:%@",mdata);
                    }
                }
            }
                break;
            case STW_BLECommand01F:           //传输当前下载包数
            {
                if (bytes[3] == 0)
                {
                    int pageNum = bytes[4] * 256 + bytes[5];
                    
                    if (self.Service_Soft_Update)
                    {
                        self.Service_Soft_Update(pageNum);
                    }
                }
                else if (bytes[3] == 0x88)
                {
                    //升级成功
                    if (self.Service_Soft_Update)
                    {
                        self.Service_Soft_Update(0x88);
                    }
                }
                else if (bytes[3] == 0xE1)
                {
                    int checkNums = 0;
                    int bytes5 = bytes[5];
                    
                    NSLog(@"bytes5 - %d",bytes5);
                    
                    switch (bytes5)
                    {
                        case 0x00:
                            checkNums = 0xE0;  //设备不匹配
                            
                            NSLog(@"设备不匹配");
                            break;
                        case 0x01:
                            checkNums = 0xE1;  //软件版本过低
                            NSLog(@"软件版版本过低");
                            break;
                        case 0x02:
                            checkNums = 0xE2;  //掉包过多
                             NSLog(@"掉包过多");
                            
                            break;
                            
                        default:
                            break;
                    }
                    
                    if (self.Service_Soft_Update)
                    {
                        self.Service_Soft_Update(checkNums);
                    }
                }
                else if(bytes[3] == 0xE8)
                {
                    int lost_page = bytes[4] * 256 + bytes[5];
                    //记录所丢失包数
                    [[STW_BLE_SDK STW_SDK].softUpdate_lostPage addObject:[NSString stringWithFormat:@"%d",lost_page]];
                }
                else if(bytes[3] == 0xF0)
                {
                    //发送一共丢失了多少包
                    int lowPage = bytes[4] * 256 + bytes[5];
                    
                    if(lowPage == [STW_BLE_SDK STW_SDK].softUpdate_lostPage.count)
                    {
                        if (self.Service_Soft_Update)
                        {
                            self.Service_Soft_Update(0xE8);
                        }
                    }
                }
                else if(bytes[3] == 0x87)
                {
                    //数据全部发送成功
                    if (self.Service_Soft_Update)
                    {
                        self.Service_Soft_Update(0x87);
                    }
                }
            }
                break;

            default:
                break;
        }
    }
}

//解析蓝牙返回的数据 0x00 - 0x1D


/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a {@link writeValue:forCharacteristic:type:} call, when the <code>CBCharacteristicWriteWithResponse</code> type is used.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //蓝牙数据发送
//    if (error)
//    {
//        NSLog(@"error.userInfo:%@",error.userInfo);
//        NSLog(@"发送数据失败->UUID:%@-\n失败数据->%@",characteristic.UUID,characteristic.value);
//    }
//    else
//    {
//        NSLog(@"发送数据成功->UUID:%@-\n成功数据->%@",characteristic.UUID,characteristic.value);
//    }
}

/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //    NSLog(@"didUpdateNotificationStateForCharacteristic");
}

/*!
 *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link discoverDescriptorsForCharacteristic: @/link call. If the descriptors were read successfully,
 *							they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //    NSLog(@"didDiscoverDescriptorsForCharacteristic");
}

/*!
 *  @method peripheral:didUpdateValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link readValueForDescriptor: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    //    NSLog(@"didUpdateValueForDescriptor");
}

/*!
 *  @method peripheral:didWriteValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link writeValue:forDescriptor: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    //    NSLog(@"didWriteValueForDescriptor");
}

//命令位加密
-(NSMutableData *)command_lock:(NSData *)unlockdata
{
    int data_leng = (int)unlockdata.length;
    
    NSMutableData *mdata = [NSMutableData dataWithData:unlockdata];
    const unsigned char* bytes = [mdata bytes];
    unsigned char buf[data_leng];
    
    for (int i = 0; i < data_leng; i++)
    {
        buf[i] = [self jiami:bytes[i] :KEY_COMMAND[i]];
    }
    
    NSMutableData *out_datas = [[NSMutableData alloc] init];
    [out_datas appendBytes:buf length:data_leng];
    
    return out_datas;
}

//命令位解密
-(NSMutableData *)command_unlock:(NSData *)lockdata
{
    int data_leng = (int)lockdata.length;
    
    NSMutableData *mdata = [NSMutableData dataWithData:lockdata];
    const unsigned char* bytes = [mdata bytes];
    unsigned char buf[data_leng];
    
    for (int i = 0; i < data_leng; i++)
    {
        buf[i] = [self jiemi:bytes[i] :KEY_COMMAND[i]];
    }
    
    NSMutableData *out_datas = [[NSMutableData alloc] init];
    [out_datas appendBytes:buf length:data_leng];
    
    return out_datas;
}

//加密 data_random 需要加密的数值：data_random 秘钥：data_key
-(int)jiami:(int)data_random :(int)data_key
{
    int nums = data_random;
    nums = [self decryption_random:nums :data_key];
    nums = [self decryption_rules_lock:nums];
    return nums;
}

//解密 data_random 需要解密的数值：data_random 秘钥：data_key
-(int)jiemi:(int)data_random :(int)data_key
{
    int nums = data_random;
    nums = [self decryption_rules_unlock:nums];
    nums = [self decryption_random:nums :data_key];
    return nums;
}

//加密/解密按字节异或随机数
-(int)decryption_random:(int)data_random :(int)data_key
{
    int nums = data_random;
    if (nums != 0x00 && nums != 0xFF && nums != data_key && (nums ^ data_key) != 0xFF)
    {
        nums =  data_random ^ data_key;
    }
    return nums;
}

//加密倒置0x01 - 0xFF
-(int)decryption_rules_lock:(int)data_rules
{
    int nums = 0x00;
    
    if (data_rules == 0x00 || data_rules == 0x40 || data_rules == 0x80 || data_rules == 0xc0)
    {
        //0x80 0x00不需要操作
        nums = data_rules;
    }
    else if(data_rules > 0x00 && data_rules < 0x40)
    {
        nums = data_rules + 0x80;
    }
    else if(data_rules > 0x40 && data_rules < 0x80)
    {
        nums = data_rules + 0x80;
    }
    else if(data_rules > 0x80 && data_rules < 0xc0)
    {
        nums = data_rules - 0x40;
    }
    else
    {
        //data_rules > 0xc0
        nums = data_rules - 0xc0;
    }
    
    return nums;
}

//解密倒置0x01 - 0xFF
-(int)decryption_rules_unlock:(int)data_rules
{
    int nums = 0x00;
    
    if (data_rules == 0x00 || data_rules == 0x40 || data_rules == 0x80 || data_rules == 0xc0)
    {
        //0x80 0x00不需要操作
        nums = data_rules;
    }
    else if(data_rules > 0x00 && data_rules < 0x40)
    {
        nums = data_rules + 0xc0;
    }
    else if(data_rules > 0x40 && data_rules < 0x80)
    {
        nums = data_rules + 0x40;
    }
    else if(data_rules > 0x80 && data_rules < 0xc0)
    {
        nums = data_rules - 0x80;
    }
    else
    {
        //data_rules > 0xc0
        nums = data_rules - 0x80;
    }
    
    return nums;
}


//设置设备名字的方法(修改)
-(void)setDeviceNname:(NSData *)namedata
{
    NSLog(@"修改的设备名字%@",namedata);
    [self.device.peripheral writeValue:namedata forCharacteristic:characateristicDeviename type:CBCharacteristicWriteWithResponse];
}

@end
