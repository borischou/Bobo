//
//  UberTrip.h
//  Bobo
//
//  Created by Zhouboli on 15/7/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UberTrip : NSObject

@property (strong, nonatomic) NSString *distance_unit;
@property (nonatomic) NSInteger duration_estimate;
@property (nonatomic) float distance_estimate;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
