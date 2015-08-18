//
//  BBButtonbarCell.m
//  Bobo
//
//  Created by Zhouboli on 15/6/18.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBButtonbarTableViewCell.h"
#import "UIButton+Bobtn.h"
#import "NSString+Convert.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]
#define bCellBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

#define bBtnHeight bHeight/25
#define bBtnWidth (bWidth-2)/3
#define bBigGap 10
#define bSmallGap 7
#define bImageHeight self.contentView.frame.size.height-2*bSmallGap
#define bImageWidth bImageHeight
#define bFontSize 12.0

@implementation BBButtonbarTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initCellLayout];
    }
    return self;
}

-(void)initCellLayout
{
    self.contentView.backgroundColor = bCellBGColor;
    
    _retweetImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _retweetImageView.image = [UIImage imageNamed:@"retwt_icon"];
    [self.contentView addSubview:_retweetImageView];
    
    _retweetCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetCountLabel.textColor = [UIColor lightTextColor];
    _retweetCountLabel.font = [UIFont systemFontOfSize:bFontSize];
    [self.contentView addSubview:_retweetCountLabel];
    
    _commentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _commentImageView.image = [UIImage imageNamed:@"cmt_icon"];
    [self.contentView addSubview:_commentImageView];
    
    _commentCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _commentCountLabel.textColor = [UIColor lightTextColor];
    _commentCountLabel.font = [UIFont systemFontOfSize:bFontSize];
    [self.contentView addSubview:_commentCountLabel];
    
    _likeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _likeImageView.image = [UIImage imageNamed:@"like_icon"];
    [self.contentView addSubview:_likeImageView];
    
    _likeCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _likeCountLabel.textColor = [UIColor lightTextColor];
    _likeCountLabel.font = [UIFont systemFontOfSize:bFontSize];
    [self.contentView addSubview:_likeCountLabel];
    
    _favoritesImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _favoritesImageView.image = [UIImage imageNamed:@"fav_icon"];
    [self.contentView addSubview:_favoritesImageView];
}

-(void)layoutSubviews
{
    _retweetCountLabel.text = [NSString getNumStrFrom:_status.reposts_count];
    _commentCountLabel.text = [NSString getNumStrFrom:_status.comments_count];
    _likeCountLabel.text = [NSString getNumStrFrom:_status.attitudes_count];
    
    [_retweetImageView setFrame:CGRectMake(bBigGap, bSmallGap, bImageWidth, bImageHeight)];
    
    CGSize rsize = [_retweetCountLabel sizeThatFits:CGSizeMake(MAXFLOAT, bImageHeight)];
    [_retweetCountLabel setFrame:CGRectMake(bBigGap+bImageWidth+bSmallGap, bSmallGap, rsize.width, bImageHeight)];
    
    [_commentImageView setFrame:CGRectMake(bBigGap+bImageWidth+bSmallGap+_retweetCountLabel.frame.size.width+bBigGap, bSmallGap, bImageWidth, bImageHeight)];
    
    CGSize csize = [_commentCountLabel sizeThatFits:CGSizeMake(MAXFLOAT, bImageHeight)];
    [_commentCountLabel setFrame:CGRectMake(bBigGap+bImageWidth+bSmallGap+_retweetCountLabel.frame.size.width+bBigGap+bImageWidth+bSmallGap, bSmallGap, csize.width, bImageHeight)];
    
    [_likeImageView setFrame:CGRectMake(bBigGap+bImageWidth+bSmallGap+_retweetCountLabel.frame.size.width+bBigGap+bImageWidth+bSmallGap+_commentCountLabel.frame.size.width+bBigGap, bSmallGap, bImageWidth, bImageHeight)];
    
    CGSize lsize = [_likeCountLabel sizeThatFits:CGSizeMake(MAXFLOAT, bImageHeight)];
    [_likeCountLabel setFrame:CGRectMake(bBigGap+bImageWidth+bSmallGap+_retweetCountLabel.frame.size.width+bBigGap+bImageWidth+bSmallGap+_commentCountLabel.frame.size.width+bBigGap+bImageWidth+bSmallGap, bSmallGap, lsize.width, bImageHeight)];
    
    [_favoritesImageView setFrame:CGRectMake(bBigGap+bImageWidth+bSmallGap+_retweetCountLabel.frame.size.width+bBigGap+bImageWidth+bSmallGap+_commentCountLabel.frame.size.width+bBigGap+bImageWidth+bSmallGap+_likeCountLabel.frame.size.width+bBigGap, bSmallGap, bImageWidth, bImageHeight)];
}

@end
