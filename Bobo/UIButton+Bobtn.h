//
//  UIButton+Bobtn.h
//  Bobo
//
//  Created by Zhouboli on 15/6/19.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Bobtn)

-(id)initWithFrame:(CGRect)frame andTitle:(NSString *)title withBackgroundColor:(UIColor *)bgcolor andTintColor:(UIColor *)tcolor;
-(void)setTitle:(NSString *)title withBackgroundColor:(UIColor *)bgcolor andTintColor:(UIColor *)tcolor;

@end
