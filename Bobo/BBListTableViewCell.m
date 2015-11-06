//
//  BBListTableViewCell.m
//  Bobo
//
//  Created by Zhouboli on 15/10/8.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBListTableViewCell.h"
#import <YYWebImage.h>
#import "UIColor+Custom.h"
#import "NSString+Convert.h"
#import "User.h"
#import "Utils.h"

#define bCellBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define bMaleColor [UIColor colorWithRed:0.0/255 green:154.0/255 blue:205.0/255 alpha:1.0] //light blue
#define bFemaleColor [UIColor colorWithRed:255.0/255 green:52.0/255 blue:181.0/255 alpha:1.0] //pink

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
    if (self.highlighted) {
        self.contentView.alpha = 0.9;
    } else {
        self.contentView.alpha = 1.0;
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView setBackgroundColor:bCellBGColor];
        [self setBackgroundColor:bCellBGColor]; //可设置与contentView同色或透明色以防止左侧分割线颜色不一致
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews
{
    //头像
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(lBigGap, lBigGap, avatarLength, avatarLength)];
    _avatar.clipsToBounds = YES;
    _avatar.layer.masksToBounds = YES;
    _avatar.layer.cornerRadius = _avatar.bounds.size.width*0.5;
    [self.contentView addSubview:_avatar];
    
    //状态
    _relationship = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_relationship setUserInteractionEnabled:YES];
    [_relationship addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(relationshipTapped:)]];
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
    [_preview setTextColor:[UIColor customGray]];
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
    [_avatar yy_setImageWithURL:[NSURL URLWithString:_user.avatar_large] placeholder:[UIImage imageNamed:@"bb_holder_profile_image"] options:YYWebImageOptionProgressiveBlur|YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error)
    {
        //nothing
    }];
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
    if (_user.verified) {
        [_vip setHidden:NO];
    } else {
        [_vip setHidden:YES];
    }
    [_name setText:_user.screen_name];
    if ([_user.gender isEqualToString:@"m"]) {
        [_name setTextColor:bMaleColor];
    } else if ([_user.gender isEqualToString:@"f"]) {
        [_name setTextColor:bFemaleColor];
    } else {
        [_name setTextColor:[UIColor customGray]];
    }
    [_preview setText:_user.status? _user.status.text: nil];
    [_time setText:_user.status? [NSString formatPostTime:_user.status.created_at]: nil];
}

-(void)adaptSubviews
{
    CGSize nameSize = [_name sizeThatFits:CGSizeMake(MAXFLOAT, nameHeight)];
    [_relationship setFrame:CGRectMake(self.contentView.frame.size.width-lBigGap-statusLength, (self.contentView.frame.size.height-statusLength)*.5, statusLength, statusLength)];
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

-(void)relationshipTapped:(UITapGestureRecognizer *)tap
{
    [self.delegate tableViewCell:self didTapRelationshipView:tap];
}

@end
