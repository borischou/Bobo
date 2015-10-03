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

static CGFloat lineHeight = 3;

@interface BBProfileMenuHeaderView ()

@property (strong, nonatomic) UIImageView *lineView;

@end

@implementation BBProfileMenuHeaderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews
{
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton setTitle:@"Album" forState:UIControlStateNormal];
    [photoButton setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    [photoButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [photoButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:photoButton];
    
    UIButton *allButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [allButton setTitle:@"All" forState:UIControlStateNormal];
    [allButton setFrame:CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight)];
    [allButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [allButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:allButton];
    
    UIButton *originButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [originButton setTitle:@"Origin" forState:UIControlStateNormal];
    [originButton setFrame:CGRectMake(buttonWidth*2, 0, buttonWidth, buttonHeight)];
    [originButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [originButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:originButton];
}

-(void)setupLineView
{
    CGFloat lineWidth = self.frame.size.width/3;
    _lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-lineHeight, lineWidth, lineHeight)];
    [_lineView setBackgroundColor:[UIColor redColor]];
    [self addSubview:_lineView];
}

-(void)moveLineAccordingToFlag:(NSInteger)flag
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_lineView setCenter:CGPointMake(flag*buttonWidth+buttonWidth/2, self.frame.size.height-lineHeight/2)];
    } completion:^(BOOL finished) {}];
}

-(void)buttonPressed:(UIButton *)sender
{

}

@end
