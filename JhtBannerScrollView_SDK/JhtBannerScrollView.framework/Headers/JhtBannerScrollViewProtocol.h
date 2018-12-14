//
//  JhtBannerScrollViewProtocol.h
//  JhtBannerScrollView
//
//  GitHub主页: https://github.com/jinht
//  CSDN博客: http://blog.csdn.net/anticipate91
//
//  Created by Jinht on 2017/6/10.
//  Copyright © 2017年 JhtBannerScrollView. All rights reserved.
//

#ifndef JhtBannerScrollViewProtocol_h
#define JhtBannerScrollViewProtocol_h


@class JhtBannerScrollView;

#pragma mark - JhtBannerScrollViewDelegate
@protocol JhtBannerScrollViewDelegate <NSObject>
@optional
/** 当前显示cardView的Size */
- (CGSize)sizeForCurrentCardViewInBannerView:(JhtBannerScrollView *)bannerView;

/** 滚动到了某一个cardView */
- (void)bannerView:(JhtBannerScrollView *)bannerView didScrollToCardViewWithIndex:(NSInteger)index;

/** 点击了第几个cardView
 *  bannerCardView：点击cardView
 *  index：点击bannerCardView的index
 */
- (void)bannerView:(JhtBannerScrollView *)bannerView didSelectCardView:(UIView *)cardView withCardViewIndex:(NSInteger)index;

@end



#pragma mark - JhtBannerScrollViewDataSource
@protocol JhtBannerScrollViewDataSource <NSObject>
@required
/** 显示cardView的个数 */
- (NSInteger)numberOfCardViewInBannerView:(JhtBannerScrollView *)bannerView;

/** 单个cardView */
- (UIView *)bannerView:(JhtBannerScrollView *)bannerView cardViewForBannerViewAtIndex:(NSInteger)index;

@end



#endif /* JhtBannerScrollViewProtocol_h */
