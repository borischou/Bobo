//
//  Utils.m
//  Bobo
//
//  Created by Zhouboli on 15/7/13.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "Utils.h"
#import "AppDelegate.h"
#import "BBNotificationView.h"
#import <YYWebImage.h>

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

@implementation Utils

+(NSString *)preferenceSinaWeiboURL
{
    return @"prefs:root=WEIBO";
}

+(CGFloat)heightForImgsWithCount:(NSInteger)count
{
    CGFloat height = 0;
    if (count == 1 || count == 2)
    {
        height = bPostImgHeightForTwo;
    }
    if (count == 3)
    {
        height = bPostImgHeight;
    }
    if (count == 4)
    {
        height = bPostImgHeightForTwo*2+bSmallGap;
    }
    if (count > 4 && count <= 6)
    {
        height = bPostImgHeight*2+bSmallGap;
    }
    if (count >= 7 && count <= 9)
    {
        height = bPostImgHeight*3+bSmallGap*2;
    }
    return height;
}

+(CGFloat)heightForString:(NSString *)str width:(CGFloat)width fontSize:(CGFloat)size
{
    if (!str)
    {
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
    
    if (count > 0)
    {
        height += bSmallGap+[Utils heightForImgsWithCount:count]; //微博配图
    }
    
    if (retweetedScreenName != nil)
    { //转发微博
        height += bBigGap+[Utils heightForString:[NSString stringWithFormat:@"@%@:%@", retweetedScreenName, retweetText] width:bWidth-bBigGap*2 fontSize:fontSize]; //转发微博正文
        if (retweetImgCount > 0)
        {
            height += bSmallGap+[Utils heightForImgsWithCount:retweetImgCount]; //转发微博配图
        }
    }
    
    height += bSmallGap+bBtnHeight; //微博下方按钮
    return height;
}

+(CGFloat)layoutImgViews:(NSMutableArray *)views withImageCount:(NSInteger)count fromTopHeight:(CGFloat)height
{
    for (int i = 0; i < 9; i ++)
    {
        [views[i] setFrame:CGRectZero];
    }
    
    if (count == 1)
    {
        UIImageView *view = [views firstObject];
        [view setFrame:CGRectMake(bBigGap, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        return bSmallGap+bPostImgHeightForTwo;
    }
    
    if (count == 2)
    {
        [views[0] setFrame:CGRectMake(0, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        [views[1] setFrame:CGRectMake(bPostImgWidthForTwo+bSmallGap, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        return bSmallGap+bPostImgHeightForTwo;
    }
    
    if (count == 3)
    {
        for (int i = 0; i < count; i ++)
        {
            [views[i] setFrame:CGRectMake(i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        return bSmallGap+bPostImgHeight;
    }
    
    if (count == 4)
    {
        [views[0] setFrame:CGRectMake(0, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        [views[1] setFrame:CGRectMake(bPostImgWidthForTwo+bSmallGap, height+bSmallGap, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        [views[2] setFrame:CGRectMake(0, height+2*bSmallGap+bPostImgHeightForTwo, bPostImgWidthForTwo, bPostImgHeightForTwo)];
        [views[3] setFrame:CGRectMake(bPostImgWidthForTwo+bSmallGap, height+2*bSmallGap+bPostImgHeightForTwo, bPostImgWidthForTwo, bPostImgHeightForTwo)];
    }
    
    if (count > 4 && count <= 6)
    {
        for (int i = 0; i < 3; i ++)
        {
            [views[i] setFrame:CGRectMake(i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int j = 0; j < count - 3; j ++)
        {
            [views[3 + j] setFrame:CGRectMake(j * (bPostImgWidth + bSmallGap), height + bSmallGap + bPostImgHeight + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        return bSmallGap*2+bPostImgHeight*2;
    }
    
    if (count >= 7 && count <= 9)
    {
        for (int i = 0; i < 3; i ++)
        {
            [views[i] setFrame:CGRectMake(i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int j = 0; j < 3; j ++)
        {
            [views[3 + j] setFrame:CGRectMake(j * (bPostImgWidth + bSmallGap), height + bSmallGap + bPostImgHeight + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int k = 0; k < count - 6; k ++)
        {
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
    
    if (status.pic_urls.count > 0 || status.retweeted_status.pic_urls.count > 0)
    {
        height += [Utils maxHeightForWaterfallCoverPicture];
    }
    height += wSmallGap;
    height += [Utils heightForString:[NSString stringWithFormat:@"@%@:%@", status.user.screen_name, status.text] width:width fontSize:fontSize];
    
    if (status.retweeted_status && status.retweeted_status.pic_urls.count <= 0)
    {
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
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        success(operation, responseObject);
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        failure(operation, error);
    }];
    [operation start];
}

+(void)weiboPostRequestWithAccount:(ACAccount *)weiboAccount URL:(NSString *)url parameters:(NSDictionary *)params completionHandler:(SLRequestCompletionHandler)completion
{
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.weibo.com/2/%@", url]] parameters:params];
    [request setAccount:weiboAccount];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
    {
        completion(responseData, urlResponse, error);
    }];
}

+(NSArray *)systemAccounts
{
    ACAccountStore *store;
    ACAccountType *type;
    NSArray *accounts;
    store = [[ACAccountStore alloc] init];
    type = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
    accounts = [store accountsWithAccountType:type];
    return accounts;
}

+(void)setupNavigationController:(UINavigationController *)uinvc withUIViewController:(UIViewController *)uivc
{
    if (uinvc)
    {
        uinvc.navigationBar.barTintColor = kBarColor;
        uinvc.navigationBar.tintColor = [UIColor whiteColor];
        uinvc.navigationBar.layer.shadowOpacity = 0.2;
        uinvc.navigationBar.layer.shadowOffset = CGSizeMake(0, 2);
        uinvc.navigationBar.layer.shadowColor = [UIColor blackColor].CGColor;
    }
    
    uivc.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    uivc.view.backgroundColor = bBGColor;
    
    if ([uivc isKindOfClass:[UITableViewController class]])
    {
        UITableViewController *uitvc = (UITableViewController *)uivc;
        uitvc.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

+(NSMutableArray *)statusesWith:(NSData *)data
{
    NSMutableArray *statuses = @[].mutableCopy;
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (![[dict objectForKey:@"statuses"] isEqual:[NSNull null]])
    {
        NSArray *status_dicts = [dict objectForKey:@"statuses"];
        for (NSDictionary *status_dict in status_dicts)
        {
            Status *status = [[Status alloc] initWithDictionary:status_dict];
            [statuses addObject:status];
        }
    }
    return statuses;
}

+(void)presentNotificationWithText:(NSString *)text
{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    BBNotificationView *notificationView = [[BBNotificationView alloc] initWithNotification:text];
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:notificationView];
    [delegate.window bringSubviewToFront:notificationView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [notificationView setFrame:CGRectMake(0, 0, bWidth, 2*statusBarHeight)];
    }
                     completion:^(BOOL finished)
    {
        [UIView animateWithDuration:0.2 delay:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [notificationView setFrame:CGRectMake(0, -2*statusBarHeight, bWidth, 2*statusBarHeight)];
        }
                         completion:^(BOOL finished)
        {
            [notificationView removeFromSuperview];
        }];
    }];
}

+(NSString *)plistPathForFilename:(NSString *)file
{
    //获取Library/Caches目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    //将文件名拼在目录后面形成完整文件路径
    return [cachesDirectory stringByAppendingPathComponent:file];
}

+(void)clearDiskImages
{
    //[[SDImageCache sharedImageCache] clearDisk];
}

+(void)cleanDiskImages
{
    //[[SDImageCache sharedImageCache] cleanDisk];
}

+(void)clearImageCache
{
    //[[SDImageCache sharedImageCache] clearMemory];
}

@end
