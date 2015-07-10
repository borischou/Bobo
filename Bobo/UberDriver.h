//
//  UberDriver.h
//  Pods
//
//  Created by Zhouboli on 15/7/10.
//
//

#import <Foundation/Foundation.h>

@interface UberDriver : NSObject

@property (strong, nonatomic) NSString *phone_number; //The formatted phone number for contacting the driver.
@property (strong, nonatomic) NSString *picture_url; //The URL to the photo of the driver.
@property (strong, nonatomic) NSString *name; //The first name of the driver.
@property (nonatomic) float rating; //The driver's star rating out of 5 stars.

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

@end
