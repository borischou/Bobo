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

#define wMaxPictureHeight [UIScreen mainScreen].bounds.size.height*3/5
#define wSmallGap 2
#define wBigGap 4
#define wTextWidth wCellWidth-2*wSmallGap
#define wBottomItemHeight 15.0
#define wBottomItemWidth wBottomItemHeight
#define wTextFontSize 10.f

#define bCellBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

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
    self.contentView.backgroundColor = bCellBGColor;
    
    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_coverImageView setFrame:CGRectZero];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.clipsToBounds = YES;
    [self.contentView addSubview:_coverImageView];
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_avatarView];
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    _textLabel.numberOfLines = 0;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _textLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_textLabel];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    [self.contentView addSubview:_nameLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    _timeLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_timeLabel];
    
    _retweetNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetNumLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    _retweetNumLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_retweetNumLabel];
    
    _commentNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _commentNumLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    _commentNumLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_commentNumLabel];
    
    _retweetNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetNameLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    [self.contentView addSubview:_retweetNameLabel];
    
    _retweetTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetTextLabel.font = [UIFont systemFontOfSize:[Utils fontSizeForWaterfall]];
    _retweetTextLabel.numberOfLines = 0;
    _retweetTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_retweetTextLabel];
    
    _retweetIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_retweetIcon];
    
    _commentIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_commentIcon];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self loadCellData];
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
    _textLabel.text = [NSString stringWithFormat:@"@%@:%@", _status.user.screen_name, _status.text];
    
    if (_status.retweeted_status) {
        _retweetNameLabel.text = _status.retweeted_status.user.screen_name;
        _retweetTextLabel.text = _status.retweeted_status.text;
    }
    
    CGSize textSize = [_textLabel sizeThatFits:CGSizeMake([Utils cellWidthForWaterfall]-2*wSmallGap, MAXFLOAT)];
    if (_status.pic_urls.count > 0 || (_status.retweeted_status && _status.retweeted_status.pic_urls.count > 0)) {
        [self resetCoverImageView];
        _coverImageView.hidden = NO;
        [_coverImageView setFrame:CGRectMake(0, 0, [Utils cellWidthForWaterfall], [Utils maxHeightForWaterfallCoverPicture])];
        if (_status.pic_urls.count > 0) { //有微博配图
            [self loadCoverPictureWithUrl:[_status.pic_urls firstObject]];
        }
        if (_status.retweeted_status.pic_urls.count > 0) { //转发配图
            [self loadCoverPictureWithUrl:[_status.retweeted_status.pic_urls firstObject]];
        }
    } else { //仅有文字
        [self resetCoverImageView];
        _coverImageView.hidden = YES;
    }
    [_textLabel setFrame:CGRectMake(wSmallGap, _coverImageView.frame.size.height+wSmallGap, [Utils cellWidthForWaterfall]-2*wSmallGap, textSize.height)];
    [self layoutBottomButtonsWithTop:_coverImageView.frame.size.height+wSmallGap+textSize.height];
}

-(void)loadCoverPictureWithUrl:(NSString *)url
{
    NSString *sdUrl;
    if ([url hasSuffix:@"gif"]) {
        sdUrl = url;
    } else {
        sdUrl = [NSString largePictureUrlConvertedFromThumbUrl:url];
    }
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:sdUrl] placeholderImage:[UIImage imageNamed:@"pic_placeholder"]];
}

-(void)layoutBottomButtonsWithTop:(CGFloat)top
{
    _retweetIcon.image = [UIImage imageNamed:@"retwt_icon"];
    _commentIcon.image = [UIImage imageNamed:@"cmt_icon"];
    
    [_retweetIcon setFrame:CGRectMake(wSmallGap, top+wSmallGap, wBottomItemWidth*2/3, wBottomItemHeight*2/3)];
    [_retweetIcon setCenter:CGPointMake(_retweetIcon.center.x, top+wSmallGap+wBottomItemHeight/2)];
    
    CGSize rSize = [_retweetNumLabel sizeThatFits:CGSizeMake(MAXFLOAT, wBottomItemHeight)];
    [_retweetNumLabel setFrame:CGRectMake(wSmallGap+wBottomItemWidth*2/3+wSmallGap, top+wSmallGap, rSize.width, wBottomItemHeight)];
    
    [_commentIcon setFrame:CGRectMake(wSmallGap+wBottomItemWidth*2/3+wSmallGap+rSize.width+wSmallGap, top+wSmallGap, wBottomItemWidth*2/3, wBottomItemHeight*2/3)];
    [_commentIcon setCenter:CGPointMake(_commentIcon.center.x, top+wSmallGap+wBottomItemHeight/2)];
    
    CGSize cSize = [_commentNumLabel sizeThatFits:CGSizeMake(MAXFLOAT, wBottomItemHeight)];
    [_commentNumLabel setFrame:CGRectMake(wSmallGap+wBottomItemWidth*2/3+wSmallGap+rSize.width+wSmallGap+wBottomItemWidth*2/3+wSmallGap, top+wSmallGap, cSize.width, wBottomItemHeight)];
    
    CGSize timeSize = [_timeLabel sizeThatFits:CGSizeMake(MAXFLOAT, wBottomItemHeight)];
    [_timeLabel setFrame:CGRectMake(wSmallGap+wBottomItemWidth*2/3+wSmallGap+rSize.width+wSmallGap+wBottomItemWidth*2/3+wSmallGap+cSize.width+wSmallGap, top+wSmallGap, timeSize.width, wBottomItemHeight)];
}

-(void)resetCoverImageView
{
    [_coverImageView setFrame:CGRectZero];
}

@end