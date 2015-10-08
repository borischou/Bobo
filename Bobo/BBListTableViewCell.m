//
//  BBListTableViewCell.m
//  Bobo
//
//  Created by Zhouboli on 15/10/8.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBListTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "UIColor+Custom.h"
#import "NSString+Convert.h"
#import "User.h"
#import "Utils.h"

static float lBigGap = 10;
static float avatarLength = 60;
static float statusLength = 30;
static float nameHeight = 20;

@interface BBListTableViewCell ()

@property (strong, nonatomic) UIImageView *avatar;
@property (strong, nonatomic) UIImageView *relationship;
@property (strong, nonatomic) UIImageView *vip;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UILabel *preview;
@property (strong, nonatomic) UILabel *time;

@end

@implementation BBListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews
{
    //头像
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(lBigGap, lBigGap, avatarLength, avatarLength)];
    [self.contentView addSubview:_avatar];
    
    //状态
    _relationship = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-lBigGap-statusLength, (self.contentView.frame.size.height-statusLength)*.5, statusLength, statusLength)];
    [_relationship setUserInteractionEnabled:YES];
    [self.contentView addSubview:_relationship];
    
    //vip
    _vip = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_vip];
    
    //屏显名称
    _name = [[UILabel alloc] initWithFrame:CGRectZero];
    [_name setTextColor:[UIColor customGray]];
    [_name setFont:[UIFont systemFontOfSize:[Utils fontSizeForStatus]]];
    [self.contentView addSubview:_name];
    
    //微博预览
    _preview = [[UILabel alloc] initWithFrame:CGRectZero];
    [_preview setNumberOfLines:1];
    [_preview setTextColor:[UIColor lightTextColor]];
    [_preview setFont:[UIFont systemFontOfSize:[Utils fontSizeForComment]]];
    [self.contentView addSubview:_preview];
    
    //微博时间
    _time = [[UILabel alloc] initWithFrame:CGRectZero];
    [_time setNumberOfLines:1];
    [_time setTextColor:[UIColor lightTextColor]];
    [_time setFont:[UIFont systemFontOfSize:[Utils fontSizeForComment]]];
    [self.contentView addSubview:_time];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self loadData];
    [self adaptSubviews];
}

-(void)loadData
{
    [_avatar sd_setImageWithURL:[NSURL URLWithString:_user.avatar_large] placeholderImage:[UIImage imageNamed:@"bb_holder_profile_image"] options:SDWebImageLowPriority];
    [_vip setImage:[UIImage imageNamed:@"icon_vip"]];
    if (_user.follow_me && _user.following) //互相关注
    {
        [_relationship setImage:[UIImage imageNamed:@"friend_icon"]];
    }
    if (_user.follow_me && !_user.following) //未关注粉丝
    {
        [_relationship setImage:[UIImage imageNamed:@"follow_icon"]];
    }
    if (!_user.follow_me && _user.following) //已关注对象
    {
        [_relationship setImage:[UIImage imageNamed:@"following_icon"]];
    }
    [_name setText:_user.screen_name];
    [_preview setText:_user.status? _user.status.text: nil];
    [_time setText:_user.status? [NSString formatPostTime:_user.status.created_at]: nil];
}

-(void)adaptSubviews
{
    CGSize nameSize = [_name sizeThatFits:CGSizeMake(MAXFLOAT, nameHeight)];
    if (_user.status.text) //有微博
    {
        [_name setFrame:CGRectMake(lBigGap+avatarLength+lBigGap, lBigGap, nameSize.width, nameHeight)];
        [_vip setFrame:CGRectMake(lBigGap+avatarLength+lBigGap+nameSize.width, lBigGap, 15, 15)];
        [_preview setFrame:CGRectMake(lBigGap+avatarLength+lBigGap, lBigGap+nameHeight, self.contentView.frame.size.width-2*lBigGap-avatarLength-statusLength-2*lBigGap, nameHeight)];
        [_time setFrame:CGRectMake(lBigGap+avatarLength+lBigGap, lBigGap+nameHeight*2, self.contentView.frame.size.width-2*lBigGap-avatarLength-statusLength-2*lBigGap, nameHeight)];
    }
    else //无
    {
        [_name setFrame:CGRectMake(lBigGap+avatarLength+lBigGap, lBigGap+lBigGap, nameSize.width, nameHeight)];
        [_vip setFrame:CGRectMake(lBigGap+avatarLength+lBigGap+nameSize.width, lBigGap+lBigGap, 15, 15)];
    }
}

@end
