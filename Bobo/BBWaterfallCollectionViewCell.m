//
//  BBWaterfallCollectionViewCell.m
//  Bobo
//
//  Created by Boris Chow on 8/25/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import "BBWaterfallCollectionViewCell.h"
#import <UIImageView+WebCache.h>

#define wCellWidth ([UIScreen mainScreen].bounds.size.width-10)*.5

@implementation BBWaterfallCollectionViewCell

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)initCellLayout
{
    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    _coverImageView.backgroundColor = [UIColor blueColor];
    [self.contentView addSubview:_coverImageView];
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _avatarView.contentMode = UIViewContentModeScaleAspectFit;
    _avatarView.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:_avatarView];
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:_textLabel];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:_nameLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel.backgroundColor = [UIColor purpleColor];
    [self.contentView addSubview:_timeLabel];
    
    _retweetNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetNumLabel.backgroundColor = [UIColor purpleColor];
    [self.contentView addSubview:_retweetNumLabel];
    
    _commentNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _commentNumLabel.backgroundColor = [UIColor purpleColor];
    [self.contentView addSubview:_commentNumLabel];
    
    _retweetNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetNameLabel.backgroundColor = [UIColor purpleColor];
    [self.contentView addSubview:_retweetNameLabel];
    
    _retweetTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _retweetTextLabel.backgroundColor = [UIColor purpleColor];
    [self.contentView addSubview:_retweetTextLabel];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
}

-(void)loadCellData
{
    if (_status.pic_urls.count > 0) { //有微博配图
        [_coverImageView sd_setImageWithURL:[NSURL URLWithString:[_status.pic_urls firstObject]]
                           placeholderImage:[UIImage imageNamed:@"pic_placeholder"]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
        {
            if (!error) {
                CGFloat imageHeight = image.size.height*wCellWidth/image.size.width;
                _status.heightForWaterfall += imageHeight;
                [_coverImageView setFrame:CGRectMake(0, 0, wCellWidth, imageHeight)];
            }
        }];
        
    }
}

































@end