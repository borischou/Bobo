//
//  BBPhotoSelectionCollectionViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/8/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBPhotoSelectionCollectionViewController.h"
#import <Photos/Photos.h>

#import "BBPhotoSelectionCollectionViewCell.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@interface BBPhotoSelectionCollectionViewController ()

@property (copy, nonatomic) NSMutableArray *photos;

@end

@implementation BBPhotoSelectionCollectionViewController

#pragma mark - View Controller Life Cycle

-(void)viewDidLoad
{
    [self setupNavigationBarButtonItems];
    [self preparePhotoData];
}

#pragma mark - Helpers

-(void)preparePhotoData
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
            for (PHAsset *asset in photos) {
                [self loadImageFromPHAsset:asset];
            }
        }
    }];
}

-(void)loadImageFromPHAsset:(PHAsset *)asset
{
    PHImageManager *manager = [PHImageManager defaultManager];
    CGSize targetSize = _layout.itemSize;
    [manager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        [_photos addObject:result];
    }];
    [self.collectionView reloadData];
}

-(void)setupNavigationBarButtonItems
{
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonItemPressed:)];
    UIBarButtonItem *confirmButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmButtonItemPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    self.navigationItem.rightBarButtonItem = confirmButtonItem;
}

#pragma mark - UIButtons

-(void)cancelButtonItemPressed:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)confirmButtonItemPressed:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    UIImage *image = [_photos objectAtIndex:indexPath.row];
    cell.imageView.image = image;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
