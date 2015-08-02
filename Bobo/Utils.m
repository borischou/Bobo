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
#define bPostImgHeight [UIScreen mainScreen].bounds.size.width/6
#define bPostImgWidth bPostImgHeight
#define bTextFontSize 14.f
#define bSmallGap 5
#define bBigGap 10

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

-(CGFloat)heightForString:(NSString *)str andWidth:(CGFloat)width
{
    NSMutableParagraphStyle *parastyle = [[NSMutableParagraphStyle alloc] init];
    parastyle.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize sizeForFit = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:bTextFontSize], NSParagraphStyleAttributeName: parastyle} context:nil].size;
    return sizeForFit.height;
}

-(CGFloat)getHeightForCellWithStatusText:(NSString *)text statusImageCount:(NSInteger)count andRetweetScreenName:(NSString *)retweetedScreenName retweetText:(NSString *)retweetText retweetImageCount:(NSInteger)retweetImgCount
{
    CGFloat height = 0;
    
    height = 0;
    height += bBigGap + bHeadImgHeight;
    height += bBigGap + [self heightForString:text andWidth:bWidth - bBigGap * 2];
    if (count > 0) {
        height += bSmallGap + [self heightForImgsWithCount:count];
    }
    if (retweetedScreenName) {
        height += bBigGap + [self heightForString:[NSString stringWithFormat:@"@%@:%@", retweetedScreenName, retweetText] andWidth:bWidth - bBigGap * 2];
        if (retweetImgCount > 0) {
            height += bSmallGap + [self heightForImgsWithCount:retweetImgCount];
        }
    }
    
    height += bSmallGap;
    return height;
}

@end
