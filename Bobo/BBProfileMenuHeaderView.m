//
//  BBProfileMenuHeaderView.m
//  Bobo
//
//  Created by Boris Chow on 10/2/15.
//  Copyright © 2015 Zhouboli. All rights reserved.
//

#import "BBProfileMenuHeaderView.h"

#define buttonWidth self.frame.size.width/3
#define buttonHeight self.frame.size.height

#define menuColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

static CGFloat lineHeight = 3;

@interface BBProfileMenuHeaderView ()

@property (strong, nonatomic) UIImageView *lineView;

@end

@implementation BBProfileMenuHeaderView

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
    
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton setTitle:@"All" forState:UIControlStateNormal];
    [photoButton setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [photoButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [photoButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:photoButton];
    
    UIButton *allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [allButton setTitle:@"Originals" forState:UIControlStateNormal];
    [allButton setFrame:CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight)];
    [allButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [allButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:allButton];
    
    UIButton *originButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [originButton setTitle:@"Album" forState:UIControlStateNormal];
    [originButton setFrame:CGRectMake(buttonWidth*2, 0, buttonWidth, buttonHeight)];
    [originButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [originButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:originButton];
}

-(void)setupLineView
{
    CGFloat lineWidth = self.frame.size.width/3;
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
    if ([pressedButton.titleLabel.text isEqualToString:@"All"])
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_lineView setCenter:CGPointMake(buttonWidth/2, buttonHeight-lineHeight/2)];
        } completion:^(BOOL finished) {
            [self.delegate didClickMenuButtonAtIndex:menuButtonIndexAll];
        }];
    }
    if ([pressedButton.titleLabel.text isEqualToString:@"Originals"])
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_lineView setCenter:CGPointMake(buttonWidth+buttonWidth/2, buttonHeight-lineHeight/2)];
        } completion:^(BOOL finished) {
            [self.delegate didClickMenuButtonAtIndex:menuButtonIndexOriginals];
        }];
    }
    if ([pressedButton.titleLabel.text isEqualToString:@"Album"])
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_lineView setCenter:CGPointMake(buttonWidth*2+buttonWidth/2, buttonHeight-lineHeight/2)];
        } completion:^(BOOL finished) {
            [self.delegate didClickMenuButtonAtIndex:menuButtonIndexAlbum];
        }];
    }
}

@end
