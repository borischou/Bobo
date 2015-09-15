//
//  Utils.h
//  Bobo
//
//  Created by Zhouboli on 15/7/13.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Status.h"

@interface Utils : NSObject

//Calculates the height of cell
+(CGFloat)getHeightForCellWithStatusText:(NSString *)text statusImageCount:(NSInteger)count andRetweetScreenName:(NSString *)screenName retweetText:(NSString *)retweetText retweetImageCount:(NSInteger)retweetImgCount;
+(CGFloat)heightForImgsWithCount:(NSInteger)count; //Calculates the height of images in total
+(NSString *)formatPostTime:(NSString *)postTime; //EEE HH:mm:ss yy-MM-dd
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

@end