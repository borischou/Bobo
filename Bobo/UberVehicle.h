//
//  UberVehicle.h
//  Pods
//
//  Created by Zhouboli on 15/7/10.
//
//

#import <Foundation/Foundation.h>

@interface UberVehicle : NSObject

@property (strong, nonatomic) NSString *make; //The vehicle make or brand.
@property (strong, nonatomic) NSString *model; //The vehicle model or type.
@property (strong, nonatomic) NSString *license_plate; //The license plate number of the vehicle.
@property (strong, nonatomic) NSString *picture_url; //The URL to a stock photo of the vehicle (may be null).

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
