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
        
        _height = [self draftHeight];
    }
    return self;
}

-(float)draftHeight
{
    if (_draftType != DraftTypeOriginal) { //可能有original字段
        if ([_params.allKeys containsObject:@"original"] &&
            ![_params[@"original"] isEqual:[NSNull null]] &&
            ![_params[@"original"] isEqualToString:@""])
        { //包含转发内容，高度扩大
            return 105;
        }
    }
    return 80;
}

@end