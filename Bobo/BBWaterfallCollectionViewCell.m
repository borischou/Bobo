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
#import "BBImageBrowserView.h"

#define wMaxPictureHeight [UIScreen mainScreen].bounds.size.height*3/5
#define wSmallGap 2
#define wBigGap 4
#define wTextWidth wCellWidth-2*wSmallGap
#define wBottomItemHeight 15.0
#define wBottomItemWidth wBottomItemHeight
#define wTextFontSize 10.f

#define bCellBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

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
    
    CGFloat fontSize = [Utils fontSizeForWaterfall];
    
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
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.font = [UIFont systemFontOfSize:fontSize];
    _textLabel.numberOfLines = 0;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _textLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_textLabel];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.font = [UIFont systemFontOfSize:fontSize];
    [self.contentView addSubview:_nameLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel.font = [UIFont systemFontOfSize:fontSize];
    _timeLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_timeLabel];
    
    _retweetNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetNumLabel.font = [UIFont systemFontOfSize:fontSize];
    _retweetNumLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_retweetNumLabel];
    
    _commentNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _commentNumLabel.font = [UIFont systemFontOfSize:fontSize];
    _commentNumLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_commentNumLabel];
    
    _retweetNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetNameLabel.font = [UIFont systemFontOfSize:fontSize];
    [self.contentView addSubview:_retweetNameLabel];
    
    _retweetTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetTextLabel.font = [UIFont systemFontOfSize:fontSize];
    _retweetTextLabel.textColor = [UIColor lightTextColor];
    _retweetTextLabel.numberOfLines = 0;
    _retweetTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
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

@end