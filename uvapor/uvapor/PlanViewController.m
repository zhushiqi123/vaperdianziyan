//
//  PlanViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/13.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "PlanViewController.h"
#import "PlanTableViewCell.h"
#import "PlanLineTableViewCell.h"
#import "Session.h"
#import "ProgressHUD.h"
#import "Record_month.h"
#import "MJExtension.h"
#import "AlertViewInputBoxView.h"
#import "User.h"
#import "InternationalControl.h"

@interface PlanViewController ()
{
    int onOff_status;
}

@end

@implementation PlanViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ProgressHUD dismiss];
    [self.tableview reloadData];
    
    self.title = [InternationalControl return_string:@"tabBar_Plan"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [InternationalControl return_string:@"tabBar_Plan"];
    
    //初始化
    onOff_status = 1;
    
    // Do any additional setup after loading the view.
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 114.0f) style:UITableViewStylePlain];
    
    self.tableview.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableview];
    
    //设置UItableView
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.tableFooterView=[[UIView alloc]init];//关键语句
    //无分割线
    self.tableview.separatorStyle = UITableViewCellSelectionStyleNone;
    
    //设置右边button 刷新按钮
    UIButton *setButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-20, 5, 20, 20)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:setButton];
    
    [setButton setBackgroundImage:[UIImage imageNamed:@"icon_refresh"] forState:UIControlStateNormal];
    
    [setButton addTarget:self action:@selector(clickSetBtn) forControlEvents:UIControlEventTouchDown];
    
    if ([Session sharedInstance].user.cellphone.length > 0)
    {
        //获取计划
        [self getPlanData];
        //查询网络信息
        [self getMonthData];
    }
}

-(void)clickSetBtn
{
    if ([Session sharedInstance].user.cellphone.length > 0)
    {
        NSLog(@"刷新");

        //获取计划
        [self getPlanData];
        //查询网络信息
        [self getMonthData];
    }
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
    if (indexPath.row == 0)
    {
        return 150;
    }
    else
    {
        return 250;
    }
}

//设置一共有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

//TableView数据加载执行的方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        static NSString *Cell = @"PlanTableViewCell";
        PlanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
        if (!cell)
        {
            //从xlb加载内容
            cell = [[[NSBundle mainBundle] loadNibNamed:Cell owner:nil options:nil] lastObject];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        //设置圆角
        cell.plan_view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
        cell.plan_view.layer.cornerRadius = 10.0f;
        [cell.plan_view.layer setMasksToBounds:YES];
        
        //名称
//        NSString *lable_str = [NSString stringWithFormat:@"当前吸烟口数: %lu口",(unsigned long)[Session sharedInstance].total];
        NSString *lable_str = [NSString stringWithFormat:@"%@: %lu ",[InternationalControl return_string:@"Plan_lable01_title"],(unsigned long)[Session sharedInstance].total];
        
        cell.lable_plan_name.text = lable_str;
        
//        cell.lable_plan_title.text = @"计划设置";
        cell.lable_plan_title.text = [InternationalControl return_string:@"Plan_lable01_planText"];
        
        //添加按钮点击事件
        cell.btn_plan_onOff.tag = indexPath.row;
        cell.btn_plan_nums.tag = indexPath.row;
        
        [cell.btn_plan_nums setTitle:[NSString stringWithFormat:@"%d",[Session sharedInstance].smokeCount] forState:UIControlStateNormal];
        
        if (onOff_status == 0)
        {
            [cell.btn_plan_onOff setBackgroundImage:[UIImage imageNamed:@"switch_off"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.btn_plan_onOff setBackgroundImage:[UIImage imageNamed:@"switch_on"] forState:UIControlStateNormal];
        }
        
        [cell.btn_plan_onOff addTarget:self action:@selector(btn_plan_onOff_onclick:) forControlEvents:UIControlEventTouchDown];
        [cell.btn_plan_nums addTarget:self action:@selector(btn_plan_nums_onclick:) forControlEvents:UIControlEventTouchDown];
        
        return cell;
    }
    else
    {
        static NSString *Cell = @"PlanLineTableViewCell";
        PlanLineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
        if (!cell)
        {
            //从xlb加载内容
            cell = [[[NSBundle mainBundle] loadNibNamed:Cell owner:nil options:nil] lastObject];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        //设置圆角
        cell.record_view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
        cell.record_view.layer.cornerRadius = 10.0f;
        [cell.record_view.layer setMasksToBounds:YES];
        
        switch (indexPath.row)
        {
            case 1:
            {
                //名称 - 折线图
//                NSString *lable_str = @"吸烟记录曲线图";

                NSString *lable_str = [InternationalControl return_string:@"Plan_lable02_title"];
                
                cell.lable_record.text = lable_str;
                
                [cell configUI:SCChartLineStyle];

                cell.record_imageView.image = [UIImage imageNamed:@"icon_LineChart"];
            }
                break;
            case 2:
            {
                //名称 - 柱状图
//                NSString *lable_str = @"吸烟记录条形图";
                
                NSString *lable_str = [InternationalControl return_string:@"Plan_lable03_title"];
                
                cell.lable_record.text = lable_str;
                
                [cell configUI:SCChartBarStyle];
                
                cell.record_imageView.image = [UIImage imageNamed:@"icon_plan_lineChart"];
            }
                break;
            case 3:
            {
                //名称 圆环图
//                NSString *lable_str = @"吸烟习惯分析";
                NSString *lable_str = [InternationalControl return_string:@"Plan_lable04_title"];
                cell.lable_record.text = lable_str;
                
                [cell configUI:SCPieChartStyle];
                
                cell.record_imageView.image = [UIImage imageNamed:@"icon_PieChart"];
            }
                break;
                
            default:
                break;
        }
        
        return cell;
    }
}

//编辑按钮点击事件
-(void)btn_plan_onOff_onclick:(id)sender
{
    if (onOff_status == 0)
    {
        onOff_status = 1;
    }
    else
    {
        onOff_status = 0;
    }
    
    [_tableview reloadData];   //刷新列表
}
//使用按钮点击事件
-(void)btn_plan_nums_onclick:(id)sender
{
    NSInteger check_btn = [sender tag];
    
    int num = (int)check_btn;
 
    switch (num)
    {
        case 0:
        {
            NSLog(@"输入预设口数");
            //设置计划口数
            AlertViewInputBoxView* view = [[[NSBundle mainBundle] loadNibNamed:@"AlertViewInputBoxView" owner:self options:nil] lastObject];
            
//            [view showViewWith:@"请输入预设口数" :UIKeyboardTypeNumberPad];
            [view showViewWith:[InternationalControl return_string:@"Plan_lable01_planWindow_title"] :UIKeyboardTypeNumberPad];
            
            view.AlertViewBackString = ^(NSString *backString)
            {
                NSLog(@"backString - %@",backString);
                //上传口数
                if ([Session sharedInstance].user)
                {
                    if ([backString intValue] >= 0 && [backString intValue] <= 999)
                    {
                        [User somkePlan:[backString intValue] price:100 smokemouth:70 success:^(id data)
                         {
//                             [ProgressHUD showSuccess:@"设置成功"];
                             [ProgressHUD showSuccess:[InternationalControl return_string:@"Plan_lable01_planWindow_success"]];
                             
                             [self clickSetBtn];
                             //                        NSLog(@"data - %@",data);
                         }
                         failure:^(NSString *message)
                         {
                             //Custom_Update_netWork_Error
//                             [ProgressHUD showError:@"网络错误"];
                             [ProgressHUD showError:[InternationalControl return_string:@"Custom_Update_netWork_Error"]];
                         }];
                    }
                    else
                    {
//                        [ProgressHUD showError:@"参数错误"];
                        [ProgressHUD showError:[InternationalControl return_string:@"Plan_lable01_planWindow_error"]];
                    }
                }
                else
                {
                    //Vapor_login_warning
//                    [ProgressHUD showError:@"请先登录"];
                    [ProgressHUD showError:[InternationalControl return_string:@"Vapor_login_warning"]];
                }
            };
        }
            break;
            
        default:
            break;
    }
}

//获得图表显示月记录
-(void)getMonthData
{
    if ([Session sharedInstance].user)
    {
        //查询网络信息
        [User getRecordData:@"month" success:^(id data)
         {
//             NSLog(@"图表显示Month:%@",data);
             [Session sharedInstance].recordMouthArrys = [Record_month mj_objectArrayWithKeyValuesArray:data];
             
             [self.tableview reloadData];
         }
        failure:^(NSString * message)
         {
//             NSLog(@"message - %@",message);
         }];
    }
}

//获取计划信息
-(void)getPlanData
{
    [User readSomkePlan:^(id data)
    {
//        NSLog(@"计划吸烟口数：%@",data);
        if(data != NULL)
        {
            [Session sharedInstance].smokeCount = [[data objectForKey:@"my_mouth"]intValue];
        }
    } failure:^(NSString *message) {
        //        [ProgressHUD show:nil];
        //        [ProgressHUD showError:[[InternationalControl bundle] localizedStringForKey:@"error_message" value:nil table:@"Localizable"]];
    }];
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
