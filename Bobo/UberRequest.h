//
//  UberRequest.h
//  Pods
//
//  Created by Zhouboli on 15/7/10.
//
//

#import <Foundation/Foundation.h>
#import "UberDriver.h"
#import "UberLocation.h"
#import "UberVehicle.h"

@interface UberRequest : NSObject

@property (strong, nonatomic) NSString *request_id; //The unique ID of the Request.
@property (strong, nonatomic) NSString *status; //The status of the Request indicating state.
@property (strong, nonatomic) UberDriver *driver; //The object that contains driver details.
@property (strong, nonatomic) UberVehicle *vehicle; //The object that contains vehicle details.
@property (strong, nonatomic) UberLocation *location; //The object that contains the location information of the vehicle and driver.
@property (nonatomic) NSInteger eta; //The estimated time of vehicle arrival in minutes.
@property (nonatomic) float surge_multiplier; //The surge pricing multiplier used to calculate the increased price of a Request. A multiplier of 1.0 means surge pricing is not in effect.

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
