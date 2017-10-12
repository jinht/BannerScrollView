//
//  ViewController.m
//  JhtBannerScrollView
//
//  GitHub主页: https://github.com/jinht
//  CSDN博客: http://blog.csdn.net/anticipate91
//
//  Created by Jinht on 2017/6/2.
//  Copyright © 2017年 JhtBannerScrollView. All rights reserved.
//

#import "ViewController.h"
#import "JhtBannerView.h"

/** 375的比例尺 */
#define WidthScale375 (([[UIScreen mainScreen] bounds].size.width) / 375)

@interface ViewController () 

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建UI界面
    [self createUI];
}



#pragma mark - UI
/** 创建UI界面 */
- (void)createUI {
    // 添加BannerScrollView
    [self addBannerScrollView];
    
    // 添加《Dismiss》按钮
    [self addDismissButton];
}


#pragma mark BannerScrollView
/** 添加BannerScrollView */
- (void)addBannerScrollView {
    JhtBannerView *bannerView = [[JhtBannerView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 380 / 2.0 * WidthScale375)];
    [bannerView clickScrollViewInsideCardView:^(NSInteger index) {
        NSLog(@"点击第%ld张卡片啦！", index);
    }];
    [self.view addSubview:bannerView];
    
    // 假数据
    NSArray *array = @[@"http://ovxyu3jv6.bkt.clouddn.com/JhtBannerScrollView/TestImage/01.jpg",
                       @"http://ovxyu3jv6.bkt.clouddn.com/JhtBannerScrollView/TestImage/02.jpg",
                       @"http://ovxyu3jv6.bkt.clouddn.com/JhtBannerScrollView/TestImage/03.jpg",
                       @"http://ovxyu3jv6.bkt.clouddn.com/JhtBannerScrollView/TestImage/04.jpg",
                       @"http://ovxyu3jv6.bkt.clouddn.com/JhtBannerScrollView/TestImage/05.jpg",
                       @"http://ovxyu3jv6.bkt.clouddn.com/JhtBannerScrollView/TestImage/06.jpg",
                       @"http://ovxyu3jv6.bkt.clouddn.com/JhtBannerScrollView/TestImage/07.jpg"];
    bannerView.placeholderImageName = @"placeholder";
    
    [bannerView setImageArray:array];
}


#pragma mark DismissButton
/** 添加《Dismiss》按钮 */
- (void)addDismissButton {
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(300, 400, 80, 30)];
    [backBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [backBtn setTitle:@"Dismiss" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}

- (void)backBtnClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
