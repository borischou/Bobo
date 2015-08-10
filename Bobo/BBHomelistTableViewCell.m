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
#define bPostImgHeight ([UIScreen mainScreen].bounds.size.width-2*bBigGap-2*bSmallGap)/3
#define bPostImgWidth bPostImgHeight
#define bTextFontSize 14.f

#define bRetweetBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bImgBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bCellBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

@interface BBHomelistTableViewCell ()

@end

@implementation BBHomelistTableViewCell

@synthesize avatarView;
@synthesize postBodyLbl;
@synthesize repostView;
@synthesize repostLbl;
@synthesize postTimeLbl;
@synthesize nicknameLbl;
@synthesize imgViews;
@synthesize statusImgViews;

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
    avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, bAvatarWidth, bAvatarHeight)];
    avatarView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:avatarView];
    
    //nickname
    nicknameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10 + bAvatarWidth + 10, 10 + 5, bNicknameWidth, bNicknameHeight)];
    nicknameLbl.textColor = [UIColor whiteColor];
    nicknameLbl.backgroundColor = bCellBGColor;
    [self.contentView addSubview:nicknameLbl];
    
    //post time
    postTimeLbl = [[UILabel alloc] initWithFrame:CGRectMake(10 + bAvatarWidth + 10, 10 + 5 + bNicknameHeight + 3, bPostTimeWidth, bPostTimeHeight)];
    postTimeLbl.textColor = [UIColor lightTextColor];
    postTimeLbl.font = [UIFont systemFontOfSize:10.f];
    postTimeLbl.backgroundColor = bCellBGColor;
    [self.contentView addSubview:postTimeLbl];
    
    //text
    postBodyLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    postBodyLbl.backgroundColor = bCellBGColor;
    postBodyLbl.textColor = [UIColor whiteColor];
    postBodyLbl.numberOfLines = 0;
    postBodyLbl.lineBreakMode = NSLineBreakByWordWrapping;
    postBodyLbl.font = [UIFont systemFontOfSize:bTextFontSize];
    [self.contentView addSubview:postBodyLbl];
    
    //img views for status
    statusImgViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < 9; i ++) {
        UIImageView *sImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        sImgView.backgroundColor = bImgBGColor;
        sImgView.clipsToBounds = YES;
        sImgView.tag = i;
        sImgView.contentMode = UIViewContentModeCenter;
        [sImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusImageTapped:)]];
        sImgView.userInteractionEnabled = YES;
        [statusImgViews addObject:sImgView];
        [self.contentView addSubview:sImgView];
    }
    //retweet view
    repostView = [[UIView alloc] initWithFrame:CGRectZero];
    repostView.backgroundColor = bRetweetBGColor;
    
    //repost text
    repostLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    repostLbl.backgroundColor = bRetweetBGColor;
    repostLbl.textColor = [UIColor whiteColor];
    repostLbl.numberOfLines = 0;
    repostLbl.lineBreakMode = NSLineBreakByWordWrapping;
    repostLbl.font = [UIFont systemFontOfSize:bTextFontSize];
    [repostView addSubview:repostLbl];
    
    //img views for retweeted_status
    imgViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < 9; i ++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgView.backgroundColor = [UIColor redColor];
        imgView.clipsToBounds = YES;
        imgView.tag = i;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(repostImageTapped:)]];
        imgView.userInteractionEnabled = YES;
        [imgViews addObject:imgView];
        [repostView addSubview:imgView];
    }
    [self.contentView addSubview:repostView];
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
    nicknameLbl.text = _status.user.screen_name;
    postTimeLbl.text = [Utils formatPostTime:_status.created_at];
    postBodyLbl.text = _status.text;
    
    //repost status
    repostLbl.text = [NSString stringWithFormat:@"@%@:%@", _status.retweeted_status.user.screen_name, _status.retweeted_status.text];
}

-(void)setCellLayout
{    
    CGSize postSize = [postBodyLbl sizeThatFits:CGSizeMake(bWidth - 2 * bBigGap, MAXFLOAT)];
    postBodyLbl.frame = CGRectMake(bBigGap, bBigGap + bAvatarHeight + bBigGap, bWidth - bBigGap * 2, postSize.height);
    
    repostView.hidden = YES;
    if (_status.retweeted_status) { //retweeted_status
        repostView.hidden = NO;
        [self resetImageViews:statusImgViews];
        CGSize repostSize = [repostLbl sizeThatFits:CGSizeMake(bWidth - 2 * bBigGap, MAXFLOAT)];
        [repostLbl setFrame:CGRectMake(bBigGap, 0, bWidth - 2 * bBigGap, repostSize.height)];
        [self layoutImgViews:imgViews withImageCount:[_status.retweeted_status.pic_urls count] fromTopHeight:repostSize.height];
        
        [repostView setFrame:CGRectMake(0, bBigGap + bAvatarHeight + bBigGap + postSize.height + bBigGap, bWidth, repostSize.height + bSmallGap + [[[Utils alloc] init] heightForImgsWithCount:[_status.retweeted_status.pic_urls count]])];
    } else { //status imgs
        repostView.hidden = YES;
        [self layoutImgViews:statusImgViews withImageCount:[_status.pic_urls count] fromTopHeight:bBigGap + bAvatarHeight + bBigGap + postSize.height];
    }
}

-(void)resetImageViews:(NSMutableArray *)views
{
    for (int i = 0; i < [views count]; i ++) {
        [views[i] setFrame:CGRectZero];
    }
}

-(void)layoutImgViews:(NSMutableArray *)views withImageCount:(NSInteger)count fromTopHeight:(CGFloat)height
{
    for (int i = 0; i < 9; i ++) {
        [views[i] setFrame:CGRectZero];
    }
    
    if (count >= 1 && count <= 3) {
        for (int i = 0; i < count; i ++) {
            [views[i] setFrame:CGRectMake(bBigGap + i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
    }
    
    if (count >= 4 && count <= 6) {
        for (int i = 0; i < 3; i ++) {
            [views[i] setFrame:CGRectMake(bBigGap + i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int j = 0; j < count - 3; j ++) {
            [views[3 + j] setFrame:CGRectMake(bBigGap + j * (bPostImgWidth + bSmallGap), height + bSmallGap + bPostImgHeight + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
    }
    
    if (count >= 7 && count <= 9) {
        for (int i = 0; i < 3; i ++) {
            [views[i] setFrame:CGRectMake(bBigGap + i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int j = 0; j < 3; j ++) {
            [views[3 + j] setFrame:CGRectMake(bBigGap + j * (bPostImgWidth + bSmallGap), height + bSmallGap + bPostImgHeight + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int k = 0; k < count - 6; k ++) {
            [views[6 + k] setFrame:CGRectMake(bBigGap + k * (bPostImgWidth + bSmallGap), height + bSmallGap + (bPostImgHeight + bSmallGap) * 2, bPostImgWidth, bPostImgHeight)];
        }
    }
}

@end
