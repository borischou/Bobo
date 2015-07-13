//
//  UberEstimate.m
//  Bobo
//
//  Created by Zhouboli on 15/7/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "UberEstimate.h"

@implementation UberEstimate

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        if (![dictionary[@"price"] isEqual:[NSNull null]]) {
            _price = [[UberEstimatedPrice alloc] initWithDictionary:dictionary[@"price"]];
        }
        if (![dictionary[@"trip"] isEqual:[NSNull null]]) {
            _trip = [[UberTrip alloc] initWithDictionary:dictionary[@"trip"]];
        }
        _pickup_estimate = [[dictionary objectForKey:@"pickup_estimate"] integerValue];
    }
    return self;
}

@end
