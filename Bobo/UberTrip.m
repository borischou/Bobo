//
//  UberTrip.m
//  Bobo
//
//  Created by Zhouboli on 15/7/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "UberTrip.h"

@implementation UberTrip

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _distance_unit = [dictionary objectForKey:@"distance_unit"];
        _duration_estimate = [[dictionary objectForKey:@"duration_estimate"] integerValue];
        _distance_estimate = [[dictionary objectForKey:@"distance_estimate"] floatValue];
    }
    return self;
}

@end
