//
//  BBKIAccessoryNoImageView.m
//  Bobo
//
//  Created by Boris Chow on 8/23/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import "BBKIAccessoryNoImageView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define kBtnWidth bWidth/4
#define kBtnHeight self.bounds.size.height

@implementation BBKIAccessoryNoImageView

-(instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, bWidth, 50)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupAccessoryButtons];
    }
    return self;
}

-(void)setupAccessoryButtons
{
    
}

@end
