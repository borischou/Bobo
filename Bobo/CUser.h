//
//  CUser.h
//  
//
//  Created by Zhouboli on 15/8/20.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CStatus;

@interface CUser : NSManagedObject

@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * idstr;
@property (nonatomic, retain) NSString * screen_name;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * province;
@property (nonatomic, retain) NSNumber * city;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * user_description;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * profile_image_url;
@property (nonatomic, retain) NSString * profile_url;
@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSString * weihao;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * followers_count;
@property (nonatomic, retain) NSNumber * friends_count;
@property (nonatomic, retain) NSNumber * statuses_count;
@property (nonatomic, retain) NSNumber * favourites_count;
@property (nonatomic, retain) NSString * created_at;
@property (nonatomic, retain) NSNumber * allow_all_act_msg;
@property (nonatomic, retain) NSNumber * geo_enabled;
@property (nonatomic, retain) NSNumber * verified;
@property (nonatomic, retain) NSString * remark;
@property (nonatomic, retain) NSNumber * allow_all_comment;
@property (nonatomic, retain) NSString * avatar_large;
@property (nonatomic, retain) NSString * avatar_hd;
@property (nonatomic, retain) NSString * verified_reason;
@property (nonatomic, retain) NSNumber * follow_me;
@property (nonatomic, retain) NSNumber * online_status;
@property (nonatomic, retain) NSNumber * bi_followers_count;
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) CStatus *status;

@end
