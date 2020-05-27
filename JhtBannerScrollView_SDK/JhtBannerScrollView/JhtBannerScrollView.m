//
//  JhtBannerScrollView.m
//  JhtBannerScrollView
//
//  GitHub主页: https://github.com/jinht
//  CSDN博客: http://blog.csdn.net/anticipate91
//
//  Created by Jinht on 2017/6/2.
//  Copyright © 2017年 JhtBannerScrollView. All rights reserved.
//

#import "JhtBannerScrollView.h"

@interface JhtBannerScrollView () <UIScrollViewDelegate> {
    NSTimer *_bannerTimer;
    NSInteger _timerPageIndex;
    // 标识定时器是否为 暂停状态
    BOOL _timerIsPause;
    
    // 原始页数（代理传入的值）
    NSInteger _orginPageCount;
    // 总页数
    NSInteger _pageCount;
    // 单页的尺寸（代理传入的值）
    CGSize _pageSize;
    
    // 可视范围
    NSRange _visibleRange;
}
/** 装有cardView 数组 */
@property (nonatomic, strong) NSMutableArray *cardViewArray;
/** 可重用cardView 数组 */
@property (nonatomic, strong) NSMutableArray *reusableArray;

@property (nonatomic, strong) UIScrollView *insideScrollView;

@end


static const NSString *subviewClassName = @"JhtBannerCardView";

@implementation JhtBannerScrollView

#pragma mark - Init
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self bsvInitParam];
        
        [self bsvRegisterSystemNotification];
    }
    
    return self;
}

#pragma mark Init Method
/** 初始化相关参数 */
- (void)bsvInitParam {
    self.clipsToBounds = YES;
    
    _autoTime = 3.0;
    _currentIndex = 0;
    _minCoverViewAlpha = 0.4;
    
    _pageCount = 0;
    self.isCarousel = YES;
    self.isOpenAutoScroll = YES;
    self.leftRightMargin = 20.0;
    self.topBottomMargin = 15.0;
    
    _visibleRange = NSMakeRange(0, 0);
    
    // 由于UIScrollView在滚动之后会调用自己的layoutSubviews以及父View的layoutSubviews，这里为了避免scrollview滚动带来自己layoutSubviews的调用，所以给scrollView加了一层父View
    UIView *scrollViewBGView = [[UIView alloc] initWithFrame:self.bounds];
    // 自动调整view的宽度，保证左边距和右边距不变 || 自动调整view的高度，以保证上边距和下边距不变
    [scrollViewBGView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    scrollViewBGView.backgroundColor = [UIColor clearColor];
    [self addSubview:scrollViewBGView];
    [scrollViewBGView addSubview:self.insideScrollView];
}

#pragma mark Notification
/** 注册系统通知 */
- (void)bsvRegisterSystemNotification {
    // 后台 --> 前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueScroll) name:UIApplicationDidBecomeActiveNotification object:nil];
    // 前台 --> 后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseScroll) name:UIApplicationDidEnterBackgroundNotification object:nil];
}


#pragma mark - Public Method
- (void)reloadData {
    // 清空self.insideScrollView的子控件
    for (UIView *view in self.insideScrollView.subviews) {
        if ([NSStringFromClass(view.class) isEqualToString:(NSString *)subviewClassName]) {
            [view removeFromSuperview];
        }
    }
    
    // 销毁定时器，防止手势误触碰
    [self bsvDestroyTimer];
    
    // 重置pageCount
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfCardViewInBannerView:)]) {
        // 原始页数
        _orginPageCount = [_dataSource numberOfCardViewInBannerView:self];
        
        // 总页数
        if (self.isCarousel) {
            _pageCount = _orginPageCount == 1 ? 1 : [_dataSource numberOfCardViewInBannerView:self] * 3;
            
        } else {
            _pageCount = _orginPageCount == 1 ? 1 : [_dataSource numberOfCardViewInBannerView:self];
        }
        
        // 如果总页数为0，return
        if (_pageCount == 0) {
            return;
        }
        
        // 更新pageControl
        if (self.pageControl && [self.pageControl respondsToSelector:@selector(setNumberOfPages:)]) {
            [self.pageControl setNumberOfPages:_orginPageCount];
        }
    }
    
    // 重置 装有cardView的数组
    [self.cardViewArray removeAllObjects];
    for (NSInteger i = 0; i < _pageCount; i ++) {
        // 使用[NSNull null]占位
        [self.cardViewArray addObject:[NSNull null]];
    }
    
    // 重置 可重用cardView的数组 && 可视范围
    [self.reusableArray removeAllObjects];
    _visibleRange = NSMakeRange(0, 0);
    
    // 重置_pageSize
    // defaultSize
    CGFloat defaultPageSizeWidth = (CGRectGetWidth(self.bounds) - 4 * self.leftRightMargin);
    _pageSize = CGSizeMake(defaultPageSizeWidth, defaultPageSizeWidth * 9 / 16);
    // 获取 委托 中自定义的尺寸
    if (self.delegate && [self.delegate respondsToSelector:@selector(sizeForCurrentCardViewInBannerView:)]) {
        _pageSize = [self.delegate sizeForCurrentCardViewInBannerView:self];
    }
    
    // 重置self.insideScrollView
    switch (self.orientation) {
        // 横向
        case BV_Orientation_Horizontal: {
            self.insideScrollView.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
            self.insideScrollView.contentSize = CGSizeMake(_pageSize.width * _pageCount, _pageSize.height);
            CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            self.insideScrollView.center = theCenter;
            
            if (_orginPageCount > 1) {
                // 是否开启无限轮播
                if (self.isCarousel) {
                    // 滚到第二组第一张
                    [self.insideScrollView setContentOffset:CGPointMake(_pageSize.width * _orginPageCount, 0) animated:NO];
                    
                    _timerPageIndex = _orginPageCount;
                    
                    // 开启定时器
                    [self bsvStartTimer];
                    
                } else {
                    // 滚到开始
                    [self.insideScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                    
                    _timerPageIndex = _orginPageCount;
                }
            }
            break;
        }
            
        // 纵向
        case BV_Orientation_Vertical:{
            self.insideScrollView.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
            self.insideScrollView.contentSize = CGSizeMake(_pageSize.width, _pageSize.height * _pageCount);
            CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            self.insideScrollView.center = theCenter;
            
            if (_orginPageCount > 1) {
                // 是否开启无限轮播
                if (self.isCarousel) {
                    // 滚到第二组第一张
                    [self.insideScrollView setContentOffset:CGPointMake(0, _pageSize.height * _orginPageCount) animated:NO];
                    
                    _timerPageIndex = _orginPageCount;
                    
                    // 开启定时器
                    [self bsvStartTimer];
                    
                } else {
                    // 滚到第二组
                    [self.insideScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                    
                    _timerPageIndex = _orginPageCount;
                }
            }
            
            break;
        }
    }
    
    // 通过contentOffset调整insideScrollView内的cardView
    [self bsvAdjustCardViewWithContentOffset:self.insideScrollView.contentOffset];
    
    // 更新各个可见cardView
    [self bsvUpdateVisibleCardViewAppearance];
}

- (UIView *)dequeueReusableView {
    JhtBannerCardView *cardView = [self.reusableArray lastObject];
    
    if (cardView) {
        [self.reusableArray removeLastObject];
    }
    
    return cardView;
}

- (void)scrollToPageWithPageNumber:(NSUInteger)pageNumber {
    if (pageNumber < _pageCount) {
        // 销毁定时器，防止手势误触碰
        [self bsvDestroyTimer];
        
        if (self.isCarousel) {
            // 更新定时器用到的页数索引
            _timerPageIndex = pageNumber + _orginPageCount;
            // 取消之前的操作
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bsvStartTimer) object:nil];
            // 重新开启定时器
            [self performSelector:@selector(bsvStartTimer) withObject:nil afterDelay:0.5];
            
        } else {
            // 更新定时器用到的页数索引
            _timerPageIndex = pageNumber;
        }
        
        switch (self.orientation) {
            // 横向
            case BV_Orientation_Horizontal: {
                [self.insideScrollView setContentOffset:CGPointMake(_pageSize.width * _timerPageIndex, 0) animated:YES];
                
                break;
            }
                
            // 纵向
            case BV_Orientation_Vertical: {
                [self.insideScrollView setContentOffset:CGPointMake(0, _pageSize.height * _timerPageIndex) animated:YES];
                
                break;
            }
        }
        
        // 通过contentOffset调整insideScrollView内的cardView
        [self bsvAdjustCardViewWithContentOffset:self.insideScrollView.contentOffset];
        
        // 更新各个可见cardView
        [self bsvUpdateVisibleCardViewAppearance];
    }
}

- (void)continueScroll {
    // 判断定时器是否为 暂停状态
    if (_timerIsPause) {
        // 延迟0.2S调用，给人相应反应时间
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_bannerTimer) {
                [_bannerTimer setFireDate:[NSDate distantPast]];
            } else {
                // 开启
                [self bsvStartTimer];
            }
        });
        _timerIsPause = !_timerIsPause;
    }
}

- (void)pauseScroll {
    _timerIsPause = YES;
    
    [_bannerTimer setFireDate:[NSDate distantFuture]];
}


#pragma mark - Private Methods
- (void)bsvStartTimer {
    if (_orginPageCount > 1 && self.isOpenAutoScroll && self.isCarousel) {
        _bannerTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoTime target:self selector:@selector(bsvAutoNextCardView) userInfo:nil repeats:YES];
        // 使用NSRunLoopCommonModes模式，把timer加入到当前Run Loop中
        [[NSRunLoop mainRunLoop] addTimer:_bannerTimer forMode:NSRunLoopCommonModes];
    }
}

/** 自动滚动 */
- (void)bsvAutoNextCardView {
    // 更新定时器用到的页数索引
    _timerPageIndex ++;
//    NSLog(@"_timerPageIndex ==> %ld", _timerPageIndex);
    
    switch (self.orientation) {
            // 横向
        case BV_Orientation_Horizontal: {
            [self.insideScrollView setContentOffset:CGPointMake(_timerPageIndex * _pageSize.width, 0) animated:YES];
            
            break;
        }
            
            // 纵向
        case BV_Orientation_Vertical: {
            [self.insideScrollView setContentOffset:CGPointMake(0, _timerPageIndex * _pageSize.height) animated:YES];
            
            break;
        }
            
        default:
            break;
    }
}

/** 销毁定时器 */
- (void)bsvDestroyTimer {
    if (_bannerTimer) {
        [_bannerTimer invalidate];
        _bannerTimer = nil;
    }
}

/** 更新各个可见cardView */
- (void)bsvUpdateVisibleCardViewAppearance {
    if (_minCoverViewAlpha == 1.0 && self.leftRightMargin == 0 && self.topBottomMargin == 0) {
        return;
    }
    
    switch (self.orientation) {
            // 横向
        case BV_Orientation_Horizontal: {
            CGFloat offsetX = self.insideScrollView.contentOffset.x;
            
            for (NSInteger i = _visibleRange.location; i < (_visibleRange.location + _visibleRange.length); i ++) {
                JhtBannerCardView *cardView = [self.cardViewArray objectAtIndex:i];
                subviewClassName = NSStringFromClass([cardView class]);
                // 计算cardView坐标X值与偏移量X值的绝对值
                CGFloat originX = cardView.frame.origin.x;
                CGFloat delta = fabs(originX - offsetX);
                
                // 没有缩小效果情况下的原始Frame
                CGRect originCardViewFrame = CGRectMake(_pageSize.width * i, 0, _pageSize.width, _pageSize.height);
                
                if (delta < _pageSize.width) {
                    // _minCoverViewAlpha ===> 0（两侧 ==> 中间）
                    cardView.coverView.alpha = (delta / _pageSize.width) * _minCoverViewAlpha;
                    
                    CGFloat leftRightInset = self.leftRightMargin * delta / _pageSize.width;
                    CGFloat topBottomInset = self.topBottomMargin * delta / _pageSize.width;
                    
                    cardView.layer.transform = CATransform3DMakeScale((_pageSize.width - leftRightInset * 2) / _pageSize.width, (_pageSize.height - topBottomInset * 2) / _pageSize.height, 1.0);
                    // UIEdgeInsetsInsetRect: 表示在原来的rect基础上根据边缘距离内切一个rect出来
                    cardView.frame = UIEdgeInsetsInsetRect(originCardViewFrame, UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset));
                    
                } else {
                    // 中间 ==> 两侧
                    cardView.coverView.alpha = _minCoverViewAlpha;
                    cardView.layer.transform = CATransform3DMakeScale((_pageSize.width - self.leftRightMargin * 2) / _pageSize.width, (_pageSize.height - self.topBottomMargin * 2) / _pageSize.height, 1.0);
                    // UIEdgeInsetsInsetRect: 表示在原来的rect基础上根据边缘距离内切一个rect出来
                    cardView.frame = UIEdgeInsetsInsetRect(originCardViewFrame, UIEdgeInsetsMake(self.topBottomMargin, self.leftRightMargin, self.topBottomMargin, self.leftRightMargin));
                }
            }
            break;
        }
            
            // 纵向
        case BV_Orientation_Vertical:{
            CGFloat offset = self.insideScrollView.contentOffset.y;
            
            for (NSInteger i = _visibleRange.location; i < (_visibleRange.location + _visibleRange.length); i ++) {
                JhtBannerCardView *cardView = [self.cardViewArray objectAtIndex:i];
                subviewClassName = NSStringFromClass([cardView class]);
                CGFloat originY = cardView.frame.origin.y;
                CGFloat delta = fabs(originY - offset);
                
                // 没有缩小效果情况下的原始Frame
                CGRect originCardViewFrame = CGRectMake(0, _pageSize.height * i, _pageSize.width, _pageSize.height);
                
                if (delta < _pageSize.height) {
                    cardView.coverView.alpha = (delta / _pageSize.height) * _minCoverViewAlpha;
                    
                    CGFloat leftRightInset = self.leftRightMargin * delta / _pageSize.height;
                    CGFloat topBottomInset = self.topBottomMargin * delta / _pageSize.height;
                    
                    cardView.layer.transform = CATransform3DMakeScale((_pageSize.width - leftRightInset * 2) / _pageSize.width, (_pageSize.height - topBottomInset * 2) / _pageSize.height, 1.0);
                    cardView.frame = UIEdgeInsetsInsetRect(originCardViewFrame, UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset));
                    cardView.cardImageView.frame = cardView.bounds;
                    
                } else {
                    cardView.coverView.alpha = _minCoverViewAlpha;
                    cardView.frame = UIEdgeInsetsInsetRect(originCardViewFrame, UIEdgeInsetsMake(self.topBottomMargin, self.leftRightMargin, self.topBottomMargin, self.leftRightMargin));
                    cardView.cardImageView.frame = cardView.bounds;
                }
            }
        }
        default:
            break;
    }
}

/** 调整 cardView */
- (void)bsvAdjustCardViewWithContentOffset:(CGPoint)offset {
    // 计算_visibleRange
    CGPoint startPoint = CGPointMake(offset.x - CGRectGetMinX(self.insideScrollView.frame), offset.y - CGRectGetMinY(self.insideScrollView.frame));
    CGPoint endPoint = CGPointMake(startPoint.x + CGRectGetWidth(self.bounds), startPoint.y + CGRectGetHeight(self.bounds));
    
    switch (self.orientation) {
        // 横向
        case BV_Orientation_Horizontal: {
            // 屏幕可视区左侧第一个cardView（第一个）索引
            NSInteger startIndex = 0;
            for (NSInteger i = 0; i < self.cardViewArray.count; i ++) {
                if (_pageSize.width * (i + 1) > startPoint.x) {
                    startIndex = i;
                    break;
                }
            }
            
            // 屏幕可视区右侧第一个cardView（最后一个）索引
            NSInteger endIndex = startIndex;
            for (NSInteger i = startIndex; i < self.cardViewArray.count; i ++) {
                // 如果都不超过则取最后一个
                if (((_pageSize.width * (i + 1)) < endPoint.x && (_pageSize.width * (i + 2)) >= endPoint.x) || (i + 2) == self.cardViewArray.count) {
                    // i + 2 是个数，所以其index需要减去1
                    endIndex = i + 1;
                    break;
                }
            }
            
            // 分别向前后（可视区域外）扩展一个可见页，提高展示效率
            startIndex = MAX(startIndex - 1, 0);
            endIndex = MIN(endIndex + 1, self.cardViewArray.count - 1);
            // 定制visibleRange
            _visibleRange = NSMakeRange(startIndex, endIndex - startIndex + 1);
            
            // 向insideScrollView中添加CardView
            for (NSInteger i = startIndex; i <= endIndex; i ++) {
                [self bsvAddCardViewToInsideScrollViewWithIndex:i];
            }
            
            // 删除可视区域两侧cardViewArray里面的cardView
            for (NSInteger i = 0; i < startIndex; i ++) {
                [self bsvRemoveCardViewFromCardViewArrayWithIndex:i];
            }
            for (NSInteger i = endIndex + 1; i < self.cardViewArray.count; i ++) {
                [self bsvRemoveCardViewFromCardViewArrayWithIndex:i];
            }
            
            break;
        }
            
		// 纵向
        case BV_Orientation_Vertical: {
            NSInteger startIndex = 0;
            for (NSInteger i = 0; i < self.cardViewArray.count; i ++) {
                if (_pageSize.height * (i + 1) > startPoint.y) {
                    startIndex = i;
                    
                    break;
                }
            }
            
            NSInteger endIndex = startIndex;
            for (NSInteger i = startIndex; i < self.cardViewArray.count; i ++) {
                // 如果都不超过则取最后一个
                if (((_pageSize.height * (i + 1)) < endPoint.y && (_pageSize.height * (i + 2) >= endPoint.y)) || i + 2 == self.cardViewArray.count) {
                    // i + 2 是个数，所以其index需要减去1
                    endIndex = i + 1;
                    
                    break;
                }
            }
            
            // 分别向前后（可视区域外）扩展一个可见页，提高展示效率
            startIndex = MAX(startIndex - 1, 0);
            endIndex = MIN(endIndex + 1, self.cardViewArray.count - 1);
            
            _visibleRange.location = startIndex;
            _visibleRange.length = endIndex - startIndex + 1;
            
            // 向insideScrollView中添加CardView
            for (NSInteger i = startIndex; i <= endIndex; i ++) {
                [self bsvAddCardViewToInsideScrollViewWithIndex:i];
            }
            
            // 删除可视区域两侧cardViewArray里面的cardView
            for (NSInteger i = 0; i < startIndex; i ++) {
                [self bsvRemoveCardViewFromCardViewArrayWithIndex:i];
            }
            for (NSInteger i = (endIndex + 1); i < self.cardViewArray.count; i ++) {
                [self bsvRemoveCardViewFromCardViewArrayWithIndex:i];
            }
            
            break;
        }
    }
}

/** 添加 CardView */
- (void)bsvAddCardViewToInsideScrollViewWithIndex:(NSInteger)pageIndex {
    NSParameterAssert(pageIndex >= 0 && pageIndex < self.cardViewArray.count);
	
    UIView *cardView = [self.cardViewArray objectAtIndex:pageIndex];
    
    if ((NSObject *)cardView == [NSNull null]) {
        cardView = [_dataSource bannerView:self cardViewForBannerViewAtIndex:pageIndex % _orginPageCount];
        NSAssert(cardView != nil, @"cardView不能为nil");
        [self.cardViewArray replaceObjectAtIndex:pageIndex withObject:cardView];
        
        // 添加点击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bsvTapCardView:)];
        [cardView addGestureRecognizer:singleTap];
        cardView.tag = pageIndex % _orginPageCount;
        
        switch (self.orientation) {
                // 横向
            case BV_Orientation_Horizontal: {
                cardView.frame = CGRectMake(_pageSize.width * pageIndex, 0, _pageSize.width, _pageSize.height);
                
                break;
            }
                
                // 纵向
            case BV_Orientation_Vertical: {
                cardView.frame = CGRectMake(0, _pageSize.height * pageIndex, _pageSize.width, _pageSize.height);
                break;
            }
        }
        
        if (!cardView.superview) {
            [self.insideScrollView addSubview:cardView];
        }
    }
}

/** 点击 cardView */
- (void)bsvTapCardView:(UIGestureRecognizer *)ges {
    if ([self.delegate respondsToSelector:@selector(bannerView:didSelectCardView:withCardViewIndex:)]) {
        [self.delegate bannerView:self didSelectCardView:ges.view withCardViewIndex:ges.view.tag];
    }
}

/** 删除 cardViewArray 里的 cardView */
- (void)bsvRemoveCardViewFromCardViewArrayWithIndex:(NSInteger)index {
    UIView *cardView = [self.cardViewArray objectAtIndex:index];
    if ((NSObject *)cardView == [NSNull null]) {
        return;
    }
    
    // 向可重用的数组中加入 可重用cardView
    [self bsvAddReusableArrayWithCardView:cardView];
    
    if (cardView.superview) {
        [cardView removeFromSuperview];
    }
    
    [self.cardViewArray replaceObjectAtIndex:index withObject:[NSNull null]];
}

/** 向可重用的数组中加入 cardView */
- (void)bsvAddReusableArrayWithCardView:(UIView *)cardView {
    [self.reusableArray addObject:cardView];
}


#pragma mark - Getter
- (NSMutableArray *)cardViewArray {
    if (!_cardViewArray) {
        _cardViewArray = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _cardViewArray;
}

- (NSMutableArray *)reusableArray {
    if (!_reusableArray) {
        _reusableArray = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _reusableArray;
}

- (UIScrollView *)insideScrollView {
    if (!_insideScrollView) {
        _insideScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        _insideScrollView.scrollsToTop = NO;
        _insideScrollView.delegate = self;
        _insideScrollView.pagingEnabled = YES;
        _insideScrollView.clipsToBounds = NO;
        _insideScrollView.showsHorizontalScrollIndicator = NO;
        _insideScrollView.showsVerticalScrollIndicator = NO;
    }
    
    return _insideScrollView;
}


#pragma mark - Setter
- (void)setLeftRightMargin:(CGFloat)leftRightMargin {
    _leftRightMargin = leftRightMargin;
}

- (void)setTopBottomMargin:(CGFloat)topBottomMargin {
    _topBottomMargin = topBottomMargin;
}


#pragma mark - UIView(UIViewHierarchy)
/** 在父控件中移除后销毁定时器 */
- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    [self bsvDestroyTimer];
}


#pragma mark - UIViewGeometry
/** recursively calls -pointInside:withEvent:. point is in the receiver's coordinate system */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        CGPoint newPoint = CGPointZero;
        newPoint.x = point.x - self.insideScrollView.frame.origin.x + self.insideScrollView.contentOffset.x;
        newPoint.y = point.y - self.insideScrollView.frame.origin.y + self.insideScrollView.contentOffset.y;
        
        // insideScrollView内部
        if ([self.insideScrollView pointInside:newPoint withEvent:event]) {
            return [self.insideScrollView hitTest:newPoint withEvent:event];
        }
        
        // insideScrollView以外
        for (JhtBannerCardView *view in self.insideScrollView.subviews) {
            if (CGRectContainsPoint(view.frame, newPoint)) {
                return view;
            }
        }
        
        return self.insideScrollView;
    }
    
    return nil;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_orginPageCount == 0) {
        return;
    }
    
    NSInteger pageIndex;
    
    switch (self.orientation) {
        	// 横向
        case BV_Orientation_Horizontal: {
            pageIndex = (NSInteger)round(self.insideScrollView.contentOffset.x / _pageSize.width) % _orginPageCount;

            break;
        }
        
        	// 纵向
        case BV_Orientation_Vertical: {
            pageIndex = (NSInteger)round(self.insideScrollView.contentOffset.y / _pageSize.height) % _orginPageCount;
            
            break;
        }
        default:
            break;
    }
    
    // 通过contentOffset调整insideScrollView内的cardView
    [self bsvAdjustCardViewWithContentOffset:scrollView.contentOffset];
    // 更新各个可见cardView
    [self bsvUpdateVisibleCardViewAppearance];
    
    if (self.pageControl && [self.pageControl respondsToSelector:@selector(setCurrentPage:)]) {
        [self.pageControl setCurrentPage:pageIndex];
    }
    
    if ([_delegate respondsToSelector:@selector(bannerView:didScrollToCardViewWithIndex:)] && (_currentIndex != pageIndex) && (pageIndex >= 0)) {
        [_delegate bannerView:self didScrollToCardViewWithIndex:pageIndex];
    }
    
    _currentIndex = pageIndex;
    
    // 是否开启无限轮播
    if (self.isCarousel && (_orginPageCount > 1)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 通过各组之间的切换实现循环
            [self bsvAdjustEachGroupToRealizeCycle];
        });
    }
}

/** 开始拖拽 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 销毁定时器
    [self bsvDestroyTimer];
}

/** 结束拖拽 */
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    NSLog(@"velocity ===> %@", NSStringFromCGPoint(velocity));
//    NSLog(@"scrollViewWillEndDragging --> _timerPageIndex = %ld", _timerPageIndex);
    
    if (_orginPageCount > 1 && self.isOpenAutoScroll && self.isCarousel) {
        // 销毁定时器，防止手势误触碰
        [self bsvDestroyTimer];
        
        // 重新初始化定时器
        _bannerTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoTime target:self selector:@selector(bsvAutoNextCardView) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_bannerTimer forMode:NSRunLoopCommonModes];
        
        switch (self.orientation) {
                // 横向
            case BV_Orientation_Horizontal: {
                if (velocity.x > 0) {
                    // 右 --> 左
                    _timerPageIndex = self.pageControl.currentPage + _orginPageCount + 1;
                } else {
                    // 左 --> 右
                    _timerPageIndex = self.pageControl.currentPage + _orginPageCount - 1;
                }
                
                break;
            }
                
                // 纵向
            case BV_Orientation_Vertical: {
                if (velocity.y > 0) {
                    // 下 --> 上
                    _timerPageIndex = self.pageControl.currentPage + _orginPageCount + 1;
                } else {
                    // 上 --> 下
                    _timerPageIndex = self.pageControl.currentPage + _orginPageCount - 1;
                }
                
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark UIScrollViewDelegate Method
/** 通过各组之间的切换实现循环 */
- (void)bsvAdjustEachGroupToRealizeCycle {
    switch (self.orientation) {
            // 横向
        case BV_Orientation_Horizontal: {
            if ((NSInteger)round(self.insideScrollView.contentOffset.x / _pageSize.width) >= (2 * _orginPageCount)) {
                // 3组 ===> 2组（3组第1个 ====> 2组第1个）
                [self.insideScrollView setContentOffset:CGPointMake(_pageSize.width * _orginPageCount, 0) animated:NO];
                
                _timerPageIndex = _orginPageCount;
            }
            
            if ((self.insideScrollView.contentOffset.x / _pageSize.width) <= (_orginPageCount - 1)) {
                // 1组 ===> 2组
                [self.insideScrollView setContentOffset:CGPointMake((2 * _orginPageCount - 1) * _pageSize.width, 0) animated:NO];
                
                _timerPageIndex = 2 * _orginPageCount - 1;
            }
            
            break;
        }
            // 纵向
        case BV_Orientation_Vertical: {
            if (floor(self.insideScrollView.contentOffset.y / _pageSize.height) >= (2 * _orginPageCount)) {
                    [self.insideScrollView setContentOffset:CGPointMake(0, _pageSize.height * _orginPageCount) animated:NO];
                    
                    _timerPageIndex = _orginPageCount;
            }
            
            if ((self.insideScrollView.contentOffset.y / _pageSize.height) <= (_orginPageCount - 1)) {
                [self.insideScrollView setContentOffset:CGPointMake(0, (2 * _orginPageCount - 1) * _pageSize.height) animated:NO];
                _timerPageIndex = 2 * _orginPageCount;
            }
            
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - dealloc
- (void)dealloc {
    if (_bannerTimer) {
        [_bannerTimer invalidate];
        _bannerTimer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
