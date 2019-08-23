//
//  ShapeViewController.m
//  uVapour
//
//  Created by 田阳柱 on 16/9/20.
//  Copyright © 2016年 TYZ. All rights reserved.
//

#import "ShapeViewController.h"
#import "UIImageView+WebCache.h"
#import "InternationalControl.h"

@interface ShapeViewController ()
{
    UIImageView *imageShape;
}

@end

@implementation ShapeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //My_shareAPP
    self.title = [InternationalControl return_string:@"My_shareAPP"];
    
    [self addImageView];
}

-(void)addImageView
{
    imageShape = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40,  SCREEN_WIDTH - 20)];
    
    imageShape.center = CGPointMake(SCREEN_WIDTH/2.0f, SCREEN_HEIGHT/2.0f);
    
//    imageShape.image = [UIImage imageNamed:@"weixin"];
    NSString *urlImage = @"http://www.uvapour.com/weixin.png";
//
    [imageShape sd_setImageWithURL:[NSURL URLWithString:urlImage]
                        placeholderImage:[UIImage imageNamed:@"weixin"]];
    
    [self.view addSubview:imageShape];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
