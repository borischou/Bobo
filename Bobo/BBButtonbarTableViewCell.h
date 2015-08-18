//
//  BBButtonbarCell.h
//  Bobo
//
//  Created by Zhouboli on 15/6/18.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"

@interface BBButtonbarTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *retweetImageView;
@property (strong, nonatomic) UIImageView *commentImageView;
@property (strong, nonatomic) UIImageView *likeImageView;
@property (strong, nonatomic) UILabel *retweetCountLabel;
@property (strong, nonatomic) UILabel *commentCountLabel;
@property (strong, nonatomic) UILabel *likeCountLabel;
@property (strong, nonatomic) Status *status;

@end
