//
//  LanguageViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "LanguageViewController.h"
#import "InternationalControl.h"
#import "Session.h"

@interface LanguageViewController ()
{
    NSArray *tabArrayLanguge_cn;
    NSArray *tabArrayLanguge_en;
}

@end

@implementation LanguageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [InternationalControl return_string:@"My_Language"];
    
    //设置TableView
    self.tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 54, SCREEN_WIDTH, SCREEN_HEIGHT - 114.0f) style:UITableViewStyleGrouped];
    
    self.tableview.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableview];

    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.tableFooterView=[[UIView alloc]init];//关键语句
    
    tabArrayLanguge_cn = [NSArray arrayWithObjects:@"电子烟",@"自定义",@"计划",@"我的", nil];
    tabArrayLanguge_en = [NSArray arrayWithObjects:@"Vapor",@"Custom",@"Plan",@"Setting", nil];
}

#pragma tyz - Table View

//设置一共有多少个Sessiion，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

//设置每个Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

//设置一共有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

//TableView数据加载执行的方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cell = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor darkGrayColor];
    }

    cell.textLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"中文";
        if ([Session sharedInstance].isLanguage == 1)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;  //UITableViewCellAccessoryNone
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;  //UITableViewCellAccessoryNone
        }
    }
    else
    {
        cell.textLabel.text = @"English";
        if ([Session sharedInstance].isLanguage == 0)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;  //UITableViewCellAccessoryNone
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;  //UITableViewCellAccessoryNone
        }
    }
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //cell被点击之后效果消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0)
    {
        [Session sharedInstance].isLanguage = 1;
        //本地化存储语言
        [InternationalControl setUserlanguage:@"zh-Hans"];
        
        for (int i = 0; i<4; i++)
        {
            UIViewController *vc = self.tabBarController.viewControllers[i];
            vc.title = tabArrayLanguge_cn[i];
        }
        
        [self.tableview reloadData];
    }
    else
    {
        [Session sharedInstance].isLanguage = 0;
        //本地化存储语言
        [InternationalControl setUserlanguage:@"en"];
        
        for (int i = 0; i<4; i++)
        {
            UIViewController *vc = self.tabBarController.viewControllers[i];
            vc.title = tabArrayLanguge_en[i];
        }
        
        [self.tableview reloadData];
    }
    
    self.title = [InternationalControl return_string:@"My_Language"];
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
