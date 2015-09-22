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
#define bTextFontSize 17.f
#define bBtnHeight bHeight/25
#define bPostImgHeightForTwo ([UIScreen mainScreen].bounds.size.width-bSmallGap)/2
#define bPostImgWidthForTwo bPostImgHeightForTwo
#define wSmallGap 2
#define wBigGap 4
#define wBottomLabelHeight 15
#define wTextFontSize 10.f

#define bBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]
#define kBarColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

@implementation Utils

+(CGFloat)heightForImgsWithCount:(NSInteger)count
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
    [parastyle setLineSpacing:2.0];
    CGSize sizeForFit = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:size],
                                                    NSParagraphStyleAttributeName: parastyle}
                                          context:nil].size;
    
    return sizeForFit.height;
}

+(CGFloat)getHeightForCellWithStatusText:(NSString *)text statusImageCount:(NSInteger)count andRetweetScreenName:(NSString *)retweetedScreenName retweetText:(NSString *)retweetText retweetImageCount:(NSInteger)retweetImgCount
{
    CGFloat height = 0;
    CGFloat fontSize = [Utils fontSizeForStatus];
    
    height = 0;
    height += bBigGap+bHeadImgHeight; //头像
    height += bBigGap+[Utils heightForString:text width:bWidth-bBigGap*2 fontSize:fontSize]; //微博正文
    
    if (count > 0) {
        height += bSmallGap+[self heightForImgsWithCount:count]; //微博配图
    }
    
    if (retweetedScreenName != nil) { //转发微博
        height += bBigGap+[Utils heightForString:[NSString stringWithFormat:@"@%@:%@", retweetedScreenName, retweetText] width:bWidth-bBigGap*2 fontSize:fontSize]; //转发微博正文
        if (retweetImgCount > 0) {
            height += bSmallGap+[self heightForImgsWithCount:retweetImgCount]; //转发微博配图
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

#pragma mark - Measurements

+(CGFloat)maxHeightForWaterfallCoverPicture
{
    return [UIScreen mainScreen].bounds.size.height*1/4;
}

+(CGFloat)fontSizeForWaterfall
{
    return 16.f;
}

+(CGFloat)fontSizeForStatus
{
    return 16.f;
}

+(CGFloat)fontSizeForComment
{
    return 13.0;
}

+(CGFloat)cellWidthForWaterfall
{
    return ([UIScreen mainScreen].bounds.size.width-8.0)*.5;
}

+(CGFloat)heightForWaterfallCoverPicture
{
    CGFloat height = 0;
    
    return height;
}

+(CGFloat)heightForWaterfallBottom
{
    return 15.0;
}

+(CGFloat)smallGapForWaterfall
{
    return 2.0;
}

+(CGFloat)bigGapForWaterfall
{
    return 4.0;
}

+(CGFloat)heightForWaterfallCellWithStatus:(Status *)status textWidth:(CGFloat)width
{
    CGFloat height = 0;
    CGFloat fontSize = [Utils fontSizeForWaterfall];
    
    if (status.pic_urls.count > 0 || status.retweeted_status.pic_urls.count > 0) {
        height += [Utils maxHeightForWaterfallCoverPicture];
    }
    height += wSmallGap;
    height += [Utils heightForString:[NSString stringWithFormat:@"@%@:%@", status.user.screen_name, status.text] width:width fontSize:fontSize];
    
    if (status.retweeted_status && status.retweeted_status.pic_urls.count <= 0) {
        height += wSmallGap;
        height += [Utils heightForString:[NSString stringWithFormat:@"@%@:%@", status.retweeted_status.user.screen_name, status.retweeted_status.text] width:width fontSize:fontSize];
    }
    
    //底部转发评论时间标签
    height += wSmallGap;
    height += wBottomLabelHeight;
    height += wSmallGap;
    
    return height;
}

+(NSDictionary *)genericAttributesWithFontSize:(CGFloat)fontSize fontColor:(UIColor *)color
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:2.0];
    
    NSDictionary *genericAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                                        NSForegroundColorAttributeName: color,
                                        NSParagraphStyleAttributeName: paragraphStyle};
    return genericAttributes;
}

+(NSString *)appKey
{
    return @"916936343";
}

+(NSString *)accessToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"wbtoken"];
}

+(void)genericWeiboRequestWithAccount:(ACAccount *)weiboAccount
                                  URL:(NSString *)url
                  SLRequestHTTPMethod:(SLRequestMethod)method
                           parameters:(NSDictionary *)params
           completionBlockWithSuccess:(AFHTTPRequestOperationSuccessCompletionHandler)success
           completionBlockWithFailure:(AFHTTPRequestOperationFailureCompletionHandler)failure
{
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:[@"https://api.weibo.com/2/" stringByAppendingString:url]] parameters:params];
    [request setAccount:weiboAccount];
    NSURLRequest *urlrequest = [request preparedURLRequest];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlrequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
    }];
    [operation start];
}

+(void)weiboPostRequestWithAccount:(ACAccount *)weiboAccount URL:(NSString *)url parameters:(NSDictionary *)params completionHandler:(SLRequestCompletionHandler)completion
{
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.weibo.com/2/%@", url]] parameters:params];
    [request setAccount:weiboAccount];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        completion(responseData, urlResponse, error);
    }];
}

+(NSArray *)systemAccounts
{
    static dispatch_once_t onceToken;
    static ACAccountStore *store;
    static ACAccountType *type;
    static NSArray *accounts;
    dispatch_once(&onceToken, ^{
        store = [[ACAccountStore alloc] init];
        type = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
        accounts = [store accountsWithAccountType:type];
    });
    return accounts;
}

+(void)setupNavigationController:(UINavigationController *)uinvc withUIViewController:(UIViewController *)uivc
{
    uinvc.navigationBar.barTintColor = kBarColor;
    uinvc.navigationBar.tintColor = [UIColor whiteColor];
    uinvc.navigationBar.layer.shadowOpacity = 0.2;
    uinvc.navigationBar.layer.shadowOffset = CGSizeMake(0, 2);
    uinvc.navigationBar.layer.shadowColor = [UIColor blackColor].CGColor;
    
    uivc.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    uivc.view.backgroundColor = bBGColor;
    
    if ([uivc isKindOfClass:[UITableViewController class]]) {
        UITableViewController *uitvc = (UITableViewController *)uivc;
        uitvc.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

+(NSMutableArray *)statusesWith:(NSData *)data
{
    NSMutableArray *statuses = @[].mutableCopy;
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (![[dict objectForKey:@"statuses"] isEqual:[NSNull null]]) {
        NSArray *status_dicts = [dict objectForKey:@"statuses"];
        for (NSDictionary *status_dict in status_dicts) {
            Status *status = [[Status alloc] initWithDictionary:status_dict];
            [statuses addObject:status];
        }
    }
    return statuses;
}

@end
