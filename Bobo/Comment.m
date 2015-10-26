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
#define mTextWidth bWidth-2*cBigGap

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
        if (![dictionary[@"reply_comment"] isEqual:[NSNull null]]) {
            _reply_comment = [[ReplyComment alloc] initWithDictionary:dictionary[@"reply_comment"]];
        }
        
        [self calculateHeights];
    }
    return self;
}

-(void)calculateHeights
{
    CGFloat replyHeight = 0;
    if (_reply_comment.text.length > 0) {
        CGSize replySize = [_reply_comment.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:[Utils fontSizeForStatus]]}];
        replyHeight = cSmallGap + replySize.height;
    }
    
    CGFloat messageFontSize = [Utils fontSizeForStatus];
    CGFloat textHeight = [Utils heightForString:_text width:cTextWidth fontSize:[Utils fontSizeForComment]];
    _height = cAvatarHeight > cNameHeight+cSmallGap+textHeight? cBigGap*2+cAvatarHeight: cBigGap*2+cNameHeight+cSmallGap+textHeight;
    _heightForMessageCell = cBigGap*4+cAvatarHeight+[Utils heightForString:_text width:mTextWidth fontSize:messageFontSize]+[Utils heightForString:[NSString stringWithFormat:@"@%@:%@", _status.user.screen_name, _status.text] width:mTextWidth fontSize:messageFontSize]+replyHeight;
}

@end
