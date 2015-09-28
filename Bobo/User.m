//
//  User.m
//  Bobo
//
//  Created by Zhouboli on 15/7/13.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "User.h"
#import "Status.h"

@implementation User

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _user_id = [[dictionary objectForKey:@"id"] integerValue];
        _idstr = [dictionary objectForKey:@"idstr"];
        _screen_name = [dictionary objectForKey:@"screen_name"];
        _name = [dictionary objectForKey:@"name"];
        _province = [[dictionary objectForKey:@"province"] integerValue];
        _city = [[dictionary objectForKey:@"city"] integerValue];
        _location = [dictionary objectForKey:@"location"];
        _user_description = [dictionary objectForKey:@"description"];
        _url = [dictionary objectForKey:@"url"];
        _profile_image_url = [dictionary objectForKey:@"profile_image_url"];
        _profile_url = [dictionary objectForKey:@"profile_url"];
        _domain = [dictionary objectForKey:@"domain"];
        _weihao = [dictionary objectForKey:@"weihao"];
        _gender = [dictionary objectForKey:@"gender"];
        _followers_count = [[dictionary objectForKey:@"followers_count"] integerValue];
        _friends_count = [[dictionary objectForKey:@"friends_count"] integerValue];
        _statuses_count = [[dictionary objectForKey:@"statuses_count"] integerValue];
        _favourites_count = [[dictionary objectForKey:@"favourites_count"] integerValue];
        _created_at = [dictionary objectForKey:@"created_at"];
        _allow_all_act_msg = [[dictionary objectForKey:@"allow_all_act_msg"] boolValue];
        _geo_enabled = [[dictionary objectForKey:@"geo_enabled"] boolValue];
        _verified = [[dictionary objectForKey:@"verified"] boolValue];
        _remark = [dictionary objectForKey:@"remark"];
        _allow_all_comment = [[dictionary objectForKey:@"allow_all_comment"] boolValue];
        _avatar_large = [dictionary objectForKey:@"avatar_large"];
        _avatar_hd = [dictionary objectForKey:@"avatar_hd"];
        _verified_reason = [dictionary objectForKey:@"verified_reason"];
        _follow_me = [[dictionary objectForKey:@"follow_me"] boolValue];
        _following = [[dictionary objectForKey:@"following"] boolValue];
        _online_status = [[dictionary objectForKey:@"online_status"] integerValue];
        _bi_followers_count = [[dictionary objectForKey:@"bi_followers_count"] integerValue];
        _lang = [dictionary objectForKey:@"lang"];
        if ([dictionary objectForKey:@"status"]) {
            _status = [[Status alloc] initWithDictionary:[dictionary objectForKey:@"status"]];
        }
    }
    return self;
}

@end
