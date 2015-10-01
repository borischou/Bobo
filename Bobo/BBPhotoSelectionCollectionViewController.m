//
//  BBPhotoSelectionCollectionViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/8/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBPhotoSelectionCollectionViewController.h"
#import "BBPhotoSelectionCollectionViewCell.h"
#import "BBPhotoPickerCollectionView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@interface BBPhotoSelectionCollectionViewController ()

@property (strong, nonatomic) BBPhotoPickerCollectionView *photoPickerCollectionView;

@end

@implementation BBPhotoSelectionCollectionViewController

#pragma mark - View Controller Life Cycle

-(void)viewDidLoad
{
    _photoPickerCollectionView = [[BBPhotoPickerCollectionView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight) collectionViewLayout:self.collectionViewLayout];
    self.view = _photoPickerCollectionView;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupNavigationBarButtonItems];
}

#pragma mark - Helpers

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
    [self.delegate didCancelPhotoSelection];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

-(void)confirmButtonItemPressed:(UIBarButtonItem *)sender
{
    NSMutableArray *images = @[].mutableCopy;
    PHImageManager *manager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    NSInteger pickedNum = _photoPickerCollectionView.pickedOnes.count;
    for (int i = 0; i < pickedNum; i ++) {
        PHAsset *asset = _photoPickerCollectionView.pickedOnes[i];
        [manager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            [images addObject:imageData];
            if (i == pickedNum-1) {
                [self.delegate didFetchedPickedPhotos:images];
            }
        }];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

@end