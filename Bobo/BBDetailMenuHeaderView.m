//
//  BBDetailMenuHeaderView.m
//  Bobo
//
//  Created by Zhouboli on 15/10/29.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBDetailMenuHeaderView.h"
#import "UIColor+Custom.h"

#define buttonWidth self.frame.size.width/4
#define buttonHeight self.frame.size.height

#define menuColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

static CGFloat lineHeight = 3;

@interface BBDetailMenuHeaderView ()

@property (strong, nonatomic) UIImageView *lineView;

@end

@implementation BBDetailMenuHeaderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupSubviews];
        [self setupLineView];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame flag:(NSInteger)flag
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupSubviews];
        [self setupLineView];
        [self moveLineAccordingToFlag:flag];
    }
    return self;
}

-(void)setupSubviews
{
    [self.contentView setBackgroundColor:menuColor];
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowOpacity = .2;
    self.contentView.layer.shadowOffset = CGSizeMake(0, 2);
    
    UIButton *repostButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [repostButton setTitle:@"Repost" forState:UIControlStateNormal];
    [repostButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
    [repostButton setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [repostButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [repostButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:repostButton];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentButton setTitle:@"Comment" forState:UIControlStateNormal];
    [commentButton setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
    [commentButton setFrame:CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight)];
    [commentButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [commentButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:commentButton];
    
    UILabel *repostNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [repostNumLabel setTextColor:[UIColor lightTextColor]];
    [repostNumLabel setText:@"0"];
    [self.contentView addSubview:repostNumLabel];
    
    UILabel *commentNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [commentNumLabel setTextColor:[UIColor lightTextColor]];
    [commentNumLabel setText:@"0"];
    [self.contentView addSubview:commentNumLabel];
}

-(void)setupLineView
{
    CGFloat lineWidth = buttonWidth;
    _lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, buttonHeight-lineHeight, lineWidth, lineHeight)];
    [_lineView setBackgroundColor:[UIColor redColor]];
    [self.contentView addSubview:_lineView];
}

-(void)moveLineAccordingToFlag:(NSInteger)flag
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_lineView setCenter:CGPointMake(flag*buttonWidth+buttonWidth/2, buttonHeight-lineHeight/2)];
    } completion:^(BOOL finished) {}];
}

-(void)buttonPressed:(UIButton *)sender
{
    UIButton *pressedButton = (UIButton *)sender;
    if ([pressedButton.titleLabel.text isEqualToString:@"Repost"])
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_lineView setCenter:CGPointMake(buttonWidth/2, buttonHeight-lineHeight/2)];
        } completion:^(BOOL finished) {
        }];
    }
    if ([pressedButton.titleLabel.text isEqualToString:@"Comment"])
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_lineView setCenter:CGPointMake(buttonWidth+buttonWidth/2, buttonHeight-lineHeight/2)];
        } completion:^(BOOL finished) {
        }];
    }
}

@end
