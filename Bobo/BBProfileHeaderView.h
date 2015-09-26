//
//  BBMeHeaderView.h
//  Bobo
//
//  Created by Zhouboli on 15/8/6.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface BBProfileHeaderView : UIView

@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UIImageView *vipView;
@property (strong, nonatomic) UIImageView *sexView;
@property (strong, nonatomic) UILabel *name;
@property (strong, nonatomic) UILabel *introduction;

@property (strong, nonatomic) User *user;

@end
