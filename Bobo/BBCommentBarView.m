//
//  BBCommentBarView.m
//  Bobo
//
//  Created by Zhouboli on 15/8/20.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBCommentBarView.h"
#import <UIImageView+WebCache.h>
#import "AppDelegate.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define cSmallGap 5
#define cBigGap 10
#define cAvatarHeight 50
#define cAvatarWidth 50
#define cBtnHeight 50
#define cTextHeight 50
#define cSelfHeight 70
#define cBtnWidth 50
#define cTextWidth self.frame.size.width-50-50-4*10

#define cPlaceholder @"你想说点什么？"

@interface BBCommentBarView () {
    BOOL _shouldLabelShown;
}

@end

@implementation BBCommentBarView

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, 0, bWidth, cSelfHeight)];
        [self setupBarViewsWithLabel:NO];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBarViewsWithLabel:NO];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame shouldLabelShown:(BOOL)isShown
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBarViewsWithLabel:isShown];
    }
    return self;
}

-(void)setupBarViewsWithLabel:(BOOL)isLabelShown
{
    _shouldLabelShown = isLabelShown;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.backgroundColor = [UIColor whiteColor];
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(cBigGap, cBigGap, cAvatarWidth, cAvatarHeight)];
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:delegate.user.avatar_large] placeholderImage:[UIImage imageNamed:@"bb_holder_profile_image"]];
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.cornerRadius = _avatarView.bounds.size.width*0.5;
    _avatarView.layer.borderWidth = 0.1;
    _avatarView.layer.borderColor = [UIColor blackColor].CGColor;
    [self addSubview:_avatarView];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(cBigGap*2+cAvatarWidth, cBigGap, cTextWidth, cTextHeight)];
    [self addSubview:_textView];
    
    _holderLabel = [[UILabel alloc] initWithFrame:CGRectMake(cBigGap*2+cAvatarWidth, 0, cTextWidth, cTextHeight+cBigGap)];
    _holderLabel.text = cPlaceholder;
    _holderLabel.textColor = [UIColor lightGrayColor];
    [_holderLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(holderLabelTapped)]];
    [self addSubview:_holderLabel];
    
    if (_shouldLabelShown) {
        _holderLabel.hidden = NO;
    } else {
        _holderLabel.hidden = YES;
    }
    _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(cBigGap*3+cAvatarWidth+cTextWidth, cBigGap, cBtnWidth, cBtnHeight)];
    [_sendBtn setBackgroundColor:[UIColor greenColor]];
    [self addSubview:_sendBtn];
}

-(void)holderLabelTapped
{
    [self.delegate didTappedPlaceholderLabel];
}

-(void)sendButtonPressed
{

}

@end
