//
//  BBHomelistTableViewCell.m
//  Bobo
//
//  Created by Zhouboli on 15/6/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBHomelistTableViewCell.h"
#import "BBNetworkUtils.h"
#import "BBImageBrowserView.h"
#import "NSString+Convert.h"
#import "Utils.h"

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
#define bPostImgHeight ([UIScreen mainScreen].bounds.size.width-2*bSmallGap)/3
#define bPostImgWidth bPostImgHeight
#define bTextFontSize 14.f

#define bRetweetBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bImgBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bCellBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

@interface BBHomelistTableViewCell ()

@end

@implementation BBHomelistTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

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
    
    //profile image
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, bAvatarWidth, bAvatarHeight)];
    _avatarView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_avatarView];
    
    //nickname
    _nicknameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10 + bAvatarWidth + 10, 10 + 5, bNicknameWidth, bNicknameHeight)];
    _nicknameLbl.textColor = [UIColor whiteColor];
    _nicknameLbl.backgroundColor = bCellBGColor;
    [self.contentView addSubview:_nicknameLbl];
    
    //post time
    _postTimeLbl = [[UILabel alloc] initWithFrame:CGRectMake(10 + bAvatarWidth + 10, 10 + 5 + bNicknameHeight + 3, bPostTimeWidth, bPostTimeHeight)];
    _postTimeLbl.textColor = [UIColor lightTextColor];
    _postTimeLbl.font = [UIFont systemFontOfSize:10.f];
    _postTimeLbl.backgroundColor = bCellBGColor;
    [self.contentView addSubview:_postTimeLbl];
    
    //text
    _postBodyLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    _postBodyLbl.backgroundColor = bCellBGColor;
    _postBodyLbl.textColor = [UIColor whiteColor];
    _postBodyLbl.numberOfLines = 0;
    _postBodyLbl.lineBreakMode = NSLineBreakByWordWrapping;
    _postBodyLbl.font = [UIFont systemFontOfSize:bTextFontSize];
    [self.contentView addSubview:_postBodyLbl];
    
    //img views for status
    _statusImgViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < 9; i ++) {
        UIImageView *sImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        sImgView.backgroundColor = bImgBGColor;
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
    _repostView.backgroundColor = bRetweetBGColor;
    
    //repost text
    _repostLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    _repostLbl.backgroundColor = bRetweetBGColor;
    _repostLbl.textColor = [UIColor whiteColor];
    _repostLbl.numberOfLines = 0;
    _repostLbl.lineBreakMode = NSLineBreakByWordWrapping;
    _repostLbl.font = [UIFont systemFontOfSize:bTextFontSize];
    [_repostView addSubview:_repostLbl];
    
    //img views for retweeted_status
    _imgViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < 9; i ++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgView.backgroundColor = [UIColor redColor];
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

-(void)statusImageTapped:(UITapGestureRecognizer *)tap
{
    NSMutableArray *largeUrls = @[].mutableCopy;
    for (NSString *str in _status.pic_urls) {
        [largeUrls addObject:[NSString largePictureUrlConvertedFromThumbUrl:str]];
    }
    [self.delegate setImageBrowserWithImageUrls:largeUrls andTappedViewTag:tap.view.tag];
}

-(void)repostImageTapped:(UITapGestureRecognizer *)tap
{
    NSMutableArray *largeUrls = @[].mutableCopy;

    for (NSString *str in _status.retweeted_status.pic_urls) {
        [largeUrls addObject:[NSString largePictureUrlConvertedFromThumbUrl:str]];
    }
    [self.delegate setImageBrowserWithImageUrls:largeUrls andTappedViewTag:tap.view.tag];
}

//override this method to load views dynamically
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self setStatusData];
    [self setCellLayout];
}

-(void)setStatusData
{
    //status
    _nicknameLbl.text = _status.user.screen_name;
    _postTimeLbl.text = [Utils formatPostTime:_status.created_at];
    _postBodyLbl.text = _status.text;
    
    //repost status
    _repostLbl.text = [NSString stringWithFormat:@"@%@:%@", _status.retweeted_status.user.screen_name, _status.retweeted_status.text];
}

-(void)setCellLayout
{    
    CGSize postSize = [_postBodyLbl sizeThatFits:CGSizeMake(bWidth - 2 * bBigGap, MAXFLOAT)];
    _postBodyLbl.frame = CGRectMake(bBigGap, bBigGap + bAvatarHeight + bBigGap, bWidth - bBigGap * 2, postSize.height);
    
    _repostView.hidden = YES;
    if (_status.retweeted_status) { //retweeted_status
        _repostView.hidden = NO;
        [self resetImageViews:_statusImgViews];
        CGSize repostSize = [_repostLbl sizeThatFits:CGSizeMake(bWidth - 2 * bBigGap, MAXFLOAT)];
        [_repostLbl setFrame:CGRectMake(bBigGap, 0, bWidth - 2 * bBigGap, repostSize.height)];
        [BBNetworkUtils layoutImgViews:_imgViews withImageCount:[_status.retweeted_status.pic_urls count] fromTopHeight:repostSize.height];
        
        [_repostView setFrame:CGRectMake(0, bBigGap + bAvatarHeight + bBigGap + postSize.height + bBigGap, bWidth, repostSize.height + bSmallGap + [[[Utils alloc] init] heightForImgsWithCount:[_status.retweeted_status.pic_urls count]])];
    } else { //status imgs
        _repostView.hidden = YES;
        [BBNetworkUtils layoutImgViews:_statusImgViews withImageCount:[_status.pic_urls count] fromTopHeight:bBigGap + bAvatarHeight + bBigGap + postSize.height];
    }
}

-(void)resetImageViews:(NSMutableArray *)views
{
    for (int i = 0; i < [views count]; i ++) {
        [views[i] setFrame:CGRectZero];
    }
}

@end
