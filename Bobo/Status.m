//
//  Status.m
//  Bobo
//
//  Created by Zhouboli on 15/7/13.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "Status.h"
#import "Utils.h"

@interface Status () <NSCopying>

@end

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
        if ([dictionary objectForKey:@"pic_urls"]) {
            [self initModel];
            _pic_urls = @[].mutableCopy;
            for (NSDictionary *dict in [dictionary objectForKey:@"pic_urls"]) {
                [_pic_urls addObject:[dict objectForKey:@"thumbnail_pic"]];
            }
        }
        if ([dictionary objectForKey:@"user"]) {
            _user = [[User alloc] initWithDictionary:[dictionary objectForKey:@"user"]];
        }
        if ([dictionary objectForKey:@"retweeted_status"]) {
            _retweeted_status = [[Status alloc] initWithDictionary:[dictionary objectForKey:@"retweeted_status"]];
        }
        [self calculateHeight];
    }
    return self;
}

//-(id)copyWithZone:(NSZone *)zone
//{
//    Status *status = [[Status allocWithZone:zone] init];
//    status.created_at = self.created_at;
//    status.status_id = self.status_id;
//    status.status_mid = self.status_mid;
//    status.idstr = self.idstr;
//    status.text = self.text;
//    status.source = self.source;
//    status.favorited = self.favorited;
//    status.truncated = self.truncated;
//    status.thumbnail_pic = self.thumbnail_pic;
//    status.bmiddle_pic = self.bmiddle_pic;
//    status.original_pic = self.original_pic;
//    status.reposts_count = self.reposts_count;
//    status.comments_count = self.comments_count;
//    status.attitudes_count = self.attitudes_count;
//    status.pic_urls = self.pic_urls;
//    status.user = self.user;
//    status.retweeted_status = self.retweeted_status;
//    status.height = self.height;
//    return status;
//}

-(void)calculateHeight
{
    _height = [[[Utils alloc] init] getHeightForCellWithStatusText:_text statusImageCount:[_pic_urls count] andRetweetScreenName:_retweeted_status.user.screen_name retweetText:_retweeted_status.text retweetImageCount:[_retweeted_status.pic_urls count]];
}

-(void)initModel
{
    if (!_images) {
        _images = @[].mutableCopy;
    }
    for (int i = 0; i < 9; i ++) {
        [_images addObject:[NSNull null]];
    }
}

@end
