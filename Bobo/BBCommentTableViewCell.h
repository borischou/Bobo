//
//  BBCommentCell.h
//  Bobo
//
//  Created by Zhouboli on 15/7/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"
#import <TTTAttributedLabel.h>

@class BBCommentTableViewCell;
@protocol BBCommentTableViewCellDelegate <NSObject>

-(void)commentTableViewCell:(BBCommentTableViewCell *)cell didTapAvatarView:(UIImageView *)avatarView;

@end

@interface BBCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) id <BBCommentTableViewCellDelegate> delegate;

@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UILabel *nameLbl;
@property (strong, nonatomic) UILabel *timeLbl;
@property (strong, nonatomic) TTTAttributedLabel *commentTextLabel;
@property (strong, nonatomic) Comment *comment;

@end
