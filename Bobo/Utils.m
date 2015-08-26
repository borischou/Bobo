//
//  Utils.m
//  Bobo
//
//  Created by Zhouboli on 15/7/13.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "Utils.h"
#import <AFNetworking.h>

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bHeadImgWidth 50
#define bHeadImgHeight 50
#define bNicknameWidth [UIScreen mainScreen].bounds.size.width/2
#define bNicknameHeight 20
#define bPostTimeWidth bNicknameWidth
#define bPostTimeHeight 20
#define bTopPadding 10.0
#define bSmallGap 5
#define bBigGap 10
#define bPostImgHeight ([UIScreen mainScreen].bounds.size.width-2*bSmallGap)/3
#define bPostImgWidth bPostImgHeight
#define bTextFontSize 14.f
#define bBtnHeight bHeight/25

#define bPostImgHeightForTwo ([UIScreen mainScreen].bounds.size.width-bSmallGap)/2
#define bPostImgWidthForTwo bPostImgHeightForTwo

#define wBottomLabelHeight 15
#define wTextFontSize 13.f

@implementation Utils

-(CGFloat)heightForImgsWithCount:(NSInteger)count
{
    CGFloat height = 0;
    if (count == 1 || count == 2) {
        height = bPostImgHeightForTwo;
    }
    if (count == 3) {
        height = bPostImgHeight;
    }
    if (count == 4) {
        height = bPostImgHeightForTwo*2+bSmallGap;
    }
    if (count > 4 && count <= 6) {
        height = bPostImgHeight*2+bSmallGap;
    }
    if (count >= 7 && count <= 9) {
        height = bPostImgHeight*3+bSmallGap*2;
    }
    return height;
}

+(NSString *)formatPostTime:(NSString *)postTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE MMM d HH:mm:ss Z yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_CN"]];
    
    NSDate *date = [formatter dateFromString:postTime];
    NSDateFormatter *outFormatter = [[NSDateFormatter alloc] init];
    [outFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
    [outFormatter setDateFormat:@"EEE HH:mm:ss yy-MM-dd"];
    NSString *formattedTime = [outFormatter stringFromDate:date];
    
    return formattedTime;
}

+(CGFloat)heightForString:(NSString *)str width:(CGFloat)width fontSize:(CGFloat)size
{
    if (!str) {
        return 0;
    }
    NSMutableParagraphStyle *parastyle = [[NSMutableParagraphStyle alloc] init];
    parastyle.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize sizeForFit = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:size], NSParagraphStyleAttributeName: parastyle} context:nil].size;
    
    return sizeForFit.height;
}

-(CGFloat)getHeightForCellWithStatusText:(NSString *)text statusImageCount:(NSInteger)count andRetweetScreenName:(NSString *)retweetedScreenName retweetText:(NSString *)retweetText retweetImageCount:(NSInteger)retweetImgCount
{
    CGFloat height = 0;
    
    height = 0;
    height += bBigGap + bHeadImgHeight; //头像
    height += bBigGap + [Utils heightForString:text width:bWidth - bBigGap * 2 fontSize:bTextFontSize]; //微博正文
    
    if (count > 0) {
        height += bSmallGap + [self heightForImgsWithCount:count]; //微博配图
    }
    
    if (retweetedScreenName != nil) { //转发微博
        height += bBigGap + [Utils heightForString:[NSString stringWithFormat:@"@%@:%@", retweetedScreenName, retweetText] width:bWidth - bBigGap * 2 fontSize:bTextFontSize]; //转发微博正文
        if (retweetImgCount > 0) {
            height += bSmallGap + [self heightForImgsWithCount:retweetImgCount]; //转发微博配图
        }
    }
    
    height += bSmallGap+bBtnHeight; //微博下方按钮
    return height;
}

+(CGFloat)layoutImgViews:(NSMutableArray *)views withImageCount:(NSInteger)count fromTopHeight:(CGFloat)height
{
    for (int i = 0; i < 9; i ++) {
        [views[i] setFrame:CGRectZero];
    }
    
    if (count == 1) {
        UIImageView *view = [views firstObject];
        [view setFrame:CGRectMake(bBigGap, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        return bSmallGap+bPostImgHeightForTwo;
    }
    
    if (count == 2) {
        [views[0] setFrame:CGRectMake(0, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        [views[1] setFrame:CGRectMake(bPostImgWidthForTwo+bSmallGap, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        return bSmallGap+bPostImgHeightForTwo;
    }
    
    if (count == 3) {
        for (int i = 0; i < count; i ++) {
            [views[i] setFrame:CGRectMake(i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        return bSmallGap+bPostImgHeight;
    }
    
    if (count == 4) {
        [views[0] setFrame:CGRectMake(0, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        [views[1] setFrame:CGRectMake(bPostImgWidthForTwo+bSmallGap, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        [views[2] setFrame:CGRectMake(0, height+2*bSmallGap+bPostImgHeightForTwo, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        [views[3] setFrame:CGRectMake(bPostImgWidthForTwo+bSmallGap, height+2*bSmallGap+bPostImgHeightForTwo, bPostImgWidthForTwo, bPostImgHeightForTwo)];
    }
    
    if (count > 4 && count <= 6) {
        for (int i = 0; i < 3; i ++) {
            [views[i] setFrame:CGRectMake(i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int j = 0; j < count - 3; j ++) {
            [views[3 + j] setFrame:CGRectMake(j * (bPostImgWidth + bSmallGap), height + bSmallGap + bPostImgHeight + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        return bSmallGap*2+bPostImgHeight*2;
    }
    
    if (count >= 7 && count <= 9) {
        for (int i = 0; i < 3; i ++) {
            [views[i] setFrame:CGRectMake(i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int j = 0; j < 3; j ++) {
            [views[3 + j] setFrame:CGRectMake(j * (bPostImgWidth + bSmallGap), height + bSmallGap + bPostImgHeight + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int k = 0; k < count - 6; k ++) {
            [views[6 + k] setFrame:CGRectMake(k * (bPostImgWidth + bSmallGap), height + bSmallGap + (bPostImgHeight + bSmallGap) * 2, bPostImgWidth, bPostImgHeight)];
        }
        return bSmallGap*3+bPostImgHeight*3;
    }
    return 0;
}

+(CGFloat)heightForWaterfallCoverImageUrl:(NSString *)url
{
    CGFloat height = 0;
    
    return height;
}

+(CGFloat)heightForWaterfallCellWithStatus:(Status *)status cellWidth:(CGFloat)width
{
    CGFloat height = 0;
    
    if (status.text) {
        height += bSmallGap;
        height += [Utils heightForString:status.text width:width fontSize:wTextFontSize];
    }
    
    if (!status.retweeted_status) { //无转发微博
        if (status.pic_urls.count > 0) { //微博有图片
            height += [Utils heightForWaterfallCoverImageUrl:[status.pic_urls firstObject]];
        }
    }
    else //有转发微博
    {
        if (status.retweeted_status.pic_urls.count > 0) { //微博有转发图片
            height += [Utils heightForWaterfallCoverImageUrl:[status.retweeted_status.pic_urls firstObject]];
        }
        else //微博有转发文本，无图片
        {
            if (status.retweeted_status.text) {
                height += bSmallGap;
                height += [Utils heightForString:status.retweeted_status.text width:width fontSize:wTextFontSize];
            }
        }
    }
    
    //底部转发评论时间标签
    height += bSmallGap;
    height += wBottomLabelHeight;
    height += bSmallGap;
    
    return height;
}

@end
