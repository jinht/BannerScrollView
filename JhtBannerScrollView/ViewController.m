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

#define FrameW [UIScreen mainScreen].bounds.size.width
#define WidthScale375 (([[UIScreen mainScreen] bounds].size.width) / 375)

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"JhtBannerScrollView";
    
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
        NSLog(@"点击第%ld张卡片啦！", (long)index);
    }];
    [self.view addSubview:bannerView];
    
    // 假数据
    NSArray *array = @[@"image_1",
                       @"image_2",
                       @"image_3",
                       @"image_4",
                       @"image_5"
                       ];
    bannerView.placeholderImageName = @"placeholder";
    
    [bannerView setImageArray:array];
}

#pragma mark DismissButton
/** 添加《Dismiss》按钮 */
- (void)addDismissButton {
    CGFloat backBtnW = 80.0;
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(FrameW - backBtnW - 10, 330, backBtnW, 30)];
    
    [backBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [backBtn setTitle:@"Dismiss" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}

- (void)backBtnClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
