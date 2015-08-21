//
//  BBReplyCommentView.m
//  Bobo
//
//  Created by Boris Chow on 8/18/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import "BBReplyCommentView.h"
#import "BBUpdateStatusView.h"
#import "AppDelegate.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define rReplyViewHeight 150
#define bSmallGap 5
#define rSmallGap 1
#define rBtnHeight (self.frame.size.height-rSmallGap*2)/3
#define rBtnWidth self.frame.size.width

@interface BBReplyCommentView ()

@property (strong, nonatomic) UIView *mask;

@end

@implementation BBReplyCommentView

-(instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, bHeight-rReplyViewHeight, bWidth, rReplyViewHeight)];
    if (self) {
        [self setupButtonLayout];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupButtonLayout];
    }
    return self;
}

-(void)setupButtonLayout
{
    self.backgroundColor = [UIColor lightTextColor];

    _replyBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rBtnWidth, rBtnHeight)];
    [_replyBtn setTitle:@"回复" forState:UIControlStateNormal];
    [_replyBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_replyBtn addTarget:self action:@selector(replyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_replyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_replyBtn];
    
    _repostBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, rBtnHeight+rSmallGap, rBtnWidth, rBtnHeight)];
    [_repostBtn setTitle:@"转发" forState:UIControlStateNormal];
    [_repostBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_repostBtn addTarget:self action:@selector(repostButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_repostBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_repostBtn];
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, rBtnHeight*2+rSmallGap*2, rBtnWidth, rBtnHeight)];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_cancelBtn addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_cancelBtn];
    
    if (!_mask) {
        _mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight)];
        _mask.backgroundColor = [UIColor blackColor];
        _mask.alpha = 0.0;
        [_mask addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonPressed)]];

        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.window addSubview:_mask];
        [delegate.window bringSubviewToFront:self];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _mask.alpha = 0.5;
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)replyButtonPressed
{
    NSLog(@"replyButtonPressed");
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:3]; //回复评论
    updateStatusView.idStr = _idStr;
    updateStatusView.cidStr = _cidStr;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.window addSubview:updateStatusView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        updateStatusView.frame = CGRectMake(bSmallGap, statusBarHeight+bSmallGap, bWidth-2*bSmallGap, bHeight/2-5);
        [self setFrame:CGRectMake(0, bHeight, bWidth, rReplyViewHeight)];
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

-(void)repostButtonPressed
{
    NSLog(@"repostButtonPressed");
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setFrame:CGRectMake(0, bHeight, bWidth, rReplyViewHeight)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)cancelButtonPressed
{
    NSLog(@"cancelButtonPressed");
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setFrame:CGRectMake(0, bHeight, bWidth, rReplyViewHeight)];
        _mask.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [_mask removeFromSuperview];
        _mask = nil;
    }];
}

@end
