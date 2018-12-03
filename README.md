## JhtBannerScrollView

### 先上图，看一下是否符合你的场景吧！
<img src="https://raw.githubusercontent.com/jinht/BannerScrollView/master/ReadMEImages/Gif/1.gif" width=240 height=426 />

### Function Description
1. 无限循环自动滚动卡片
2. 三段式循环滚动广告卡片
     
### how to use
#### 1. podfile 
```oc
platform:ios, '8.0'
pod 'JhtBannerScrollView', '~> 1.0.1'
```


#### 2. 相关参数配置简述：各属性均有其相应default value，使用时亦可根据自己需求进行相应修改
##### a. 滚动方向
```oc
/** banner滚动方向 */
typedef NS_ENUM(NSUInteger, JhtBannerViewOrientation) {
    // 横向
    BV_Orientation_Horizontal,
    // 纵向
    BV_Orientation_Vertical,
};
/** 滚动方向
 *  default：BV_Orientation_Horizontal
 */
@property (nonatomic, assign) JhtBannerViewOrientation orientation;
```
	
##### b. alpha && space
```oc
/** 非当前页的透明比例（蒙板alpha）
 *  default：0.4
 */
@property (nonatomic, assign) CGFloat minCoverViewAlpha;
/** View之间的左右间距
 *  default：20.0
 */
@property (nonatomic, assign) CGFloat leftRightMargin;
/** 两侧小的View与中间View的高度差
 *  default：15.0
 */
@property (nonatomic, assign) CGFloat topBottomMargin;
```

##### c. 滚动 && 循环
```oc
/** 是否开启自动滚动
 *  default：YES
 */
@property (nonatomic, assign) BOOL isOpenAutoScroll;
/** 是否开启无限轮播
 *  default：YES
 */
@property (nonatomic, assign) BOOL isCarousel;
/** 自动切换视图的时间
 *  default：3.0
 */
@property (nonatomic, assign) NSTimeInterval autoTime;
```


#### 3. Public Method：可根据自己需求使用相应Method
```oc
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
```


* 在demo中可以查看相关的使用和配置方法


      
### Remind
* ARC
* iOS >= 8.0
* iPhone \ iPad 
       
## Hope
* If you find bug when used，Hope you can Issues me，Thank you or try to download the latest code of this framework to see the BUG has been fixed or not
* If you find the function is not enough when used，Hope you can Issues me，I very much to add more useful function to this framework ，Thank you !
