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
#import "BBStatusDetailViewController.h"
#import "SWRevealViewController.h"
#import "BBNotificationView.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Utils.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define bSmallGap 5
#define rSmallGap 1
#define rBtnWidth self.frame.size.width

#define bWeiboDomain @"https://api.weibo.com/2/"

@interface BBReplyCommentView ()

@property (strong, nonatomic) UIView *mask;
@property (nonatomic) CGFloat rBtnHeight;
@property (nonatomic) CGFloat viewHeight;

@end

@implementation BBReplyCommentView

-(instancetype)init
{
    return [self initWithFrame:CGRectMake(0, bHeight, bWidth, 150)];
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
    
    _replyBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [_replyBtn setTitle:@"回复评论" forState:UIControlStateNormal];
    [_replyBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_replyBtn addTarget:self action:@selector(replyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_replyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_replyBtn];
    
    _repostBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [_repostBtn setTitle:@"转发评论" forState:UIControlStateNormal];
    [_repostBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_repostBtn addTarget:self action:@selector(repostButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_repostBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_repostBtn];
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_cancelBtn addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_cancelBtn];
    
    _viewStatusBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [_viewStatusBtn setTitle:@"查看微博" forState:UIControlStateNormal];
    [_viewStatusBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_viewStatusBtn addTarget:self action:@selector(viewStatusButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_viewStatusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_viewStatusBtn];
    
    _deleteBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [_deleteBtn setTitle:@"删除评论" forState:UIControlStateNormal];
    [_deleteBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_deleteBtn addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_deleteBtn];
    
    if (!_mask) {
        _mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight)];
        _mask.backgroundColor = [UIColor blackColor];
        _mask.alpha = 0.0;
        [_mask addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonPressed:)]];

        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.window addSubview:_mask];
        [delegate.window bringSubviewToFront:self];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _mask.alpha = 0.5;
        } completion:^(BOOL finished) {}];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat rBtnHeight = (self.frame.size.height-rSmallGap*2)/3;
    _viewHeight = rBtnHeight*3+rSmallGap*2;
    if (_shouldShowViewStatusOption && _shouldShowDeleteOption) {
        rBtnHeight = (self.frame.size.height-rSmallGap*4)/5;
    }
    if ((_shouldShowDeleteOption && !_shouldShowViewStatusOption) || (!_shouldShowDeleteOption && _shouldShowViewStatusOption)) {
        rBtnHeight = (self.frame.size.height-rSmallGap*3)/4;
    }
    
    [_replyBtn setFrame:CGRectMake(0, 0, rBtnWidth, rBtnHeight)];
    [_repostBtn setFrame:CGRectMake(0, rBtnHeight+rSmallGap, rBtnWidth, rBtnHeight)];
    
    if (_shouldShowDeleteOption && _shouldShowViewStatusOption) {
        [_viewStatusBtn setFrame:CGRectMake(0, rBtnHeight*2+rSmallGap*2, rBtnWidth, rBtnHeight)];
        [_deleteBtn setFrame:CGRectMake(0, rBtnHeight*3+rSmallGap*3, rBtnWidth, rBtnHeight)];
        [_cancelBtn setFrame:CGRectMake(0, rBtnHeight*4+rSmallGap*4, rBtnWidth, rBtnHeight)];
        _viewHeight = rBtnHeight*5+rSmallGap*4;
    }
    if (_shouldShowViewStatusOption && !_shouldShowDeleteOption) {
        [_viewStatusBtn setFrame:CGRectMake(0, rBtnHeight*2+rSmallGap*2, rBtnWidth, rBtnHeight)];
        [_cancelBtn setFrame:CGRectMake(0, rBtnHeight*3+rSmallGap*3, rBtnWidth, rBtnHeight)];
        _viewHeight = rBtnHeight*4+rSmallGap*3;
    }
    if (!_shouldShowViewStatusOption && _shouldShowDeleteOption) {
        [_deleteBtn setFrame:CGRectMake(0, rBtnHeight*2+rSmallGap*2, rBtnWidth, rBtnHeight)];
        [_cancelBtn setFrame:CGRectMake(0, rBtnHeight*3+rSmallGap*3, rBtnWidth, rBtnHeight)];
        _viewHeight = rBtnHeight*4+rSmallGap*3;
    }
    if (!_shouldShowDeleteOption && !_shouldShowViewStatusOption) {
        [_cancelBtn setFrame:CGRectMake(0, rBtnHeight*2+rSmallGap*2, rBtnWidth, rBtnHeight)];
        _viewHeight = rBtnHeight*3+rSmallGap*2;
    }
}

#pragma mark - Button Actions

-(void)viewStatusButtonPressed:(UIButton *)sender
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _mask.alpha = 0;
        [self setFrame:CGRectMake(0, bHeight, bWidth, _viewHeight)];
    } completion:^(BOOL finished) {
        if (finished) {
            [_mask removeFromSuperview];
            _mask = nil;
            if ([self.window.rootViewController isKindOfClass:[SWRevealViewController class]]) {
                BBStatusDetailViewController *dtvc = [[BBStatusDetailViewController alloc] init];
                dtvc.title = @"Detail";
                dtvc.hidesBottomBarWhenPushed = YES;
                dtvc.status = _comment.status;
                SWRevealViewController *swrvc = (SWRevealViewController *)self.window.rootViewController;
                UITabBarController *tbc = (UITabBarController *)swrvc.frontViewController;
                UINavigationController *uinc = (UINavigationController *)tbc.selectedViewController;
                [uinc pushViewController:dtvc animated:YES];
            }
            [self removeFromSuperview];
        }
    }];
}

-(void)deleteButtonPressed:(UIButton *)sender
{
    //调用删除接口
    NSDictionary *params = @{@"cid": _comment.idstr};
    [Utils weiboPostRequestWithAccount:[[AppDelegate delegate] defaultAccount] URL:@"comments/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSString *notificationText = nil;
        if (!error) {
            NSLog(@"评论删除成功。");
            notificationText = @"评论删除成功";
        }
        else
        {
            NSLog(@"评论删除失败：%@", error);
            notificationText = [NSString stringWithFormat:@"评论删除失败: %@", error];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _mask.alpha = 0;
                [self setFrame:CGRectMake(0, bHeight, bWidth, _viewHeight)];
            } completion:^(BOOL finished) {
                if (finished) {
                    [self callbackForUpdateCompletionWithNotificationText:notificationText];
                    [_mask removeFromSuperview];
                    _mask = nil;
                    [self removeFromSuperview];
                }
            }];
        });
    }];
}

-(void)replyButtonPressed:(UIButton *)sender
{
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:3]; //回复评论
    updateStatusView.idStr = _comment.status.idstr;
    updateStatusView.cidStr = _comment.idstr;
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:updateStatusView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _mask.alpha = 0;
        updateStatusView.frame = CGRectMake(bSmallGap, statusBarHeight+bSmallGap, bWidth-2*bSmallGap, bHeight/2-5);
        [self setFrame:CGRectMake(0, bHeight, bWidth, _viewHeight)];
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {
        if (finished) {
            [_mask removeFromSuperview];
            _mask = nil;
            [self removeFromSuperview];
        }
    }];
}

-(void)repostButtonPressed:(UIButton *)sender
{
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:2]; //转发评论
    updateStatusView.idStr = _comment.status.idstr;
    updateStatusView.cidStr = _comment.idstr;
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:updateStatusView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setFrame:CGRectMake(0, bHeight, bWidth, _viewHeight)];
        _mask.alpha = 0;
        updateStatusView.frame = CGRectMake(bSmallGap, statusBarHeight+bSmallGap, bWidth-2*bSmallGap, bHeight/2-5);
        [self setFrame:CGRectMake(0, bHeight, bWidth, _viewHeight)];
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {
        [_mask removeFromSuperview];
        _mask = nil;
        [self removeFromSuperview];
    }];
}

-(void)cancelButtonPressed:(UIButton *)sender
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setFrame:CGRectMake(0, bHeight, bWidth, _viewHeight)];
        _mask.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [_mask removeFromSuperview];
        _mask = nil;
    }];
}

-(void)callbackForUpdateCompletionWithNotificationText:(NSString *)text
{
    BBNotificationView *notificationView = [[BBNotificationView alloc] initWithNotification:text];
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:notificationView];
    [delegate.window bringSubviewToFront:notificationView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [notificationView setFrame:CGRectMake(0, 0, bWidth, 2*statusBarHeight)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [notificationView setFrame:CGRectMake(0, -2*statusBarHeight, bWidth, 2*statusBarHeight)];
        } completion:^(BOOL finished) {
            [notificationView removeFromSuperview];
        }];
    }];
}

@end
