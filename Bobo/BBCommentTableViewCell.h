//
//  BBCommentCell.h
//  Bobo
//
//  Created by Zhouboli on 15/7/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface BBCommentTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UILabel *nameLbl;
@property (strong, nonatomic) UILabel *timeLbl;
@property (strong, nonatomic) UILabel *textLbl;
@property (strong, nonatomic) Comment *comment;

@end
