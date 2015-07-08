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
#import "StatusModel.h"
#import "UserModel.h"

@interface BBNetworkUtils : NSObject

+(void)fetchAvatarForStatus:(StatusModel *)status withCell:(BBHomelistTableViewCell *)cell;
+(void)fetchImageFromUrl:(NSString *)url atIndex:(NSInteger)index forImages:(NSMutableArray *)imgs withViews:(NSMutableArray *)views;

@end
