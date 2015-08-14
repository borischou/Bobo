//
//  BBPhotoSelectionCollectionViewCell.m
//  Bobo
//
//  Created by Zhouboli on 15/8/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBPhotoSelectionCollectionViewCell.h"

@implementation BBPhotoSelectionCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCellLayout];
    }
    return self;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setupCellLayout];
    }
    return self;
}

-(void)setupCellLayout
{
    _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_imageView];
}

@end