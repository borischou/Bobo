//
//  BBPhotoSelectionCollectionViewCell.m
//  Bobo
//
//  Created by Zhouboli on 15/8/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBPhotoSelectionCollectionViewCell.h"

@implementation BBPhotoSelectionCollectionViewCell

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (self.highlighted) {
        self.contentView.alpha = 0.5;
    } else {
        self.contentView.alpha = 1.0;
    }
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setupImageView];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupImageView];
    }
    return self;
}

-(void)setupImageView
{
    _imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self.contentView addSubview:_imageView];
}

@end