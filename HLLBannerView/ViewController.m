//
//  ViewController.m
//  HLLBannerView
//
//  Created by Rocky Young on 16/7/26.
//  Copyright © 2016年 HLL. All rights reserved.
//

#import "ViewController.h"
#import "HLLBannerView.h"
#import "HLLContentView.h"

@interface ViewController ()<HLLBannerViewDataSource,HLLBannerViewDelegate>

@property (weak, nonatomic) IBOutlet HLLBannerView *bannerView;

@property (nonatomic ,assign) NSInteger count;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    HLLBannerView * bannerView = [[HLLBannerView alloc] initWithFrame:CGRectMake(0, 0, 375, 200)];
    bannerView.delegate        = self;
    bannerView.dataSource      = self;
    bannerView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:bannerView];

    self.count = 2;
    
    [self performSelector:@selector(test) withObject:nil afterDelay:6];
}

- (void) test{
    
    self.count = 1;
    
    [self.bannerView reloadData];
}
#pragma mark - HLLBannerViewDataSource

- (NSInteger)hll_numberOfItemsOfBannerView:(HLLBannerView *)bannerView{

    return self.count;
}

- (UIView *)hll_bannerView:(HLLBannerView *)bannerView viewForItemAtIndex:(NSInteger)index{

    if (![bannerView isEqual:self.bannerView]) {// 用于测试自动布局的视图

        HLLContentView * contentView = [HLLContentView loadWithNib];
        contentView.indexLabel.text = [NSString stringWithFormat:@"index:%ld",(long)index];
        return contentView;
        
    }else{// 用于测试Frame布局的视图
    
        UIView * contentView        = [[UIView alloc] init];
        contentView.backgroundColor = [UIColor orangeColor];

        UILabel * label             = [[UILabel alloc] init];
        label.backgroundColor       = [UIColor lightGrayColor];
        label.textColor             = [UIColor whiteColor];
        label.text                  = [NSString stringWithFormat:@"index:%ld",(long)index];
        
        label.textAlignment         = NSTextAlignmentCenter;
        [contentView addSubview:label];
        
#if 1
        label.frame                 = CGRectMake(0, 0, 200, 30);
        label.center                = CGPointMake(bannerView.bounds.size.width/2, bannerView.bounds.size.height/2);
#else
        [label mas_makeConstraints:^(MASConstraintMaker *make){
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(40);
            make.centerX.mas_equalTo(bannerView.bounds.size.width/2);
            make.centerY.mas_equalTo(bannerView.bounds.size.height/2);
        }];
#endif
        
        return contentView;
    }
}

- (void)hll_bannerView:(HLLBannerView *)bannerView didSelectItemAtIndex:(NSInteger)index{

    NSLog(@"You tap on <%ld> contentView.",(long)index);
}

@end
