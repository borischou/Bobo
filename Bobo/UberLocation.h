//
//  UberLocation.h
//  Pods
//
//  Created by Zhouboli on 15/7/10.
//
//

#import <Foundation/Foundation.h>

@interface UberLocation : NSObject

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic) NSInteger bearing; //The current bearing of the vehicle in degrees (0-359).

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
