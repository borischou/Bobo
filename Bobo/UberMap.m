//
//  UberMap.m
//  Bobo
//
//  Created by Zhouboli on 15/7/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "UberMap.h"

@implementation UberMap

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _request_id = [dictionary objectForKey:@"request_id"];
        _href = [dictionary objectForKey:@"href"];
    }
    return self;
}

@end
