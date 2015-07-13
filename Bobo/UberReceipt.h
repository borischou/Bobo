//
//  UberReceipt.h
//  Bobo
//
//  Created by Zhouboli on 15/7/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UberCharge.h"

@interface UberReceipt : NSObject

@property (strong, nonatomic) NSString *request_id;
@property (strong, nonatomic) NSString *duration;
@property (strong, nonatomic) NSString *distance;
@property (strong, nonatomic) NSString *distance_label;
@property (strong, nonatomic) NSString *currency_code;

@property (strong, nonatomic) NSMutableArray *charges;
@property (strong, nonatomic) NSMutableArray *charge_adjustments;
@property (strong, nonatomic) UberCharge *surge_charge;

@property (nonatomic) float normal_fare;
@property (nonatomic) float subtotal;
@property (nonatomic) float total_charged;
@property (nonatomic) float total_owed;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
