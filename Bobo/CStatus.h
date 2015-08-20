//
//  CStatus.h
//  
//
//  Created by Zhouboli on 15/8/20.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CStatus, CUser;

@interface CStatus : NSManagedObject

@property (nonatomic, retain) NSNumber * attitudes_count;
@property (nonatomic, retain) NSString * bmiddle_pic;
@property (nonatomic, retain) NSNumber * comments_count;
@property (nonatomic, retain) NSString * created_at;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * idstr;
@property (nonatomic, retain) NSString * original_pic;
@property (nonatomic, retain) NSNumber * reposts_count;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSNumber * status_id;
@property (nonatomic, retain) NSNumber * status_mid;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * thumbnail_pic;
@property (nonatomic, retain) NSNumber * truncated;
@property (nonatomic, retain) CUser *user;
@property (nonatomic, retain) CStatus *retweeted_status;

@end
