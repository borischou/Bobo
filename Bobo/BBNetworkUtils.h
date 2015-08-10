//
//  BBNetworkUtils.h
//  Bobo
//
//  Created by Zhouboli on 15/6/19.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBHomelistTableViewCell.h"
#import "User.h"
#import "Status.h"

@interface BBNetworkUtils : NSObject

+(void)fetchAvatarForStatus:(Status *)status withCell:(BBHomelistTableViewCell *)cell;
+(void)fetchImageFromUrl:(NSString *)url atIndex:(NSInteger)index forImages:(NSMutableArray *)imgs withViews:(NSMutableArray *)views;
+(void)layoutImgViews:(NSMutableArray *)views withImageCount:(NSInteger)count fromTopHeight:(CGFloat)height;

@end
