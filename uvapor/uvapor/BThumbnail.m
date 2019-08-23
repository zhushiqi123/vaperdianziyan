//
//  BPaginator.m
//  school-customer
//
//  Created by stw01 on 14-2-24.
//  Copyright (c) 2014年 stw01. All rights reserved.
//

#import "BThumbnail.h"
#import "NSDictionary+Stwid.h"

@implementation BThumbnail

+(BThumbnail *)initWithData:(id)data
{
    BThumbnail *obj = [[BThumbnail alloc] init];
    if(data == nil || data == [NSNull null]){
        return obj;
    }
    obj.small = [NSURL URLWithString:[data stringForKey:@"small"]];
    obj.medium = [NSURL URLWithString:[data stringForKey:@"medium"]];
    obj.large = [NSURL URLWithString:[data stringForKey:@"large"]];
    obj.original = [NSURL URLWithString:[data stringForKey:@"original"]];
    return obj;
}

@end
