//
//  CustomVolumeBar.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/28.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "CustomVolumeBar.h"
#import "STW_BLE_SDK.h"
#import "TYZFileData.h"

@implementation CustomVolumeBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame :(float)view_width  :(float)view_height :(int)arry_type :(NSMutableArray *)setArrys
{
    self = [self initWithFrame:frame];
    if (self)
    {
        //画图板宽
        float drawingViewWidth = view_width - 20;
        
        //画图板高
        float drawingViewHeight = view_height - 60;
        
        int width_box = drawingViewWidth / 22;
        int height_box = drawingViewHeight / 11;
        
        //选择单个方框边长
        int width_drawingViewBox = 0;
        int height_drawingViewBox = 0;
        

        width_drawingViewBox =  width_box;

        height_drawingViewBox = height_box;
        
        
        int drawingWidth = width_drawingViewBox * 22;
        int drawingHeight = height_drawingViewBox * 11;
        
        CGRect framebg = CGRectMake(((view_width - drawingWidth) * 3/4),(view_height - drawingHeight - 40),drawingWidth,drawingHeight);
        
        _CustomView = [[DrawingCustomLineView alloc] initWithFrame:framebg :width_drawingViewBox :height_drawingViewBox :arry_type :setArrys];
        
//        _CustomView.backgroundColor = [UIColor redColor];
        
        /***********************************************************************/
        //设置纵轴坐标系
        float margin_width_H = ((view_width - drawingWidth) * 3/ 4);
        float margin_height_H = (view_height - drawingHeight - 40);
        
        int box_height_box = height_box * 2;
        
//        for(int i  = 5;i >= 0;i--)
//        {
//            UILabel *lable_line_H = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, margin_width_H, box_height_box)];
//            
//            CGPoint lable_line_H_center = CGPointMake(margin_width_H / 2, margin_height_H - ((i - 5) * box_height_box) + height_box);
//            
//            lable_line_H.center = lable_line_H_center;
//            
//            lable_line_H.font = [UIFont systemFontOfSize:10];
//            
//            lable_line_H.text = [NSString stringWithFormat:@"%d",([STW_BLE_SDK STW_SDK].max_power * i/5)];
//
//            lable_line_H.textColor = [UIColor darkGrayColor];
//            
//            lable_line_H.textAlignment = NSTextAlignmentCenter;
//            
//            [self addSubview:lable_line_H];
//        }
        
        UILabel *lable_line_H = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, margin_width_H, box_height_box)];

        CGPoint lable_line_H_center = CGPointMake(margin_width_H / 2, margin_height_H - ((0 - 5) * box_height_box) + height_box);

        lable_line_H.center = lable_line_H_center;

        lable_line_H.font = [UIFont systemFontOfSize:10];

        lable_line_H.text = [NSString stringWithFormat:@"%d",([STW_BLE_SDK STW_SDK].max_power * 0/5)];

        lable_line_H.textColor = [UIColor darkGrayColor];

        lable_line_H.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:lable_line_H];
        
        //第1个坐标点
        _lable_line_H01 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, margin_width_H, box_height_box)];
        
        CGPoint lable_line_H_center01 = CGPointMake(margin_width_H / 2, margin_height_H - ((1 - 5) * box_height_box) + height_box);
        
        _lable_line_H01.center = lable_line_H_center01;
        
        _lable_line_H01.font = [UIFont systemFontOfSize:10];
        
        _lable_line_H01.text = [NSString stringWithFormat:@"%d",([STW_BLE_SDK STW_SDK].max_power * 1/5)];
        
        _lable_line_H01.textColor = [UIColor darkGrayColor];
        
        _lable_line_H01.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_lable_line_H01];
        
        
        //第2个坐标点
        _lable_line_H02 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, margin_width_H, box_height_box)];
        
        CGPoint lable_line_H_center02 = CGPointMake(margin_width_H / 2, margin_height_H - ((2 - 5) * box_height_box) + height_box);
        
        _lable_line_H02.center = lable_line_H_center02;
        
        _lable_line_H02.font = [UIFont systemFontOfSize:10];
        
        _lable_line_H02.text = [NSString stringWithFormat:@"%d",([STW_BLE_SDK STW_SDK].max_power * 2/5)];
        
        _lable_line_H02.textColor = [UIColor darkGrayColor];
        
        _lable_line_H02.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_lable_line_H02];
        
        //第3个坐标点
        _lable_line_H03 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, margin_width_H, box_height_box)];
        
        CGPoint lable_line_H_center03 = CGPointMake(margin_width_H / 2, margin_height_H - ((3 - 5) * box_height_box) + height_box);
        
        _lable_line_H03.center = lable_line_H_center03;
        
        _lable_line_H03.font = [UIFont systemFontOfSize:10];
        
        _lable_line_H03.text = [NSString stringWithFormat:@"%d",([STW_BLE_SDK STW_SDK].max_power * 3/5)];
        
        _lable_line_H03.textColor = [UIColor darkGrayColor];
        
        _lable_line_H03.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_lable_line_H03];
        
        //第4个坐标点
        _lable_line_H04 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, margin_width_H, box_height_box)];
        
        CGPoint lable_line_H_center04 = CGPointMake(margin_width_H / 2, margin_height_H - ((4 - 5) * box_height_box) + height_box);
        
        _lable_line_H04.center = lable_line_H_center04;
        
        _lable_line_H04.font = [UIFont systemFontOfSize:10];
        
        _lable_line_H04.text = [NSString stringWithFormat:@"%d",([STW_BLE_SDK STW_SDK].max_power * 4/5)];
        
        _lable_line_H04.textColor = [UIColor darkGrayColor];
        
        _lable_line_H04.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_lable_line_H04];
        
        //第5个坐标点
        _lable_line_H05 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, margin_width_H, box_height_box)];
        
        CGPoint lable_line_H_center05 = CGPointMake(margin_width_H / 2, margin_height_H - ((5 - 5) * box_height_box) + height_box);
        
        _lable_line_H05.center = lable_line_H_center05;
        
        _lable_line_H05.font = [UIFont systemFontOfSize:10];
        
        _lable_line_H05.text = [NSString stringWithFormat:@"%d",([STW_BLE_SDK STW_SDK].max_power * 5/5)];
        
        _lable_line_H05.textColor = [UIColor darkGrayColor];
        
        _lable_line_H05.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_lable_line_H05];
        
        
        /***************************************************************************/
        
        //设置横轴坐标系
        float margin_width_W = ((view_width - drawingWidth) * 3/ 4);
        float margin_height_W = (view_height - drawingHeight - 44 + drawingHeight);
        
        width_box = width_box * 2;
        
        for(int i  = 0;i < 11;i++)
        {
            UILabel *lable_line_W = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width_box,10)];
            
            CGPoint lable_line_W_center = CGPointMake(margin_width_W + (i * width_box) + width_box/2, margin_height_W + (width_box / 2));
            
            lable_line_W.center = lable_line_W_center;
            
            lable_line_W.font = [UIFont systemFontOfSize:10];
            
            lable_line_W.text = [NSString stringWithFormat:@"%d",i];
            
            lable_line_W.textColor = [UIColor darkGrayColor];
            
            lable_line_W.textAlignment = NSTextAlignmentCenter;
            
            [self addSubview:lable_line_W];
        }
        
//        //最后一个点
//        UILabel *lable_line_22 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, height_box * 2,10)];
//        
//        CGPoint lable_line_W_center = CGPointMake(margin_width_W + (22 * height_box + (height_box / 2)), margin_height_W + (height_box / 2));
//        
//        lable_line_22.center = lable_line_W_center;
//        
//        lable_line_22.font = [UIFont systemFontOfSize:10];
//        
//        lable_line_22.text = @"Time/s";
//        
//        lable_line_22.textColor = [UIColor darkGrayColor];
//        
//        lable_line_22.textAlignment = NSTextAlignmentCenter;
//        
//        [self addSubview:lable_line_22];
        
        /*************************************************************************************/
        
        [self addSubview:_CustomView];
    }
    return self;
}

//存储并发送曲线
-(void)saveAndSendPowerLine
{
    
}

//刷新曲线
-(void)updateUI:(int)choseNum
{
    //刷新第几条曲线
    self.instrumentDataLabel.text = [NSString stringWithFormat:@"C%d",choseNum];
    self.instrumentLabel.text = [NSString stringWithFormat:@"Custom-%d",choseNum];
    //获取本地数据
    int ArryType = choseNum;
    //获取本地数据
    NSMutableArray *choose_arrys = [TYZFileData GetPowerLineData:choseNum];
    
    _lable_line_H01.text = [NSString stringWithFormat:@"%d",([STW_BLE_SDK STW_SDK].max_power * 1/5)];
    _lable_line_H02.text = [NSString stringWithFormat:@"%d",([STW_BLE_SDK STW_SDK].max_power * 2/5)];
    _lable_line_H03.text = [NSString stringWithFormat:@"%d",([STW_BLE_SDK STW_SDK].max_power * 3/5)];
    _lable_line_H04.text = [NSString stringWithFormat:@"%d",([STW_BLE_SDK STW_SDK].max_power * 4/5)];
    _lable_line_H05.text = [NSString stringWithFormat:@"%d",([STW_BLE_SDK STW_SDK].max_power * 5/5)];
    
    if(choose_arrys.count == 23)
    {
        LineCGPoint *chosePoint = [choose_arrys objectAtIndex:22];
        
        ArryType = (int)chosePoint.line_y_h;
        
        //update 画图UI
        [_CustomView update_UI:choose_arrys :ArryType];
    }
    else
    {
        choose_arrys = [NSMutableArray array];
        //update 画图UI
        [_CustomView update_UI:choose_arrys :ArryType];
    }
}

//吸烟实时更新UI
-(void)updateUI_vapor_refresh:(int)refreshNum
{
    [_CustomView update_vapor_refresh:refreshNum+2];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
