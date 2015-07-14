//
//  Comment.m
//  Bobo
//
//  Created by Zhouboli on 15/7/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _created_at = [dictionary objectForKey:@"created_at"];
        _text = [dictionary objectForKey:@"text"];
        _source = [dictionary objectForKey:@"source"];
        _mid = [dictionary objectForKey:@"mid"];
        _idstr = [dictionary objectForKey:@"idstr"];
        _comnt_id = [[dictionary objectForKey:@"id"] integerValue];
        _user = [[User alloc] initWithDictionary:[dictionary objectForKey:@"user"]];
        _status = [[Status alloc] initWithDictionary:[dictionary objectForKey:@"status"]];
        _reply_comment = [[Comment alloc] initWithDictionary:[dictionary objectForKey:@"reply_comment"]];
    }
    return self;
}

@end
