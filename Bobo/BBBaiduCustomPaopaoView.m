//
//  BBBaiduCustomPaopaoView.m
//  Bobo
//
//  Created by Zhouboli on 15/7/8.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBBaiduCustomPaopaoView.h"
#import "UIButton+Bobtn.h"

#define btnWidth 80
#define btnHeight 20
#define addressHeight 80

@implementation BBBaiduCustomPaopaoView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setPaopaoViewButtons];
    }
    return self;
}

-(id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, btnWidth + 3 + 10, btnHeight * 2 + 10 + addressHeight)];
    if (self) {
        [self setPaopaoViewButtons];
    }
    return self;
}

-(void)setPaopaoViewButtons
{
    self.backgroundColor = [UIColor whiteColor];
    
    _setStartPointBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 2 * btnHeight - 10, btnWidth, btnHeight) andTitle:@"Start" withBackgroundColor:[UIColor redColor] andTintColor:[UIColor greenColor]];
    [self addSubview:_setStartPointBtn];
    
    _setEndPointBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, self.frame.size.height - 5 - btnHeight, btnWidth, btnHeight) andTitle:@"End" withBackgroundColor:[UIColor redColor] andTintColor:[UIColor greenColor]];
    [self addSubview:_setEndPointBtn];
}

@end
