//
//  BBWaterfallCollectionView.m
//  Bobo
//
//  Created by Boris Chow on 8/25/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import <SafariServices/SafariServices.h>
#import <MJRefresh/MJRefresh.h>

#import "CHTCollectionViewWaterfallLayout.h"
#import "BBWaterfallCollectionView.h"
#import "BBWaterfallCollectionViewCell.h"
#import "BBStatusDetailViewController.h"
#import "BBWaterfallStatusViewController.h"
#import "BBProfileTableViewController.h"
#import "BBImageBrowserView.h"
#import "Utils.h"
#import "AppDelegate.h"

#import "NSString+Convert.h"
#import "UIColor+Custom.h"

#define wSmallGap 2
#define wBottomItemHeight 15
#define wBottomItemWidth wBottomItemHeight

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

static NSString *reuseCellId = @"reuseCell";

@interface BBWaterfallCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout, BBWaterfallCollectionViewCellDelegate, TTTAttributedLabelDelegate>

@end

static inline NSRegularExpression * HotwordRegularExpression() {
    static NSRegularExpression *_hotwordRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _hotwordRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"(@([\\w-]+[\\w-]*))|((https?://([\\w]+).([\\w]+))+/[\\w]+)|(#[^#]+#)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _hotwordRegularExpression;
}

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

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (fabs(targetContentOffset->y+bHeight-self.contentSize.height) <= 350) {
        id nextResponder = [self nextResponder];
        if ([nextResponder isKindOfClass:[BBWaterfallStatusViewController class]]) {
            BBWaterfallStatusViewController *wsvc = (BBWaterfallStatusViewController *)nextResponder;
            [wsvc fetchHistoryStatuses];
        }
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
        cell.delegate = self;
        cell.tweetTextLabel.delegate = self;
        cell.retweetTextLabel.delegate = self;
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
    NSRegularExpression *regex = HotwordRegularExpression();
    
    cell.timeLabel.text = [NSString formatPostTime:status.created_at];
    cell.retweetNumLabel.text = [NSString stringWithFormat:@"%ld", status.reposts_count];
    cell.commentNumLabel.text = [NSString stringWithFormat:@"%ld", status.comments_count];
    cell.nameLabel.text = status.user.screen_name;
    if (status.text) {
        [cell.tweetTextLabel setText:[NSString stringWithFormat:@"@%@:%@", status.user.screen_name, status.text]];
        NSArray *tweetLinkRanges = [regex matchesInString:[NSString stringWithFormat:@"@%@:%@", status.user.screen_name, status.text] options:0 range:NSMakeRange(0, [[NSString stringWithFormat:@"@%@:%@", status.user.screen_name, status.text] length])];
        for (NSTextCheckingResult *result in tweetLinkRanges) {
            [cell.tweetTextLabel addLinkWithTextCheckingResult:result];
        }
    }
    
    if (status.retweeted_status) {
        [cell.retweetNameLabel setText:status.retweeted_status.user.screen_name];
        [cell.retweetTextLabel setText:[NSString stringWithFormat:@"@%@:%@", status.retweeted_status.user.screen_name, status.retweeted_status.text]];
        NSArray *retweetLinkRanges = [regex matchesInString:[NSString stringWithFormat:@"@%@:%@", status.retweeted_status.user.screen_name, status.retweeted_status.text] options:0 range:NSMakeRange(0, [[NSString stringWithFormat:@"@%@:%@", status.retweeted_status.user.screen_name, status.retweeted_status.text] length])];
        for (NSTextCheckingResult *result in retweetLinkRanges) {
            [cell.retweetTextLabel addLinkWithTextCheckingResult:result];
        }
    }
}

-(void)loadLayoutWithStatus:(Status *)status cell:(BBWaterfallCollectionViewCell *)cell
{
    CGFloat imageHeight = [Utils maxHeightForWaterfallCoverPicture];
    CGFloat cellWidth = [Utils cellWidthForWaterfall];
    CGSize textSize = [cell.tweetTextLabel sizeThatFits:CGSizeMake(cellWidth-2*wSmallGap, MAXFLOAT)];
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
    
    [cell.tweetTextLabel setFrame:CGRectMake(wSmallGap, cell.coverImageView.frame.size.height+wSmallGap, cellWidth-2*wSmallGap, textSize.height)];
    
    if (status.retweeted_status.text && status.retweeted_status.pic_urls.count <= 0) { //转发无配图
        [cell.retweetTextLabel setFrame:CGRectMake(wSmallGap, wSmallGap+textSize.height+wSmallGap, cellWidth-2*wSmallGap, rSize.height)];
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
        sdUrl = [NSString middlePictureUrlConvertedFromThumbUrl:url];
    }
    [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:sdUrl] placeholderImage:[UIImage imageNamed:@"pic_placeholder"] options:SDWebImageLowPriority];
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

#pragma mark - BBWaterfallCollectionViewCellDelegate & support

-(void)collectionViewCell:(BBWaterfallCollectionViewCell *)cell didTapCoverpicture:(UIImageView *)coverpicture
{
    NSMutableArray *originUrls = nil;
    NSMutableArray *largeUrls = @[].mutableCopy;
    if (cell.status.pic_urls.count > 0) {
        originUrls = cell.status.pic_urls;
    }
    if (cell.status.retweeted_status.pic_urls.count > 0) {
        originUrls = cell.status.retweeted_status.pic_urls;
    }
    for (NSString *str in originUrls) {
        [largeUrls addObject:[NSString largePictureUrlConvertedFromThumbUrl:str]];
    }
    [self setImageBrowserWithImageUrls:largeUrls andTappedViewTag:0];
}

-(void)setImageBrowserWithImageUrls:(NSMutableArray *)urls andTappedViewTag:(NSInteger)tag
{
    BBImageBrowserView *browserView = [[BBImageBrowserView alloc] initWithFrame:[UIScreen mainScreen].bounds imageUrls:urls imageTag:tag];
    [self.window addSubview:browserView];
}

#pragma mark - TTTAttributedLabelDelegate & support

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result
{
    NSLog(@"pressed: %@", [label.text substringWithRange:result.range]);
    [self presentDetailViewWithHotword:[label.text substringWithRange:result.range]];
}

-(void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    NSLog(@"long pressed: %@", [label.text substringWithRange:result.range]);
    [self presentDetailViewWithHotword:[label.text substringWithRange:result.range]];
}

-(void)presentDetailViewWithHotword:(NSString *)hotword
{
    BBWaterfallStatusViewController *wsvc = (BBWaterfallStatusViewController *)self.nextResponder;
    
    if ([hotword hasPrefix:@"@"]) {
        NSDictionary *params = @{@"screen_name": [hotword substringFromIndex:1]};
        [Utils genericWeiboRequestWithAccount:[[AppDelegate delegate] defaultAccount]
                                          URL:@"statuses/user_timeline.json"
                          SLRequestHTTPMethod:SLRequestMethodGET
                                   parameters:params
                   completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSMutableArray *statuses = [Utils statusesWith:responseObject];
             Status *status = statuses.firstObject;
             User *user = status.user;
             
             BBProfileTableViewController *profiletvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
             [Utils setupNavigationController:wsvc.navigationController withUIViewController:profiletvc];
             profiletvc.uid = user.idstr;
             profiletvc.statuses = statuses;
             profiletvc.user = user;
             profiletvc.shouldNavBtnShown = NO;
             profiletvc.title = @"Profile";
             profiletvc.hidesBottomBarWhenPushed = YES;
             [wsvc.navigationController pushViewController:profiletvc animated:YES];
         }
                   completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"error %@", error);
             dispatch_async(dispatch_get_main_queue(), ^{
                 [Utils presentNotificationWithText:@"访问失败"];
             });
         }];
    }
    if ([hotword hasPrefix:@"http"]) {
        //打开webview
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[hotword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
        [wsvc.navigationController presentViewController:sfvc animated:YES completion:^{}];
    }
    if ([hotword hasPrefix:@"#"]) {
        //热门话题
    }
}

@end
