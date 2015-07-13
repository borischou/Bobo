//
//  UberCharge.m
//  Bobo
//
//  Created by Zhouboli on 15/7/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "UberCharge.h"

@implementation UberCharge

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _name = [dictionary objectForKey:@"name"];
        _amount = [[dictionary objectForKey:@"amount"] floatValue];
        _type = [dictionary objectForKey:@"type"];
    }
    return self;
}

@end
