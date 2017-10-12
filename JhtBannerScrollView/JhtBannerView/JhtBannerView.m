//
//  JhtBannerView.m
//  JhtBannerScrollView
//
//  GitHub主页: https://github.com/jinht
//  CSDN博客: http://blog.csdn.net/anticipate91
//
//  Created by Jinht on 2017/6/2.
//  Copyright © 2017年 JhtBannerScrollView. All rights reserved.
//

#import "JhtBannerView.h"
#import <JhtBannerScrollView/JhtBannerScrollView.h>
#import "UIImageView+WebCache.h"

/** 单个卡片宽度 */
#define KBavCardViewWidth (480 / 2.0 * WidthScale375)
/** 单个卡片高度 */
#define KBavCardViewHeight (280 / 2.0 * WidthScale375)

@interface JhtBannerView () <JhtBannerScrollViewDelegate, JhtBannerScrollViewDataSource> {
    // 点击内部卡片View回调的Block
    clickInsideCardView _block;
}

/** banner view（整条view） */
@property (nonatomic, strong) JhtBannerScrollView *bannerView;

@end


@implementation JhtBannerView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        
        // 添加相关控件
        [self bavAddControl];
    }
    
    return self;
}

#pragma mark Init Method
/** 添加相关控件 */
- (void)bavAddControl {
    // 添加banner view（整条view）
    [self addSubview:self.bannerView];
    
    // 自己扩展 pageControl
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bannerView.frame) + 3, 100, 8)];
    pageControl.center = CGPointMake(self.center.x, pageControl.center.y);
    pageControl.numberOfPages = 4;
    pageControl.pageIndicatorTintColor = [UIColor purpleColor];
    self.bannerView.pageControl = pageControl;
    [self addSubview:self.bannerView.pageControl];
}



#pragma mark - Public Method
/** 点击ScrollView内部卡片 */
- (void)clickScrollViewInsideCardView:(clickInsideCardView)clickBlock {
    _block = clickBlock;
}



#pragma mark - Get
/** banner view（整条view） */
- (JhtBannerScrollView *)bannerView {
    if (!_bannerView) {
        _bannerView = [[JhtBannerScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), KBavCardViewHeight)];
        _bannerView.delegate = self;
        _bannerView.dataSource = self;
        _bannerView.minCoverViewAlpha = 0.2;
        _bannerView.autoTime = 3.0;
        _bannerView.leftRightMargin = 25 / 2.0 * WidthScale375;
        _bannerView.topBottomMargin = 15 / 2.0 * WidthScale375;
        _bannerView.orientation = BV_Orientation_Horizontal;
        _bannerView.isOpenAutoScroll = YES;
    }
    
    return _bannerView;
}



#pragma mark - Set
/** 图片数组 */
- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    [_bannerView reloadData];
}



#pragma mark - JhtBannerViewDelegate
/** 当前显示cardView的Size */
- (CGSize)sizeForCurrentCardViewInBannerView:(JhtBannerScrollView *)bannerView {
    return CGSizeMake(KBavCardViewWidth, KBavCardViewHeight);
}

/** 滚动到了某一个cardView */
- (void)bannerView:(JhtBannerScrollView *)bannerView didScrollToCardViewWithIndex:(NSInteger)index {
//    NSLog(@"滚动到了第 %ld 页", index);
}

/** 点击了第几个cardView
 *  bannerCardView：点击cardView
 *  index：点击bannerCardView的index
 */
- (void)bannerView:(JhtBannerScrollView *)bannerView didSelectCardView:(UIView *)cardView withCardViewIndex:(NSInteger)index {
    if (_block) {
        _block(index);
    }
}



#pragma mark - JhtBannerViewDataSource
/** 显示cardView的个数 */
- (NSInteger)numberOfCardViewInBannerView:(JhtBannerScrollView *)bannerView {
    return self.imageArray.count;
}

/** 单个cardView */
- (UIView *)bannerView:(JhtBannerScrollView *)bannerView cardViewForBannerViewAtIndex:(NSInteger)index {
    JhtBannerCardView *cardView = (JhtBannerCardView *)[bannerView dequeueReusableView];
    if (!cardView) {
        cardView = [[JhtBannerCardView alloc] initWithFrame:CGRectMake(0, 0, KBavCardViewWidth, KBavCardViewHeight)];
        cardView.tag = index;
    }
    // 加载网络图片
    [cardView.cardImageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[index]] placeholderImage:[UIImage imageNamed:self.placeholderImageName]];
    
    return cardView;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
