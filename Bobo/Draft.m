//
//  Draft.m
//  Bobo
//
//  Created by Zhouboli on 15/10/16.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "Draft.h"

@implementation Draft

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _text = dictionary[@"text"];
        _draftType = [dictionary[@"flag"] integerValue];
        _url = dictionary[@"url"];
        _images = dictionary[@"images"];
        _time = dictionary[@"time"];
        _params = dictionary[@"params"];
    }
    return self;
}

@end