//
//  Comment.h
//  Bobo
//
//  Created by Zhouboli on 15/7/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Status.h"

@interface Comment : NSObject

@property (strong, nonatomic) NSString *created_at;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *source;
@property (strong, nonatomic) NSString *mid;
@property (strong, nonatomic) NSString *idstr;
@property (nonatomic) NSInteger comnt_id;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Status *status;
@property (strong, nonatomic) Comment *reply_comment;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
