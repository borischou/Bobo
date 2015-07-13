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
@property (strong, nonatomic) NSString *idstr;
@property (strong, nonatomic) NSString *screen_name;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) NSInteger province;
@property (nonatomic) NSInteger city;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *user_description;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *profile_image_url;
@property (strong, nonatomic) NSString *profile_url;
@property (strong, nonatomic) NSString *domain;
@property (strong, nonatomic) NSString *weihao;
@property (strong, nonatomic) NSString *gender;
@property (nonatomic) NSInteger followers_count;
@property (nonatomic) NSInteger friends_count;
@property (nonatomic) NSInteger statuses_count;
@property (nonatomic) NSInteger favourites_count;
@property (strong, nonatomic) NSString *created_at;
@property (nonatomic) BOOL allow_all_act_msg;
@property (nonatomic) BOOL geo_enabled;
@property (nonatomic) BOOL verified;
@property (strong, nonatomic) NSString *remark;
@property (nonatomic) BOOL allow_all_comment;
@property (strong, nonatomic) NSString *avatar_large;
@property (strong, nonatomic) NSString *avatar_hd;
@property (strong, nonatomic) NSString *verified_reason;
@property (nonatomic) BOOL follow_me;
@property (nonatomic) NSInteger online_status;
@property (nonatomic) NSInteger bi_followers_count;
@property (strong, nonatomic) NSString *lang;
@property (strong, nonatomic) UIImage *avatar;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
