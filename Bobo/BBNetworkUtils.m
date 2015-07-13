//
//  BBNetworkUtils.m
//  Bobo
//
//  Created by Zhouboli on 15/6/19.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBNetworkUtils.h"

@implementation BBNetworkUtils

+(void)fetchAvatarForStatus:(Status *)status withCell:(BBHomelistTableViewCell *)cell
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
                    cell.avatarView.image = img;
                }
                status.user.avatar = img;
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
