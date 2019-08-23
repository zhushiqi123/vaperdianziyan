//
//  PlanLineTableViewCell.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/19.
//  Copyright © 2016年 TYZ. All rights reserved.
//
#define itemWidth  30.0f
#define chartView_weight (SCREEN_WIDTH - 16.0f)
#define chartView_weight_half ((SCREEN_WIDTH - 16.0f) / 2.0f)

#import "PlanLineTableViewCell.h"
#import "Session.h"
#import "Record_month.h"

@interface PlanLineTableViewCell ()<SCChartDataSource,UIScrollViewDelegate>
{
    SCChart *chartView;
    SCPieChart *pieChartView;
    UIScrollView *scrollView;
}

@end

@implementation PlanLineTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)configUI:(SCChartStyle)withStyle
{
    if (chartView)
    {
        [chartView removeFromSuperview];
        chartView= nil;
    }
    
    if (withStyle == SCChartLineStyle)
    {
        scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0,chartView_weight, self.record_view.frame.size.height)];
        
        scrollView.delegate = self;
        
        float sViewWeith = chartView_weight;
        
        if(chartView_weight < [Session sharedInstance].recordMouthArrys.count * itemWidth)
        {
            sViewWeith = 30 * itemWidth;
        }
        // 设置内容大小
        scrollView.contentSize = CGSizeMake(sViewWeith,self.record_view.frame.size.height - 50);
        
        [self.record_view addSubview:scrollView];
        
        chartView = [[SCChart alloc] initwithSCChartDataFrame:CGRectMake(0,50,sViewWeith, self.record_view.frame.size.height - 50) withSource:self withStyle:withStyle];
        [chartView showInView:scrollView];
    }
    else if(withStyle == SCChartBarStyle)
    {
        chartView = [[SCChart alloc] initwithSCChartDataFrame:CGRectMake(0,50,chartView_weight, self.record_view.frame.size.height - 50) withSource:self withStyle:withStyle];
        [chartView showInView:self.record_view];
    }
    else
    {
        NSArray *items = @[[SCPieChartDataItem dataItemWithValue:10 color:SCGreen description:@"0~4s"],
                           [SCPieChartDataItem dataItemWithValue:20 color:SCBlue description:@"5~7s"],
                           [SCPieChartDataItem dataItemWithValue:40 color:SCDarkBlue description:@"8~10s"],
                           [SCPieChartDataItem dataItemWithValue:40 color:SCRed description:@"10s+"],
                           ];
        
        float cell_pieView_height = self.record_view.frame.size.height - 50;
        
        float pieView_height = cell_pieView_height;
        float pieView_weights = chartView_weight;
        
        if (pieView_height > chartView_weight_half)
        {
            pieView_height = chartView_weight_half - 30.0f;
            pieView_weights = chartView_weight - 30.0f;
        }
        else
        {
            pieView_height = self.record_view.frame.size.height - 50;
            pieView_weights = pieView_height * 2;
        }
        
        pieChartView = [[SCPieChart alloc] initWithFrame:CGRectMake(0,0,pieView_weights ,pieView_height) items:items];

//        pieChartView = [[SCPieChart alloc] initWithFrame:CGRectMake(0,50,chartView_weight, self.record_view.frame.size.height - 50) items:items];
        
        pieChartView.descriptionTextColor = [UIColor whiteColor];
        pieChartView.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:12.0];
        
        [pieChartView strokeChart];
        
        CGPoint center_point = CGPointMake((chartView_weight/2.0f), (cell_pieView_height / 2.0f));
        
        pieChartView.center = center_point;
        
        [self.chart_view addSubview:pieChartView];
    }
 

}

- (NSArray *)getXTitles:(int)num
{
    NSMutableArray *xTitles = [NSMutableArray array];
    for (int i=0; i<num; i++)
    {
        NSString * str = [NSString stringWithFormat:@"%d",i+1];
        [xTitles addObject:str];
    }
    return xTitles;
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)SCChart_xLableArray:(SCChart *)chart
{
//    return [self getXTitles:30];
    return [self retrn_chart_abscissa];
}

//数值多重数组
- (NSArray *)SCChart_yValueArray:(SCChart *)chart
{
//    NSMutableArray *ary = [NSMutableArray array];
//    
//    for (NSInteger i = 0; i < 30; i++)
//    {
//        CGFloat num = arc4random_uniform(100);
//        NSString *str = [NSString stringWithFormat:@"%f",num];
//        [ary addObject:str];
//    }
    
    return @[[self retrn_chart_ordinate]];
}

//返回横坐标 - 日期
-(NSArray *)retrn_chart_abscissa
{
    NSMutableArray *return_arrys = [NSMutableArray array];
    
    for (Record_month *record_m in [Session sharedInstance].recordMouthArrys)
    {
        NSString *str_date = [record_m.date substringWithRange:NSMakeRange(5, 5)];
        [return_arrys addObject:[NSString stringWithFormat:@"%@",str_date]];
    }
    
    return return_arrys;
}

//返回纵坐标 - 吸烟口数
-(NSArray *)retrn_chart_ordinate
{
    NSMutableArray *return_arrys = [NSMutableArray array];
    
    for (Record_month *record_m in [Session sharedInstance].recordMouthArrys)
    {
        [return_arrys addObject:[NSString stringWithFormat:@"%@",record_m.count]];
    }
    
    return return_arrys;
}

#pragma mark - @optional
//颜色数组
- (NSArray *)SCChart_ColorArray:(SCChart *)chart
{
    return @[SCBlue,SCRed,SCGreen];
}

#pragma mark 折线图专享功能
//标记数值区域
- (CGRange)SCChartMarkRangeInLineChart:(SCChart *)chart {
    return CGRangeZero;
}

//判断显示横线条
- (BOOL)SCChart:(SCChart *)chart ShowHorizonLineAtIndex:(NSInteger)index {
    return YES;
}

//判断显示最大最小值
- (BOOL)SCChart:(SCChart *)chart ShowMaxMinAtIndex:(NSInteger)index {
    return NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
