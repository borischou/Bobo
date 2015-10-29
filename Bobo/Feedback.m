//
//  Feedback.m
//  Bobo
//
//  Created by Zhouboli on 15/10/29.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "Feedback.h"

@implementation Feedback

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _status_id = [[dictionary objectForKey:@"id"] integerValue];
        _comments = [[dictionary objectForKey:@"comments"] integerValue];
        _reposts = [[dictionary objectForKey:@"reposts"] integerValue];
    }
    return self;
}

@end
