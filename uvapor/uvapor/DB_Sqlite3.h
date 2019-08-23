//
//  DB_Sqlite3.h
//  uvapor
//
//  Created by TYZ on 16/12/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JPushMessage.h"
#import "FMDB.h"

@interface DB_Sqlite3 : NSObject

//用户数据 sqlite 数据库
@property(nonatomic,retain)FMDatabase *database;

/**
 *  写入数据到JPushMsg数据库
 *
 *  @return YES 写入成功
 */
+(Boolean)writeData_JPushMsg:(JPushMessage *)JPushMsg;

/**
 *  删除JPushMsg数据 根据_ID
 *
 *  @return YES 删除成功
 */
+(Boolean)deleteData_JPushMsg:(int)notification_ID;

/**
 *  查找数据
 *
 *  @return 查找到数据数组
 */
+(NSMutableArray *)FindData_JPushMsg:(int)page_num;


/**
 删除多余的数据

 @return 是否操作成功
 */
+(void)Delete_MoreData_JPushMsg;

/**
 *  查找所有的数据
 *
 *  @return 查找到数据数组
 */
+(NSMutableArray *)FindAllData_JPushMsg;

/**
 *  更新数据
 *
 *  @return YES 更新成功
 */
+(Boolean)UpdateData_JPushMsg:(JPushMessage *)JMg;

+(DB_Sqlite3 *)sharedInstance;

@end
