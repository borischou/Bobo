//
//  BBPhotoSelectionCollectionViewController.h
//  Bobo
//
//  Created by Zhouboli on 15/8/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBUpdateStatusView.h"

@class BBPhotoSelectionCollectionViewController;
@protocol BBPhotoSelectionCollectionViewControllerDelegate <NSObject>

-(void)photoCollectionViewController:(BBPhotoSelectionCollectionViewController *)photocvc didFetchPickedPhotos:(NSMutableArray *)photos;
-(void)photoCollectionViewController:(BBPhotoSelectionCollectionViewController *)photocvc didPressCancelButton:(UIBarButtonItem *)sender;

@end

@interface BBPhotoSelectionCollectionViewController : UICollectionViewController

@property (weak, nonatomic) id <BBPhotoSelectionCollectionViewControllerDelegate> delegate;

@property (strong, nonatomic) UIView *mask;
@property (strong, nonatomic) BBUpdateStatusView *updateView;

@end
