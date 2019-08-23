//
//  PowerLineViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/18.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "PowerLineViewController.h"
#import "PowerLineCell.h"
#import "DrawingPowerLineViewController.h"
#import "PowerLineDrawingCellView.h"
#import "TYZFileData.h"
#import "ProgressHUD.h"
#import "STW_BLE_SDK.h"
#import "STW_BLE_Protocol.h"
#import "InternationalControl.h"
@implementation PowerLineViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //刷新列表
    [self.tableview reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [InternationalControl return_string:@"Custom_bar_powerLine"];

    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 114.0f) style:UITableViewStylePlain];
    
    self.tableview.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableview];
    
    //设置UItableView
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.tableFooterView=[[UIView alloc]init];//关键语句
    //无分割线
    self.tableview.separatorStyle = UITableViewCellSelectionStyleNone;
//    //设置右边button 
//    UIButton *setButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-20, 5, 20, 20)];
//    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:setButton];
//    
//    [setButton setBackgroundImage:[UIImage imageNamed:@"icon_add_power_line"] forState:UIControlStateNormal];
//    
//    [setButton addTarget:self action:@selector(clickSetBtn) forControlEvents:UIControlEventTouchDown];
}

//-(void)clickSetBtn
//{
//    //跳转画线界面
////    //返回
////    [self dismissViewControllerAnimated:YES completion:^{
////        NSLog(@"已经销毁");
////    }];
//    
//    //跳转
//    UIViewController *view = [[DrawingPowerLineViewController alloc]init];
//    
//    [self presentViewController:view animated:YES completion:^{
//        NSLog(@"展示完毕");
//    }];
//
//    
//    NSLog(@"set");
//}

#pragma tyz - Table View
//[tableview reloadData];   //刷新列表

//设置一共有多少个Sessiion，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

//设置每个Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200;
}

//设置一共有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

//TableView数据加载执行的方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *Cell = @"PowerLineCell";
    PowerLineCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
    if (!cell)
    {
        //从xlb加载内容
        cell = [[[NSBundle mainBundle] loadNibNamed:Cell owner:nil options:nil] lastObject];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    //设置圆角
    cell.powerLineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
    cell.powerLineView.layer.cornerRadius = 10.0f;
    [cell.powerLineView.layer setMasksToBounds:YES];
    
//    cell.btn_edit.titleLabel.text = [InternationalControl return_string:@"Custom_PowerLine_editor"];
    [cell.btn_edit setTitle:[InternationalControl return_string:@"Custom_PowerLine_editor"] forState:UIControlStateNormal];
//    cell.btn_use.titleLabel.text = [InternationalControl return_string:@"Custom_PowerLine_use"];
    [cell.btn_use setTitle:[InternationalControl return_string:@"Custom_PowerLine_use"] forState:UIControlStateNormal];
 
    //设置头部logo
    NSString *image_str = [NSString stringWithFormat:@"icon_custom0%d",(int)indexPath.row + 1];
    cell.image_logo.image = [UIImage imageNamed:image_str];
    
    //曲线名称
    NSString *lable_str = [NSString stringWithFormat:@"Custom - %d",(int)indexPath.row + 1];
    cell.lable_line_name.text = lable_str;
    
    //设置曲线图表数据
    float view_width = SCREEN_WIDTH - 70 - 16;
    float view_height = 130;
    
    //画图板宽
    float drawingViewWidth = view_width - 20;
    
    //画图板高
    float drawingViewHeight = view_height;
    
    int width_box = drawingViewWidth / 22;
    int height_box = drawingViewHeight / 11;
    
    //选择单个方框边长
    int width_drawingViewBox = 0;
    int height_drawingViewBox = 0;
    
    
    width_drawingViewBox =  width_box;
    
    height_drawingViewBox = height_box;
    
    
    int drawingWidth = width_drawingViewBox * 22;
    int drawingHeight = height_drawingViewBox * 11;
    
    CGRect framebg = CGRectMake(((view_width - drawingWidth) /2),(view_height - drawingHeight + 50),drawingWidth,drawingHeight);
    
    int arry_type = (int)indexPath.row + 1;
    
    NSMutableArray *setArrys = [NSMutableArray array];
    
    //取出本地数据
    setArrys = [TYZFileData GetPowerLineData:arry_type];
    
    PowerLineDrawingCellView *cellPowerView = [[PowerLineDrawingCellView alloc] initWithFrame:framebg :width_drawingViewBox :height_drawingViewBox :arry_type :setArrys];
    
    [cell.powerLineView addSubview:cellPowerView];

   
    //添加按钮点击事件
    cell.btn_edit.tag = indexPath.row;
    cell.btn_use.tag = indexPath.row;
    
    [cell.btn_edit addTarget:self action:@selector(btn_edit_onclick:) forControlEvents:UIControlEventTouchDown];
    [cell.btn_use addTarget:self action:@selector(btn_use_onclick:) forControlEvents:UIControlEventTouchDown];
    
    return cell;
}

//编辑按钮点击事件
-(void)btn_edit_onclick:(id)sender
{
    NSInteger check_btn = [sender tag];
    
    NSLog(@"编辑 - %d",(int)check_btn);
    
    DrawingPowerLineViewController *view = [[DrawingPowerLineViewController alloc]init];
    
    view.ArryType = (int)check_btn + 1;
    
    [self presentViewController:view animated:YES completion:^{
        NSLog(@"展示完毕");
    }];

}
//使用按钮点击事件
-(void)btn_use_onclick:(id)sender
{
    [ProgressHUD show:nil];
    
    if([STW_BLEService sharedInstance].isBLEStatus)
    {
        NSInteger check_btn = [sender tag];
        
        NSLog(@"曲线 - %d",(int)check_btn + 1);
        
        //发送曲线数据
        int lineNum = (int)check_btn + 1;
        //获取本地数据
        NSMutableArray *linePowerArrys = [TYZFileData GetPowerLineData:lineNum];
        
        if (linePowerArrys.count == 23)
        {
            NSLog(@"数据存在可以发送");
            //调用发送方法
            [STW_BLE_Protocol sendLinePowerData01:lineNum :0x00 :4 :21 :linePowerArrys];
            [ProgressHUD showSuccess:nil];
            
            double delayInSeconds = 0.1f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                           {
                               if(lineNum > 0 && lineNum <= 3)
                               {
                                   //切换自定模式
                                   [STW_BLE_Protocol the_work_mode_custom:lineNum];
                               }
                           });
        }
        else
        {
//            [ProgressHUD showError:@"曲线数据错误"];
            [ProgressHUD showError:[InternationalControl return_string:@"Custom_PowerLine_dataa_rror"]];
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

- (void)didReceiveMemoryWarning
{
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
