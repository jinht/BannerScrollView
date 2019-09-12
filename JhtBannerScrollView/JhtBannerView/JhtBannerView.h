//
//  JhtBannerView.h
//  JhtBannerScrollView
//
//  GitHub主页: https://github.com/jinht
//  CSDN博客: http://blog.csdn.net/anticipate91
//
//  Created by Jinht on 2017/6/2.
//  Copyright © 2017年 JhtBannerScrollView. All rights reserved.
//

#import <UIKit/UIKit.h>

/** banner ScrollView */
@interface JhtBannerView : UIView

#pragma mark - property
#pragma mark required
/** 图片数组
 *  tips: [imageStr containsString:@"http"] ? 网络图片 : 本地图片（不会使用placeholderImageName作为占位图）
 */
@property (nonatomic, strong) NSArray<NSString *> *imageArray;

#pragma mark optional
/** 占位图片名（本地） */
@property (nonatomic, strong) NSString *placeholderImageName;


#pragma mark - Public Method
/** 点击内部卡片View回调
 *  index: 在内容数组里的索引
 */
typedef void(^clickInsideCardView)(NSInteger index);
/** 点击ScrollView内部卡片 */
- (void)clickScrollViewInsideCardView:(clickInsideCardView)clickBlock;


@end
