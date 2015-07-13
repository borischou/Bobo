//
//  WeiboCountsModel.m
//  Bobo
//
//  Created by Zhouboli on 15/6/25.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "WeiboCountsModel.h"

@implementation WeiboCountsModel

-(id)initWithWeiboCounts:(NSDictionary *)weiboCounts
{
    self = [super init];
    if (self) {
        _followers_count = [weiboCounts[@"followers_count"] integerValue];
        _friends_count = [weiboCounts[@"friends_count"] integerValue];
        _statuses_count = [weiboCounts[@"statuses_count"] integerValue];
    }
    return self;
}

@end
