//
//  ReplyComment.h
//  Bobo
//
//  Created by Boris Chow on 9/30/15.
//  Copyright © 2015 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface ReplyComment : NSObject

@property (copy, nonatomic) NSString *source;
@property (nonatomic) NSInteger floor_num;
@property (copy, nonatomic) NSString *reply_id;
@property (copy, nonatomic) NSString *idstr;
@property (copy, nonatomic) NSString *mid;
@property (nonatomic) BOOL source_allowclick;
@property (nonatomic) NSInteger source_type;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *created_at;
@property (strong, nonatomic) User *user;

-(instancetype)initWithDictionary:(NSDictionary *)dict;

@end
