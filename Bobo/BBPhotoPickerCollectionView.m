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

@property (copy, nonatomic) NSMutableArray *pickOnes;

@end

@implementation BBPhotoPickerCollectionView

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        [self preparePhotoDataWithLayout:(UICollectionViewFlowLayout *)layout];
        _pickOnes = @[].mutableCopy;
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
            
            NSMutableArray *assets = @[].mutableCopy;
            
            PHCachingImageManager *manager = [[PHCachingImageManager alloc] init];
            
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.synchronous = YES;
            
            CGFloat scale = [UIScreen mainScreen].scale;
            
            CGSize targetSize = CGSizeMake(layout.itemSize.width*scale, layout.itemSize.height*scale);
            for (PHAsset *asset in photos) {
                [self loadImageFromPHAsset:asset withManager:manager options:options targetSize:targetSize];
                [assets addObject:asset];
            }
            [manager startCachingImagesForAssets:assets targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options];
        }
    }];
}

-(void)loadImageFromPHAsset:(PHAsset *)asset withManager:(PHCachingImageManager *)manager options:(PHImageRequestOptions *)options targetSize:(CGSize)targetSize
{
    __block NSMutableArray *photos = @[].mutableCopy;
    [manager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        [photos addObject:result];
    }];
    _photos = photos;
    [self reloadData];
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
    [collectionView registerClass:[BBPhotoSelectionCollectionViewCell class] forCellWithReuseIdentifier:@"reuseCell"];
    BBPhotoSelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseCell" forIndexPath:indexPath];
    UIImage *image = [_photos objectAtIndex:indexPath.item];
    cell.imageView.image = image;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BBPhotoSelectionCollectionViewCell *cell = (BBPhotoSelectionCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isPicked) {
        cell.layer.borderWidth = 0.0;
        if (_pickOnes.count) {
            [_pickOnes removeObject:[_photos objectAtIndex:indexPath.item]];
        }
    } else {
        if (_pickOnes.count == 9) {
            NSLog(@"PICKED: %ld", _pickOnes.count);
            return;
        }
        [_pickOnes addObject:[_photos objectAtIndex:indexPath.item]];
        cell.layer.borderWidth = 2.0;
        cell.layer.borderColor = UIColor.greenColor.CGColor;
    }
}

@end