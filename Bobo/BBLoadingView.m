//
//  BBLoadingView.m
//  Bobo
//
//  Created by Zhouboli on 15/9/24.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBLoadingView.h"

@implementation BBLoadingView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayout];
    }
    return self;
}

-(void)setupLayout
{
    //圆形
    self.backgroundColor = [UIColor redColor];
    self.layer.cornerRadius = self.bounds.size.width*0.5;
}

@end
