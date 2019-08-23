//
//  NSDictionary+Stwid.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/21.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "NSDictionary+Stwid.h"

@implementation NSDictionary (Bctid)

- (id)safeObjectForKey:(id)key {
    id value = [self valueForKey:key];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

-(NSString *)stringForKey:(id)key
{
    id v = [self safeObjectForKey:key];
    if(v == nil) return @"";
    return v;
}

-(int)intForKey:(id)key
{
    return [[self safeObjectForKey:key] intValue];
}

-(BOOL)boolForKey:(id)key
{
    return [[self safeObjectForKey:key] integerValue] == 1 ? YES : NO;
}

-(BThumbnail *)thumbnailForKey:(id)key
{
    return [BThumbnail initWithData:[self objectForKey:key]];
}

-(NSDate *)dateForKey:(id)key
{
    return [NSDate dateWithTimeIntervalSince1970:[[self safeObjectForKey:key] intValue]];
}

-(NSArray *)arrayForKey:(id)key
{
    id rs = [self safeObjectForKey:key];
    if([rs isKindOfClass:[NSArray class]]){
        return rs;
    }
    return nil;
}

-(NSMutableArray *)marrayForKey:(id)key
{
    id rs = [self safeObjectForKey:key];
    if([rs isKindOfClass:[NSMutableArray class]]){
        return rs;
    }
    return nil;
}

@end
