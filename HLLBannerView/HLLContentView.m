//
//  HLLContentView.m
//  HLLBannerView
//
//  Created by Rocky Young on 16/7/26.
//  Copyright © 2016年 HLL. All rights reserved.
//

#import "HLLContentView.h"

@implementation HLLContentView

+ (instancetype) loadWithNib{
    
    return [[[NSBundle mainBundle] loadNibNamed:@"HLLContentView" owner:nil options:nil] firstObject];
}
@end
