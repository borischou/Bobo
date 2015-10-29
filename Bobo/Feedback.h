//
//  Feedback.h
//  Bobo
//
//  Created by Zhouboli on 15/10/29.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feedback : NSObject

@property (assign, nonatomic) NSInteger status_id;
@property (assign, nonatomic) NSInteger comments;
@property (assign, nonatomic) NSInteger reposts;
@property (assign, nonatomic) NSInteger attitudes;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
