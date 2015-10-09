//
//  BBAlbumCollectionViewController.h
//  Bobo
//
//  Created by Zhouboli on 15/10/9.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@class BBAlbumCollectionViewController;
@protocol BBAlbumCollectionViewControllerDelegate <NSObject>

@optional
-(void)collectionViewControllerDidPushBack:(BBAlbumCollectionViewController *)collectionViewController;

@end

@interface BBAlbumCollectionViewController : UICollectionViewController

@property (weak, nonatomic) id <BBAlbumCollectionViewControllerDelegate> delegate;

@property (strong, nonatomic) User *user;

@end
