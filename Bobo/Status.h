//
//  Status.h
//  Bobo
//
//  Created by Zhouboli on 15/7/13.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "User.h"

@interface Status : NSObject

@property (copy, nonatomic) NSString *created_at;
@property (nonatomic) NSInteger status_id;
@property (nonatomic) NSInteger status_mid;
@property (copy, nonatomic) NSString *idstr;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *source;
@property (nonatomic) BOOL favorited;
@property (nonatomic) BOOL truncated;
@property (copy, nonatomic) NSString *thumbnail_pic;
@property (copy, nonatomic) NSString *bmiddle_pic;
@property (copy, nonatomic) NSString *original_pic;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Status *retweeted_status;
@property (nonatomic) NSInteger reposts_count;
@property (nonatomic) NSInteger comments_count;
@property (nonatomic) NSInteger attitudes_count;

@property (copy, nonatomic) NSMutableArray *pic_urls;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat heightForWaterfall;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
