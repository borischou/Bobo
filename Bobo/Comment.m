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
#define cTextFontSize 13.f

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
        
        CGFloat textHeight = [Utils heightForString:_text width:cTextWidth fontSize:cTextFontSize];
        _height = cAvatarHeight > cNameHeight+cSmallGap+textHeight? cBigGap*2+cAvatarHeight: cBigGap*2+cNameHeight+cSmallGap+textHeight;
        _heightForMessageCell = cBigGap+cAvatarHeight+cBigGap+textHeight+cBigGap+[Utils heightForString:_status.text width:cTextWidth fontSize:cTextFontSize]+cSmallGap;
    }
    return self;
}

@end
