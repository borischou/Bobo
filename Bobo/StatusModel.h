//
//  StatusModel.h
//  Bobo
//
//  Created by Zhouboli on 15/6/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StatusModel : NSObject

@property (nonatomic) CGFloat height;

//status
@property (strong, nonatomic) NSString *statusIdStr;
@property (strong, nonatomic) NSString *created_at;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSMutableArray *pic_urls;
@property (strong, nonatomic) NSMutableArray *postImgs;
@property (strong, nonatomic) NSString *formattedPostTime;
@property (nonatomic) NSInteger statusId;
@property (nonatomic) NSInteger reposts_count;
@property (nonatomic) NSInteger comments_count;
@property (nonatomic) NSInteger pic_count;
@property (nonatomic) NSInteger attitudes_count;

//status_user
@property (strong, nonatomic) NSString *screen_name;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *avatar_large;
@property (strong, nonatomic) UIImage *avatar;
@property BOOL isVerified;

//retweeted_status
@property (nonatomic) NSInteger retweeted_pic_count;
@property (strong, nonatomic) NSMutableArray *retweeted_image_urls;
@property (strong, nonatomic) NSString *retweeted_text;
@property (strong, nonatomic) NSMutableArray *repostImgs;

//retweeted_status_user
@property (strong, nonatomic) NSString *retweeted_screen_name;

-(id)initWithStatusData:(NSDictionary *)status;

-(CGFloat)heightForImgsWithCount:(NSInteger)count;

@end
