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
    
    __weak BBWaterfallCollectionViewCell *weakSelf = self;
    CGFloat fontSize = [Utils fontSizeForWaterfall];
    _tweetTextLabel = [[STTweetLabel alloc] initWithFrame:CGRectZero];
    [_tweetTextLabel setNumberOfLines:0];
    [_tweetTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_tweetTextLabel setBackgroundColor:[UIColor clearColor]];
    [_tweetTextLabel setTextSelectable:NO];
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
    
    _retweetTextLabel = [[STTweetLabel alloc] initWithFrame:CGRectZero];
    _retweetTextLabel.numberOfLines = 0;
    _retweetTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _retweetTextLabel.backgroundColor = [UIColor clearColor];
    [_retweetTextLabel setTextSelectable:NO];
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
    [self.delegate collectionViewCell:self didTapCoverpicture:_coverImageView];
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

#pragma mark - STTweetLabelBlockCallbacks support

-(void)didTapHotword:(NSString *)hotword
{
    [self.delegate collectionViewCell:self didTapHotword:hotword];
}

@end