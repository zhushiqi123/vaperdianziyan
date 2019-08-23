//
//  MyMessageViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "MyMessageViewController.h"
#import "InternationalControl.h"
#import "MyMessageTableViewCell.h"
#import "DB_Sqlite3.h"
#import "JPushMessage.h"
#import "UIImageView+WebCache.h"
#import "MessageUrlViewController.h"
#import "MJRefresh.h"
#import "ProgressHUD.h"

@interface MyMessageViewController ()
{
    int table_View_num;
    NSMutableArray *table_arrays;
}

@end

@implementation MyMessageViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
    
    //加载数据库数据
    //分页初始化查询 - table_View_num 页数
    table_View_num = 1;
    table_arrays = [self findDataToSql:table_View_num];
    [self.tableview reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.title = @"我的消息";
    //************ 设置导航栏以及背景 ************
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    //去掉返回按钮上的文字
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    //改变返回按钮颜色为白色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //设置电池为白色
    [self preferredStatusBarStyle];
    //设置导航栏背景图片
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_fooder"]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //************ 设置导航栏以及背景结束 *********
    self.view.backgroundColor = RGBCOLOR(0xF9, 0xF9,0xF9);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = [InternationalControl return_string:@"My_friend_message"];
    
    //设置TableView
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0,66.0f, SCREEN_WIDTH, SCREEN_HEIGHT - 66.0f) style:UITableViewStylePlain];
    
    self.tableview.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableview];
    
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.tableFooterView=[[UIView alloc]init];//关键语句
    
    //在viewDidLoad设置tableview分割线
    [self.tableview setSeparatorColor:RGBCOLOR(0xE6, 0xE6,0xE6)];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    //设置下拉刷新上拉加载
     __unsafe_unretained UITableView *tableView = self.tableview;
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //下拉刷新操作
        table_View_num = 1;
        table_arrays = [self findDataToSql:table_View_num];
        
        // 模拟2秒延迟加载数据
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [tableView.mj_header endRefreshing];
            //刷新列表
            [self.tableview reloadData];
        });
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用
        table_View_num = table_View_num + 1;
        NSMutableArray *arry_low = [self findDataToSql:table_View_num];
        
        if (arry_low.count > 0)
        {
            int nums_a = (int)table_arrays.count;
            
            [table_arrays addObjectsFromArray:arry_low];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 结束刷新
                [tableView.mj_footer endRefreshing];
                
                NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                
                //插入新的数据列表
                for (int i = 0; i < arry_low.count; i++)
                {
                    NSIndexPath *indexpath =  [NSIndexPath indexPathForRow:(nums_a + i) inSection:0];
                    
                    [indexPaths addObject:indexpath];
                }
                
                [self.tableview insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
                
                float height = SCREEN_HEIGHT - 66.0f;
                
                int arry_nums_height = height/100;
                
                if (arry_low.count < arry_nums_height)
                {
                    [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(table_arrays.count - arry_nums_height - 1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
                else
                {
                    [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(nums_a - 1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            });
        }
        else
        {
//            [ProgressHUD showError:@"没有更多的数据"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 结束刷新
                [tableView.mj_footer endRefreshing];
            });
        }
    }];
    
    //设置右边button 刷新按钮
    UIButton *setButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-20, 5, 20, 20)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:setButton];
    
    [setButton setBackgroundImage:[UIImage imageNamed:@"icon_set"] forState:UIControlStateNormal];
    
    [setButton addTarget:self action:@selector(clickSetBtn) forControlEvents:UIControlEventTouchDown];
}

#pragma tyz - Table View

//设置一共有多少个Sessiion，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//设置每个Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

//设置一共有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return table_arrays.count;
}

//TableView数据加载执行的方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //MyMessageTableViewCell
    static NSString *MessageTableViewCell = @"MyMessageTableViewCell";
    MyMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageTableViewCell];
    if (!cell)
    {
        //从xlb加载内容
        cell = [[[NSBundle mainBundle] loadNibNamed:MessageTableViewCell owner:nil options:nil] lastObject];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    int cell_height = cell.lable_message.frame.size.height / 15;
    
    cell.lable_message.numberOfLines = cell_height;
    cell.lable_message.numberOfLines = 3;
    cell.lable_message.textAlignment = NSTextAlignmentLeft;
    
    JPushMessage *jpushMsg = table_arrays[indexPath.row];
    
    cell.lable_title.text = jpushMsg.notice_title;
    cell.lable_message.text = jpushMsg.notice_text;
//    cell.lable_time.text = jpushMsg.notice_time;
    
//    if (jpushMsg.notice_status == 0)
//    {
//        cell.backgroundColor = [UIColor clearColor];
//    }
//    else
//    {
//        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
//    }

    [cell.image_message sd_setImageWithURL:[NSURL URLWithString:jpushMsg.image_url]
                          placeholderImage:[UIImage imageNamed:@"icon_add_power_line"]];
    
    return cell;
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

//点击某个CEll执行的方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell被点击之后效果消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MessageUrlViewController *view = [[MessageUrlViewController alloc] init];
    
    view.jpMsg = table_arrays[indexPath.row];
    
    if (view.jpMsg.notice_status == 0)
    {
        view.jpMsg.notice_status = 1;
        [DB_Sqlite3 UpdateData_JPushMsg:view.jpMsg];
        
        //发送刷新的消息
        [[NSNotificationCenter defaultCenter] postNotificationName:@"freshJPushMessage" object:nil userInfo:nil];
    }
    
    [self.navigationController pushViewController:view animated:YES];
}

/**
 *  分页查询
 *
 *  @param pageNum 页数
 *
 */
-(NSMutableArray *)findDataToSql:(int)pageNum
{
    table_View_num = pageNum;
    return [DB_Sqlite3 FindData_JPushMsg:table_View_num];
}

//右上角设置按钮
-(void)clickSetBtn
{
    //设置界面
    NSLog(@"音量设置");
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
