//
//  UserModel.m
//  Bobo
//
//  Created by Zhouboli on 15/6/22.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

-(id)initWithUserData:(NSDictionary *)user
{
    self = [super init];
    if (self) {
        self.screen_name = user[@"screen_name"];
        self.introduction = user[@"description"];
        self.gender = user[@"gender"];
        self.created_at = user[@"created_at"];
        self.verified = user[@"verified"];
        self.verified_reason = user[@"verified_reason"];
        self.avatar_large = user[@"avatar_large"];
        self.userId = [user[@"id"] integerValue];
        self.favourites_count = [user[@"favourites_count"] integerValue];
        self.statuses_count = [user[@"statuses_count"] integerValue];
        self.friends_count = [user[@"friends_count"] integerValue];
        self.followers_count = [user[@"followers_count"] integerValue];
    }
    return self;
}

@end
