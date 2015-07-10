//
//  UberLocation.m
//  Pods
//
//  Created by Zhouboli on 15/7/10.
//
//

#import "UberLocation.h"

@implementation UberLocation

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _latitude = [dictionary[@"latitude"] floatValue];
        _longitude = [dictionary[@"longitude"] floatValue];
        _bearing = [dictionary[@"bearing"] integerValue];
    }
    return self;
}

@end
