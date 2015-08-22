//
//  BBPhotoSelectionCollectionViewController.h
//  Bobo
//
//  Created by Zhouboli on 15/8/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBUpdateStatusView.h"

@interface BBPhotoSelectionCollectionViewController : UICollectionViewController

@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (strong, nonatomic) UIView *mask;
@property (strong, nonatomic) BBUpdateStatusView *updateView;

@end
