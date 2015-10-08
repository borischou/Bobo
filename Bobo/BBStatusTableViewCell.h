//
//  BBHomelistTableViewCell.h
//  Bobo
//
//  Created by Zhouboli on 15/6/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel.h>
#import "Status.h"

@class BBStatusTableViewCell;
@protocol BBStatusTableViewCellDelegate <NSObject>

@optional
-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetIcon:(UIImageView *)retweetIcon;
-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapCommentIcon:(UIImageView *)commentIcon;
-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapAttitudeIcon:(UIImageView *)attitudeIcon;
-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapFavoriteIcon:(UIImageView *)favoriteIcon;
-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapAvatar:(UIImageView *)avatar;
-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetView:(UIView *)retweetView;
-(void)tableViewCell:(BBStatusTableViewCell *)cell didPressDeleteButton:(UIButton *)sender;
-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapStatusPicture:(UITapGestureRecognizer *)tap;
-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetPicture:(UITapGestureRecognizer *)tap;

@end

@interface BBStatusTableViewCell : UITableViewCell

@property (strong, nonatomic) Status *status;
@property (strong, nonatomic) TTTAttributedLabel *retweetTextLabel;
@property (strong, nonatomic) TTTAttributedLabel *tweetTextLabel;

@property (weak, nonatomic) id <BBStatusTableViewCellDelegate> delegate;

@end
