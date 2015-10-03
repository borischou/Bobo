//
//  BBProfileMenuHeaderView.m
//  Bobo
//
//  Created by Boris Chow on 10/2/15.
//  Copyright © 2015 Zhouboli. All rights reserved.
//

#import "BBProfileMenuHeaderView.h"

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
    [photoButton setFrame:CGRectMake(0, 0, self.frame.size.width/3, self.frame.size.height)];
    [photoButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [photoButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:photoButton];
}

-(void)buttonPressed:(UIButton *)sender
{

}

@end
