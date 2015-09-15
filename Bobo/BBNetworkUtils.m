//
//  BBNetworkUtils.m
//  Bobo
//
//  Created by Zhouboli on 15/6/19.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBNetworkUtils.h"
#import "BBUpdateStatusView.h"

#define bSmallGap 5
#define bBigGap 10
#define bPostImgHeight ([UIScreen mainScreen].bounds.size.width-2*bSmallGap)/3
#define bPostImgWidth bPostImgHeight

#define bPostImgHeightForTwo ([UIScreen mainScreen].bounds.size.width-bSmallGap)/2
#define bPostImgWidthForTwo bPostImgHeightForTwo

typedef void (^AnimationHandler) (void);
typedef void (^CompletionHandler) (BOOL finished);

@interface BBNetworkUtils ()

@end

@implementation BBNetworkUtils

+(void)fetchAvatarForStatus:(Status *)status withCell:(BBStatusTableViewCell *)cell
{
    NSURL *imgUrl = [NSURL URLWithString:status.user.avatar_large];
    NSURLRequest *request = [NSURLRequest requestWithURL:imgUrl];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (!error) {
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cell) {
                }
            });
        }
    }];
    [task resume];
}

+(void)fetchImageFromUrl:(NSString *)url atIndex:(NSInteger)index forImages:(NSMutableArray *)imgs withViews:(NSMutableArray *)views
{
    NSURL *imgUrl = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:imgUrl];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (!error) {
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [imgs replaceObjectAtIndex:index withObject:img];
                if (views) {
                    UIImageView *view = [views objectAtIndex:index];
                    view.image = img;
                }
            });
        }
    }];
    [task resume];
}

@end
