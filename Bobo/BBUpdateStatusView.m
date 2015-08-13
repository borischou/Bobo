//
//  BBUpdateStatusView.m
//  Bobo
//
//  Created by Zhouboli on 15/8/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBUpdateStatusView.h"
#import "UIButton+Bobtn.h"

#define uSmallGap 5
#define uBigGap 10
#define uBtnHeight 20
#define uBtnWidth 50

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]

@interface BBUpdateStatusView () <UITextViewDelegate>

@end

@implementation BBUpdateStatusView

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(uSmallGap, -bHeight/2, bWidth-2*uSmallGap, bHeight/2);
        [self setupViewLayout];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViewLayout];
    }
    return self;
}

-(void)setupViewLayout
{
    self.backgroundColor = bBGColor;
    self.alpha = 1.0;
    self.layer.cornerRadius = 8.0;
    self.layer.borderWidth = 0.2;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectZero andTitle:@"取消" withBackgroundColor:nil andTintColor:nil];
    [_cancelBtn setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelBtn];
    
    _sendBtn = [[UIButton alloc] initWithFrame:CGRectZero andTitle:@"发送" withBackgroundColor:nil andTintColor:nil];
    [_sendBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [_sendBtn addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _sendBtn.enabled = NO;
    [self addSubview:_sendBtn];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor lightTextColor];
    [self addSubview:_nameLabel];
    
    _statusTextView = [[UITextView alloc] init];
    _statusTextView.textColor = [UIColor lightTextColor];
    _statusTextView.backgroundColor = bBGColor;
    _statusTextView.delegate = self;
    [self addSubview:_statusTextView];
    
    [_cancelBtn setFrame:CGRectMake(uBigGap, uBigGap, uBtnWidth, uBtnHeight)];
    [_sendBtn setFrame:CGRectMake(self.frame.size.width-uBigGap-uBtnWidth, uBigGap, uBtnWidth, uBtnHeight)];
    [_nameLabel setFrame:CGRectMake(0, 0, self.frame.size.width/2, uBtnHeight)];
    [_nameLabel setCenter:CGPointMake(self.frame.size.width/2, uSmallGap+uBtnHeight/2)];
}

-(void)layoutSubviews
{
    _statusTextView.frame = CGRectMake(uBigGap, uBigGap*2+uBtnHeight, self.frame.size.width-2*uBigGap, self.frame.size.height-3*uBigGap-uBtnHeight);
}

#pragma mark - UIButtons

-(void)cancelButtonPressed:(UIButton *)sender
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(uSmallGap, -bHeight/2, bWidth-2*uSmallGap, bHeight/2);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

-(void)sendButtonPressed:(UIButton *)sender
{
    NSLog(@"Status ready to send: %@", _statusTextView.text);
    [self.delegate updateStatusDidFinishInput:_statusTextView.text];
}

#pragma mark - UITextViewDelegate

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0 || textView.text.length >= 140) {
        _sendBtn.enabled = NO;
    } else {
        _sendBtn.enabled = YES;
    }
}

@end




































