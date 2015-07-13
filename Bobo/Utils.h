//
//  Utils.h
//  Bobo
//
//  Created by Zhouboli on 15/7/13.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

-(CGFloat)getHeightForCellWithStatusText:(NSString *)text statusImageCount:(NSInteger)count andRetweetText:(NSString *)retweetText retweetImageCount:(NSInteger)retweetCount;

-(CGFloat)heightForImgsWithCount:(NSInteger)count;

+(NSString *)formatPostTime:(NSString *)postTime;

@end
