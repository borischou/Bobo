//
//  UberRequests.h
//  Bobo
//
//  Created by Zhouboli on 15/7/6.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UberRequest : NSObject

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSDictionary *parameters;

typedef void (^RequestHandler) (NSDictionary *uberResponse, NSURLResponse *response, NSError *error);

-(void)getResponseFromRequestWithCompletionHandler:(RequestHandler)handler;

@end
