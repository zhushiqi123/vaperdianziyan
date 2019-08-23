//
//  FriendsViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendsTableViewCell.h"
#import "FriendsTableViewCell02.h"

#import "User.h"
#import "ProgressHUD.h"
#import "MyFriends.h"
#import "Session.h"
#import "MJExtension.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [ProgressHUD show:nil];
    
    [self getFriendData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的好友";
    
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
    self.tableview.separatorInset = UIEdgeInsetsMake(0,68, 0, 0);
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

-(void)addButtonView
{
    //设置右边button
    UIButton *setButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-28, 5, 28, 28)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:setButton];
    
    [setButton setBackgroundImage:[UIImage imageNamed:@"icon_add_friends"] forState:UIControlStateNormal];
    
    [setButton addTarget:self action:@selector(clickSetBtn) forControlEvents:UIControlEventTouchDown];
}

#pragma tyz - Table View
//[tableview reloadData];   //刷新列表

//设置一共有多少个Sessiion，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

//设置每个Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 100;
    }
    else
    {
        return 50;
    }
}

//设置一共有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return [Session sharedInstance].friendsArrys.count;
    }
}

//TableView数据加载执行的方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *ID = @"FriendsTableViewCell";
        FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell)
        {
            //从xlb加载内容
            cell = [[[NSBundle mainBundle] loadNibNamed:ID owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]]; //icon_navigationbar
        }
    
        return cell;
    }
    else
    {
        static NSString *ID = @"FriendsTableViewCell02";
        FriendsTableViewCell02 *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell)
        {
            //从xlb加载内容
            cell = [[[NSBundle mainBundle] loadNibNamed:ID owner:nil options:nil] lastObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
        }
        
        MyFriends *friends = [[Session sharedInstance].friendsArrys objectAtIndex:indexPath.row];
        
        NSString *str_url = [NSString stringWithFormat:@"%@",friends.thumbnail.small];
        
        NSArray *array = [str_url componentsSeparatedByString:@"/"];
        
        NSString *strs_url = array[array.count - 1];
        
        if ([strs_url isEqualToString:@"no_image.png"])
        {
            cell.imageView_image.image = [UIImage imageNamed:@"icon_people"];
        }
        else
        {
            cell.imageView_image.layer.cornerRadius = 20.0f;
            
            UIImage *image_url = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:friends.thumbnail.small]];
            
            cell.imageView_image.image = image_url;
        }
       
        
        cell.lableView_title.text = friends.realname;
        cell.lableView_data.text = friends.status_name;
        
        return cell;
    }
}

//点击某个CEll执行的方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //cell被点击之后效果消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"-->第%d行",(int)indexPath.row);
}

-(void)clickSetBtn
{
    NSLog(@"set");
}

-(void)getFriendData
{
    [User getUserFriend:^(id data)
    {
        NSLog(@"用户好友列表：%@",data);
        [ProgressHUD showSuccess:nil];
        
        [Session sharedInstance].friendsArrys = [NSMutableArray array];
        
        //将字典数组转为Device模型数组
        [Session sharedInstance].friendsArrys = [MyFriends mj_objectArrayWithKeyValuesArray:data];
    
        //刷新列表
        [self.tableview reloadData];
        [ProgressHUD dismiss];
    }
    failure:^(NSString *message)
    {
        [ProgressHUD dismiss];
        NSLog(@"失败 - %@",message);
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
