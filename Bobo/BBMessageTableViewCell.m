//
//  BBMessageTableViewCell.m
//  Bobo
//
//  Created by Zhouboli on 15/9/2.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBMessageTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "Utils.h"
#import "AppDelegate.h"
#import "NSString+Convert.h"
#import "UIColor+Custom.h"
#import "STTweetLabel.h"
#import "BBMessageViewController.h"
#import "BBProfileTableViewController.h"

#define bRetweetBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]
#define bCellBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define bMaleColor [UIColor colorWithRed:0.0/255 green:154.0/255 blue:205.0/255 alpha:1.0] //light blue
#define bFemaleColor [UIColor colorWithRed:255.0/255 green:52.0/255 blue:181.0/255 alpha:1.0] //pink

#define bBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]
#define kBarColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

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
@property (strong, nonatomic) STTweetLabel *tweetTextLabel;
//@property (strong, nonatomic) UILabel *postBodyLbl;
@property (strong, nonatomic) UILabel *nicknameLbl;
@property (strong, nonatomic) UILabel *postTimeLbl;
@property (strong, nonatomic) UILabel *sourceLbl;
@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UIImageView *vipView;

//repost status
@property (strong, nonatomic) UIView *repostView;
@property (strong, nonatomic) STTweetLabel *retweetTextLabel;
//@property (strong, nonatomic) UILabel *repostLbl;

@end

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
    
    __weak BBMessageTableViewCell *weakSelf = self;
    CGFloat fontSize = [Utils fontSizeForStatus];
    //text
//    _postBodyLbl = [[UILabel alloc] initWithFrame:CGRectZero];
//    _postBodyLbl.numberOfLines = 0;
//    _postBodyLbl.lineBreakMode = NSLineBreakByWordWrapping;
//    [self.contentView addSubview:_postBodyLbl];
    _tweetTextLabel = [[STTweetLabel alloc] initWithFrame:CGRectZero];
    _tweetTextLabel.numberOfLines = 0;
    _tweetTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _tweetTextLabel.backgroundColor = [UIColor clearColor];
    [_tweetTextLabel setAttributes:[Utils genericAttributesWithFontSize:fontSize fontColor:[UIColor customGray]]];
    [_tweetTextLabel setAttributes:[Utils genericAttributesWithFontSize:fontSize fontColor:[UIColor dodgerBlue]] hotWord:STTweetLink];
    [_tweetTextLabel setAttributes:[Utils genericAttributesWithFontSize:fontSize fontColor:[UIColor dodgerBlue]] hotWord:STTweetHashtag];
    [_tweetTextLabel setDetectionBlock:^(STTweetHotWord hotword, NSString *string, NSString *protocol, NSRange range) {
        //callback
        [weakSelf didTapHotword:string];
    }];
    [self.contentView addSubview:_tweetTextLabel];
    
    //retweet view
    _repostView = [[UIView alloc] initWithFrame:CGRectZero];
    _repostView.userInteractionEnabled = YES;
    _repostView.backgroundColor = bRetweetBGColor;
    [self.contentView addSubview:_repostView];
    
    //repost text
//    _repostLbl = [[UILabel alloc] initWithFrame:CGRectZero];
//    _repostLbl.numberOfLines = 0;
//    _repostLbl.lineBreakMode = NSLineBreakByWordWrapping;
//    [_repostView addSubview:_repostLbl];
    _retweetTextLabel = [[STTweetLabel alloc] initWithFrame:CGRectZero];
    _retweetTextLabel.numberOfLines = 0;
    _retweetTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _retweetTextLabel.backgroundColor = [UIColor clearColor];
    [_retweetTextLabel setAttributes:[Utils genericAttributesWithFontSize:fontSize fontColor:[UIColor customGray]]];
    [_retweetTextLabel setAttributes:[Utils genericAttributesWithFontSize:fontSize fontColor:[UIColor dodgerBlue]] hotWord:STTweetLink];
    [_retweetTextLabel setAttributes:[Utils genericAttributesWithFontSize:fontSize fontColor:[UIColor dodgerBlue]] hotWord:STTweetHashtag];
    [_retweetTextLabel setDetectionBlock:^(STTweetHotWord hotword, NSString *string, NSString *protocol, NSRange range) {
        //callback
        [weakSelf didTapHotword:string];
    }];
    [_repostView addSubview:_retweetTextLabel];
}

-(void)loadData
{
    //status
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:_comment.user.avatar_large] placeholderImage:[UIImage imageNamed:@"bb_holder_profile_image"] options:SDWebImageLowPriority];
    
    _nicknameLbl.text = _comment.user.screen_name;
    if ([_comment.user.gender isEqualToString:@"m"]) {
        [_nicknameLbl setTextColor:bMaleColor];
    }
    if ([_comment.user.gender isEqualToString:@"f"]) {
        [_nicknameLbl setTextColor:bFemaleColor];
    }
    if ([_comment.user.gender isEqualToString:@"n"]) {
        [_nicknameLbl setTextColor:[UIColor lightTextColor]];
    }
    
    _postTimeLbl.text = [Utils formatPostTime:_comment.created_at];
    _sourceLbl.text = [NSString trim:_comment.source];
    //_postBodyLbl.attributedText = [NSString markedText:_comment.text fontSize:fontSize fontColor:[UIColor customGray]];
    [_tweetTextLabel setText:_comment.text];
    
    //repost status
    //_repostLbl.attributedText = [NSString markedText:[NSString stringWithFormat:@"@%@:%@", _comment.status.user.screen_name, _comment.status.text] fontSize:fontSize fontColor:[UIColor customGray]];
    [_retweetTextLabel setText:[NSString stringWithFormat:@"@%@:%@", _comment.status.user.screen_name, _comment.status.text]];
}

-(void)loadLayout
{
    //vip
    if (_comment.user.verified) {
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
    
    //微博正文
    //CGSize postSize = [_postBodyLbl sizeThatFits:CGSizeMake(bWidth-2*bBigGap, MAXFLOAT)];
    //_postBodyLbl.frame = CGRectMake(bBigGap, bBigGap+bAvatarHeight+bBigGap, bWidth-bBigGap*2, postSize.height);
    CGSize postSize = [_tweetTextLabel suggestedFrameSizeToFitEntireStringConstrainedToWidth:bWidth-2*bBigGap];
    [_tweetTextLabel setFrame:CGRectMake(bBigGap, bBigGap+bAvatarHeight+bBigGap, bWidth-bBigGap*2, postSize.height)];
    
    //CGSize repostSize = [_repostLbl sizeThatFits:CGSizeMake(bWidth-2*bBigGap, MAXFLOAT)];
    //[_repostLbl setFrame:CGRectMake(bBigGap, 0, bWidth-2*bBigGap, repostSize.height)];
    CGSize repostSize = [_retweetTextLabel suggestedFrameSizeToFitEntireStringConstrainedToWidth:bWidth-2*bBigGap];
    [_retweetTextLabel setFrame:CGRectMake(bBigGap, 0, bWidth-2*bBigGap, repostSize.height)];
    
    [_repostView setFrame:CGRectMake(0, bBigGap+bAvatarHeight+bBigGap+postSize.height+bBigGap, bWidth, repostSize.height+bSmallGap)];
}

-(void)avatarViewTapped
{
    NSLog(@"avatarViewTapped");
    NSDictionary *params = @{@"uid": _comment.user.idstr};
    [Utils genericWeiboRequestWithAccount:[[AppDelegate delegate] defaultAccount]
                                      URL:@"statuses/user_timeline.json"
                      SLRequestHTTPMethod:SLRequestMethodGET
                               parameters:params
               completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSMutableArray *statuses = [self statusesWith:responseObject];
         Status *status = statuses.firstObject;
         User *user = status.user;
         
         id obj = nil;
         for (obj = self; obj; obj = [obj nextResponder]) {
             if ([obj isKindOfClass:[BBMessageViewController class]])
             {
                 UIViewController *uivc = (UIViewController *)obj;
                 BBProfileTableViewController *profiletvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                 [self setupNavigationController:uivc.navigationController withUIViewController:profiletvc];
                 profiletvc.uid = user.idstr;
                 profiletvc.statuses = statuses;
                 profiletvc.user = user;
                 profiletvc.shouldNavBtnShown = NO;
                 profiletvc.title = [NSString stringWithFormat:@"%@", user.screen_name];
                 [uivc.navigationController pushViewController:profiletvc animated:YES];
                 return;
             }
         }
         
     }
               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error %@", error);
     }];
}

#pragma mark - STTweetLabelBlockCallbacks support

-(void)didTapHotword:(NSString *)hotword
{
    NSLog(@"点击%@", hotword);
    if ([hotword hasPrefix:@"@"]) {
        NSDictionary *params = @{@"screen_name": [hotword substringFromIndex:1]};
        [Utils genericWeiboRequestWithAccount:[[AppDelegate delegate] defaultAccount]
                                          URL:@"statuses/user_timeline.json"
                          SLRequestHTTPMethod:SLRequestMethodGET
                                   parameters:params
                   completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSMutableArray *statuses = [self statusesWith:responseObject];
             Status *status = statuses.firstObject;
             User *user = status.user;
             
             id obj = nil;
             for (obj = self; obj; obj = [obj nextResponder]) {
                 if ([obj isKindOfClass:[BBMessageViewController class]])
                 {
                     UIViewController *uivc = (UIViewController *)obj;
                     BBProfileTableViewController *profiletvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                     [self setupNavigationController:uivc.navigationController withUIViewController:profiletvc];
                     profiletvc.uid = user.idstr;
                     profiletvc.statuses = statuses;
                     profiletvc.user = user;
                     profiletvc.shouldNavBtnShown = NO;
                     profiletvc.title = [NSString stringWithFormat:@"%@", user.screen_name];
                     [uivc.navigationController pushViewController:profiletvc animated:YES];
                     return;
                 }
             }
         }
                   completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"error %@", error);
         }];
    }
    if ([hotword hasPrefix:@"http"]) {
        //打开webview
    }
    if ([hotword hasPrefix:@"#"]) {
        //热门话题
    }
}

-(NSMutableArray *)statusesWith:(NSData *)data
{
    NSMutableArray *statuses = @[].mutableCopy;
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (![[dict objectForKey:@"statuses"] isEqual:[NSNull null]]) {
        NSArray *status_dicts = [dict objectForKey:@"statuses"];
        for (NSDictionary *status_dict in status_dicts) {
            Status *status = [[Status alloc] initWithDictionary:status_dict];
            [statuses addObject:status];
        }
    }
    return statuses;
}

-(void)setupNavigationController:(UINavigationController *)uinvc withUIViewController:(UIViewController *)uivc
{
    uinvc.navigationBar.barTintColor = kBarColor;
    uinvc.navigationBar.tintColor = [UIColor whiteColor];
    uinvc.navigationBar.layer.shadowOpacity = 0.2;
    uinvc.navigationBar.layer.shadowOffset = CGSizeMake(0, 2);
    uinvc.navigationBar.layer.shadowColor = [UIColor blackColor].CGColor;
    
    uivc.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    uivc.view.backgroundColor = bBGColor;
    
    if ([uivc isKindOfClass:[UITableViewController class]]) {
        UITableViewController *uitvc = (UITableViewController *)uivc;
        uitvc.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

@end
