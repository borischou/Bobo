//
//  UserModel.h
//  Bobo
//
//  Created by Zhouboli on 15/6/22.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UserModel : NSObject

@property (strong, nonatomic) NSString *screen_name;
@property (strong, nonatomic) NSString *introduction;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *created_at;
@property (strong, nonatomic) NSString *verified_reason;
@property (strong, nonatomic) NSString *avatar_large;
@property (nonatomic) NSInteger userId;
@property (nonatomic) NSInteger followers_count;
@property (nonatomic) NSInteger friends_count;
@property (nonatomic) NSInteger statuses_count;
@property (nonatomic) NSInteger favourites_count;
@property (nonatomic) BOOL verified;

-(id)initWithUserData:(NSDictionary *)user;

@end
