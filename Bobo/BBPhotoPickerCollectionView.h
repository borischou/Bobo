//
//  BBPhotoPickerCollectionView.h
//  Bobo
//
//  Created by Zhouboli on 15/8/28.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface BBPhotoPickerCollectionView : UICollectionView

@property (copy, nonatomic) NSMutableArray *pickedOnes;
@property (copy, nonatomic) NSMutableArray *pickedStatuses;

@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (strong, nonatomic) PHFetchResult *fetchedPhotos;

@end
