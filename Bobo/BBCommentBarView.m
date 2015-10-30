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
#import "BBUpdateStatusView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define cSmallGap 5
#define cBigGap 10
#define cAvatarHeight 40
#define cAvatarWidth cAvatarHeight
#define cBtnHeight cAvatarHeight
#define cTextHeight cAvatarHeight
#define cSelfHeight cAvatarHeight+2*cBigGap
#define cBtnWidth cAvatarHeight
#define cTextWidth self.frame.size.width-cAvatarHeight*2-4*10

#define cPlaceholder @"想说就说吧"

@interface BBCommentBarView () <BBUpdateStatusViewDelegate>

@property (strong, nonatomic) NSString *avatarUrl;

@end

@implementation BBCommentBarView

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setFrame:CGRectMake(0, 0, bWidth, cSelfHeight)];
        [self setupBarViews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupBarViews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame status:(Status *)status
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _status = status;
        [self setupBarViews];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (!_avatarUrl)
    {
        AppDelegate *delegate = [AppDelegate delegate];
        if (!delegate.user)
        {
            [delegate fetchUserProfile];
        }
        _avatarUrl = delegate.user.avatar_large;
        [_avatarView sd_setImageWithURL:[NSURL URLWithString:_avatarUrl] placeholderImage:[UIImage imageNamed:@"bb_holder_profile_image"]];
    }
}

-(void)setupBarViews
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.2;

    AppDelegate *delegate = [AppDelegate delegate];
    _avatarUrl = delegate.user.avatar_large;
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(cBigGap, cBigGap, cAvatarWidth, cAvatarHeight)];
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:_avatarUrl] placeholderImage:[UIImage imageNamed:@"bb_holder_profile_image"]];
    _avatarView.clipsToBounds = YES;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.cornerRadius = _avatarView.bounds.size.width*0.5;
    _avatarView.layer.borderWidth = 0.1;
    _avatarView.layer.borderColor = [UIColor blackColor].CGColor;
    [self addSubview:_avatarView];
 
    _holderLabel = [[UILabel alloc] initWithFrame:CGRectMake(cBigGap*2+cAvatarWidth, cSmallGap, cTextWidth, cTextHeight+cBigGap)];
    _holderLabel.text = cPlaceholder;
    _holderLabel.font = [UIFont systemFontOfSize:14.0];
    _holderLabel.textColor = [UIColor lightGrayColor];
    _holderLabel.userInteractionEnabled = YES;
    [_holderLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(holderLabelTapped)]];
    [self addSubview:_holderLabel];
    
    _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(cBigGap*3+cAvatarWidth+cTextWidth+cBigGap, cBigGap*2, cBtnWidth-2*cBigGap, cBtnHeight-2*cBigGap)];
    [_sendBtn setBackgroundImage:[UIImage imageNamed:@"comntbar_icon"] forState:UIControlStateNormal];
    [_sendBtn addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendBtn];
}

-(void)holderLabelTapped
{
    [self presentUpdateView];
}

-(void)sendButtonPressed
{
    [self presentUpdateView];
}

-(void)presentUpdateView
{
    AppDelegate *delegate = [AppDelegate delegate];
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:updateStatusTypeComment]; //写评论
    updateStatusView.delegate = self;
    updateStatusView.status = _status;
    //updateStatusView.nameLabel.text = _status.user.screen_name;
    [delegate.window addSubview:updateStatusView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        updateStatusView.frame = CGRectMake(cSmallGap, statusBarHeight+cSmallGap, bWidth-2*cSmallGap, bHeight/2-5);
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {
        if (finished) {}
    }];
}

#pragma mark - BBUpdateStatusViewDelegate

-(void)updateStatusView:(BBUpdateStatusView *)updateStatusView shouldDisplayComment:(Comment *)comment
{
    [self.delegate commentBarView:self didDisplayComment:comment];
}

@end
