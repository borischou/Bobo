//
//  StatusModel.m
//  Bobo
//
//  Created by Zhouboli on 15/6/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "StatusModel.h"
#import "BBNetworkUtils.h"

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

@interface StatusModel ()

@property (strong, nonatomic) NSDictionary *user;
@property (strong, nonatomic) NSDictionary *retweeted_status;
@property (strong, nonatomic) NSDictionary *retweeted_user;

@end

@implementation StatusModel

@synthesize user;
@synthesize retweeted_status;
@synthesize retweeted_user;
@synthesize postImgs;
@synthesize repostImgs;

-(void)initDicts
{
    //status
    if (!user) {
        user = [NSDictionary dictionary];
    }
    if (!retweeted_status) {
        retweeted_status = [NSDictionary dictionary];
    }
    if (!retweeted_user) {
        retweeted_user = [NSDictionary dictionary];
    }
    if (!self.pic_urls) {
        self.pic_urls = @[].mutableCopy;
    }
    if (!postImgs) {
        postImgs = @[].mutableCopy;
        for (int i = 0; i < 9; i ++) {
            [postImgs addObject:[NSNull null]];
        }
    }
    
    //retweeted_status
    if (!self.retweeted_image_urls) {
        self.retweeted_image_urls = @[].mutableCopy;
    }
    if (!repostImgs) {
        repostImgs = @[].mutableCopy;
        for (int i = 0; i < 9; i ++) {
            [repostImgs addObject:[NSNull null]];
        }
    }
}

-(id)initWithStatusData:(NSDictionary *)status
{
    self = [super init];
    if (self) {
        [self initDicts];
        
        //status
        self.statusId = [status[@"id"] integerValue];
        self.statusIdStr = status[@"idstr"];
        self.text = status[@"text"];
        self.created_at = status[@"created_at"];
        self.pic_count = [status[@"pic_urls"] count];
        for (NSDictionary *dict in status[@"pic_urls"]) {
            [self.pic_urls addObject:dict[@"thumbnail_pic"]];
        }
        self.source = status[@"source"];
        self.pic_count = [self.pic_urls count];
        self.comments_count = [status[@"comments_count"] integerValue];
        self.reposts_count = [status[@"reposts_count"] integerValue];
        self.attitudes_count = [status[@"attitudes_count"] integerValue];
        self.formattedPostTime = [self formatPostTime:status[@"created_at"]];

        //user
        user = status[@"user"];
        self.avatar_large = user[@"avatar_large"];
        self.screen_name = user[@"screen_name"];
        self.gender = user[@"gender"];
        self.isVerified = user[@"verified"];
        
        //repostStatus
        retweeted_status = status[@"retweeted_status"];
        if (retweeted_status) {
            retweeted_user = retweeted_status[@"user"];
            self.retweeted_screen_name = retweeted_user[@"screen_name"];
            self.retweeted_text = [NSString stringWithFormat:@"@%@:%@", self.retweeted_screen_name, retweeted_status[@"text"]];
            for (NSDictionary *dict in retweeted_status[@"pic_urls"]) {
                [self.retweeted_image_urls addObject:dict[@"thumbnail_pic"]];
            }
            self.retweeted_pic_count = [self.retweeted_image_urls count];
        }
        self.height = [self getHeightForCell];
    }
    return self;
}

-(NSString *)formatPostTime:(NSString *)postTime
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

-(CGFloat)getHeightForCell
{
    CGFloat height = 0;
    
    height = 0;
    height += bBigGap + bHeadImgHeight;
    height += bBigGap + [self heightForString:self.text andWidth:bWidth - bBigGap * 2];
    height += bSmallGap + [self heightForImgsWithCount:self.pic_count];
    
    if ([self.retweeted_text length] > 0) {
        height += bBigGap + [self heightForString:self.retweeted_text andWidth:bWidth - bBigGap * 2];
        height += bSmallGap + [self heightForImgsWithCount:self.retweeted_pic_count];
    }
    
    height += bSmallGap;
    return height;
}

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

@end
