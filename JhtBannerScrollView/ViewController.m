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
    
    [self addBannerScrollView];
}


#pragma mark - UI
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


@end
