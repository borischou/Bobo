//
//  BBMessageMenuView.m
//  Bobo
//
//  Created by Zhouboli on 15/9/8.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBMessageMenuView.h"

#define mButtonWidth [UIScreen mainScreen].bounds.size.width/4

#define mBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

static CGFloat height = 35;
static CGFloat lineHeight = 3;

@interface BBMessageMenuView ()

@property (strong, nonatomic) UIImageView *bgImgView;

@end

@implementation BBMessageMenuView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initLayout];
    }
    return self;
}

-(instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
}

-(void)initLayout
{
    self.backgroundColor = mBGColor;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = .2;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    
    _bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, height-lineHeight, mButtonWidth, lineHeight)];
    _bgImgView.backgroundColor = [UIColor redColor];
    [self addSubview:_bgImgView];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setFrame:CGRectMake(0, 0, mButtonWidth, height-lineHeight)];
    [button1 setTitle:@"我收到的评论" forState:UIControlStateNormal];
    [button1.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [button1 addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setFrame:CGRectMake(mButtonWidth, 0, mButtonWidth, height-lineHeight)];
    [button2 setTitle:@"我发出的评论" forState:UIControlStateNormal];
    [button2.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [button2 addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setFrame:CGRectMake(mButtonWidth*2, 0, mButtonWidth, height-lineHeight)];
    [button3 setTitle:@"@我的评论" forState:UIControlStateNormal];
    [button3.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [button3 addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button4 setFrame:CGRectMake(mButtonWidth*3, 0, mButtonWidth, height-lineHeight)];
    [button4 setTitle:@"所有的评论" forState:UIControlStateNormal];
    [button4.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [button4 addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button4];
}

-(void)moveLineAccordingToFlag:(NSInteger)flag
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_bgImgView setCenter:CGPointMake(flag*mButtonWidth+mButtonWidth/2, height-lineHeight/2)];
    } completion:^(BOOL finished) {}];
}

-(void)buttonPressed:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"我收到的评论"]) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_bgImgView setCenter:CGPointMake(mButtonWidth/2, height-lineHeight/2)];
        } completion:^(BOOL finished) {
            [self.delegate didClickMenuButtonAtIndex:0];
        }];
    }
    if ([sender.titleLabel.text isEqualToString:@"我发出的评论"]) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_bgImgView setCenter:CGPointMake(mButtonWidth+mButtonWidth/2, height-lineHeight/2)];
        } completion:^(BOOL finished) {
            [self.delegate didClickMenuButtonAtIndex:1];
        }];
    }
    if ([sender.titleLabel.text isEqualToString:@"@我的评论"]) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_bgImgView setCenter:CGPointMake(mButtonWidth*2+mButtonWidth/2, height-lineHeight/2)];
        } completion:^(BOOL finished) {
            [self.delegate didClickMenuButtonAtIndex:2];
        }];
    }
    if ([sender.titleLabel.text isEqualToString:@"所有的评论"]) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_bgImgView setCenter:CGPointMake(mButtonWidth*3+mButtonWidth/2, height-lineHeight/2)];
        } completion:^(BOOL finished) {
            [self.delegate didClickMenuButtonAtIndex:3];
        }];
    }
}

@end
