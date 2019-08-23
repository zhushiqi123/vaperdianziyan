//
//  UaerViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "UserViewController.h"
#import "Session.h"
#import "MyImageViewCell.h"
#import "MyNickNameViewCell.h"
#import "MyOutLoginViewCell.h"
#import "MyPasswordViewCell.h"
#import "ProgressHUD.h"
#import "TYZFileData.h"
#import "AlertViewInputBoxView.h"
#import "BFile.h"
#import "UpdatePasswordViewController.h"
#import "UpdatePhoneViewController.h"
#import "UIImageView+WebCache.h"
#import "InternationalControl.h"

@interface UserViewController ()
{
    NSArray *tableViewData_arry;
    NSArray *tableViewTitle_arry_cn;
    NSArray *tableViewTitle_arry_en;
    UIImagePickerController *_picker;
}

@end

@implementation UserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化相机
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    
    self.title = [Session sharedInstance].user.nikename;
    
    //设置tableview 结构信息
    tableViewData_arry =  [NSArray arrayWithObjects:@"1",@"4",@"1", nil];
    tableViewTitle_arry_cn = [NSArray arrayWithObjects:@"昵称:",@"登录密码",@"手机:",@"邮箱:", nil];
    tableViewTitle_arry_en = [NSArray arrayWithObjects:@"Name:",@"Password",@"Phone:",@"Email:", nil];
    

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
//    self.tableview.separatorInset = UIEdgeInsetsMake(0,0,0, 0);
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

//设置一共有多少个Sessiion，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
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
        static NSString *Cell = @"MyImageViewCell";
        
        MyImageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
        if (!cell)
        {
            //从xlb加载内容
            cell = [[[NSBundle mainBundle] loadNibNamed:Cell owner:nil options:nil] lastObject];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
        }
        
//        cell.lable_image.image = [];
        
//        int pageNum = [self return_pagenum:(int)indexPath.section :(int)indexPath.row];
        
        cell.lable_title.text = [InternationalControl return_string:@"My_information_imagetext"];
        //设置图标
        cell.lable_image.layer.cornerRadius = cell.lable_image.bounds.size.width * 0.5;
        
        NSString *urlImage = [[Session sharedInstance].user.bthumbnail.small absoluteString];
//        if (![urlImage isEqualToString:@"http://120.24.175.35/uvapor-web/public/data/cache/images/no_image.png"])
        if (![urlImage isEqualToString:@"http://www.uvapour.com/uvapor-web/public/data/cache/images/no_image.png"])
        {
            [cell.lable_image sd_setImageWithURL:[NSURL URLWithString:urlImage]
                                placeholderImage:[UIImage imageNamed:@"icon_people"]];
        }
        else
        {
            cell.lable_image.image = [UIImage imageNamed:@"icon_people"];
        }
        
        cell.lable_image.layer.masksToBounds = YES;
        
        return cell;
    }
    else if(indexPath.section == 2)
    {
        static NSString *Cell = @"MyOutLoginViewCell";
        
        MyOutLoginViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
        if (!cell)
        {
            //从xlb加载内容
            cell = [[[NSBundle mainBundle] loadNibNamed:Cell owner:nil options:nil] lastObject];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
        }
        //        int pageNum = [self return_pagenum:(int)indexPath.section :(int)indexPath.row];
        
        cell.lable_title.text = [InternationalControl return_string:@"My_information_out"];
        
        return cell;
    }
    else
    {
        if (indexPath.row == 1)
        {
            static NSString *Cell = @"MyPasswordViewCell";
            
            MyPasswordViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
            if (!cell)
            {
                //从xlb加载内容
                cell = [[[NSBundle mainBundle] loadNibNamed:Cell owner:nil options:nil] lastObject];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
            }
            
            if ([Session sharedInstance].isLanguage == 1)
            {
                cell.lable_title.text = [NSString stringWithFormat:@"%@",[tableViewTitle_arry_cn objectAtIndex:indexPath.row]];
            }
            else
            {
                cell.lable_title.text = [NSString stringWithFormat:@"%@",[tableViewTitle_arry_en objectAtIndex:indexPath.row]];
            }

            return cell;
        }
        else
        {
            static NSString *Cell = @"MyNickNameViewCell";
            
            MyNickNameViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
            if (!cell)
            {
                //从xlb加载内容
                cell = [[[NSBundle mainBundle] loadNibNamed:Cell owner:nil options:nil] lastObject];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_navigationbar"]];
            }
            
            if ([Session sharedInstance].isLanguage == 1)
            {
                cell.lable_title.text = [NSString stringWithFormat:@"%@",[tableViewTitle_arry_cn objectAtIndex:indexPath.row]];
            }
            else
            {
                cell.lable_title.text = [NSString stringWithFormat:@"%@",[tableViewTitle_arry_en objectAtIndex:indexPath.row]];
            }
            
            switch (indexPath.row)
            {
                case 0:
                    cell.lable_data.text = [Session sharedInstance].user.nikename;
                    break;
                case 2:
                    cell.lable_data.text = [Session sharedInstance].user.cellphone;
                    break;
                case 3:
                    cell.lable_data.text = [Session sharedInstance].user.email;
                    break;
                    
                default:
                    break;
            }
            
            return cell;
        }
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
            pagenum = row + 5;
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
            [self replaceHeading:0];
        }
            break;
        case 1:
        {
            NSLog(@"1 - 昵称");
            AlertViewInputBoxView* view = [[[NSBundle mainBundle] loadNibNamed:@"AlertViewInputBoxView" owner:self options:nil] lastObject];
            
            //view.inpuBoxView.btn_confim
            [view.inpuBoxView.btn_confim addTarget:self action:@selector(confim_btn_01) forControlEvents:UIControlEventTouchUpInside];
            
            //请输入新的昵称 - My_information_input_nickname
            [view showViewWith:[InternationalControl return_string:@"My_information_input_nickname"] :UIKeyboardTypeDefault];
            
            view.AlertViewBackString = ^(NSString *backString)
            {
                NSLog(@"backString - %@",backString);
                if (backString.length > 0 && backString.length < 32)
                {
                    [User setNickname:backString success:^(id data)
                    {
                        [ProgressHUD showSuccess:nil];
//                        NSLog(@"data - > %@",data);
                       [Session sharedInstance].user = [User initdata:data];
                        //刷新页面
                        [self.tableview reloadData];
                    }
                    failure:^(NSString *message)
                    {
                        //昵称设置失败 - My_information_nickname_failure
                        [ProgressHUD showError:[InternationalControl return_string:@"My_information_nickname_failure"]];
                    }];
                }
                else
                {
                    //昵称格式设置错误 - My_information_nickname_error
                    [ProgressHUD showError:[InternationalControl return_string:@"My_information_nickname_error"]];
                }
            };
        }
            break;
        case 2:
        {
            NSLog(@"登录密码");
            UpdatePasswordViewController *view = [[UpdatePasswordViewController alloc] init];
            //解决push跳转卡顿问题就是保证跳转的view是有背景颜色的
            [self.navigationController pushViewController: view animated:true];
        }
            break;
        case 3:
        {
            NSLog(@"3 - 手机");
            UpdatePhoneViewController *view = [[UpdatePhoneViewController alloc] init];
            //解决push跳转卡顿问题就是保证跳转的view是有背景颜色的
            [self.navigationController pushViewController: view animated:true];
        }
            break;
        case 4:
        {
            NSLog(@"4 - 邮箱");
            AlertViewInputBoxView* view = [[[NSBundle mainBundle] loadNibNamed:@"AlertViewInputBoxView" owner:self options:nil] lastObject];
            //请输入新的邮箱 - My_information_inputEmail
            [view showViewWith:[InternationalControl return_string:@"My_information_inputEmail"] :UIKeyboardTypeEmailAddress];
            
            view.AlertViewBackString = ^(NSString *backString)
            {
                NSLog(@"backString - %@",backString);
                if (![self validateEmail:backString])
                {
                    //邮箱格式错误 - My_information_EmailError
                    [ProgressHUD showError:[InternationalControl return_string:@"My_information_EmailError"]];
                }
                else
                {
                    [User setEmail:backString success:^(id data)
                    {
                        [ProgressHUD showSuccess:nil];
//                        NSLog(@"data - > %@",data);
                        [Session sharedInstance].user = [User initdata:data];
                        //刷新页面
                        [self.tableview reloadData];
                    }
                    failure:^(NSString *message)
                    {
                        //邮箱设置失败 - My_information_EmailFailure
                         [ProgressHUD showError:[InternationalControl return_string:@"My_information_EmailFailure"]];
                    }];
                }
            };
        }
            break;
        case 5:
        {
            NSLog(@"5 - 退出登录");
            //清空User
            [Session sharedInstance].user = [[User alloc] init];
            //清空本地缓存
            [TYZFileData SaveUserData:[Session sharedInstance].user];
            //提示成功退出
            [ProgressHUD showSuccess:nil];
            //返回上一界面
            [[self navigationController] popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(void)confim_btn_01
{
    
}


- (void)replaceHeading:(int)num
{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[InternationalControl return_string:@"window_cancle"] destructiveButtonTitle:nil otherButtonTitles:[InternationalControl return_string:@"My_information_image"],[InternationalControl return_string:@"My_information_camera"], nil];
    [as showInView:self.view];
}

#pragma mark actionsheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                _picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:_picker.sourceType];
                [self presentViewController:_picker animated:YES completion:nil];
            }
            else
            {
                //无法访问相册 - My_information_imageError
                [ProgressHUD showError:[InternationalControl return_string:@"My_information_imageError"]];
            }
            break;
        case 1:
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                _picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
                [self presentViewController:_picker animated:YES completion:nil];
            }
            else
            {
//                [ProgressHUD showError:@"相机不可用"];
                [ProgressHUD showError:[InternationalControl return_string:@"My_information_cameraError"]];
            }
            break;
        default:
            break;
    }
}

#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)ainfo
{
    NSString *mediaType = [ainfo objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"])
    {
        UIImage *image = [ainfo objectForKey:UIImagePickerControllerOriginalImage];
        
        UIImage *smallImage=[self scaleFromImage:image toSize:CGSizeMake(300.f, 400.0f)];
        
        NSData *imageData = UIImageJPEGRepresentation(smallImage, 300.0f);
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [BFile upload:@"customer" data:imageData filename:@"user_headimg.jpg" mimeType:@"image/jpeg" success:^(BFile *file)
            {
                NSLog(@"file - > %@",file);
                [User setHeading:file.file success:^(id data)
                 {
                    User *user =[User initdata:data];
                    [Session sharedInstance].user.bthumbnail = user.bthumbnail;
                     //设置成功 - My_information_setSuccess
                    [ProgressHUD showSuccess:[InternationalControl return_string:@"My_information_setSuccess"]];
                    [self.tableview reloadData];
                 }
                 failure:^(NSString *message)
                 {
                     //设置失败 - My_information_setError
                    [ProgressHUD showError:[InternationalControl return_string:@"My_information_setError"]];
                 }];
            }
            failure:^(NSString *message)
            {
                //失败 - My_information_failure
                [ProgressHUD showError:[InternationalControl return_string:@"My_information_failure"]];
            }];
        }];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
}

//改变图片尺寸
- (UIImage *)scaleFromImage:(UIImage *)image toSize: (CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//检测邮箱格式
- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
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
