//
//  BBMeHeaderView.m
//  Bobo
//
//  Created by Zhouboli on 15/8/6.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBMeHeaderView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@implementation BBMeHeaderView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setHeaderLayout];
    }
    return self;
}

-(void)setHeaderLayout
{
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(self.center.x-bWidth/8, 5, bWidth/4, bWidth/4)];
    _avatarView.backgroundColor = [UIColor redColor];
    [self addSubview:_avatarView];
    
    _name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bWidth, 30)];
    _name.center = CGPointMake(self.center.x, self.frame.size.height*3/4);
    _name.backgroundColor = [UIColor blueColor];
    _name.textColor = [UIColor whiteColor];
    [self addSubview:_name];    
}

@end
