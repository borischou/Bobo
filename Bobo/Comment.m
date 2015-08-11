//
//  Comment.m
//  Bobo
//
//  Created by Zhouboli on 15/7/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "Comment.h"
#import "Utils.h"

#define cAvatarHeight 40
#define cAvatarWidth cAvatarHeight
#define cBigGap 10
#define cSmallGap 5
#define cNameHeight 15
#define bWidth [UIScreen mainScreen].bounds.size.width
#define cTextWidth bWidth-2*cBigGap-cSmallGap-cAvatarWidth

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
//        if (![[dictionary objectForKey:@"reply_comment"] isEqual:[NSNull null]]) {
//            _reply_comment = [[Comment alloc] initWithDictionary:[dictionary objectForKey:@"reply_comment"]];
//        }
        
        _height = cBigGap+cNameHeight+cSmallGap+[Utils heightForString:_text andWidth:cTextWidth]+cBigGap;
    }
    return self;
}

@end
