//
//  MyVapeViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "MyVapeViewController.h"
#import "MyDeviceCell.h"
#import "ProgressHUD.h"
#import "User.h"
#import "Session.h"
#import "Device.h"
#import "MJExtension.h"
#import "TYZFileData.h"
#import "STW_BLE_SDK.h"
#import "MLTableAlert.h"
#import "InternationalControl.h"
#import "MLTableAlert.h"

@interface MyVapeViewController ()
{
    NSMutableArray *deviceArray;
}

@end

@implementation MyVapeViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //网络获取设备信息
    [self getDevicesList];
    //获取设备延时刷新
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //My_Device - 我的设备
    self.title = [InternationalControl return_string:@"My_Device"];
    
    //添加左侧按钮
    [self addButtonView];
    
    //设置TableView
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 114.0f) style:UITableViewStyleGrouped];
    
    self.tableview.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableview];
    
    //在设置UItableView
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.tableFooterView=[[UIView alloc]init];//关键语句
    //无分割线
    //    self.tableview.separatorStyle = UITableViewCellSelectionStyleNone;
    
    //在viewDidLoad设置tableview分割线
    [self.tableview setSeparatorColor:[UIColor darkGrayColor]];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

-(void)addButtonView
{
    //设置右边button
    UIButton *setButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-28, 5, 28, 28)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:setButton];
    
    [setButton setBackgroundImage:[UIImage imageNamed:@"icon_add_device"] forState:UIControlStateNormal];
    
    [setButton addTarget:self action:@selector(clickSetBtn) forControlEvents:UIControlEventTouchDown];
}

//扫描到设备的回调
-(void)Service_scanHandler
{
    [STW_BLEService sharedInstance].Service_scanHandler = ^(STW_BLEDevice *device)
    {
        [ProgressHUD dismiss];
    
        //弹出选择框让用户进行选择
        [self showalert:device];
    };
}

-(void)showalert:(STW_BLEDevice *)device
{
    NSLog(@"绑定扫描 - %@",device.deviceName);
    
    if(self.alert == nil)
    {
        self.alert = [[MLTableAlert alloc] initWithTitle:[InternationalControl return_string:@"My_device_scan_list"] cancelButtonTitle:[InternationalControl return_string:@"window_cancle"]];
        self.alert.cells = ^UITableViewCell* (MLTableAlert *anAlert, NSIndexPath *indexPath)
        {
            static NSString *CellIdentifier = @"CellIdentifier";
            
            UITableViewCell *cell = [anAlert.table dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            STW_BLEDevice *dev = [[STW_BLEService sharedInstance].scanedDevices objectAtIndex:indexPath.row];
            
            cell.textLabel.text =[NSString stringWithFormat:@"%@",dev.deviceName];
            
            return cell;
        };
        
        self.alert.height = 290;
        
        [self.alert configureSelectionBlock:^(NSIndexPath *indexPath)
         {
             NSLog(@"dev - %d",(int)indexPath.row);
             
             STW_BLEDevice *dev = [[STW_BLEService sharedInstance].scanedDevices objectAtIndex:indexPath.row];
             
             NSLog(@"dev - %@",dev.deviceName);
             
             //如果用户存在就添加设备
             if ([Session sharedInstance].user)
             {
                 //绑定设备
                 [self addDvice:dev];
             }
             self.alert = nil;
         }
         andCompletionBlock:^
         {
             self.alert = nil;
         }];
        self.alert.numberOfRows = ^NSInteger (NSInteger section)
        {
            return [STW_BLEService sharedInstance].scanedDevices.count;
        };
        [self.alert show];
    }
    [self.alert.table reloadData];
}

-(void)clickSetBtn
{
    [ProgressHUD show:nil];
    
    //扫描到设备的回调
    [self Service_scanHandler];
    
    //开始蓝牙扫描
    [[STW_BLEService sharedInstance] scanStart];
    
    //5秒钟没有扫描到设备判定扫描失败
    [self performSelector:@selector(stop_scan) withObject:nil afterDelay:5.0f];
}

- (void)stop_scan
{
    if([STW_BLEService sharedInstance].scanedDevices.count < 1)
    {
        [ProgressHUD dismiss];
        
        [ProgressHUD showWarning:[InternationalControl return_string:@"My_device_no_scan"]];
//        [ProgressHUD showWarning:@"没有扫描到设备"];
    }
    
    //结束扫描蓝牙
    [[STW_BLEService sharedInstance] scanStop];
}


#pragma tyz - Table View
//[tableview reloadData];   //刷新列表

//设置一共有多少个Sessiion，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

//设置每个Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

//设置一共有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return deviceArray.count;
}

//TableView数据加载执行的方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"MyDeviceCell";
    MyDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell)
    {
        //从xlb加载内容
        cell = [[[NSBundle mainBundle] loadNibNamed:ID owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]]; //icon_navigationbar
    }
    
    NSString *str_title = [InternationalControl return_string:@"My_device_lable"];//@"设备名:";
    NSString *str_data = [InternationalControl return_string:@"My_device_nums"];//@"序列号:";
    
    Device *devices = [deviceArray objectAtIndex:indexPath.row];
    cell.lableTitleView.text = [NSString stringWithFormat:@"%@%@",str_title,devices.name];
    cell.lableData.text = [NSString stringWithFormat:@"%@%@",str_data,devices.address];
    
    return cell;
}

//点击某个CEll执行的方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //cell被点击之后效果消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"-->第%d行",(int)indexPath.row);
}

//Cell删除tite
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [InternationalControl return_string:@"window_delete"];
}
//Cell删除方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Device *devices = [deviceArray objectAtIndex:indexPath.row];
        [self delectDevice:devices.address];
        
        // 1. 删除self.dataList中indexPath对应的数据
        [deviceArray removeObjectAtIndex:indexPath.row];

        // 2. 刷新表格(重新加载数据)
        //     重新加载所有数据
        //     [self.tableView reloadData];
        [self.tableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

/******************分割线对齐左右两端*****************/
-(void)viewDidLayoutSubviews {
    
    if ([self.tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableview setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableview respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableview setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
/*************************************************/

//查询设备列表
-(void)getDevicesList
{
    [ProgressHUD show:nil];
    NSString *string = [NSString stringWithFormat:@"%d",[Session sharedInstance].user.uid];
    [User devicesList:string success:^(id data)
     {
         [ProgressHUD showSuccess:nil];
         
         //将字典数组转为Device模型数组
         deviceArray = [Device mj_objectArrayWithKeyValuesArray:data];
         [Session sharedInstance].deviceArrys = [Device mj_objectArrayWithKeyValuesArray:data];;
         
         //保存网络数据到本地
         [TYZFileData SaveDeviceData:deviceArray];
         
         //刷新列表
         [self.tableview reloadData];
         [ProgressHUD dismiss];
     }
     failure:^(NSString *message)
     {
         //My_device_NoBinding - 没有绑定设备
         [ProgressHUD showError:[InternationalControl return_string:@"My_device_NoBinding"]];
         //没有绑定的设备
         [Session sharedInstance].deviceArrys = [NSMutableArray array];
         //保存网络数据到本地
         [TYZFileData SaveDeviceData:[Session sharedInstance].deviceArrys];
     }];
}

//解绑设备
-(void)delectDevice:(NSString *)devicemac
{
    [User delectDevice:devicemac success:^(id data)
     {
         NSString *string;
         
         string = [NSString stringWithFormat:@"%@",[data objectForKey:@"message"]];
         
         if ([string isEqualToString:@"1"])
         {
             //My_device_DeleteBinding - 解绑成功
             [ProgressHUD showSuccess:[InternationalControl return_string:@"My_device_DeleteBinding"]];
             [self getDevicesList];
         }
         else
         {
             //解绑失败,请查看您的网络连接! - My_device_DeleteError
             [ProgressHUD showError:[InternationalControl return_string:@"My_device_DeleteError"]];
             [ProgressHUD show:nil];
             [self getDevicesList];
         }
     }
               failure:^(NSString *message)
     {
         [ProgressHUD showError:message];
     }];
}

//增加设备
-(void)addDvice:(STW_BLEDevice *)devices
{
    NSLog(@"string - %@",devices.deviceMac);
    [User addDevice:devices.deviceMac :devices.deviceName success:^(id data)
     {
         NSString *string;
         string = [NSString stringWithFormat:@"%@",[data objectForKey:@"message"]];
         
         if ([string isEqualToString:@"1"])
         {
             [ProgressHUD showSuccess:nil];
             [self getDevicesList];
         }
         else
         {
             //My_device_BindingFailure - 设备已经被绑定
             [ProgressHUD showError:[InternationalControl return_string:@"My_device_BindingFailure"]];
         }
     }
     failure:^(NSString *message)
     {
         
//         [ProgressHUD showError:@"绑定失败，请检查您的网络设置"];
         [ProgressHUD showError:[InternationalControl return_string:@"My_device_BindingError"]];
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
