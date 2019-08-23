//
//  NSDictionary_STW.h
//  uVapour
//
//  Created by 田阳柱 on 16/10/15.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BThumbnail.h"

@interface NSDictionary (STWID)

-(NSString *)stringForKey:(id)key;

-(int)intForKey:(id)key;

-(BOOL)boolForKey:(id)key;

-(BThumbnail *)thumbnailForKey:(id)key;

-(NSDate *)dateForKey:(id)key;

-(NSArray *)arrayForKey:(id)key;

-(NSMutableArray *)marrayForKey:(id)key;
@end