//
//  UberMap.h
//  Bobo
//
//  Created by Zhouboli on 15/7/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UberMap : NSObject

@property (strong, nonatomic) NSString *request_id;
@property (strong, nonatomic) NSString *href;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
