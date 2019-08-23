//
//  LOGOViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/18.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "LOGOViewController.h"
#import "LogoTableViewCell.h"
#import "DrawingLOGOViewController.h"
#import "LogoClass.h"

@interface LOGOViewController ()

@end

@implementation LOGOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *strings = @"LOGO";
    self.title = strings;
    
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
    
    [setButton setBackgroundImage:[UIImage imageNamed:@"icon_add_drawing"] forState:UIControlStateNormal];
    
    [setButton addTarget:self action:@selector(clickSetBtn) forControlEvents:UIControlEventTouchDown];
}

-(void)clickSetBtn
{
    //跳转
    DrawingLOGOViewController *view = [[DrawingLOGOViewController alloc]init];
    
    view.logoClass = [[LogoClass alloc]init];

    view.logoClass.drawingBoard_width = 128;   //屏幕宽
    view.logoClass.drawingBoard_height = 32;  //屏幕高
    
    view.logoClass.drawing_type = 0; //屏幕类型  0 - 单色 1 - 彩色
    view.logoClass.drawing_way = 1;  //取模方式  0 - 纵向取模  1 - 横向取模
    
    view.logoClass.image_type = 0;   //图片用途  0 - 开机LOGO  1 - 无负载提示  2 - 短路提示  3 - 负载过大提示
    
    view.logoClass.image_foreground_color = 0x000;   //图片前景色
    view.logoClass.image_background_color = 0xFFF;   //图片背景色
    
    view.logoClass.coordinates_x = 0;   //起始坐标点 x
    view.logoClass.coordinates_y = 0;   //起始坐标点 y
    
    view.logoClass.logo_arrys = [NSMutableArray array];
    
    
    [self presentViewController:view animated:YES completion:^{
        NSLog(@"展示完毕");
    }];
}

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
    
    static NSString *Cell = @"LogoTableViewCell";
    LogoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
    if (!cell)
    {
        //从xlb加载内容
        cell = [[[NSBundle mainBundle] loadNibNamed:Cell owner:nil options:nil] lastObject];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    //设置圆角
    cell.logo_View.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
    cell.logo_View.layer.cornerRadius = 10.0f;
    [cell.logo_View.layer setMasksToBounds:YES];
    
    NSString *lable_str = [NSString stringWithFormat:@"LOGO - %d",(int)indexPath.row + 1];
    cell.lable_name.text = lable_str;
    
    //添加按钮点击事件
    cell.btn_edit.tag = indexPath.row;
    cell.btn_delete.tag = indexPath.row;
    cell.btn_use.tag = indexPath.row;
    
    [cell.btn_edit addTarget:self action:@selector(btn_edit_onclick:) forControlEvents:UIControlEventTouchDown];
    [cell.btn_delete addTarget:self action:@selector(btn_delete_onclick:) forControlEvents:UIControlEventTouchDown];
    [cell.btn_use addTarget:self action:@selector(btn_use_onclick:) forControlEvents:UIControlEventTouchDown];
    
    return cell;
}

//编辑按钮点击事件
-(void)btn_edit_onclick:(id)sender
{
    NSInteger check_btn = [sender tag];

    NSLog(@"编辑 - %d",(int)check_btn);
}

//删除按钮点击事件
-(void)btn_delete_onclick:(id)sender
{
    NSInteger check_btn = [sender tag];
    
    NSLog(@"删除 - %d",(int)check_btn);
}

//使用按钮点击事件
-(void)btn_use_onclick:(id)sender
{
    NSInteger check_btn = [sender tag];
    
    NSLog(@"LOGO - %d",(int)check_btn);
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
