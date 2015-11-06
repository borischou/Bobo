//
//  BBMessageTableViewCell.m
//  Bobo
//
//  Created by Zhouboli on 15/9/2.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBMessageTableViewCell.h"
#import <YYWebImage.h>

#import "Utils.h"
#import "AppDelegate.h"
#import "NSString+Convert.h"
#import "UIColor+Custom.h"
#import "BBMessageViewController.h"
#import "BBProfileTableViewController.h"

#define bRetweetBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]
#define bCellBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define bMaleColor [UIColor colorWithRed:0.0/255 green:154.0/255 blue:205.0/255 alpha:1.0] //light blue
#define bFemaleColor [UIColor colorWithRed:255.0/255 green:52.0/255 blue:181.0/255 alpha:1.0] //pink

#define kBarColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define tLinkColor [UIColor colorWithRed:106.f/255 green:90.f/255 blue:205.f/255 alpha:1.f]
#define tActiveLinkColor [UIColor colorWithRed:0.f/255 green:205.f/255 blue:102.f/255 alpha:1.f]

#define bWeiboDomain @"https://api.weibo.com/2/"

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

@interface BBMessageTableViewCell ()

//status
@property (strong, nonatomic) UILabel *nicknameLbl;
@property (strong, nonatomic) UILabel *postTimeLbl;
@property (strong, nonatomic) UILabel *sourceLbl;
@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UIImageView *vipView;

//repost status
@property (strong, nonatomic) UIView *repostView;

@end

static inline NSRegularExpression * HotwordRegularExpression() {
    static NSRegularExpression *_hotwordRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _hotwordRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"(@([\\w-]+[\\w-]*))|((https?://([\\w]+).([\\w]+))+/[\\w]+)|(#[^#]+#)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _hotwordRegularExpression;
}

@implementation BBMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initCellLayout];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self loadData];
    [self loadLayout];
}

-(void)initCellLayout
{
    self.contentView.backgroundColor = bCellBGColor;
    
    /*----------文字部分与微博状态cell保持一致，仅隐藏配图------------*/
    
    //profile image
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, bAvatarWidth, bAvatarHeight)];
    _avatarView.userInteractionEnabled = YES;
    _avatarView.clipsToBounds = YES;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.cornerRadius = _avatarView.bounds.size.width*0.5;
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewTapped)]];
    [self.contentView addSubview:_avatarView];
    
    //nickname
    _nicknameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10+bAvatarWidth+10, 10+5, bNicknameWidth, bNicknameHeight)];
    [self.contentView addSubview:_nicknameLbl];
    
    //vip
    _vipView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_vipView];
    
    //post time
    _postTimeLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    _postTimeLbl.textColor = [UIColor lightTextColor];
    _postTimeLbl.font = [UIFont systemFontOfSize:10.f];
    [self.contentView addSubview:_postTimeLbl];
    
    //source
    _sourceLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    _sourceLbl.textColor = [UIColor lightTextColor];
    [_sourceLbl setFont:[UIFont systemFontOfSize:10.f]];
    [self.contentView addSubview:_sourceLbl];
    
    CGFloat fontSize = [Utils fontSizeForStatus];
    //text
    _tweetTextLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    [_tweetTextLabel setNumberOfLines:0];
    [_tweetTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_tweetTextLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [_tweetTextLabel setTextColor:[UIColor customGray]];
    [_tweetTextLabel setLineSpacing:2.0];
    [_tweetTextLabel setLinkAttributes:@{(__bridge NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:NO],
                                         (NSString *)kCTForegroundColorAttributeName: (__bridge id)tLinkColor.CGColor}];
    [_tweetTextLabel setActiveLinkAttributes:@{(__bridge NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:NO],
                                               (NSString *)kCTForegroundColorAttributeName: (__bridge id)tActiveLinkColor.CGColor}];
    [self.contentView addSubview:_tweetTextLabel];
    
    //如果有最近一次回复文本（仅显示一行)
    _lastReplyLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    [_lastReplyLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [_lastReplyLabel setTextColor:[UIColor lightTextColor]];
    [_lastReplyLabel setLinkAttributes:@{(__bridge NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:NO],
                                         (NSString *)kCTForegroundColorAttributeName: (__bridge id)tLinkColor.CGColor}];
    [_lastReplyLabel setActiveLinkAttributes:@{(__bridge NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:NO],
                                               (NSString *)kCTForegroundColorAttributeName: (__bridge id)tActiveLinkColor.CGColor}];
    [self.contentView addSubview:_lastReplyLabel];
    
    //retweet view (评论的微博内容)
    _repostView = [[UIView alloc] initWithFrame:CGRectZero];
    _repostView.userInteractionEnabled = YES;
    _repostView.backgroundColor = bRetweetBGColor;
    [self.contentView addSubview:_repostView];
    
    //repost text
    _retweetTextLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    [_retweetTextLabel setNumberOfLines:0];
    [_retweetTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_retweetTextLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [_retweetTextLabel setTextColor:[UIColor lightTextColor]];
    [_retweetTextLabel setLineSpacing:2.0];
    [_retweetTextLabel setLinkAttributes:@{(__bridge NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:NO],
                                           (NSString *)kCTForegroundColorAttributeName: (__bridge id)tLinkColor.CGColor}];
    [_retweetTextLabel setActiveLinkAttributes:@{(__bridge NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:NO],
                                                 (NSString *)kCTForegroundColorAttributeName: (__bridge id)tActiveLinkColor.CGColor}];
    [_repostView addSubview:_retweetTextLabel];
}

-(void)loadData
{
    NSRegularExpression *regex = HotwordRegularExpression();

    //status
    [_avatarView yy_setImageWithURL:[NSURL URLWithString:_comment.user.avatar_large] placeholder:[UIImage imageNamed:@"bb_holder_profile_image"] options:YYWebImageOptionProgressiveBlur|YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error)
    {
        //nothing
    }];
    
    _nicknameLbl.text = _comment.user.screen_name;
    if ([_comment.user.gender isEqualToString:@"m"])
    {
        [_nicknameLbl setTextColor:bMaleColor];
    }
    if ([_comment.user.gender isEqualToString:@"f"])
    {
        [_nicknameLbl setTextColor:bFemaleColor];
    }
    if ([_comment.user.gender isEqualToString:@"n"])
    {
        [_nicknameLbl setTextColor:[UIColor lightTextColor]];
    }
    
    _postTimeLbl.text = [NSString formatPostTime:_comment.created_at];
    _sourceLbl.text = [NSString trim:_comment.source];
    if (_comment.text)
    {
        [_tweetTextLabel setText:_comment.text];
        NSArray *tweetLinkRanges = [regex matchesInString:_comment.text options:0 range:NSMakeRange(0, _comment.text.length)];
        for (NSTextCheckingResult *result in tweetLinkRanges)
        {
            [_tweetTextLabel addLinkWithTextCheckingResult:result];
        }
    }
    
    if (_comment.reply_comment.text)
    {
        [_lastReplyLabel setText:[NSString stringWithFormat:@"@%@:%@", _comment.reply_comment.user.screen_name, _comment.reply_comment.text]];
        NSArray *tweetLinkRanges = [regex matchesInString:[NSString stringWithFormat:@"@%@:%@", _comment.reply_comment.user.screen_name, _comment.reply_comment.text] options:0 range:NSMakeRange(0, [[NSString stringWithFormat:@"@%@:%@", _comment.reply_comment.user.screen_name, _comment.reply_comment.text] length])];
        for (NSTextCheckingResult *result in tweetLinkRanges)
        {
            [_lastReplyLabel addLinkWithTextCheckingResult:result];
        }
    }
    
    //repost status
    if (_comment.status.text)
    {
        [_retweetTextLabel setText:[NSString stringWithFormat:@"@%@:%@", _comment.status.user.screen_name, _comment.status.text]];
        NSArray *retweetLinkRanges = [regex matchesInString:[NSString stringWithFormat:@"@%@:%@", _comment.status.user.screen_name, _comment.status.text] options:0 range:NSMakeRange(0, [[NSString stringWithFormat:@"@%@:%@", _comment.status.user.screen_name, _comment.status.text] length])];
        for (NSTextCheckingResult *result in retweetLinkRanges)
        {
            [_retweetTextLabel addLinkWithTextCheckingResult:result];
        }
    }
}

-(void)loadLayout
{
    //vip
    if (_comment.user.verified)
    {
        CGSize nameSize = [_nicknameLbl sizeThatFits:CGSizeMake(MAXFLOAT, bNicknameHeight)];
        [_vipView setFrame:CGRectMake(10+bAvatarWidth+10+nameSize.width, 10+5, 15, 15)];
        [_vipView setImage:[UIImage imageNamed:@"icon_vip"]];
    }
    else
    {
        [_vipView setFrame:CGRectZero];
        [_vipView setImage:nil];
    }
    
    [_lastReplyLabel setFrame:CGRectZero]; //标签尺寸置零防止cell复用时造成的内容重叠
    
    //时间
    CGSize timeSize = [_postTimeLbl sizeThatFits:CGSizeMake(MAXFLOAT, bPostTimeHeight)];
    [_postTimeLbl setFrame:CGRectMake(10+bAvatarWidth+10, 10+5+bNicknameHeight+3, timeSize.width, bPostTimeHeight)];
    
    //来源
    CGSize sourceSize = [_sourceLbl sizeThatFits:CGSizeMake(MAXFLOAT, bPostTimeHeight)];
    [_sourceLbl setFrame:CGRectMake(10+bAvatarWidth+10+timeSize.width+10, 10+5+bNicknameHeight+3, sourceSize.width, bPostTimeHeight)];
    
    //微博正文
    CGSize postSize = [_tweetTextLabel sizeThatFits:CGSizeMake(bWidth-2*bBigGap, MAXFLOAT)];
    [_tweetTextLabel setFrame:CGRectMake(bBigGap, bBigGap+bAvatarHeight+bBigGap, bWidth-bBigGap*2, postSize.height)];
    
    CGFloat replyHeight = 0;
    if (_comment.reply_comment.text.length > 0) {
        CGSize replySize = [_lastReplyLabel sizeThatFits:CGSizeMake(bWidth-2*bBigGap, MAXFLOAT)];
        [_lastReplyLabel setFrame:CGRectMake(bBigGap, bBigGap+bAvatarHeight+bBigGap+postSize.height+bSmallGap, bWidth-2*bBigGap, replySize.height)];
        replyHeight += bSmallGap+replySize.height;
    }
    
    CGSize repostSize = [_retweetTextLabel sizeThatFits:CGSizeMake(bWidth-2*bBigGap, MAXFLOAT)];
    [_retweetTextLabel setFrame:CGRectMake(bBigGap, 0, bWidth-2*bBigGap, repostSize.height)];
    
    [_repostView setFrame:CGRectMake(0, bBigGap+bAvatarHeight+bBigGap+postSize.height+replyHeight+bBigGap, bWidth, repostSize.height+bSmallGap)];
}

-(void)avatarViewTapped
{
    [self.delegate tableViewCell:self didTapAvatarView:_avatarView];
}

@end
