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

@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (strong, nonatomic) PHFetchResult *fetchedPhotos;
@property (strong, nonatomic) PHCachingImageManager *manager;
@property (strong, nonatomic) PHImageRequestOptions *options;

@end

@implementation BBPhotoPickerCollectionView

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        _layout = (UICollectionViewFlowLayout *)layout;
        [self preparePhotoDataWithLayout:(UICollectionViewFlowLayout *)layout];
        [self registerClass:[BBPhotoSelectionCollectionViewCell class] forCellWithReuseIdentifier:@"reuseCell"];
        _pickedOnes = @[].mutableCopy;
    }
    return self;
}

-(void)preparePhotoDataWithLayout:(UICollectionViewFlowLayout *)layout
{
    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        NSLog(@"ALBUM NAME: %@", collection.localizedTitle);
        if ([collection.localizedTitle isEqualToString:@"Camera Roll"]) {
            _fetchedPhotos = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            NSLog(@"PHOTOS: %ld", _fetchedPhotos.count);
            
            _pickedStatuses = nil;
            _pickedStatuses = @[].mutableCopy;
            
            for (int i = 0; i < _fetchedPhotos.count; i ++) {
                [_pickedStatuses addObject:@"0"];
            }
            
            NSMutableArray *assets = @[].mutableCopy;
            
            _manager = [[PHCachingImageManager alloc] init];
            _options = [[PHImageRequestOptions alloc] init];
            _options.resizeMode = PHImageRequestOptionsResizeModeExact;
            _options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            
            CGFloat scale = [UIScreen mainScreen].scale;
            CGSize targetSize = CGSizeMake(layout.itemSize.width*scale, layout.itemSize.height*scale);
            
            [_manager startCachingImagesForAssets:assets targetSize:targetSize contentMode:PHImageContentModeAspectFill options:_options];
        }
    }];
}

#pragma mark - UICollectionViewDelegate & data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _fetchedPhotos.count;
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
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(_layout.itemSize.width*scale, _layout.itemSize.height*scale);
    
    PHAsset *asset = _fetchedPhotos[indexPath.item];
    [_manager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:_options resultHandler:^(UIImage *result, NSDictionary *info) {
        cell.imageView.image = result;
    }];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BBPhotoSelectionCollectionViewCell *cell = (BBPhotoSelectionCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([[_pickedStatuses objectAtIndex:indexPath.item] isEqualToString:@"1"]) {
        cell.layer.borderWidth = 0.0;
        if (_pickedOnes.count) {
            [_pickedStatuses setObject:@"0" atIndexedSubscript:indexPath.item];
            [_pickedOnes removeObject:cell.imageView.image];
            NSLog(@"LEFT: %ld", _pickedOnes.count);
        }
    } else {
        if (_pickedOnes.count == 9) {
            return;
        }
        [_pickedOnes addObject:cell.imageView.image];
        [_pickedStatuses setObject:@"1" atIndexedSubscript:indexPath.item];
        NSLog(@"PICKED: %ld", _pickedOnes.count);
        cell.layer.borderWidth = 2.0;
        cell.layer.borderColor = UIColor.greenColor.CGColor;
    }
}

@end