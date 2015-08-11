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

#define cAvatarHeight self.contentView.frame.size.height*3/4
#define cAvatarWidth cAvatarHeight
#define cWidth self.contentView.frame.size.width
#define cHeight self.contentView.frame.size.height
#define cBigGap 10
#define cSmallGap 5
#define cNameHeight 20
#define cTextWidth self.contentView.frame.size.width-2*cBigGap-cSmallGap-cAvatarWidth

@implementation BBCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
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
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(cBigGap, cBigGap, cAvatarWidth, cAvatarHeight)];
    _avatarView.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:_avatarView];
    
    _nameLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_nameLbl];
    
    _timeLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_timeLbl];
    
    _textLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLbl.lineBreakMode = NSLineBreakByWordWrapping;
    _textLbl.numberOfLines = 0;
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




































