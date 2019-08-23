//
//  DB_Sqlite3.m
//  uvapor
//
//  Created by TYZ on 16/12/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

/**
 *  JPush notice表
 *  _ID  编号/主键
 *  image_url  通知携带照片的URL
 *  message_type  通知类型
 *  notice_text  消息内容
 *  notice_time  消息时间
 *  notice_title  消息标题
 *  notice_type  消息类型
 *  notice_url  消息链接
 *  notice_status  消息是否已读
 
    //更新数据库
    if ([DB_Sqlite3 UpdateData_JPushMsg:2 :2])
    {
     NSLog(@"数据更新成功");
    }
    else
    {
     NSLog(@"数据更新失败");
    }

    //插入数据
    JPushMessage *JPushMsg = [JPushMessage alloc];

    JPushMsg.image_url = @"imageurl";
    JPushMsg.message_type = @"messagetype";
    JPushMsg.notice_text = @"noticetext";
    JPushMsg.notice_time = @"noticetime";
    JPushMsg.notice_title = @"noticetitle";
    JPushMsg.notice_type = @"noticetype";
    JPushMsg.notice_url = @"noticeurl";
    JPushMsg.notice_status = text_num;

    NSLog(@"JPushMsg.notice_type - %@",JPushMsg.notice_type);

    if ([DB_Sqlite3 writeData_JPushMsg:JPushMsg])
    {
    NSLog(@"数据插入成功");
    }
    else
    {
    NSLog(@"数据插入失败");
    }

    //分页查询 - text_num 页数
    NSLog(@"arrys - %@",[DB_Sqlite3 FindData_JPushMsg:text_num]);
 
    //删除数据 id _ID
    [DB_Sqlite3 deleteData_JPushMsg:id]
 */

#import "DB_Sqlite3.h"

static DB_Sqlite3 *shareInstance = nil;

@implementation DB_Sqlite3

+(DB_Sqlite3 *)sharedInstance
{
    if (!shareInstance)
    {
        shareInstance = [[DB_Sqlite3 alloc] init];
        //初始化数据库
        [self InitializeTheDatabase];
    }
    return shareInstance;
}

//初始化数据库
+(void)InitializeTheDatabase
{
    //ios下Document路径，Document为ios中可读写的文件夹
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
    NSString *filePath = [path stringByAppendingPathComponent:@"uVaporDataBase.db"];
//    NSLog(@"filePath : %@",filePath);
    shareInstance.database = [FMDatabase databaseWithPath:filePath];
    
    if ([shareInstance.database open])
    {
        //初始化表 JPushMsg - 指定 _ID为主键 自增
        BOOL open_dataSource = [shareInstance.database executeUpdate:@"CREATE TABLE IF NOT EXISTS JPushMsg (_ID INTEGER PRIMARY KEY AUTOINCREMENT,image_url TEXT,message_type TEXT,notice_text TEXT,notice_time TEXT,notice_title TEXT,notice_type TEXT,notice_url TEXT,notice_status INTEGER)"];
        
        if(open_dataSource)
        {
            NSLog(@"数据库初始化成功");
        }
        else
        {
            //数据库初始化失败
            NSLog(@"数据库初始化失败");
        }
        
        //关闭数据库
        if ([shareInstance.database close])
        {
            NSLog(@"数据库关闭");
        }
        else
        {
            NSLog(@"数据库关闭失败");
        }
    }
    else
    {
        NSLog(@"数据库打开失败");
    }
}

/**
 *  写入数据到数据库
 *
 *  @return YES 写入成功
 */
+(Boolean)writeData_JPushMsg:(JPushMessage *)JPushMsg
{
    NSString *sql_str = [NSString stringWithFormat:@"INSERT INTO JPushMsg (image_url,message_type,notice_text,notice_time,notice_title,notice_type,notice_url,notice_status) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",%d)",JPushMsg.image_url,JPushMsg.message_type,JPushMsg.notice_text,JPushMsg.notice_time,JPushMsg.notice_title,JPushMsg.notice_type,JPushMsg.notice_url,JPushMsg.notice_status];
    
//    NSLog(@"插入数据 : %@",sql_str);
    
    return [self datasource_DO:sql_str];
}

/**
 *  删除数据
 *
 *  @return YES 删除成功
 */
+(Boolean)deleteData_JPushMsg:(int)notification_ID
{
    NSString *sql_str = [NSString stringWithFormat:@"DELETE FROM JPushMsg WHERE _ID = %d",notification_ID];
    
    NSLog(@"删除数据 : %@",sql_str);
    
    return [self datasource_DO:sql_str];
}

/**
 *  查找数据
 *
 *  page_num  代表查询的页数 - 每页 10个
 *
 *  -> (page_num - 1)*10 ~ page_num * 10
 *
 *  @return 查找到数据数组
 */
+(NSMutableArray *)FindData_JPushMsg:(int)page_num
{
    NSString *sql_str = [NSString stringWithFormat:@"SELECT * FROM JPushMsg ORDER BY _ID DESC LIMIT %d,%d",(page_num - 1)*10,page_num * 10];
    
//    NSLog(@"查找数据 : %@",sql_str);
    
    NSMutableArray *JPushMsg_arry = [NSMutableArray array];
    
    //打开数据库
    if ([shareInstance.database open])
    {
        FMResultSet *JPushMsg_List = [shareInstance.database executeQuery:sql_str];
        
        while([JPushMsg_List next])
        {
            JPushMessage *JPushMsg = [JPushMessage alloc];
            
            //封装查询获取的数据
            JPushMsg._ID = [JPushMsg_List intForColumn:@"_ID"];
            JPushMsg.image_url = [JPushMsg_List stringForColumn:@"image_url"];
            JPushMsg.message_type = [JPushMsg_List stringForColumn:@"message_type"];
            JPushMsg.notice_text = [JPushMsg_List stringForColumn:@"notice_text"];
            JPushMsg.notice_time = [JPushMsg_List stringForColumn:@"notice_time"];
            JPushMsg.notice_title = [JPushMsg_List stringForColumn:@"notice_title"];
            JPushMsg.notice_type = [JPushMsg_List stringForColumn:@"notice_type"];
            JPushMsg.notice_url = [JPushMsg_List stringForColumn:@"notice_url"];
            JPushMsg.notice_status = [JPushMsg_List intForColumn:@"notice_status"];
            
            //将数据添加到返回数组
            [JPushMsg_arry addObject:JPushMsg];
        }
        
        //关闭数据库
        if ([shareInstance.database close])
        {
            NSLog(@"数据库关闭");
        }
        else
        {
            NSLog(@"数据库关闭失败");
        }
    }
    else
    {
        NSLog(@"数据库打开失败");
    }
    
    return JPushMsg_arry;
}

/**
 删除多余的数据
 
 @return 是否操作成功
 */
+(void)Delete_MoreData_JPushMsg
{
    //查询所有推送的信息
    NSMutableArray *JPushMsg_arry = [self FindAllData_JPushMsg];
    
    for (JPushMessage *JPushMsg_utils in JPushMsg_arry)
    {
        NSDate *time_msg = [NSDate dateWithTimeIntervalSince1970:[JPushMsg_utils.notice_time intValue]];
        
        NSTimeInterval times = [time_msg timeIntervalSinceNow];
        
        int day_num = fabs(times)/(60 * 60 * 24);
        
//        NSLog(@"times - -%d - %f",day_num,times);
        
        //删除掉多余的数据
        if (day_num >= 7)
        {
//            NSLog(@"可以删除");
            [self deleteData_JPushMsg:JPushMsg_utils._ID];
        }
    }
}

/**
 *  查找所有的数据
 *
 *  @return 查找到数据数组
 */
+(NSMutableArray *)FindAllData_JPushMsg
{
    NSString *sql_str = @"SELECT * FROM JPushMsg";
    
//    NSLog(@"查找数据 : %@",sql_str);
    
    NSMutableArray *JPushMsg_arry = [NSMutableArray array];
    
    //打开数据库
    if ([shareInstance.database open])
    {
        FMResultSet *JPushMsg_List = [shareInstance.database executeQuery:sql_str];
        
        while([JPushMsg_List next])
        {
            JPushMessage *JPushMsg = [JPushMessage alloc];
            
            //封装查询获取的数据
            JPushMsg._ID = [JPushMsg_List intForColumn:@"_ID"];
            JPushMsg.image_url = [JPushMsg_List stringForColumn:@"image_url"];
            JPushMsg.message_type = [JPushMsg_List stringForColumn:@"message_type"];
            JPushMsg.notice_text = [JPushMsg_List stringForColumn:@"notice_text"];
            JPushMsg.notice_time = [JPushMsg_List stringForColumn:@"notice_time"];
            JPushMsg.notice_title = [JPushMsg_List stringForColumn:@"notice_title"];
            JPushMsg.notice_type = [JPushMsg_List stringForColumn:@"notice_type"];
            JPushMsg.notice_url = [JPushMsg_List stringForColumn:@"notice_url"];
            JPushMsg.notice_status = [JPushMsg_List intForColumn:@"notice_status"];
            
            //将数据添加到返回数组
            [JPushMsg_arry addObject:JPushMsg];
        }
        
        //关闭数据库
        if ([shareInstance.database close])
        {
            NSLog(@"数据库关闭");
        }
        else
        {
            NSLog(@"数据库关闭失败");
        }
    }
    else
    {
        NSLog(@"数据库打开失败");
    }
    
    return JPushMsg_arry;
}

/**
 *  更新数据
 *
 *  @return YES 更新成功
 */
+(Boolean)UpdateData_JPushMsg:(JPushMessage *)JMg
{
    NSString *sql_str = [NSString stringWithFormat:@"UPDATE JPushMsg SET notice_status = %d WHERE _ID = %d",JMg.notice_status,JMg._ID];
    
//    NSLog(@"更新数据 : %@",sql_str);
    
    return [self datasource_DO:sql_str];
}

+(Boolean)datasource_DO:(NSString *)sql_str
{
    Boolean res = YES;
    //打开数据库
    if ([shareInstance.database open])
    {
        res = [shareInstance.database executeUpdate:sql_str];
        
        //关闭数据库
        if ([shareInstance.database close])
        {
            NSLog(@"数据库关闭");
        }
        else
        {
            NSLog(@"数据库关闭失败");
        }
        
        return res;
    }
    else
    {
        NSLog(@"数据库打开失败");
    }
    return NO;
}

@end
