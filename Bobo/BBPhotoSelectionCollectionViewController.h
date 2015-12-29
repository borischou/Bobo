//
//  BBPhotoSelectionCollectionViewController.h
//  Bobo
//
//  Created by Zhouboli on 15/8/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBUpdateStatusView.h"

@protocol BBPhotoSelectionCollectionViewControllerDelegate <NSObject>

-(void)didFetchPickedPhotos:(NSMutableArray *)photos;
-(void)didCancelPhotoSelection;

@end

@interface BBPhotoSelectionCollectionViewController : UICollectionViewController

@property (weak, nonatomic) id <BBPhotoSelectionCollectionViewControllerDelegate> delegate;

@property (strong, nonatomic) UIView *mask;
@property (strong, nonatomic) BBUpdateStatusView *updateView;

@end
