//
//  HLLBannerView.m
//  HLLBannerView
//
//  Created by Rocky Young on 16/7/26.
//  Copyright © 2016年 HLL. All rights reserved.
//

#import "HLLBannerView.h"

@interface NSTimer (HLL)

- (void)pauseTimer;

- (void)resumeTimer;

- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;

@end

CGFloat const pageControlHeight = 25.0f;

@interface HLLBannerView ()<UIScrollViewDelegate>
{
    CGFloat scrollViewStartContentOffsetX;
}

@property (nonatomic, strong, readwrite) UIPageControl *pageControl;

@property (nonatomic, assign) CGFloat        animationDuration;

@property (nonatomic, assign) NSInteger      currentPageIndex;

@property (nonatomic, assign) NSInteger      totalItemCount;

@property (nonatomic, strong) NSMutableArray * contentViews;

@property (nonatomic, assign) NSInteger      itemCount;

@property (nonatomic, strong) UIScrollView   * scrollView;

@property (nonatomic, strong) NSTimer        * timer;

@end

@implementation HLLBannerView

#pragma mark - System

/**
 *  使用init进行初始化的时候由于BannerView是没有Frame的，所以会有一个bug：第一个contentView不是第一个而是最后一个，所以，建议使用-initWithFrame:
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self configureDefault];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configureDefault];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self configureDefault];
    }
    return self;
}

- (void)layoutSubviews{

    [super layoutSubviews];
    
    self.scrollView.frame = CGRectMake(0,
                                       0,
                                       CGRectGetWidth(self.bounds),
                                       CGRectGetHeight(self.bounds) - 0);
    self.pageControl.frame = CGRectMake(0,
                                        CGRectGetHeight(self.bounds) - pageControlHeight,
                                        CGRectGetWidth(self.bounds),
                                        pageControlHeight);
    
    [self reloadData];
}
#pragma mark - Private

- (void) configureDefault{
    
    // Default
    self.autoresizesSubviews = YES;

    self.totalItemCount      = 0;
    self.currentPageIndex    = 0;
    self.autoScroll          = YES;
    self.currentPageIndex    = 0;
    self.animationDuration   = 3.0f;
    
    // UIScrollView
    self.scrollView                                = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.autoresizingMask               = 0xFF;
    self.scrollView.backgroundColor                = [UIColor clearColor];
    self.scrollView.contentMode                    = UIViewContentModeCenter;
    self.scrollView.contentSize                    = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    self.scrollView.delegate                       = self;
    self.scrollView.pagingEnabled                  = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    // UIPageControl
    self.pageControl                        = [[UIPageControl alloc] init];
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.backgroundColor        = [UIColor clearColor];
    [self addSubview:self.pageControl];
    
    // NSTimer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration
                                                  target:self
                                                selector:@selector(animationTimerDidFired:)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer pauseTimer];
}

- (void)configContentViews
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewContentDataSource];
    
    NSInteger counter = 0;
    for (UIView *contentView in self.contentViews) {
        
        contentView.userInteractionEnabled = YES;
        
        // LongPress Gesture
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewLongPressGestureAction:)];
        [contentView addGestureRecognizer:longPressGesture];
        
        // Tap Gesture
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [contentView addGestureRecognizer:tapGesture];
        
        // Frame
        CGRect rightRect = contentView.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        rightRect.size = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        contentView.frame = rightRect;
        
        [self.scrollView addSubview:contentView];
    }
    if (self.totalItemCount > 1) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, 0)];
    }
}

/**
 *  设置scrollView的content数据源，即contentViews
 */
- (void)setScrollViewContentDataSource
{
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
    
    if (self.contentViews == nil) {
        self.contentViews = [@[] mutableCopy];
    }
    [self.contentViews removeAllObjects];
  
    if (self.totalItemCount > 0) {
        
        id set = (self.totalItemCount == 1)?[NSSet setWithObjects:@(previousPageIndex),@(_currentPageIndex),@(rearPageIndex), nil]:@[@(previousPageIndex),@(_currentPageIndex),@(rearPageIndex)];
        
        for (NSNumber *tempNumber in set) {
            
            NSInteger tempIndex = [tempNumber integerValue];
            
            if ([self isValidArrayIndex:tempIndex]) {
                
                UIView * contentView = [self.dataSource hll_bannerView:self viewForItemAtIndex:tempIndex];
                [self.contentViews addObject:contentView];
            }
        }
    }
}

- (BOOL)isValidArrayIndex:(NSInteger)index
{
    if (index >= 0 && index <= self.totalItemCount - 1) {
        return YES;
    } else {
        return NO;
    }
}

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1) {
        return self.totalItemCount - 1;
    } else if (currentPageIndex == self.totalItemCount) {
        return 0;
    } else {
        return currentPageIndex;
    }
}

#pragma mark - API

- (void)reloadData{
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(hll_numberOfItemsOfBannerView:)]) {
        self.totalItemCount = [self.dataSource hll_numberOfItemsOfBannerView:self];
    }
    
    if (self.totalItemCount) {
        self.pageControl.numberOfPages = self.totalItemCount;
    }
    self.pageControl.hidden = !(self.totalItemCount && self.totalItemCount != 1);
    
    if (self.totalItemCount > 0) {
        
        if (self.totalItemCount > 1) {
            
            self.scrollView.scrollEnabled = YES;
            self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
            
            if (self.autoScroll) {
                [self.timer resumeTimerAfterTimeInterval:self.animationDuration];
            }
        } else {
            self.scrollView.scrollEnabled = NO;
        }
        [self configContentViews];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0)
                        animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollViewStartContentOffsetX = scrollView.contentOffset.x;
    
    [self.timer pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.autoScroll) {
        [self.timer resumeTimerAfterTimeInterval:self.animationDuration];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    if (self.totalItemCount == 2) {
        if (scrollViewStartContentOffsetX < contentOffsetX) {
            
            UIView *tempView = (UIView *)[self.contentViews lastObject];
            tempView.frame = (CGRect){{2 * CGRectGetWidth(scrollView.frame),0},tempView.frame.size};
        } else if (scrollViewStartContentOffsetX > contentOffsetX) {
            
            UIView *tempView = (UIView *)[self.contentViews firstObject];
            tempView.frame = (CGRect){{0,0},tempView.frame.size};
        }
    }
    
    if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
        
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
        [self configContentViews];
    }
    if(contentOffsetX <= 0) {
        
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
        [self configContentViews];
    }
    
    self.pageControl.currentPage = self.currentPageIndex;
}

#pragma mark - Action

- (void)animationTimerDidFired:(NSTimer *)timer
{
    CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame), self.scrollView.contentOffset.y);
    
    [self.scrollView setContentOffset:newOffset animated:YES];
}

- (void)contentViewLongPressGestureAction:(UILongPressGestureRecognizer *)longPressGesture
{
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [self.timer pauseTimer];
    }
    if (longPressGesture.state == UIGestureRecognizerStateEnded) {
        [self.timer resumeTimer];
    }
}

- (void)contentViewTapAction:(UITapGestureRecognizer *)tapGesture
{
    if ([self.delegate respondsToSelector:@selector(hll_bannerView:didSelectItemAtIndex:)]) {
        [self.delegate hll_bannerView:self didSelectItemAtIndex:self.currentPageIndex];
    }
}

@end

@implementation NSTimer (HLL)


-(void)pauseTimer
{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate distantFuture]];
}


-(void)resumeTimer
{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate date]];
}

- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval
{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}


@end