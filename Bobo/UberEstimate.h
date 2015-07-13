//
//  UberEstimate.h
//  Bobo
//
//  Created by Zhouboli on 15/7/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UberTrip.h"
#import "UberEstimatedPrice.h"

@interface UberEstimate : NSObject

@property (strong, nonatomic) UberTrip *trip;
@property (strong, nonatomic) UberEstimatedPrice *price;
@property (nonatomic) NSInteger pickup_estimate;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
