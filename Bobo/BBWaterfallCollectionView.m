//
//  BBWaterfallCollectionView.m
//  Bobo
//
//  Created by Boris Chow on 8/25/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import "CHTCollectionViewWaterfallLayout.h"
#import "BBWaterfallCollectionView.h"
#import "BBWaterfallCollectionViewCell.h"
#import "BBStatusDetailViewController.h"
#import "BBWaterfallStatusViewController.h"
#import "Utils.h"
#import <UIImageView+WebCache.h>
#import "NSString+Convert.h"
#import <MJRefresh/MJRefresh.h>

#define wSmallGap 2
#define wBottomItemHeight 15
#define wBottomItemWidth wBottomItemHeight

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]

static NSString *reuseCellId = @"reuseCell";

@interface BBWaterfallCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout>

@end

@implementation BBWaterfallCollectionView

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.backgroundColor = bBGColor;
        _statuses = @[].mutableCopy;
        [self registerClass:[BBWaterfallCollectionViewCell class] forCellWithReuseIdentifier:reuseCellId];
    }
    return self;
}

#pragma mark - UIScrollDelegate

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (fabs(targetContentOffset->y+bHeight-self.contentSize.height) <= 100) {
        [self.footer beginRefreshing];
    }
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _statuses.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BBWaterfallCollectionViewCell *cell = (BBWaterfallCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseCellId forIndexPath:indexPath];
    if (_statuses.count > 0) {
        Status *status = [_statuses objectAtIndex:indexPath.item];
        cell.status = status;
        [self loadDataWithStatus:status cell:cell];
        if (cell.frame.size.height != status.heightForWaterfall) {
            [self loadLayoutWithStatus:status cell:cell];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BBStatusDetailViewController *dtvc = [[BBStatusDetailViewController alloc] init];
    dtvc.title = @"Detail";
    dtvc.hidesBottomBarWhenPushed = YES;
    Status *status = [_statuses objectAtIndex:indexPath.item];
    dtvc.status = status;
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[BBWaterfallStatusViewController class]]) {
        BBWaterfallStatusViewController *wsvc = (BBWaterfallStatusViewController *)nextResponder;
        [wsvc.navigationController pushViewController:dtvc animated:YES];
    }
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_statuses.count > 0) {
        Status *status = [_statuses objectAtIndex:indexPath.item];
        CGSize cellSize = CGSizeMake([Utils cellWidthForWaterfall], status.heightForWaterfall);
        return cellSize;
    } else {
        return CGSizeZero;
    }
}

#pragma BBWaterfallCollectionViewCell support

-(void)loadDataWithStatus:(Status *)status cell:(BBWaterfallCollectionViewCell *)cell
{
    cell.timeLabel.text = [Utils formatPostTime:status.created_at];
    cell.retweetNumLabel.text = [NSString stringWithFormat:@"%ld", status.reposts_count];
    cell.commentNumLabel.text = [NSString stringWithFormat:@"%ld", status.comments_count];
    cell.nameLabel.text = status.user.screen_name;
    cell.textLabel.text = [NSString stringWithFormat:@"@%@:%@", status.user.screen_name, status.text];
    
    if (status.retweeted_status) {
        cell.retweetNameLabel.text = status.retweeted_status.user.screen_name;
        cell.retweetTextLabel.text = [NSString stringWithFormat:@"@%@:%@", status.retweeted_status.user.screen_name, status.retweeted_status.text];
    }
}

-(void)loadLayoutWithStatus:(Status *)status cell:(BBWaterfallCollectionViewCell *)cell
{
    CGFloat imageHeight = [Utils maxHeightForWaterfallCoverPicture];
    CGFloat cellWidth = [Utils cellWidthForWaterfall];
    CGSize textSize = [cell.textLabel sizeThatFits:CGSizeMake(cellWidth-2*wSmallGap, MAXFLOAT)];
    CGSize rSize = [cell.retweetTextLabel sizeThatFits:CGSizeMake(cellWidth-2*wSmallGap, MAXFLOAT)];
  
    if (status.pic_urls.count > 0 || (status.retweeted_status && status.retweeted_status.pic_urls.count > 0)) {
        cell.coverImageView.hidden = NO;
        [cell.coverImageView setFrame:CGRectMake(0, 0, cellWidth, imageHeight)];
        if (status.pic_urls.count > 0) { //有微博配图
            [self loadCoverPictureWithUrl:[status.pic_urls firstObject] cell:cell];
        }
        if (status.retweeted_status.pic_urls.count > 0) { //转发配图
            [self loadCoverPictureWithUrl:[status.retweeted_status.pic_urls firstObject] cell:cell];
        }
    } else { //仅有文字
        cell.coverImageView.hidden = YES;
    }
    
    [cell.textLabel setFrame:CGRectMake(wSmallGap, cell.coverImageView.frame.size.height+wSmallGap, cellWidth-2*wSmallGap, textSize.height)];
    
    if (status.retweeted_status.text && status.retweeted_status.pic_urls.count <= 0) { //转发无配图
        [cell.retweetTextLabel setFrame:CGRectMake(wSmallGap, wSmallGap+textSize.height+wSmallGap, cellWidth-2*wSmallGap, rSize.height)];
        [cell.retweetTextLabel setTextColor:[UIColor lightTextColor]];
        [self layoutBottomButtonsWithTop:wSmallGap+textSize.height+wSmallGap+rSize.height forCell:cell];
    }
    else if (status.retweeted_status.text && status.retweeted_status.pic_urls.count > 0) { //转发有配图
        CGFloat retweetLabelHeight = 0;
        if (rSize.height > imageHeight/4) {
            retweetLabelHeight = imageHeight/4;
        } else {
            retweetLabelHeight = rSize.height;
        }
        
        if (!cell.mask) {
            cell.mask = [[UIView alloc] initWithFrame:CGRectZero];
        }
        [cell.mask setFrame:CGRectMake(0, imageHeight-retweetLabelHeight, cellWidth, retweetLabelHeight)];
        cell.mask.backgroundColor = [UIColor blackColor];
        cell.mask.alpha = 0.5;
        [cell.contentView addSubview:cell.mask];
        
        [cell.retweetTextLabel setFrame:CGRectMake(wSmallGap, imageHeight-retweetLabelHeight, cellWidth-2*wSmallGap, retweetLabelHeight)];
        [cell.retweetTextLabel setTextColor:[UIColor whiteColor]];
        [cell.contentView bringSubviewToFront:cell.retweetTextLabel];
        [self layoutBottomButtonsWithTop:imageHeight+wSmallGap+textSize.height forCell:cell];
    } else {
        if (status.pic_urls.count > 0) {
            [self layoutBottomButtonsWithTop:imageHeight+wSmallGap+textSize.height forCell:cell];
        } else {
            [self layoutBottomButtonsWithTop:wSmallGap+textSize.height forCell:cell];
        }
    }
}

-(void)loadCoverPictureWithUrl:(NSString *)url cell:(BBWaterfallCollectionViewCell *)cell
{
    NSString *sdUrl;
    if ([url hasSuffix:@"gif"]) {
        sdUrl = url;
    } else {
        sdUrl = [NSString largePictureUrlConvertedFromThumbUrl:url];
    }
    [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:sdUrl] placeholderImage:[UIImage imageNamed:@"pic_placeholder"]];
}

-(void)layoutBottomButtonsWithTop:(CGFloat)top forCell:(BBWaterfallCollectionViewCell *)cell
{
    cell.retweetIcon.image = [UIImage imageNamed:@"retwt_icon"];
    cell.commentIcon.image = [UIImage imageNamed:@"cmt_icon"];
    
    [cell.retweetIcon setFrame:CGRectMake(wSmallGap, top+wSmallGap, wBottomItemWidth*2/3, wBottomItemHeight*2/3)];
    [cell.retweetIcon setCenter:CGPointMake(cell.retweetIcon.center.x, top+wSmallGap+wBottomItemHeight/2)];
    
    CGSize rSize = [cell.retweetNumLabel sizeThatFits:CGSizeMake(MAXFLOAT, wBottomItemHeight)];
    [cell.retweetNumLabel setFrame:CGRectMake(wSmallGap+wBottomItemWidth*2/3+wSmallGap, top+wSmallGap, rSize.width, wBottomItemHeight)];
    
    [cell.commentIcon setFrame:CGRectMake(wSmallGap+wBottomItemWidth*2/3+wSmallGap+rSize.width+wSmallGap, top+wSmallGap, wBottomItemWidth*2/3, wBottomItemHeight*2/3)];
    [cell.commentIcon setCenter:CGPointMake(cell.commentIcon.center.x, top+wSmallGap+wBottomItemHeight/2)];
    
    CGSize cSize = [cell.commentNumLabel sizeThatFits:CGSizeMake(MAXFLOAT, wBottomItemHeight)];
    [cell.commentNumLabel setFrame:CGRectMake(wSmallGap+wBottomItemWidth*2/3+wSmallGap+rSize.width+wSmallGap+wBottomItemWidth*2/3+wSmallGap, top+wSmallGap, cSize.width, wBottomItemHeight)];
    
    CGSize timeSize = [cell.timeLabel sizeThatFits:CGSizeMake(MAXFLOAT, wBottomItemHeight)];
    [cell.timeLabel setFrame:CGRectMake(wSmallGap+wBottomItemWidth*2/3+wSmallGap+rSize.width+wSmallGap+wBottomItemWidth*2/3+wSmallGap+cSize.width+wSmallGap, top+wSmallGap, timeSize.width, wBottomItemHeight)];
}

@end
