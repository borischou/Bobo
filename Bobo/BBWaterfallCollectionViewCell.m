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

#define wCellWidth ([UIScreen mainScreen].bounds.size.width-.5)*.5
#define wMaxPictureHeight [UIScreen mainScreen].bounds.size.height*3/5
#define wSmallGap 2
#define wBigGap 4
#define wTextWidth wCellWidth-2*wSmallGap
#define wBottomItemHeight 15
#define wBottomItemWidth wBottomItemHeight
#define wTextFontSize 10.f

@implementation BBWaterfallCollectionViewCell

-(void)initCellLayout
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 2.0;
    
    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_coverImageView setFrame:CGRectMake(0, 0, [Utils cellWidthForWaterfall], [Utils maxHeightForWaterfallCoverPicture])];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.clipsToBounds = YES;
    [self.contentView addSubview:_coverImageView];
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_avatarView];
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    [self.contentView addSubview:_textLabel];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    [self.contentView addSubview:_nameLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    [self.contentView addSubview:_timeLabel];
    
    _retweetNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetNumLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    [self.contentView addSubview:_retweetNumLabel];
    
    _commentNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _commentNumLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    [self.contentView addSubview:_commentNumLabel];
    
    _retweetNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetNameLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    [self.contentView addSubview:_retweetNameLabel];
    
    _retweetTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetTextLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    [self.contentView addSubview:_retweetTextLabel];
    
    _retweetIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_retweetIcon];
    
    _commentIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_commentIcon];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (!_coverImageView) {
        [self initCellLayout];
    }
    [self loadCellData];
    [self layoutCellViews];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self resetCoverImageView];
}

-(void)loadCellData
{
    _timeLabel.text = [Utils formatPostTime:_status.created_at];
    _retweetNumLabel.text = [NSString stringWithFormat:@"%ld", _status.reposts_count];
    _commentNumLabel.text = [NSString stringWithFormat:@"%ld", _status.comments_count];
    _nameLabel.text = _status.user.screen_name;
    _textLabel.text = _status.text;
    
    if (_status.retweeted_status) {
        _retweetNameLabel.text = _status.retweeted_status.user.screen_name;
        _retweetTextLabel.text = _status.retweeted_status.text;
    }
    
    if (_status.pic_urls.count > 0) { //有微博配图
        [self loadCoverPictureWithUrl:[_status.pic_urls firstObject]];
    }
    if (_status.retweeted_status.pic_urls.count > 0) { //转发配图
        [self loadCoverPictureWithUrl:[_status.retweeted_status.pic_urls firstObject]];
    }
}

-(void)loadCoverPictureWithUrl:(NSString *)url
{
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:[NSString largePictureUrlConvertedFromThumbUrl:url]]
                       placeholderImage:[UIImage imageNamed:@"pic_placeholder"]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if (!error) {
             _coverImageView.image = image;
         }
     }];
}

-(void)layoutCellViews
{
    [self resetCoverImageView];
    [_coverImageView setFrame:CGRectMake(0, 0, [Utils cellWidthForWaterfall], [Utils maxHeightForWaterfallCoverPicture])];

    CGSize textSize = [_textLabel sizeThatFits:CGSizeMake(wTextWidth, MAXFLOAT)];
    [_textLabel setFrame:CGRectMake(wSmallGap, [Utils maxHeightForWaterfallCoverPicture]+wSmallGap, wTextWidth, textSize.height)];
    
    [self layoutBottomButtonsWithTop:[Utils maxHeightForWaterfallCoverPicture]+wSmallGap+textSize.height];
}

-(void)layoutBottomButtonsWithTop:(CGFloat)top
{
    [_retweetIcon setFrame:CGRectMake(wSmallGap, top+wSmallGap, wBottomItemWidth, wBottomItemHeight)];
    
    CGSize rSize = [_retweetNumLabel sizeThatFits:CGSizeMake(MAXFLOAT, wBottomItemHeight)];
    [_retweetNumLabel setFrame:CGRectMake(wSmallGap+wBottomItemWidth+wSmallGap, top+wSmallGap, rSize.width, wBottomItemHeight)];
    
    [_commentIcon setFrame:CGRectMake(wSmallGap+wBottomItemWidth+wSmallGap+rSize.width+wSmallGap, top+wSmallGap, wBottomItemWidth, wBottomItemHeight)];
    
    CGSize cSize = [_commentNumLabel sizeThatFits:CGSizeMake(MAXFLOAT, wBottomItemHeight)];
    [_commentNumLabel setFrame:CGRectMake(wSmallGap+wBottomItemWidth+wSmallGap+rSize.width+wSmallGap+wBottomItemWidth+wSmallGap, top+wSmallGap, cSize.width, wBottomItemHeight)];
    
    CGSize timeSize = [_timeLabel sizeThatFits:CGSizeMake(MAXFLOAT, wBottomItemHeight)];
    [_timeLabel setFrame:CGRectMake(wSmallGap+wBottomItemWidth+wSmallGap+rSize.width+wSmallGap+wBottomItemWidth+wSmallGap+cSize.width+wSmallGap, top+wSmallGap, timeSize.width, wBottomItemHeight)];
}

-(void)resetCoverImageView
{
    [_coverImageView setFrame:CGRectZero];
}

@end