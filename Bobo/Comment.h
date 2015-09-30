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
#import "ReplyComment.h"

@interface Comment : NSObject

@property (copy, nonatomic) NSString *created_at;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *source;
@property (copy, nonatomic) NSString *mid;
@property (copy, nonatomic) NSString *idstr;
@property (nonatomic) NSInteger comnt_id;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Status *status;
@property (strong, nonatomic) ReplyComment *reply_comment;

@property (nonatomic) CGFloat height; //评论cell高度
@property (nonatomic) CGFloat heightForMessageCell;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
