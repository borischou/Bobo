//
//  UberVehicle.m
//  Pods
//
//  Created by Zhouboli on 15/7/10.
//
//

#import "UberVehicle.h"

@implementation UberVehicle

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _make = dictionary[@"make"];
        _model = dictionary[@"model"];
        _license_plate = dictionary[@"license_plate"];
        _picture_url = dictionary[@"picture_url"];
    }
    return self;
}

@end
