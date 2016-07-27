HLLBannerView

====

`HLLBannerView`是一个使用UIScrollView+NSTimer实现的可以无限滚动的BannerView，支持使用Xib以及Frame布局的ContentView，使用数据源以及代理为控件提供显示数据以及捕获交互事件。

在显示内容视图个数`1`的时候自动禁掉滚动事件，当内容数据有更新，在更新完成之后调用`-reLoadData`可以对BannerView进行内容的重新布局。


### Content


#### HLLBannerViewDataSource

* 用于设置BannerView内容视图的个数

```
- (NSInteger)hll_numberOfItemsOfBannerView:(HLLBannerView *)bannerView;
```

* 用于定制BannerView中进行滚动的视图样式，可以使用xib进行初始化，也可以使用通过Frame布局的视图，但是如果要是使用Masnory自动布局的视图却不能正常显示

```
- (UIView *)hll_bannerView:(HLLBannerView *)bannerView viewForItemAtIndex:(NSInteger)index;
```

#### HLLBannerViewDelegate

当点击内容视图的时候的响应方法

```
- (void)hll_bannerView:(HLLBannerView *)bannerView didSelectItemAtIndex:(NSInteger)index;
```

#### Bug

* 使用init进行初始化的时候由于BannerView是没有Frame的，所以会有一个bug：第一个contentView不是第一个而是最后一个，所以，建议使用`-initWithFrame:`

* 通过数据源返回的ContentView个数如果一开始为`0`，通过某些需要延时获得数据，比如网络请求获得ContentView个数为`1`的时候ContentView就不会显示，而如果是`1`以外的个数就没有问题
 