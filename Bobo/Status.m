//
//  Status.m
//  Bobo
//
//  Created by Zhouboli on 15/7/13.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "Status.h"
#import "Utils.h"

@implementation Status

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _created_at = [dictionary objectForKey:@"created_at"];
        _status_id = [[dictionary objectForKey:@"id"] integerValue];
        _status_mid = [[dictionary objectForKey:@"mid"] integerValue];
        _idstr = [dictionary objectForKey:@"idstr"];
        _text = [dictionary objectForKey:@"text"];
        _source = [dictionary objectForKey:@"source"];
        _favorited = [[dictionary objectForKey:@"favorited"] boolValue];
        _truncated = [[dictionary objectForKey:@"truncated"] boolValue];
        _thumbnail_pic = [dictionary objectForKey:@"thumbnail_pic"];
        _bmiddle_pic = [dictionary objectForKey:@"bmiddle_pic"];
        _original_pic = [dictionary objectForKey:@"original_pic"];
        _reposts_count = [[dictionary objectForKey:@"reposts_count"] integerValue];
        _comments_count = [[dictionary objectForKey:@"comments_count"] integerValue];
        _attitudes_count = [[dictionary objectForKey:@"attitudes_count"] integerValue];
        for (NSDictionary *dict in [dictionary objectForKey:@"pic_urls"]) {
            [_pic_urls addObject:dict];
        }
        if ([dictionary objectForKey:@"user"]) {
            _user = [[User alloc] initWithDictionary:[dictionary objectForKey:@"user"]];
        }
        if ([dictionary objectForKey:@"retweeted_status"]) {
            _retweeted_status = [[Status alloc] initWithDictionary:[dictionary objectForKey:@"retweeted_status"]];
        }
    }
    return self;
}

-(void)calculateHeight
{
    Utils *utils = [[Utils alloc] init];
    _height = [utils getHeightForCellWithStatusText:_text statusImageCount:[_pic_urls count] andRetweetText:[NSString stringWithFormat:@"@%@:%@", _retweeted_status.user.name, _retweeted_status.text] retweetImageCount:[_retweeted_status.pic_urls count]];
}

@end
