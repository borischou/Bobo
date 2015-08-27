//
//  BBWaterfallCollectionViewFlowLayout.m
//  Bobo
//
//  Created by Boris Chow on 8/25/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import "BBWaterfallCollectionViewFlowLayout.h"

@implementation BBWaterfallCollectionViewFlowLayout

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setupFlowLayoutParams];
    }
    return self;
}

-(void)setupFlowLayoutParams
{
//    self.minimumInteritemSpacing = .5;
//    self.minimumLineSpacing = .5;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

//-(CGSize)collectionViewContentSize
//{
//    return _contentSize;
//}

@end
