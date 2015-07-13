//
//  UberEstimatedPrice.m
//  Bobo
//
//  Created by Zhouboli on 15/7/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "UberEstimatedPrice.h"

@implementation UberEstimatedPrice

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _surge_confirmation_href = [dictionary objectForKey:@"surge_confirmation_href"];
        _high_estimate = [[dictionary objectForKey:@"high_estimate"] integerValue];
        _surge_confirmation_id = [dictionary objectForKey:@"surge_confirmation_id"];
        _minimum = [[dictionary objectForKey:@"minimum"] integerValue];
        _low_estimate = [[dictionary objectForKey:@"low_estimate"] integerValue];
        _surge_multiplier = [[dictionary objectForKey:@"surge_multiplier"] floatValue];
        _display = [dictionary objectForKey:@"display"];
        _currency_code = [dictionary objectForKey:@"currency_code"];
    }
    return self;
}

@end
