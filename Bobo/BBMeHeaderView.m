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
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(self.center.x-bWidth/10, 20, bWidth/5, bWidth/5)];
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.cornerRadius = _avatarView.bounds.size.width*0.5;
    _avatarView.layer.borderWidth = 0.1;
    _avatarView.layer.borderColor = [UIColor blackColor].CGColor;
    [self addSubview:_avatarView];
    
    _name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bWidth, 30)];
    _name.center = CGPointMake(self.center.x, self.frame.size.height*3/4);
    _name.textColor = [UIColor whiteColor];
    _name.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_name];    
}

@end
