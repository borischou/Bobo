//
//  Utils.m
//  Bobo
//
//  Created by Zhouboli on 15/7/13.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "Utils.h"

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

@implementation Utils

-(CGFloat)heightForImgsWithCount:(NSInteger)count
{
    CGFloat height = 0;
    if (count >= 1 && count <= 3) {
        height = bPostImgHeight;
    }
    if (count >= 4 && count <= 6) {
        height = bPostImgHeight * 2 + bSmallGap;
    }
    if (count >= 7 && count <= 9) {
        height = bPostImgHeight * 3 + bSmallGap * 2;
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

@end
