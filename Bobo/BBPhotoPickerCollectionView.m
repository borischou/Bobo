//
//  BBPhotoPickerCollectionView.m
//  Bobo
//
//  Created by Zhouboli on 15/8/28.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBPhotoPickerCollectionView.h"
#import "BBPhotoSelectionCollectionViewCell.h"
#import <Photos/Photos.h>

@interface BBPhotoPickerCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation BBPhotoPickerCollectionView

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        [self preparePhotoDataWithLayout:(UICollectionViewFlowLayout *)layout];
        [self registerClass:[BBPhotoSelectionCollectionViewCell class] forCellWithReuseIdentifier:@"reuseCell"];
        _pickedOnes = @[].mutableCopy;
    }
    return self;
}

-(void)preparePhotoDataWithLayout:(UICollectionViewFlowLayout *)layout
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        NSLog(@"ALBUM NAME: %@", collection.localizedTitle);
        if ([collection.localizedTitle isEqualToString:@"Camera Roll"]) {
            PHFetchResult *photos = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            NSLog(@"PHOTOS: %ld", photos.count);
            
            _photos = nil;
            _photos = @[].mutableCopy;
            _pickedStatuses = nil;
            _pickedStatuses = @[].mutableCopy;
            
            NSMutableArray *assets = @[].mutableCopy;
            PHCachingImageManager *manager = [[PHCachingImageManager alloc] init];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.synchronous = YES;

            CGFloat scale = [UIScreen mainScreen].scale;
            CGSize targetSize = CGSizeMake(layout.itemSize.width*scale, layout.itemSize.height*scale);
            
            [manager startCachingImagesForAssets:assets targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options];

            for (PHAsset *asset in photos) {
                [self loadImageFromPHAsset:asset withManager:manager options:options targetSize:targetSize];
                [assets addObject:asset];
            }

            [manager stopCachingImagesForAllAssets];
            [self reloadData];
        }
    }];
}

-(void)loadImageFromPHAsset:(PHAsset *)asset withManager:(PHCachingImageManager *)manager options:(PHImageRequestOptions *)options targetSize:(CGSize)targetSize
{
    [manager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        [_photos addObject:result];
        [_pickedStatuses addObject:@"0"];
    }];
}

#pragma mark - UICollectionViewDelegate & data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BBPhotoSelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseCell" forIndexPath:indexPath];
    if ([[_pickedStatuses objectAtIndex:indexPath.item] isEqualToString:@"0"]) {
        cell.layer.borderWidth = 0.0;
    }
    if ([[_pickedStatuses objectAtIndex:indexPath.item] isEqualToString:@"1"]) {
        cell.layer.borderWidth = 2.0;
        cell.layer.borderColor = UIColor.greenColor.CGColor;
    }
    UIImage *image = [_photos objectAtIndex:indexPath.item];
    cell.imageView.image = image;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BBPhotoSelectionCollectionViewCell *cell = (BBPhotoSelectionCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([[_pickedStatuses objectAtIndex:indexPath.item] isEqualToString:@"1"]) {
        cell.layer.borderWidth = 0.0;
        if (_pickedOnes.count) {
            [_pickedStatuses setObject:@"0" atIndexedSubscript:indexPath.item];
            [_pickedOnes removeObject:[_photos objectAtIndex:indexPath.item]];
            NSLog(@"LEFT: %ld", _pickedOnes.count);
        }
    } else {
        if (_pickedOnes.count == 9) {
            return;
        }
        [_pickedOnes addObject:[_photos objectAtIndex:indexPath.item]];
        [_pickedStatuses setObject:@"1" atIndexedSubscript:indexPath.item];
        NSLog(@"PICKED: %ld", _pickedOnes.count);
        cell.layer.borderWidth = 2.0;
        cell.layer.borderColor = UIColor.greenColor.CGColor;
    }
}

@end