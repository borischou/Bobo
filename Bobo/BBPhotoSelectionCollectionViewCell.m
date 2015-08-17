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

@end