//
//  HLLBannerView.h
//  HLLBannerView
//
//  Created by Rocky Young on 16/7/26.
//  Copyright © 2016年 HLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HLLBannerViewDataSource,HLLBannerViewDelegate;

@interface HLLBannerView : UIView

/**
 *  是否自动滑动, 默认为 YES
 */
@property (nonatomic, assign ,getter=isAutoScroll) IBInspectable BOOL autoScroll;

/**
 *  UIPageControl, 用于指示滚动视图，可以按需求对其进行自定义甚至隐藏
 */
@property (nonatomic, strong, readonly) UIPageControl *pageControl;

@property (nonatomic ,weak) IBOutlet id<HLLBannerViewDataSource> dataSource;
@property (nonatomic ,weak) IBOutlet id<HLLBannerViewDelegate> delegate;

#pragma mark - API

/**
 *  当对BannerView的内容进行修改之后调用
 */
- (void)reloadData;

@end

@protocol HLLBannerViewDataSource <NSObject>

@required
/**
 *  用于设置BannerView内容视图的个数
 *
 *  @param bannerView HLLBannerView实例
 *
 *  @return 内容视图的个数
 */
- (NSInteger)hll_numberOfItemsOfBannerView:(HLLBannerView *)bannerView;


/**
 *  用于定制BannerView中进行滚动的视图样式，可以使用xib进行初始化，也可以使用通过Frame布局的视图，但是如果要是使用Masnory自动布局的视图却不能正常显示
 *
 *  @param bannerView HLLBannerView实例
 *  @param index      当前内容视图的索引
 *
 *  @return 定制的内容视图
 */
- (UIView *)hll_bannerView:(HLLBannerView *)bannerView viewForItemAtIndex:(NSInteger)index;

@end

@protocol HLLBannerViewDelegate <NSObject>

@optional

/**
 *  当点击内容视图的时候的响应方法
 *
 *  @param bannerView HLLBannerView实例
 *  @param index      当前内容视图的索引
 */
- (void)hll_bannerView:(HLLBannerView *)bannerView didSelectItemAtIndex:(NSInteger)index;

@end

/**
 *  用于设置UIPageControl控件的高度
 */
extern CGFloat const pageControlHeight;
