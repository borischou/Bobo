//
//  BBHomelistTableViewCell.m
//  Bobo
//
//  Created by Zhouboli on 15/6/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <AFNetworking.h>
#import <WebKit/WebKit.h>

#import "BBStatusTableViewCell.h"
#import "NSString+Convert.h"
#import "UIColor+Custom.h"

#import "Utils.h"
#import "AppDelegate.h"
#import "BBUpdateStatusView.h"
#import "BBImageBrowserView.h"

#import "BBStatusDetailViewController.h"
#import "BBMainStatusTableViewController.h"
#import "BBProfileTableViewController.h"
#import "BBFavoritesTableViewController.h"

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
#define bDeleteBtnWidth 20
#define bTextFontSize 14.f
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define bPostImgHeight ([UIScreen mainScreen].bounds.size.width-2*bSmallGap)/3
#define bPostImgHeightForTwo ([UIScreen mainScreen].bounds.size.width-2*bSmallGap)/2
#define bPostImgWidth bPostImgHeight
#define bPostImgWidthForTwo bPostImgHeightForTwo

#define bBarHeight bHeight/25
#define bBarSmallGap 7
#define bImageHeight [UIScreen mainScreen].bounds.size.height/25-2*bBarSmallGap
#define bImageWidth bImageHeight
#define bFontSize 12.0

#define bRetweetBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]
#define bCellBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define bMaleColor [UIColor colorWithRed:0.0/255 green:154.0/255 blue:205.0/255 alpha:1.0] //light blue
#define bFemaleColor [UIColor colorWithRed:255.0/255 green:52.0/255 blue:181.0/255 alpha:1.0] //pink

#define bBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]
#define kBarColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define tLinkColor [UIColor colorWithRed:106.f/255 green:90.f/255 blue:205.f/255 alpha:1.f]
#define tActiveLinkColor [UIColor colorWithRed:0.f/255 green:205.f/255 blue:102.f/255 alpha:1.f]

#define bWeiboDomain @"https://api.weibo.com/2/"

@interface BBStatusTableViewCell ()

//status
@property (strong, nonatomic) UILabel *nicknameLbl;
@property (strong, nonatomic) UILabel *postTimeLbl;
@property (strong, nonatomic) UILabel *sourceLbl;
@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UIImageView *vipView;
@property (strong, nonatomic) NSMutableArray *statusImgViews;

@property (strong, nonatomic) UIButton *deleteButton;

//repost status
@property (strong, nonatomic) UIView *repostView;
@property (strong, nonatomic) NSMutableArray *imgViews;

//barbuttons
@property (strong, nonatomic) UIImageView *retweetImageView;
@property (strong, nonatomic) UIImageView *commentImageView;
@property (strong, nonatomic) UIImageView *likeImageView;
@property (strong, nonatomic) UIImageView *favoritesImageView;

@property (strong, nonatomic) UILabel *retweetCountLabel;
@property (strong, nonatomic) UILabel *commentCountLabel;
@property (strong, nonatomic) UILabel *likeCountLabel;

@end

static inline NSRegularExpression * HotwordRegularExpression() {
    static NSRegularExpression *_hotwordRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _hotwordRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"(@([\\w-]+[\\w-]*))|((https?://([\\w]+).([\\w]+))+/[\\w]+)|(#[^#]+#)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _hotwordRegularExpression;
}

@implementation BBStatusTableViewCell

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
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initCellLayout];
        [self setupBarButtonsLayout];
    }
    return self;
}

-(void)initCellLayout
{
    self.contentView.backgroundColor = bCellBGColor;
    
    //profile image
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, bAvatarWidth, bAvatarHeight)];
    _avatarView.userInteractionEnabled = YES;
    _avatarView.clipsToBounds = YES;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.cornerRadius = _avatarView.bounds.size.width*0.5;
    _avatarView.layer.borderWidth = 0.1;
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
    
    //delete
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setFrame:CGRectZero];
    [_deleteButton setBackgroundImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteButton];
    
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
    
    //img views for status
    _statusImgViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < 9; i ++) {
        UIImageView *sImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        sImgView.clipsToBounds = YES;
        sImgView.tag = i;
        sImgView.contentMode = UIViewContentModeScaleAspectFill;
        [sImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusImageTapped:)]];
        sImgView.userInteractionEnabled = YES;
        [_statusImgViews addObject:sImgView];
        [self.contentView addSubview:sImgView];
    }
    //retweet view
    _repostView = [[UIView alloc] initWithFrame:CGRectZero];
    _repostView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(repostViewTapped:)];
    [_repostView addGestureRecognizer:tap];
    _repostView.backgroundColor = bRetweetBGColor;
    
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
    
    //img views for retweeted_status
    _imgViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < 9; i ++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgView.clipsToBounds = YES;
        imgView.tag = i;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(repostImageTapped:)]];
        imgView.userInteractionEnabled = YES;
        [_imgViews addObject:imgView];
        [_repostView addSubview:imgView];
    }
    [self.contentView addSubview:_repostView];
}

-(void)setupBarButtonsLayout
{
    self.contentView.backgroundColor = bCellBGColor;
    
    _retweetImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _retweetImageView.image = [UIImage imageNamed:@"retwt_icon"];
    _retweetImageView.userInteractionEnabled = YES;
    [_retweetImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retweetImageViewTapped)]];
    [self.contentView addSubview:_retweetImageView];
    
    _retweetCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetCountLabel.textColor = [UIColor lightTextColor];
    _retweetCountLabel.font = [UIFont systemFontOfSize:bFontSize];
    [self.contentView addSubview:_retweetCountLabel];
    
    _commentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _commentImageView.image = [UIImage imageNamed:@"cmt_icon"];
    _commentImageView.clipsToBounds = YES;
    _commentImageView.userInteractionEnabled = YES;
    [_commentImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentImageViewTapped)]];
    [self.contentView addSubview:_commentImageView];
    
    _commentCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _commentCountLabel.textColor = [UIColor lightTextColor];
    _commentCountLabel.font = [UIFont systemFontOfSize:bFontSize];
    [self.contentView addSubview:_commentCountLabel];
    
    _likeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _likeImageView.image = [UIImage imageNamed:@"like_icon_2"];
    _likeImageView.clipsToBounds = YES;
    _likeImageView.userInteractionEnabled = YES;
    [_likeImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeImageViewTapped)]];
    [self.contentView addSubview:_likeImageView];
    
    _likeCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _likeCountLabel.textColor = [UIColor lightTextColor];
    _likeCountLabel.font = [UIFont systemFontOfSize:bFontSize];
    [self.contentView addSubview:_likeCountLabel];
    
    _favoritesImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _favoritesImageView.image = [UIImage imageNamed:@"fav_icon_3"];
    _favoritesImageView.clipsToBounds = YES;
    _favoritesImageView.userInteractionEnabled = YES;
    [_favoritesImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favoritesImageViewTapped)]];
    [self.contentView addSubview:_favoritesImageView];
}

#pragma mark - Icon action support

-(void)retweetImageViewTapped
{
    [self.delegate tableViewCell:self didTapRetweetIcon:_retweetImageView];
}

-(void)commentImageViewTapped
{
    [self.delegate tableViewCell:self didTapCommentIcon:_commentImageView];
}

-(void)likeImageViewTapped
{
    NSLog(@"likeImageViewTapped");
}

-(void)favoritesImageViewTapped
{
    [self.delegate tableViewCell:self didTapFavoriteIcon:_favoritesImageView];
}

-(void)statusImageTapped:(UITapGestureRecognizer *)tap
{
    [self.delegate tableViewCell:self didTapStatusPicture:tap];
}

-(void)repostImageTapped:(UITapGestureRecognizer *)tap
{
    [self.delegate tableViewCell:self didTapRetweetPicture:tap];
}

-(void)repostViewTapped:(UITapGestureRecognizer *)tap
{
    [self.delegate tableViewCell:self didTapRetweetView:_repostView];
}

-(void)avatarViewTapped
{
    [self.delegate tableViewCell:self didTapAvatar:_avatarView];
}

-(void)deleteButtonPressed:(UIButton *)sender
{
    [self.delegate tableViewCell:self didPressDeleteButton:sender];
}

#pragma mark - Cell configure support

//override this method to load views dynamically
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self loadData];
    [self loadLayout];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
}

-(void)loadData
{
    NSRegularExpression *regex = HotwordRegularExpression();
    
    //status
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:_status.user.avatar_large] placeholderImage:[UIImage imageNamed:@"bb_holder_profile_image"] options:SDWebImageLowPriority];
    
    _nicknameLbl.text = _status.user.screen_name;
    if ([_status.user.gender isEqualToString:@"m"]) {
        [_nicknameLbl setTextColor:bMaleColor];
    }
    if ([_status.user.gender isEqualToString:@"f"]) {
        [_nicknameLbl setTextColor:bFemaleColor];
    }
    if ([_status.user.gender isEqualToString:@"n"]) {
        [_nicknameLbl setTextColor:[UIColor lightTextColor]];
    }
    
    _postTimeLbl.text = [NSString formatPostTime:_status.created_at];
    _sourceLbl.text = [NSString trim:_status.source];

    if (_status.text) {
        [_tweetTextLabel setText:_status.text];
        NSArray *tweetLinkRanges = [regex matchesInString:_status.text options:0 range:NSMakeRange(0, _status.text.length)];
        for (NSTextCheckingResult *result in tweetLinkRanges) {
            [_tweetTextLabel addLinkWithTextCheckingResult:result];
        }
    }
    
    if (_status.pic_urls.count > 0) {
        for (int i = 0; i < [_status.pic_urls count]; i ++) {
            if ([_status.pic_urls[i] hasSuffix:@"gif"]) {
                [_statusImgViews[i] sd_setImageWithURL:[NSURL URLWithString:_status.pic_urls[i]] placeholderImage:[UIImage imageNamed:@"pic_placeholder"]];
            } else {
                [_statusImgViews[i] sd_setImageWithURL:[NSURL URLWithString:[NSString middlePictureUrlConvertedFromThumbUrl:_status.pic_urls[i]]] placeholderImage:[UIImage imageNamed:@"pic_placeholder"] options:SDWebImageLowPriority];
            }
        }
    }
    
    //repost status
    if (_status.retweeted_status.text) {
        [_retweetTextLabel setText:[NSString stringWithFormat:@"@%@:%@", _status.retweeted_status.user.screen_name, _status.retweeted_status.text]];
        NSArray *retweetLinkRanges = [regex matchesInString:[NSString stringWithFormat:@"@%@:%@", _status.retweeted_status.user.screen_name, _status.retweeted_status.text] options:0 range:NSMakeRange(0, [[NSString stringWithFormat:@"@%@:%@", _status.retweeted_status.user.screen_name, _status.retweeted_status.text] length])];
        for (NSTextCheckingResult *result in retweetLinkRanges) {
            [_retweetTextLabel addLinkWithTextCheckingResult:result];
        }
    }
    
    if (_status.retweeted_status.pic_urls.count > 0) {
        for (int i = 0; i < [_status.retweeted_status.pic_urls count]; i ++) {
            if ([_status.retweeted_status.pic_urls[i] hasSuffix:@"gif"]) {
                [_imgViews[i] sd_setImageWithURL:[NSURL URLWithString:_status.retweeted_status.pic_urls[i]] placeholderImage:[UIImage imageNamed:@"pic_placeholder"]];
            } else {
                [_imgViews[i] sd_setImageWithURL:[NSURL URLWithString:[NSString middlePictureUrlConvertedFromThumbUrl:_status.retweeted_status.pic_urls[i]]] placeholderImage:[UIImage imageNamed:@"pic_placeholder"] options:SDWebImageLowPriority];
            }
        }
    }
    
    //barbuttons
    _retweetCountLabel.text = [NSString formatNum:_status.reposts_count];
    _commentCountLabel.text = [NSString formatNum:_status.comments_count];
    _likeCountLabel.text = [NSString formatNum:_status.attitudes_count];
    
    if (_status.favorited) {
        _favoritesImageView.image = [UIImage imageNamed:@"faved_icon"];
    } else {
        _favoritesImageView.image = [UIImage imageNamed:@"fav_icon_3"];
    }
}

-(void)loadLayout
{
    //vip
    if (_status.user.verified) {
        CGSize nameSize = [_nicknameLbl sizeThatFits:CGSizeMake(MAXFLOAT, bNicknameHeight)];
        [_vipView setFrame:CGRectMake(10+bAvatarWidth+10+nameSize.width, 10+5, 15, 15)];
        [_vipView setImage:[UIImage imageNamed:@"icon_vip"]];
    } else {
        [_vipView setFrame:CGRectZero];
        [_vipView setImage:nil];
    }
    
    //时间
    CGSize timeSize = [_postTimeLbl sizeThatFits:CGSizeMake(MAXFLOAT, bPostTimeHeight)];
    [_postTimeLbl setFrame:CGRectMake(10+bAvatarWidth+10, 10+5+bNicknameHeight+3, timeSize.width, bPostTimeHeight)];
    
    //来源
    CGSize sourceSize = [_sourceLbl sizeThatFits:CGSizeMake(MAXFLOAT, bPostTimeHeight)];
    [_sourceLbl setFrame:CGRectMake(10+bAvatarWidth+10+timeSize.width+10, 10+5+bNicknameHeight+3, sourceSize.width, bPostTimeHeight)];
    
    //删除
    AppDelegate *delegate = [AppDelegate delegate];
    [_deleteButton setFrame:CGRectMake(bWidth-bBigGap-bDeleteBtnWidth, 10+5, bDeleteBtnWidth, bDeleteBtnWidth)];
    if ([_status.user.idstr isEqualToString:delegate.user.idstr]) {
        [_deleteButton setHidden:NO];
    } else {
        [_deleteButton setHidden:YES];
    }
    
    //微博正文
    CGSize postSize = [_tweetTextLabel sizeThatFits:CGSizeMake(bWidth-2*bBigGap, MAXFLOAT)];
    [_tweetTextLabel setFrame:CGRectMake(bBigGap, bBigGap+bAvatarHeight+bBigGap, bWidth-bBigGap*2, postSize.height)];
    
    _repostView.hidden = YES;
    if (_status.retweeted_status) {
        //转发微博
        _repostView.hidden = NO;
        [self resetImageViews:_statusImgViews];
        CGSize repostSize = [_retweetTextLabel sizeThatFits:CGSizeMake(bWidth-2*bBigGap, MAXFLOAT)];
        [_retweetTextLabel setFrame:CGRectMake(bBigGap, 0, bWidth-2*bBigGap, repostSize.height)];
        [Utils layoutImgViews:_imgViews withImageCount:[_status.retweeted_status.pic_urls count] fromTopHeight:repostSize.height];
        
        [_repostView setFrame:CGRectMake(0, bBigGap+bAvatarHeight+bBigGap+postSize.height+bBigGap, bWidth, repostSize.height+bSmallGap+[Utils heightForImgsWithCount:[_status.retweeted_status.pic_urls count]])];        
    }
    else
    {
        //微博配图
        _repostView.hidden = YES;
        [Utils layoutImgViews:_statusImgViews withImageCount:[_status.pic_urls count] fromTopHeight:bBigGap+bAvatarHeight+bBigGap+postSize.height];
    }
    [self layoutBarButtonsWithTop:_status.height-bBarHeight];
}

-(void)layoutBarButtonsWithTop:(CGFloat)top
{
    [_retweetImageView setFrame:CGRectMake(bBigGap, top+bBarSmallGap, bImageWidth, bImageHeight)];
    
    CGSize rsize = [_retweetCountLabel sizeThatFits:CGSizeMake(MAXFLOAT, bImageHeight)];
    [_retweetCountLabel setFrame:CGRectMake(bBigGap+bImageWidth+bSmallGap, top+bBarSmallGap, rsize.width, bImageHeight)];
    
    [_commentImageView setFrame:CGRectMake(bBigGap+bImageWidth+bSmallGap+_retweetCountLabel.frame.size.width+bBigGap, top+bBarSmallGap, bImageWidth, bImageHeight)];
    
    CGSize csize = [_commentCountLabel sizeThatFits:CGSizeMake(MAXFLOAT, bImageHeight)];
    [_commentCountLabel setFrame:CGRectMake(bBigGap+bImageWidth+bSmallGap+_retweetCountLabel.frame.size.width+bBigGap+bImageWidth+bSmallGap, top+bBarSmallGap, csize.width, bImageHeight)];
    
    [_likeImageView setFrame:CGRectMake(bBigGap+bImageWidth+bSmallGap+_retweetCountLabel.frame.size.width+bBigGap+bImageWidth+bSmallGap+_commentCountLabel.frame.size.width+bBigGap, top+bBarSmallGap, bImageWidth, bImageHeight)];
    
    CGSize lsize = [_likeCountLabel sizeThatFits:CGSizeMake(MAXFLOAT, bImageHeight)];
    [_likeCountLabel setFrame:CGRectMake(bBigGap+bImageWidth+bSmallGap+_retweetCountLabel.frame.size.width+bBigGap+bImageWidth+bSmallGap+_commentCountLabel.frame.size.width+bBigGap+bImageWidth+bSmallGap, top+bBarSmallGap, lsize.width, bImageHeight)];
    
    [_favoritesImageView setFrame:CGRectMake(bBigGap+bImageWidth+bSmallGap+_retweetCountLabel.frame.size.width+bBigGap+bImageWidth+bSmallGap+_commentCountLabel.frame.size.width+bBigGap+bImageWidth+bSmallGap+_likeCountLabel.frame.size.width+bBigGap, top+bBarSmallGap, bImageWidth, bImageHeight)];
}

-(void)resetImageViews:(NSMutableArray *)views
{
    for (int i = 0; i < [views count]; i ++) {
        [views[i] setFrame:CGRectZero];
    }
}

@end
