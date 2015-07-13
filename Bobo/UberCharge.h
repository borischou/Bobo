//
//  UberCharge.h
//  Bobo
//
//  Created by Zhouboli on 15/7/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UberCharge : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *type;
@property (nonatomic) float amount;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
