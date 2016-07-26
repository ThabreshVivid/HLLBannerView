//
//  HLLContentView.h
//  HLLBannerView
//
//  Created by Rocky Young on 16/7/26.
//  Copyright © 2016年 HLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLLContentView : UIView

@property (weak, nonatomic) IBOutlet UILabel *indexLabel;

+ (instancetype) loadWithNib;
@end
