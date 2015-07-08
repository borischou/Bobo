//
//  WeiboCountsModel.h
//  Bobo
//
//  Created by Zhouboli on 15/6/25.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboCountsModel : NSObject

@property (nonatomic) NSInteger followers_count;
@property (nonatomic) NSInteger friends_count;
@property (nonatomic) NSInteger statuses_count;

-(id)initWithWeiboCounts:(NSDictionary *)weiboCounts;

@end
