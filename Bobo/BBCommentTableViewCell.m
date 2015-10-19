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
#import "UIColor+Custom.h"
#import "NSString+Convert.h"
#import "AppDelegate.h"
#import "BBStatusDetailViewController.h"
#import "BBProfileTableViewController.h"

#define cAvatarHeight 40
#define cAvatarWidth cAvatarHeight
#define bWidth [UIScreen mainScreen].bounds.size.width
#define cBigGap 10
#define cSmallGap 5
#define cNameHeight 15
#define cTextWidth bWidth-2*cBigGap-cSmallGap-cAvatarWidth

#define bCellBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]
#define bMaleColor [UIColor colorWithRed:0.0/255 green:154.0/255 blue:205.0/255 alpha:1.0] //light blue
#define bFemaleColor [UIColor colorWithRed:255.0/255 green:52.0/255 blue:181.0/255 alpha:1.0] //pink

#define bBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]
#define kBarColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define tLinkColor [UIColor colorWithRed:106.f/255 green:90.f/255 blue:205.f/255 alpha:1.f]
#define tActiveLinkColor [UIColor colorWithRed:0.f/255 green:205.f/255 blue:102.f/255 alpha:1.f]

static inline NSRegularExpression * HotwordRegularExpression() {
    static NSRegularExpression *_hotwordRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _hotwordRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"(@([\\w-]+[\\w-]*))|((https?://([\\w]+).([\\w]+))+/[\\w]+)|(#[^#]+#)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _hotwordRegularExpression;
}

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
    _avatarView.clipsToBounds = YES;
    _avatarView.userInteractionEnabled = YES;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.cornerRadius = _avatarView.bounds.size.width*0.5;
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewTapped)]];
    [self.contentView addSubview:_avatarView];
    
    _nameLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLbl.textColor = [UIColor whiteColor];
    _nameLbl.font = [UIFont systemFontOfSize:13.f];
    [self.contentView addSubview:_nameLbl];
    
    _timeLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLbl.textColor = [UIColor lightTextColor];
    _timeLbl.font = [UIFont systemFontOfSize:10.f];
    [self.contentView addSubview:_timeLbl];
    
    CGFloat fontSize = [Utils fontSizeForComment];
    _commentTextLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    [_commentTextLabel setNumberOfLines:0];
    [_commentTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_commentTextLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [_commentTextLabel setTextColor:[UIColor customGray]];
    [_commentTextLabel setLineSpacing:2.0];
    [_commentTextLabel setLinkAttributes:@{(__bridge NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:NO],
                                         (NSString *)kCTForegroundColorAttributeName: (__bridge id)tLinkColor.CGColor}];
    [_commentTextLabel setActiveLinkAttributes:@{(__bridge NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:NO],
                                               (NSString *)kCTForegroundColorAttributeName: (__bridge id)tActiveLinkColor.CGColor}];
    [self.contentView addSubview:_commentTextLabel];
}

-(void)layoutSubviews
{
    [self loadCommentData];
    [self loadCommentLayout];
}

-(void)loadCommentData
{
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:_comment.user.profile_image_url] placeholderImage:[UIImage imageNamed:@"bb_holder_profile_image"] options:SDWebImageLowPriority];

    _nameLbl.text = _comment.user.screen_name;
    if ([_comment.user.gender isEqualToString:@"m"]) {
        [_nameLbl setTextColor:bMaleColor];
    }
    if ([_comment.user.gender isEqualToString:@"f"]) {
        [_nameLbl setTextColor:bFemaleColor];
    }
    if ([_comment.user.gender isEqualToString:@"n"]) {
        [_nameLbl setTextColor:[UIColor lightTextColor]];
    }
    
    _timeLbl.text = [NSString formatPostTime:_comment.created_at];
    NSRegularExpression *regex = HotwordRegularExpression();

    if (_comment.text) {
        [_commentTextLabel setText:_comment.text];
        NSArray *tweetLinkRanges = [regex matchesInString:_comment.text options:0 range:NSMakeRange(0, _comment.text.length)];
        for (NSTextCheckingResult *result in tweetLinkRanges) {
            [_commentTextLabel addLinkWithTextCheckingResult:result];
        }
    }
}

-(void)loadCommentLayout
{
    CGSize nameSize = [_nameLbl sizeThatFits:CGSizeMake(MAXFLOAT, cNameHeight)];
    _nameLbl.frame = CGRectMake(cBigGap+cSmallGap+cAvatarWidth, cBigGap, nameSize.width, cNameHeight);
    
    CGSize timeSize = [_timeLbl sizeThatFits:CGSizeMake(MAXFLOAT, cNameHeight)];
    _timeLbl.frame = CGRectMake(cBigGap+2*cSmallGap+cAvatarWidth+_nameLbl.frame.size.width, cBigGap, timeSize.width, cNameHeight);
    
    CGSize textSize = [_commentTextLabel sizeThatFits:CGSizeMake(cTextWidth, MAXFLOAT)];
    [_commentTextLabel setFrame:CGRectMake(cBigGap+cSmallGap+cAvatarWidth, cBigGap+cNameHeight+cSmallGap, cTextWidth, textSize.height)];
}

-(void)avatarViewTapped
{
    [self.delegate commentTableViewCell:self didTapAvatarView:_avatarView];
}

@end