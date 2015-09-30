//
//  ReplyComment.m
//  Bobo
//
//  Created by Boris Chow on 9/30/15.
//  Copyright © 2015 Zhouboli. All rights reserved.
//

#import "ReplyComment.h"

@implementation ReplyComment

-(instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _source = [dict objectForKey:@"source"];
        _created_at = dict[@"created_at"];
        _idstr = dict[@"idstr"];
        _reply_id = dict[@"id"];
        _floor_num = [dict[@"floor_num"] integerValue];
        _source_allowclick = [dict[@"source_allowclick"] boolValue];
        _source_type = [dict[@"source_type"] integerValue];
        _mid = dict[@"mid"];
        _user = [[User alloc] initWithDictionary:dict[@"user"]];
    }
    return self;
}

@end
