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

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bAvatarWidth 45
#define bAvatarHeight bAvatarWidth
#define bNicknameWidth [UIScreen mainScreen].bounds.size.width/2
#define bNicknameHeight 20
#define bPostTimeWidth bNicknameWidth
#define bPostTimeHeight 20
#define bTopPadding 10.0
#define bSmallGap 5
#define bBigGap 10
#define sbGap 15
#define bDeleteBtnWidth 20
#define bTextFontSize 14.f
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define bBarHeight bHeight/25
#define bBarSmallGap 7
#define bFontSize 12.0

#define bPostImgHeightForTwo ([UIScreen mainScreen].bounds.size.width-bSmallGap)/2
#define bPostImgWidthForTwo bPostImgHeightForTwo

#define bPostImgHeight ([UIScreen mainScreen].bounds.size.width-2*bSmallGap)/3
#define bPostImgWidth bPostImgHeight

#define bRetweetBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]
#define bCellBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define bMaleColor [UIColor colorWithRed:0.0/255 green:154.0/255 blue:205.0/255 alpha:1.0] //light blue
#define bFemaleColor [UIColor colorWithRed:255.0/255 green:52.0/255 blue:181.0/255 alpha:1.0] //pink

#define kBarColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define tLinkColor [UIColor colorWithRed:106.f/255 green:90.f/255 blue:205.f/255 alpha:1.f]
#define tActiveLinkColor [UIColor colorWithRed:0.f/255 green:205.f/255 blue:102.f/255 alpha:1.f]

#define bWeiboDomain @"https://api.weibo.com/2/"

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

static inline CGFloat heightForImgsWithCount(NSInteger count)
{
    CGFloat height = 0;
    if (count == 1 || count == 2)
    {
        height = bPostImgHeightForTwo;
    }
    if (count == 3)
    {
        height = bPostImgHeight;
    }
    if (count == 4)
    {
        height = bPostImgHeightForTwo*2+bSmallGap;
    }
    if (count > 4 && count <= 6)
    {
        height = bPostImgHeight*2+bSmallGap;
    }
    if (count >= 7 && count <= 9)
    {
        height = bPostImgHeight*3+bSmallGap*2;
    }
    return height;
}

static inline CGFloat layoutImgViews(NSMutableArray *views, NSInteger count, CGFloat height)
{
    for (int i = 0; i < 9; i ++)
    {
        [views[i] setFrame:CGRectZero];
    }
    if (count == 1)
    {
        UIImageView *view = [views firstObject];
        [view setFrame:CGRectMake(bBigGap, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        return bSmallGap+bPostImgHeightForTwo;
    }
    if (count == 2)
    {
        [views[0] setFrame:CGRectMake(0, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        [views[1] setFrame:CGRectMake(bPostImgWidthForTwo+bSmallGap, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        return bSmallGap+bPostImgHeightForTwo;
    }
    if (count == 3)
    {
        for (int i = 0; i < count; i ++)
        {
            [views[i] setFrame:CGRectMake(i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        return bSmallGap+bPostImgHeight;
    }
    if (count == 4)
    {
        [views[0] setFrame:CGRectMake(0, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        [views[1] setFrame:CGRectMake(bPostImgWidthForTwo+bSmallGap, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        [views[2] setFrame:CGRectMake(0, height+2*bSmallGap+bPostImgHeightForTwo, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        [views[3] setFrame:CGRectMake(bPostImgWidthForTwo+bSmallGap, height+2*bSmallGap+bPostImgHeightForTwo, bPostImgWidthForTwo, bPostImgHeightForTwo)];
    }
    if (count > 4 && count <= 6)
    {
        for (int i = 0; i < 3; i ++)
        {
            [views[i] setFrame:CGRectMake(i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int j = 0; j < count - 3; j ++)
        {
            [views[3 + j] setFrame:CGRectMake(j * (bPostImgWidth + bSmallGap), height + bSmallGap + bPostImgHeight + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        return bSmallGap*2+bPostImgHeight*2;
    }
    if (count >= 7 && count <= 9)
    {
        for (int i = 0; i < 3; i ++)
        {
            [views[i] setFrame:CGRectMake(i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int j = 0; j < 3; j ++)
        {
            [views[3 + j] setFrame:CGRectMake(j * (bPostImgWidth + bSmallGap), height + bSmallGap + bPostImgHeight + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int k = 0; k < count - 6; k ++)
        {
            [views[6 + k] setFrame:CGRectMake(k * (bPostImgWidth + bSmallGap), height + bSmallGap + (bPostImgHeight + bSmallGap) * 2, bPostImgWidth, bPostImgHeight)];
        }
        return bSmallGap*3+bPostImgHeight*3;
    }
    return 0;
}

@interface BBStatusTableViewCell : UITableViewCell

@property (strong, nonatomic) Status *status;
@property (strong, nonatomic) TTTAttributedLabel *retweetTextLabel;
@property (strong, nonatomic) TTTAttributedLabel *tweetTextLabel;

@property (weak, nonatomic) id <BBStatusTableViewCellDelegate> delegate;

@end
