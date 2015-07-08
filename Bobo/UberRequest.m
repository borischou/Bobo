//
//  UberRequests.m
//  Bobo
//
//  Created by Zhouboli on 15/7/6.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "UberRequest.h"


@interface UberRequest ()

@end

@implementation UberRequest

#pragma mark - Request

-(void)getResponseFromRequestWithCompletionHandler:(RequestHandler)handler
{
    NSString *baseURL = @"https://sandbox-api.uber.com/v1";
    NSString *url = [NSString stringWithFormat:@"%@/requests", baseURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", _accessToken] forHTTPHeaderField:@"Authorization"];

    NSError *error = nil;
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:_parameters options:0 error:&error];
    
    [self performNetworkOperationWithRequest:request completionHandler:^(NSDictionary *uResponse, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"response status code: %ld", httpResponse.statusCode);
        NSLog(@"access token: %@", _accessToken);
        if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) { //OK
            handler(uResponse, response, error);
        } else {
            NSLog(@"Request error: %@", error);
            handler(nil, response, error);
        }
    }];
}

#pragma mark - POST operation

-(void)performNetworkOperationWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSDictionary *, NSURLResponse *, NSError *))completion
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            
            NSError *jsonError = nil;
            NSDictionary *serializedResults = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (jsonError == nil) {
                completion(serializedResults, response, jsonError);
            } else {
                NSHTTPURLResponse *convertedResponse = (NSHTTPURLResponse *)response;
                completion(nil, convertedResponse, error);
            }
            
        } else {
            NSHTTPURLResponse *convertedResponse = (NSHTTPURLResponse *)response;
            completion(nil, convertedResponse, error);
        }
    }] resume];
}
                                                      
@end
