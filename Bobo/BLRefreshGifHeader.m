//
//  BLRefreshGifHeader.m
//  BankwelLiuxue
//
//  Created by Zhouboli on 16/1/29.
//  Copyright © 2016年 bankwel. All rights reserved.
//

#import "BLRefreshGifHeader.h"

@implementation BLRefreshGifHeader

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.lastUpdatedTimeLabel.hidden = YES;
        self.stateLabel.hidden = YES;
        
        NSArray *images = @[[UIImage imageNamed:@"cow1"], [UIImage imageNamed:@"cow2"]];
        
        [self setImages:images forState:MJRefreshStateIdle];
        [self setImages:images forState:MJRefreshStatePulling];
        [self setImages:images forState:MJRefreshStateRefreshing];
    }
    return self;
}

@end
