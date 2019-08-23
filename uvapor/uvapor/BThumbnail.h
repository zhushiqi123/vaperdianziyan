//
//  BPaginator.h
//  school-customer
//
//  Created by stw01 on 14-2-24.
//  Copyright (c) 2014年 stw01. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BThumbnail : NSObject

//@property(nonatomic,copy) NSString *small;
//@property(nonatomic,copy) NSString *medium;
//@property(nonatomic,copy) NSString *large;

@property(nonatomic,copy) NSURL *small;
@property(nonatomic,copy) NSURL *medium;
@property(nonatomic,copy) NSURL *large;
@property(nonatomic,copy) NSURL *original;

+(BThumbnail *) initWithData:(id)data;

@end
