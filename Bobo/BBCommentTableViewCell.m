//
//  BBCommentCell.m
//  Bobo
//
//  Created by Zhouboli on 15/7/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBCommentTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "Utils.h"

#define cAvatarHeight 40
#define cAvatarWidth cAvatarHeight
#define bWidth [UIScreen mainScreen].bounds.size.width
#define cBigGap 10
#define cSmallGap 5
#define cNameHeight 15
#define cTextWidth bWidth-2*cBigGap-cSmallGap-cAvatarWidth

#define bCellBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

@implementation BBCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (self.highlighted) {
        self.contentView.alpha = 0.9;
    } else {
        self.contentView.alpha = 1.0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(cBigGap, cBigGap, cAvatarWidth, cAvatarHeight)];
    [self.contentView addSubview:_avatarView];
    
    _nameLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLbl.textColor = [UIColor whiteColor];
    _nameLbl.font = [UIFont systemFontOfSize:13.f];
    [self.contentView addSubview:_nameLbl];
    
    _timeLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLbl.textColor = [UIColor lightTextColor];
    _timeLbl.font = [UIFont systemFontOfSize:10.f];
    [self.contentView addSubview:_timeLbl];
    
    _textLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLbl.textColor = [UIColor lightTextColor];
    _textLbl.lineBreakMode = NSLineBreakByWordWrapping;
    _textLbl.numberOfLines = 0;
    _textLbl.font = [UIFont systemFontOfSize:13.f];
    [self.contentView addSubview:_textLbl];
}

-(void)layoutSubviews
{
    [self loadCommentData];
    [self loadCommentLayout];
}

-(void)loadCommentData
{
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:_comment.user.profile_image_url] placeholderImage:[UIImage imageNamed:@"bb_holder_profile_image"] options:SDWebImageRetryFailed];
    _nameLbl.text = _comment.user.screen_name;
    _timeLbl.text = [Utils formatPostTime:_comment.created_at];
    _textLbl.text = _comment.text;
}

-(void)loadCommentLayout
{
    CGSize nameSize = [_nameLbl sizeThatFits:CGSizeMake(MAXFLOAT, cNameHeight)];
    _nameLbl.frame = CGRectMake(cBigGap+cSmallGap+cAvatarWidth, cBigGap, nameSize.width, cNameHeight);
    
    CGSize timeSize = [_timeLbl sizeThatFits:CGSizeMake(MAXFLOAT, cNameHeight)];
    _timeLbl.frame = CGRectMake(cBigGap+2*cSmallGap+cAvatarWidth+_nameLbl.frame.size.width, cBigGap, timeSize.width, cNameHeight);
    
    CGSize textSize = [_textLbl sizeThatFits:CGSizeMake(cTextWidth, MAXFLOAT)];
    _textLbl.frame = CGRectMake(cBigGap+cSmallGap+cAvatarWidth, cBigGap+cNameHeight+cSmallGap, cTextWidth, textSize.height);
}

@end