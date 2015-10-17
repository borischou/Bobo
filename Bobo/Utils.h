//
//  Utils.h
//  Bobo
//
//  Created by Zhouboli on 15/7/13.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFNetworking.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Status.h"

typedef void (^AFHTTPRequestOperationSuccessCompletionHandler) (AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFHTTPRequestOperationFailureCompletionHandler) (AFHTTPRequestOperation *operation, NSError *error);
typedef void (^SLRequestCompletionHandler) (NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error);

@interface Utils : NSObject

//Calculates the height of cell
+(CGFloat)getHeightForCellWithStatusText:(NSString *)text statusImageCount:(NSInteger)count andRetweetScreenName:(NSString *)screenName retweetText:(NSString *)retweetText retweetImageCount:(NSInteger)retweetImgCount;
+(CGFloat)heightForImgsWithCount:(NSInteger)count; //Calculates the height of images in total
+(CGFloat)heightForString:(NSString *)str width:(CGFloat)width fontSize:(CGFloat)size;
+(CGFloat)layoutImgViews:(NSMutableArray *)views withImageCount:(NSInteger)count fromTopHeight:(CGFloat)height;
+(CGFloat)heightForWaterfallCellWithStatus:(Status *)status textWidth:(CGFloat)width;
+(CGFloat)fontSizeForWaterfall;
+(CGFloat)fontSizeForComment;
+(CGFloat)fontSizeForStatus;
+(CGFloat)cellWidthForWaterfall;
+(CGFloat)maxHeightForWaterfallCoverPicture;
+(NSDictionary *)genericAttributesWithFontSize:(CGFloat)fontSize fontColor:(UIColor *)color;

+(NSString *)appKey;
+(NSString *)accessToken;

+(void)genericWeiboRequestWithAccount:(ACAccount *)weiboAccount URL:(NSString *)url SLRequestHTTPMethod:(SLRequestMethod)method parameters:(NSDictionary *)params completionBlockWithSuccess:(AFHTTPRequestOperationSuccessCompletionHandler)success completionBlockWithFailure:(AFHTTPRequestOperationFailureCompletionHandler)failure;
+(NSArray *)systemAccounts;
+(void)weiboPostRequestWithAccount:(ACAccount *)weiboAccount URL:(NSString *)url parameters:(NSDictionary *)params completionHandler:(SLRequestCompletionHandler)completion;

+(void)setupNavigationController:(UINavigationController *)uinvc withUIViewController:(UIViewController *)uivc;
+(NSMutableArray *)statusesWith:(NSData *)data;

+(void)presentNotificationWithText:(NSString *)text;

+(NSString *)plistPathForFilename:(NSString *)file;

@end