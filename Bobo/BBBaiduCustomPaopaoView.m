//
//  BBBaiduCustomPaopaoView.m
//  Bobo
//
//  Created by Zhouboli on 15/7/8.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBBaiduCustomPaopaoView.h"
#import "UIButton+Bobtn.h"

@implementation BBBaiduCustomPaopaoView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)setPaopaoViewLayout
{
    _setStartPointBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 25, 40, 20) andTitle:@"Start" withBackgroundColor:[UIColor redColor] andTintColor:[UIColor greenColor]];
    [self addSubview:_setStartPointBtn];
    
    _setEndPointBtn = [[UIButton alloc] initWithFrame:CGRectMake(5+40+3, self.frame.size.height - 25, 40, 20) andTitle:@"End" withBackgroundColor:[UIColor redColor] andTintColor:[UIColor greenColor]];
    [self addSubview:_setEndPointBtn];
}

@end
