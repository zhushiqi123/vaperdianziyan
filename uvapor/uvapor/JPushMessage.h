//
//  JPushMessage.h
//  uvapor
//
//  Created by TYZ on 16/12/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPushMessage : NSObject

/**
 *  主键唯一ID
 */
@property (assign,nonatomic) int _ID;

/**
 *  通知携带照片的URL
 */
@property (retain,nonatomic) NSString *image_url;
/**
 *  通知类型
 */
@property (retain,nonatomic) NSString *message_type;
/**
 *  消息内容
 */
@property (retain,nonatomic) NSString *notice_text;
/**
 *  消息时间
 */
@property (retain,nonatomic) NSString *notice_time;
/**
 *  消息标题
 */
@property (retain,nonatomic) NSString *notice_title;
/**
 *  消息类型
 */
@property (retain,nonatomic) NSString *notice_type;
/**
 *  消息链接
 */
@property (retain,nonatomic) NSString *notice_url;
/**
 *  消息是否已读 1 - 已读  0 - 未读
 */
@property (assign,nonatomic) int notice_status;

@end
