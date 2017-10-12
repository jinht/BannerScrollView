//
//  JhtBannerScrollView.h
//  JhtBannerScrollView
//
//  GitHub主页: https://github.com/jinht
//  CSDN博客: http://blog.csdn.net/anticipate91
//
//  Created by Jinht on 2017/6/2.
//  Copyright © 2017年 JhtBannerScrollView. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JhtBannerCardView.h"
#import "JhtBannerScrollViewProtocol.h"
@class JhtBannerScrollView;

/** 375的比例尺 */
#define WidthScale375 (([[UIScreen mainScreen] bounds].size.width) / 375)


/** banner view（整条view） */
@interface JhtBannerScrollView : UIView

#pragma mark - property(optional)
/** banner滚动方向 */
typedef NS_ENUM(NSUInteger, JhtBannerViewOrientation) {
    // 横向
    BV_Orientation_Horizontal,
    // 纵向
    BV_Orientation_Vertical,
};
/** 滚动方向
 *	default：BV_Orientation_Horizontal
 */
@property (nonatomic, assign) JhtBannerViewOrientation orientation;

/** 非当前页的透明比例（蒙板alpha）
 *	default：0.4
 */
@property (nonatomic, assign) CGFloat minCoverViewAlpha;
/** View之间的左右间距
 *	default：20.0
 */
@property (nonatomic, assign) CGFloat leftRightMargin;
/** 两侧小的View与中间View的高度差
 *	default：15.0
 */
@property (nonatomic, assign) CGFloat topBottomMargin;

/** 是否开启自动滚动
 *	default：YES
 */
@property (nonatomic, assign) BOOL isOpenAutoScroll;
/** 是否开启无限轮播
 *	default：YES
 */
@property (nonatomic, assign) BOOL isCarousel;
/** 自动切换视图的时间
 *	default：3.0
 */
@property (nonatomic, assign) NSTimeInterval autoTime;

/** 当前是第几页 */
@property (nonatomic, assign, readonly) NSInteger currentIndex;
/** pageControl（自定义扩展） */
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, assign)  id<JhtBannerScrollViewDataSource> dataSource;
@property (nonatomic, assign)  id<JhtBannerScrollViewDelegate> delegate;



#pragma mark - Public Method
/** 刷新视图 */
- (void)reloadData;

/** 获取可重复使用的卡片View（cardView） */
- (UIView *)dequeueReusableView;

/** 滚动到指定的页面 */
- (void)scrollToPageWithPageNumber:(NSUInteger)pageNumber;

/** 继续滚动 */
- (void)scrollContinue;
/** 暂停滚动 */
- (void)scrollPause;


@end
