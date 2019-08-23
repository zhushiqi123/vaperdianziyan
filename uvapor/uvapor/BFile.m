//
//  BFile.m
//  card
//
//  Created by stw01 on 15/2/7.
//  Copyright (c) 2015年 bct. All rights reserved.
//

#import "BFile.h"
#import "TYZ_AFNet_Client.h"
#import "NSDictionary+Stwid.h"
#import "MBProgressHUD.h"

@implementation BFile

+(BFile *)initWithData:(id)data
{
    BFile *file = [[BFile alloc] init];
    file.ids = [data intForKey:@"id"];
    file.file = [data stringForKey:@"file"];
    file.size = [data intForKey:@"size"];
    file.name = [data stringForKey:@"name"];
    file.createTime = [data dateForKey:@"create_time"];
    file.height = [data intForKey:@"height"];
    file.width = [data intForKey:@"width"];
    file.module = [data stringForKey:@"module"];
    //file.thumbnail = [data thumbnailForKey:@"thumbnail"];
    file.uid = [data intForKey:@"uid"];
    return file;
}

+(void)upload:(NSString *)module data:(NSData *)data filename:(NSString *)filename mimeType:(NSString *)mimeType success:(void (^)(BFile *))success failure:(void (^)(NSString *))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.progress = 0;
    
    [[TYZ_AFNet_Client sharedInstance] POST:[NSString stringWithFormat:@"files/%@/file",module] parameters:@{@"result":@"json"} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
    {
        [formData appendPartWithFileData:data name:@"file" fileName:filename mimeType:mimeType];
    }
    progress:^(NSProgress * _Nonnull uploadProgress)
   {
       double percentDone = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
       hud.progress = percentDone;
   }
   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
   {
       NSLog(@"responseObject - %@",responseObject);
       BFile *file = [BFile initWithData:responseObject];
       success(file);
       [hud hide:YES];
   }
   failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
   {
       NSLog(@"error -> %@",error);
       failure(@"设置失败");
       [hud hide:YES];
   }];
}
@end
