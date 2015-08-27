//
//  BBWaterfallCollectionView.m
//  Bobo
//
//  Created by Boris Chow on 8/25/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import <CHTCollectionViewWaterfallLayout.h>

#import "BBWaterfallCollectionView.h"
#import "BBWaterfallCollectionViewCell.h"
#import "Utils.h"
#import "BBStatusDetailViewController.h"

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]

static NSString *reuseCellId = @"reuseCell";

@interface BBWaterfallCollectionView () <CHTCollectionViewDelegateWaterfallLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation BBWaterfallCollectionView

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = bBGColor;
        _statuses = @[].mutableCopy;
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
    [collectionView registerClass:[BBWaterfallCollectionViewCell class] forCellWithReuseIdentifier:reuseCellId];
    BBWaterfallCollectionViewCell *cell = (BBWaterfallCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseCellId forIndexPath:indexPath];
    if (_statuses.count > 0) {
        Status *status = [_statuses objectAtIndex:indexPath.row];
        cell.status = status;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BBStatusDetailViewController *dtvc = [[BBStatusDetailViewController alloc] init];
    dtvc.title = @"Detail";
    dtvc.hidesBottomBarWhenPushed = YES;
    Status *status = [_statuses objectAtIndex:indexPath.row];
    dtvc.status = status;
    
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

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
