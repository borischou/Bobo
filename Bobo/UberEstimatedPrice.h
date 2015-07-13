//
//  UberEstimatedPrice.h
//  Bobo
//
//  Created by Zhouboli on 15/7/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UberEstimatedPrice : NSObject

@property (strong, nonatomic) NSString *surge_confirmation_href;
@property (strong, nonatomic) NSString *surge_confirmation_id;
@property (strong, nonatomic) NSString *currency_code;
@property (strong, nonatomic) NSString *display;
@property (nonatomic) NSInteger high_estimate;
@property (nonatomic) NSInteger low_estimate;
@property (nonatomic) NSInteger minimum;
@property (nonatomic) float surge_multiplier;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
