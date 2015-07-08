//
//  UIButton+Bobtn.m
//  Bobo
//
//  Created by Zhouboli on 15/6/19.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "UIButton+Bobtn.h"

@implementation UIButton (Bobtn)

-(id)initWithFrame:(CGRect)frame andTitle:(NSString *)title withBackgroundColor:(UIColor *)bgcolor andTintColor:(UIColor *)tcolor
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:title forState:UIControlStateNormal];
        self.backgroundColor = bgcolor;
        self.tintColor = tcolor;
        self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.f]}];
    }
    return self;
}

-(void)setTitle:(NSString *)title withBackgroundColor:(UIColor *)bgcolor andTintColor:(UIColor *)tcolor
{
    [self setTitle:title forState:UIControlStateNormal];
    self.backgroundColor = bgcolor;
    self.tintColor = tcolor;
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.f]}];
}

@end
