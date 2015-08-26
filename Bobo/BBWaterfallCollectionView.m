//
//  BBWaterfallCollectionView.m
//  Bobo
//
//  Created by Boris Chow on 8/25/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import "BBWaterfallCollectionView.h"
#import "BBWaterfallCollectionViewCell.h"
#import "Utils.h"

static NSString *reuseCellId = @"reuseCell";

@interface BBWaterfallCollectionView () <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation BBWaterfallCollectionView

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        _statuses = @[].mutableCopy;
        [self registerClass:[BBWaterfallCollectionViewCell class] forCellWithReuseIdentifier:reuseCellId];
        [self reloadData];
    }
    return self;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _statuses.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BBWaterfallCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCellId forIndexPath:indexPath];
    if (_statuses.count > 0) {
        cell.status = [_statuses objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_statuses.count > 0) {
        Status *status = [_statuses objectAtIndex:indexPath.row];
        CGSize cellSize = CGSizeMake([Utils cellWidthForWaterfall], status.heightForWaterfall);
        return cellSize;
    } else {
        return CGSizeZero;
    }
}

@end
