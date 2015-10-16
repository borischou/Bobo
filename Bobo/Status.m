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
        if (![[dictionary objectForKey:@"created_at"] isEqual:[NSNull null]]) {
            _created_at = [dictionary objectForKey:@"created_at"];
        }
        if (![[dictionary objectForKey:@"id"] isEqual:[NSNull null]]) {
            _status_id = [[dictionary objectForKey:@"id"] integerValue];
        }
        if (![[dictionary objectForKey:@"mid"] isEqual:[NSNull null]]) {
            _status_mid = [[dictionary objectForKey:@"mid"] integerValue];
        }
        if (![[dictionary objectForKey:@"idstr"] isEqual:[NSNull null]]) {
            _idstr = [dictionary objectForKey:@"idstr"];
        }
        if (![[dictionary objectForKey:@"text"] isEqual:[NSNull null]]) {
            _text = [dictionary objectForKey:@"text"];
        }
        if (![[dictionary objectForKey:@"source"] isEqual:[NSNull null]]) {
            _source = [dictionary objectForKey:@"source"];
        }
        if (![[dictionary objectForKey:@"favorited"] isEqual:[NSNull null]]) {
            _favorited = [[dictionary objectForKey:@"favorited"] boolValue];
        }
        if (![[dictionary objectForKey:@"truncated"] isEqual:[NSNull null]]) {
            _truncated = [[dictionary objectForKey:@"truncated"] boolValue];
        }
        if (![[dictionary objectForKey:@"thumbnail_pic"] isEqual:[NSNull null]]) {
            _thumbnail_pic = [dictionary objectForKey:@"thumbnail_pic"];
        }
        if (![[dictionary objectForKey:@"bmiddle_pic"] isEqual:[NSNull null]]) {
            _bmiddle_pic = [dictionary objectForKey:@"bmiddle_pic"];
        }
        if (![[dictionary objectForKey:@"original_pic"] isEqual:[NSNull null]]) {
            _original_pic = [dictionary objectForKey:@"original_pic"];
        }
        if (![[dictionary objectForKey:@"reposts_count"] isEqual:[NSNull null]]) {
            _reposts_count = [[dictionary objectForKey:@"reposts_count"] integerValue];
        }
        if (![[dictionary objectForKey:@"comments_count"] isEqual:[NSNull null]]) {
            _comments_count = [[dictionary objectForKey:@"comments_count"] integerValue];
        }
        if (![[dictionary objectForKey:@"attitudes_count"] isEqual:[NSNull null]]) {
            _attitudes_count = [[dictionary objectForKey:@"attitudes_count"] integerValue];
        }
        if ([dictionary objectForKey:@"pic_urls"]) {
            _pic_urls = @[].mutableCopy;
            for (NSDictionary *dict in [dictionary objectForKey:@"pic_urls"]) {
                [_pic_urls addObject:[dict objectForKey:@"thumbnail_pic"]];
            }
        }
        if ([dictionary objectForKey:@"user"] && ![[dictionary objectForKey:@"user"] isEqual:[NSNull null]]) {
            _user = [[User alloc] initWithDictionary:[dictionary objectForKey:@"user"]];
        }
        if ([dictionary objectForKey:@"retweeted_status"] && ![[dictionary objectForKey:@"retweeted_status"] isEqual:[NSNull null]]) {
            _retweeted_status = [[Status alloc] initWithDictionary:[dictionary objectForKey:@"retweeted_status"]];
        }
        [self calculateStatusHeight];
        [self calculateWaterfallHeight];
    }
    return self;
}

-(NSDictionary *)convertToDictionary
{
    NSNull *sNull = [NSNull null];
    NSMutableDictionary *dict = @{@"created_at": _created_at? _created_at: sNull,
                                  @"id": @(_status_id), @"mid": @(_status_mid), @"idstr": _idstr? _idstr: sNull,
                                  @"text": _text? _text: sNull, @"source": _source? _source: sNull,
                                  @"favorited": @(_favorited), @"truncated": @(_truncated),
                                  @"thumbnail_pic": _thumbnail_pic? _thumbnail_pic: sNull,
                                  @"bmiddle_pic": _bmiddle_pic? _bmiddle_pic: sNull,
                                  @"original_pic": _original_pic? _original_pic: sNull,
                                  @"reposts_count": @(_reposts_count), @"comments_count": @(_comments_count),
                                  @"attitudes_count": @(_attitudes_count)}.mutableCopy;
    if (_pic_urls.count > 0) {
        NSMutableArray *urls = @[].mutableCopy;
        for (NSString *url in _pic_urls) {
            [urls addObject:@{@"thumbnail_pic": url}];
        }
        [dict setObject:urls forKey:@"pic_urls"];
    }
    [dict setObject:_user? [_user convertToDictionary]: sNull forKey:@"user"];
    [dict setObject:_retweeted_status? [_retweeted_status convertToDictionary]: sNull forKey:@"retweeted_status"];
    
    return dict;
}

-(void)calculateStatusHeight
{
    _height = [Utils getHeightForCellWithStatusText:_text statusImageCount:[_pic_urls count] andRetweetScreenName:_retweeted_status.user.screen_name retweetText:_retweeted_status.text retweetImageCount:[_retweeted_status.pic_urls count]];
}

-(void)calculateWaterfallHeight
{
    _heightForWaterfall = [Utils heightForWaterfallCellWithStatus:self textWidth:[Utils cellWidthForWaterfall]-4];
}

@end
