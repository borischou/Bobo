//
//  UberDriver.m
//  Pods
//
//  Created by Zhouboli on 15/7/10.
//
//

#import "UberDriver.h"

@implementation UberDriver

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _phone_number = [dictionary objectForKey:@"phone_number"];
        _picture_url = [dictionary objectForKey:@"picture_url"];
        _name = [dictionary objectForKey:@"name"];
        _rating = [[dictionary objectForKey:@"rating"] floatValue];
    }
    return self;
}

@end
