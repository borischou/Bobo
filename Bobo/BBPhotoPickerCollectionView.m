//
//  BBPhotoPickerCollectionView.m
//  Bobo
//
//  Created by Zhouboli on 15/8/28.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBPhotoPickerCollectionView.h"
#import "BBPhotoSelectionCollectionViewCell.h"

static CGFloat scale = 1.0;

@interface BBPhotoPickerCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) PHCachingImageManager *manager;

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
            PHFetchOptions *options  = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            
            _fetchedPhotos = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            
            _pickedStatuses = nil;
            _pickedStatuses = @[].mutableCopy;
            
            for (int i = 0; i < _fetchedPhotos.count; i ++) {
                [_pickedStatuses addObject:@"0"];
            }
            if (!_manager) {
                _manager = [[PHCachingImageManager alloc] init];
            }
            
            NSRange range = NSMakeRange(0, _fetchedPhotos.count);
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
            NSArray *assets = [_fetchedPhotos objectsAtIndexes:set];
            
            CGSize targetSize = CGSizeMake(_layout.itemSize.width*scale, _layout.itemSize.height*scale);
            
            [_manager startCachingImagesForAssets:assets targetSize:targetSize contentMode:PHImageContentModeAspectFill options:nil];
            [_manager stopCachingImagesForAllAssets];
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
    
    CGSize targetSize = CGSizeMake(_layout.itemSize.width*scale, _layout.itemSize.height*scale);
    PHAsset *asset = _fetchedPhotos[indexPath.item];
    [_manager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
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
            [_pickedOnes removeObject:_fetchedPhotos[indexPath.item]];
        }
    } else {
        if (_pickedOnes.count == 9) {
            return;
        }
        [_pickedOnes addObject:_fetchedPhotos[indexPath.item]];
        [_pickedStatuses setObject:@"1" atIndexedSubscript:indexPath.item];
        cell.layer.borderWidth = 2.0;
        cell.layer.borderColor = UIColor.greenColor.CGColor;
    }
}

@end