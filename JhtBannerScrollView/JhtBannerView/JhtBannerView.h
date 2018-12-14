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
/** 图片数组 */
@property (nonatomic, strong) NSArray *imageArray;


#pragma mark optional
/** 占位图片名（本地） */
@property (nonatomic, strong) NSString *placeholderImageName;



#pragma mark - Public Method
/** 点击内部卡片View回调的Block
 *  index：在内容数组里的索引
 */
typedef void(^clickInsideCardView)(NSInteger index);
/** 点击ScrollView内部卡片 */
- (void)clickScrollViewInsideCardView:(clickInsideCardView)clickBlock;


@end
