//
//  User.h
//  Bobo
//
//  Created by Zhouboli on 15/7/13.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class Status;

@interface User : NSObject

@property (strong, nonatomic) Status *status;
@property (nonatomic) NSInteger user_id;
@property (copy, nonatomic) NSString *idstr;
@property (copy, nonatomic) NSString *screen_name;
@property (copy, nonatomic) NSString *name;
@property (nonatomic) NSInteger province;
@property (nonatomic) NSInteger city;
@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *user_description;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *profile_image_url;
@property (copy, nonatomic) NSString *profile_url;
@property (copy, nonatomic) NSString *domain;
@property (copy, nonatomic) NSString *weihao;
@property (copy, nonatomic) NSString *gender;
@property (nonatomic) NSInteger followers_count;
@property (nonatomic) NSInteger friends_count;
@property (nonatomic) NSInteger statuses_count;
@property (nonatomic) NSInteger favourites_count;
@property (copy, nonatomic) NSString *created_at;
@property (nonatomic) BOOL allow_all_act_msg;
@property (nonatomic) BOOL geo_enabled;
@property (nonatomic) BOOL verified;
@property (copy, nonatomic) NSString *remark;
@property (nonatomic) BOOL allow_all_comment;
@property (copy, nonatomic) NSString *avatar_large;
@property (copy, nonatomic) NSString *avatar_hd;
@property (copy, nonatomic) NSString *verified_reason;
@property (nonatomic) BOOL follow_me;
@property (nonatomic) BOOL following;
@property (nonatomic) NSInteger online_status;
@property (nonatomic) NSInteger bi_followers_count;
@property (copy, nonatomic) NSString *lang;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
