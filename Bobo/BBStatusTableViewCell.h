//
//  BBHomelistTableViewCell.h
//  Bobo
//
//  Created by Zhouboli on 15/6/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"

@interface BBStatusTableViewCell : UITableViewCell

@property (strong, nonatomic) Status *status;

//status
@property (strong, nonatomic) UILabel *postBodyLbl;
@property (strong, nonatomic) UILabel *nicknameLbl;
@property (strong, nonatomic) UILabel *postTimeLbl;
@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) NSMutableArray *statusImgViews;

//repost status
@property (strong, nonatomic) UIView *repostView;
@property (strong, nonatomic) UILabel *repostLbl;
@property (strong, nonatomic) NSMutableArray *imgViews;

//barbuttons
@property (strong, nonatomic) UIImageView *retweetImageView;
@property (strong, nonatomic) UIImageView *commentImageView;
@property (strong, nonatomic) UIImageView *likeImageView;
@property (strong, nonatomic) UIImageView *favoritesImageView;

@property (strong, nonatomic) UILabel *retweetCountLabel;
@property (strong, nonatomic) UILabel *commentCountLabel;
@property (strong, nonatomic) UILabel *likeCountLabel;

@property (nonatomic) BOOL shouldBeShown;

- (void) clear;
- (void) releaseMemory;

@end
