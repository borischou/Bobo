//
//  BBWaterfallCollectionViewCell.m
//  Bobo
//
//  Created by Boris Chow on 8/25/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import "BBWaterfallCollectionViewCell.h"
#import <UIImageView+WebCache.h>
#import "Utils.h"
#import "NSString+Convert.h"
#import "UIColor+Custom.h"
#import "BBProfileTableViewController.h"
#import "BBStatusDetailViewController.h"
#import "BBWaterfallStatusViewController.h"
#import "BBImageBrowserView.h"
#import "AppDelegate.h"

#define wMaxPictureHeight [UIScreen mainScreen].bounds.size.height*3/5
#define wSmallGap 2
#define wBigGap 4
#define wTextWidth wCellWidth-2*wSmallGap
#define wBottomItemHeight 15.0
#define wBottomItemWidth wBottomItemHeight
#define wTextFontSize 10.f

#define bCellBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define bBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]
#define kBarColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

@interface BBWaterfallCollectionViewCell ()

@end

@implementation BBWaterfallCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCellLayout];
    }
    return self;
}

-(void)initCellLayout
{
    self.contentView.layer.cornerRadius = 5.0;
    self.contentView.backgroundColor = bCellBGColor;
    
    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_coverImageView setFrame:CGRectZero];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.clipsToBounds = YES;
    _coverImageView.userInteractionEnabled = YES;
    [_coverImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverImageViewTapped)]];
    [self.contentView addSubview:_coverImageView];
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarView.clipsToBounds = YES;
    [self.contentView addSubview:_avatarView];
    
//    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    _textLabel.numberOfLines = 0;
//    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    [self.contentView addSubview:_textLabel];
    __weak BBWaterfallCollectionViewCell *weakSelf = self;
    CGFloat fontSize = [Utils fontSizeForWaterfall];
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
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.font = [UIFont systemFontOfSize:fontSize];
    [self.contentView addSubview:_nameLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel.font = [UIFont systemFontOfSize:10.0];
    _timeLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_timeLabel];
    
    _retweetNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetNumLabel.font = [UIFont systemFontOfSize:10.0];
    _retweetNumLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_retweetNumLabel];
    
    _commentNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _commentNumLabel.font = [UIFont systemFontOfSize:10.0];
    _commentNumLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_commentNumLabel];
    
    _retweetNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetNameLabel.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:_retweetNameLabel];
    
//    _retweetTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    _retweetTextLabel.textColor = [UIColor lightTextColor];
//    _retweetTextLabel.numberOfLines = 0;
//    _retweetTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    [self.contentView addSubview:_retweetTextLabel];
    _retweetTextLabel = [[STTweetLabel alloc] initWithFrame:CGRectZero];
    _retweetTextLabel.numberOfLines = 0;
    _retweetTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _retweetTextLabel.backgroundColor = [UIColor clearColor];
    [_retweetTextLabel setAttributes:[Utils genericAttributesWithFontSize:fontSize fontColor:[UIColor lightTextColor]]];
    [_retweetTextLabel setAttributes:[Utils genericAttributesWithFontSize:fontSize fontColor:[UIColor dodgerBlue]] hotWord:STTweetLink];
    [_retweetTextLabel setAttributes:[Utils genericAttributesWithFontSize:fontSize fontColor:[UIColor dodgerBlue]] hotWord:STTweetHashtag];
    [_retweetTextLabel setDetectionBlock:^(STTweetHotWord hotword, NSString *string, NSString *protocol, NSRange range) {
        //callback
        [weakSelf didTapHotword:string];
    }];
    [self.contentView addSubview:_retweetTextLabel];
    
    _retweetIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_retweetIcon];
    
    _commentIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_commentIcon];
}

-(void)coverImageViewTapped
{
    NSMutableArray *originUrls = nil;
    NSMutableArray *largeUrls = @[].mutableCopy;
    if (_status.pic_urls.count > 0) {
        originUrls = _status.pic_urls;
    }
    if (_status.retweeted_status.pic_urls.count > 0) {
        originUrls = _status.retweeted_status.pic_urls;
    }
    for (NSString *str in originUrls) {
        [largeUrls addObject:[NSString middlePictureUrlConvertedFromThumbUrl:str]];
    }
    [self setImageBrowserWithImageUrls:largeUrls andTappedViewTag:0];
}

-(void)setImageBrowserWithImageUrls:(NSMutableArray *)urls andTappedViewTag:(NSInteger)tag
{
    BBImageBrowserView *browserView = [[BBImageBrowserView alloc] initWithFrame:[UIScreen mainScreen].bounds withImageUrls:urls andImageTag:tag];
    [self.window addSubview:browserView];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self resetCoverImageView];
}

-(void)resetCoverImageView
{
    [_coverImageView setFrame:CGRectZero];
    [_retweetTextLabel setFrame:CGRectZero];
    [_mask removeFromSuperview];
}

#pragma mark - STTweetLabelBlockCallbacks

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
                 if ([obj isKindOfClass:[BBStatusDetailViewController class]] ||
                     [obj isKindOfClass:[BBWaterfallStatusViewController class]])
                 {
                     UIViewController *uivc = (UIViewController *)obj;
                     BBProfileTableViewController *profiletvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                     [self setupNavigationController:uivc.navigationController withUIViewController:profiletvc];
                     profiletvc.uid = user.idstr;
                     profiletvc.statuses = statuses;
                     profiletvc.user = user;
                     profiletvc.shouldNavBtnShown = NO;
                     profiletvc.title = @"Profile";
                     [uivc.navigationController pushViewController:profiletvc animated:YES];
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