//
//  BBNetworkUtils.m
//  Bobo
//
//  Created by Zhouboli on 15/6/19.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBNetworkUtils.h"

#define bSmallGap 5
#define bBigGap 10
#define bPostImgHeight ([UIScreen mainScreen].bounds.size.width-2*bSmallGap)/3
#define bPostImgWidth bPostImgHeight

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

+(CGFloat)layoutImgViews:(NSMutableArray *)views withImageCount:(NSInteger)count fromTopHeight:(CGFloat)height
{
    for (int i = 0; i < 9; i ++) {
        [views[i] setFrame:CGRectZero];
    }
    
    if (count >= 1 && count <= 2) {
        for (int i = 0; i < count; i ++) {
            [views[i] setFrame:CGRectMake(bBigGap + i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        return bSmallGap+bPostImgHeight;
    }
    
    if (count == 3) {
        for (int i = 0; i < count; i ++) {
            [views[i] setFrame:CGRectMake(i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        return bSmallGap+bPostImgHeight;
    }
    
    if (count >= 4 && count <= 6) {
        for (int i = 0; i < 3; i ++) {
            [views[i] setFrame:CGRectMake(i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int j = 0; j < count - 3; j ++) {
            [views[3 + j] setFrame:CGRectMake(j * (bPostImgWidth + bSmallGap), height + bSmallGap + bPostImgHeight + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        return bSmallGap*2+bPostImgHeight*2;
    }
    
    if (count >= 7 && count <= 9) {
        for (int i = 0; i < 3; i ++) {
            [views[i] setFrame:CGRectMake(i * (bPostImgWidth + bSmallGap), height + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int j = 0; j < 3; j ++) {
            [views[3 + j] setFrame:CGRectMake(j * (bPostImgWidth + bSmallGap), height + bSmallGap + bPostImgHeight + bSmallGap, bPostImgWidth, bPostImgHeight)];
        }
        for (int k = 0; k < count - 6; k ++) {
            [views[6 + k] setFrame:CGRectMake(k * (bPostImgWidth + bSmallGap), height + bSmallGap + (bPostImgHeight + bSmallGap) * 2, bPostImgWidth, bPostImgHeight)];
        }
        return bSmallGap*3+bPostImgHeight*3;
    }
    return 0;
}


@end
