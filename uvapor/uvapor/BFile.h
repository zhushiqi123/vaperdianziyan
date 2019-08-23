//
//  BFile.h
//  card
//
//  Created by stw01 on 15/2/7.
//  Copyright (c) 2015年 bct. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BThumbnail.h"

@interface BFile : NSObject

@property(nonatomic,assign) int ids;
@property(nonatomic,strong)NSData *data;
@property(nonatomic,copy)NSString *file;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign) int size;
@property(nonatomic,strong) NSDate *createTime;
@property(nonatomic,assign) int height;
@property(nonatomic,assign) int width;
@property(nonatomic,copy)NSString *module;
@property(nonatomic,assign) int uid;


+(BFile *)initWithData:(id)data;

+(void)upload:(NSString *)module data:(NSData *)data filename:(NSString *)filename mimeType:(NSString *)mimeType success:(void(^)(BFile *file))success failure:(void(^)(NSString *message))failure;
@end
