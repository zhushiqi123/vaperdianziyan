//
//  DrawingCustomLineView.h
//  uVapour
//
//  Created by 田阳柱 on 16/9/28.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingCustomLineView : UIView
{
@private
    int box_Side_width;
    int box_Side_height;
    
//    float PowerView_X;
//    float PowerView_Y;
    float PowerView_Width;
    float PowerView_Height;
}

@property (nonatomic, retain)NSMutableArray *array_lineData;    //画线数据
@property (nonatomic, retain)NSMutableArray *array_CustomData;

@property (nonatomic,assign) int check_num;

@property (nonatomic, assign)CGPoint point_start;
@property (nonatomic, assign)CGPoint point_end;

@property (nonatomic,assign) int point_num;

//曲线编号
@property (nonatomic,assign) int arry_type;

//初始化设置
- (id)initWithFrame:(CGRect)frame :(int)box_width :(int)box_height :(int)arry_type :(NSMutableArray *)setArrys;

//刷新曲线UI
-(void)update_UI:(NSMutableArray *)setArrys :(int)arry_type;

//吸烟效果刷新
-(void)update_vapor_refresh:(int)refresh_num;

@end
