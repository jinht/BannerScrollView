//
//  JhtBannerCardView.m
//  JhtBannerScrollView
//
//  GitHub主页: https://github.com/jinht
//  CSDN博客: http://blog.csdn.net/anticipate91
//
//  Created by Jinht on 2017/6/2.
//  Copyright © 2017年 JhtBannerScrollView. All rights reserved.
//

#import "JhtBannerCardView.h"

@implementation JhtBannerCardView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // 中间显示的图片（当前主图）
        [self addSubview:self.cardImageView];
        
        // 覆盖在mainImageView上的view（蒙板）
        [self addSubview:self.coverView];
    }
    
    return self;
}


#pragma mark - Get
- (UIImageView *)cardImageView {
    if (!_cardImageView) {
        _cardImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        _cardImageView.userInteractionEnabled = YES;
    }
    
    return _cardImageView;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.bounds];
        
        _coverView.backgroundColor = [UIColor whiteColor];
    }
    
    return _coverView;
}


@end
