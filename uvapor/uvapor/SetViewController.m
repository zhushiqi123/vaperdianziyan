//
//  SetViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/13.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "SetViewController.h"
#import "SetTableViewCell.h"
#import "LoginTableViewCell.h"
#import "LoginViewController.h"
#import "FriendsViewController.h"
#import "MyMessageViewController.h"
#import "MyVapeViewController.h"
#import "LanguageViewController.h"
#import "ShopViewController.h"
#import "FeedBackViewController.h"
#import "ShapeViewController.h"
#import "SettingViewController.h"
#import "TYZFileData.h"
#import "UserViewController.h"
#import "UIImageView+WebCache.h"
#import "InternationalControl.h"
#import "DB_Sqlite3.h"
#import "JPushMessage.h"
#import "GreenHandViewController.h"
#import "InternationalControl.h"
#import "STW_BLE_SDK.h"

#import "User.h"
#import "Device.h"
#import "Session.h"

#import "ProgressHUD.h"

@interface SetViewController ()
{
    NSArray *tableViewData_arry;
    NSArray *tableViewCell_title_arry_cn;
    NSArray *tableViewCell_title_arry_en;
    NSArray *tableViewCell_image_arry;
}

@end

@implementation SetViewController

-(void)viewWillAppear:(BOOL)animated
{
    [ProgressHUD dismiss];

    [super viewWillAppear:YES];
    
    self.title = [InternationalControl return_string:@"tabBar_My"];
    
    //刷新UI
    [self.tableview reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [InternationalControl return_string:@"tabBar_My"];
    
//    //设置tableview 结构信息
//    tableViewData_arry =  [NSArray arrayWithObjects:@"1",@"3",@"1",@"3", nil];
    
//    tableViewCell_title_arry_cn = [NSArray arrayWithObjects:@"登录",@"我的好友",@"我的消息",@"我的设备",@"语言",@"在线商店" ,@"意见反馈",@"推荐给好友",nil];
//    
//    tableViewCell_title_arry_en = [NSArray arrayWithObjects:@"Login",@"Friends",@"Message",@"Device",@"Language",@"Shop" ,@"Feedback",@"Recommend App to friends",nil];
    
//        tableViewCell_image_arry = [NSArray arrayWithObjects:@"icon_people",@"icon_friends",@"icon_message",@"icon_vape",@"icon_language" ,@"icon_shop",@"icon_feedback",@"icon_shapeapp",nil];
    
    //设置tableview 结构信息
    tableViewData_arry =  [NSArray arrayWithObjects:@"1",@"1",@"1",@"3", nil];
    
    tableViewCell_title_arry_cn = [NSArray arrayWithObjects:@"登录",@"我的设备",@"语言",@"在线商店" ,@"意见反馈",@"推荐给好友",nil];
    
    tableViewCell_title_arry_en = [NSArray arrayWithObjects:@"Login",@"Device",@"Language",@"Shop" ,@"Feedback",@"Recommend App to friends",nil];
    
    tableViewCell_image_arry = [NSArray arrayWithObjects:@"icon_people",@"icon_vape",@"icon_language" ,@"icon_shop",@"icon_feedback",@"icon_shapeapp",nil];
    
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
    self.tableview.separatorInset = UIEdgeInsetsMake(0,43, 0, 0);
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    //设置右边button
//    UIButton *setButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-20, 5, 20, 20)];
//    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:setButton];
//
//    [setButton setBackgroundImage:[UIImage imageNamed:@"icon_set"] forState:UIControlStateNormal];
//   
//    [setButton addTarget:self action:@selector(clickSetBtn) forControlEvents:UIControlEventTouchDown];
}

-(void)clickSetBtn
{
    //跳转设置页面
    SettingViewController *view = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

#pragma tyz - Table View
//[tableview reloadData];   //刷新列表

//设置一共有多少个Sessiion，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

//设置每个Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0)
    {
        return 60;
    }
    else
    {
        return 44;
    }
}

//设置一共有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [tableViewData_arry[section] intValue];
}

//TableView数据加载执行的方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0)
    {
        static NSString *Cell = @"LoginTableViewCell";
        
        LoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
        if (!cell)
        {
            //从xlb加载内容
            cell = [[[NSBundle mainBundle] loadNibNamed:Cell owner:nil options:nil] lastObject];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
        }
        
        int pageNum = [self return_pagenum:(int)indexPath.section :(int)indexPath.row];
        
        if (![[Session sharedInstance].user.cellphone isEqualToString:@""] && [Session sharedInstance].user.cellphone != NULL)
        {
            //设置图标
            cell.login_image.layer.cornerRadius = cell.login_image.bounds.size.width * 0.5f;
            
            NSString *urlImage = [[Session sharedInstance].user.bthumbnail.small absoluteString];

            if (![urlImage isEqualToString:@"http://120.24.175.35/uvapor-web/public/data/cache/images/no_image.png"])
            {
                [cell.login_image sd_setImageWithURL:[NSURL URLWithString:urlImage]
                                    placeholderImage:[UIImage imageNamed:@"icon_people"]];
            }
            else
            {
                cell.login_image.image = [UIImage imageNamed:@"icon_people"];
            }
            
            //名称
            NSString *lable_str = [Session sharedInstance].user.nikename;
            cell.login_lable.text = lable_str;
        }
        else
        {
            //设置图标
            NSString *image_str = [NSString stringWithFormat:@"%@",tableViewCell_image_arry[pageNum]];
            cell.login_image.image = [UIImage imageNamed:image_str];
            
            NSString *lable_str;
            
            if ([Session sharedInstance].isLanguage == 1)
            {
                //名称
                lable_str = [NSString stringWithFormat:@"%@",tableViewCell_title_arry_cn[pageNum]];
            }
            else
            {
                //名称
                lable_str = [NSString stringWithFormat:@"%@",tableViewCell_title_arry_en[pageNum]];
            }
            
            cell.login_lable.text = lable_str;
        }
        
        cell.login_image.layer.masksToBounds = YES;
        
        return cell;
    }
    else if (indexPath.row == 2 && indexPath.section == 1)
    {
        static NSString *Cell = @"SetTableViewCell";
        
        SetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
        if (!cell)
        {
            //从xlb加载内容
            cell = [[[NSBundle mainBundle] loadNibNamed:Cell owner:nil options:nil] lastObject];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
        }
        
        int pageNum = [self return_pagenum:(int)indexPath.section :(int)indexPath.row];
        
        //设置图标
        NSString *image_str = [NSString stringWithFormat:@"%@",tableViewCell_image_arry[pageNum]];
        cell.set_imageview_logo.image = [UIImage imageNamed:image_str];
        
        NSString *lable_str;
        
        if ([Session sharedInstance].isLanguage == 1)
        {
            //名称
            lable_str = [NSString stringWithFormat:@"%@",tableViewCell_title_arry_cn[pageNum]];
        }
        else
        {
            //名称
            lable_str = [NSString stringWithFormat:@"%@",tableViewCell_title_arry_en[pageNum]];
        }
        
        //名称
        //        NSString *lable_str = [NSString stringWithFormat:@"%@",tableViewCell_title_arry_cn[pageNum]];
        cell.lable_set_Cell.text = lable_str;
        
//        if ([[STW_BLE_SDK STW_SDK].greenhand_on_off isEqualToString:@"on"])
//        {
//            //GreenHandStatus
//            cell.lable_on_off.text = [InternationalControl return_string:@"GreenHandON"];
//        }
//        else
//        {
//            //GreenHandStatus
//            cell.lable_on_off.text = [InternationalControl return_string:@"GreenHandOFF"];
//        }
        
        return cell;
    }
    else
    {
        static NSString *Cell = @"SetTableViewCell";
        
        SetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
        if (!cell)
        {
            //从xlb加载内容
            cell = [[[NSBundle mainBundle] loadNibNamed:Cell owner:nil options:nil] lastObject];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
        }
        
        int pageNum = [self return_pagenum:(int)indexPath.section :(int)indexPath.row];
        
        //设置图标
        NSString *image_str = [NSString stringWithFormat:@"%@",tableViewCell_image_arry[pageNum]];
        cell.set_imageview_logo.image = [UIImage imageNamed:image_str];
        
        NSString *lable_str;
        
        if ([Session sharedInstance].isLanguage == 1)
        {
            //名称
            lable_str = [NSString stringWithFormat:@"%@",tableViewCell_title_arry_cn[pageNum]];
        }
        else
        {
            //名称
            lable_str = [NSString stringWithFormat:@"%@",tableViewCell_title_arry_en[pageNum]];
        }

        //名称
//        NSString *lable_str = [NSString stringWithFormat:@"%@",tableViewCell_title_arry_cn[pageNum]];
        cell.lable_set_Cell.text = lable_str;

        return cell;
    }
}

//点击某个CEll执行的方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell被点击之后效果消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self push_view:(int)indexPath.section :(int)indexPath.row];
}


//返回当前的格数
-(int)return_pagenum:(int)setion :(int)row
{
    int pagenum = 0;
    
    switch (setion)
    {
        case 0:
            pagenum = row;
            break;
        case 1:
            pagenum = row + 1;
            break;
        case 2:
            pagenum = row + 2;
            break;
        case 3:
            pagenum = row + 3;
            break;
            
        default:
            break;
    }
    
    return pagenum;
}

//进行跳转
-(void)push_view:(int)setion :(int)row
{
    int pageNum = [self return_pagenum:setion :row];
    
    switch (pageNum)
    {
        case 0:
        {
            if (![[Session sharedInstance].user.cellphone isEqualToString:@""] && [Session sharedInstance].user.cellphone != NULL)
            {
                //跳转个人信息界面
                UserViewController *view = [[UserViewController alloc] init];
                [self.navigationController pushViewController:view animated:YES];
            }
            else
            {
                //登录
                LoginViewController *view = [[LoginViewController alloc] init];
                [self.navigationController pushViewController:view animated:YES];
            }
        }
            break;
//        case 1:
//        {
//            if (![[Session sharedInstance].user.cellphone isEqualToString:@""] && [Session sharedInstance].user.cellphone != NULL)
//            {
//                //我的好友
//                FriendsViewController *view = [[FriendsViewController alloc] init];
//                [self.navigationController pushViewController:view animated:YES];
//            }
//            else
//            {
//                //登录
//                LoginViewController *view = [[LoginViewController alloc] init];
//                [self.navigationController pushViewController:view animated:YES];
//            }
//        }
//            break;
//        case 1:
//        {
////            if (![[Session sharedInstance].user.cellphone isEqualToString:@""] && [Session sharedInstance].user.cellphone != NULL)
////            {
//                //我的消息
//                MyMessageViewController *view = [[MyMessageViewController alloc] init];
//                [self.navigationController pushViewController:view animated:YES];
////            }
////            else
////            {
////                //登录
////                LoginViewController *view = [[LoginViewController alloc] init];
////                [self.navigationController pushViewController:view animated:YES];
////            }
//        }
//            break;
        case 1:
        {
            if (![[Session sharedInstance].user.cellphone isEqualToString:@""] && [Session sharedInstance].user.cellphone != NULL)
            {
                //我的设备 MyVapeViewController
                MyVapeViewController *view = [[MyVapeViewController alloc] init];
                [self.navigationController pushViewController:view animated:YES];
            }
            else
            {
                //登录
                LoginViewController *view = [[LoginViewController alloc] init];
                [self.navigationController pushViewController:view animated:YES];
            }
        }
            break;
//        case 3:
//        {
//            //新手模式
//            GreenHandViewController *view = [[GreenHandViewController alloc] init];
//            [self.navigationController pushViewController:view animated:YES];
//        }
//            break;
        case 2:
        {
            //语言 LanguageViewController
            LanguageViewController *view = [[LanguageViewController alloc] init];
            [self.navigationController pushViewController:view animated:YES];
        }
            break;
        case 3:
        {
            //在线商店 ShopViewController
            ShopViewController *view = [[ShopViewController alloc] init];
            view.url_string = @"http://www.stw-ecig.com";
            view.title = [InternationalControl return_string:@"My_shop"];
            [self.navigationController pushViewController:view animated:YES];
        }
            break;
        case 4:
        {
            //意见反馈 FeedBackViewController
            FeedBackViewController *view = [[FeedBackViewController alloc] init];
            [self.navigationController pushViewController:view animated:YES];
        }
            break;
        case 5:
        {
            //推荐给好友 ShapeViewController
            ShapeViewController *view = [[ShapeViewController alloc] init];
            [self.navigationController pushViewController:view animated:YES];
        }
            break;
            
        default:
            break;
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
