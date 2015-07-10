//
//  BBUberCarTableViewCell.h
//  Bobo
//
//  Created by Zhouboli on 15/7/9.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBUberCarTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *carImgView;
@property (strong, nonatomic) UILabel *carType;
@property (strong, nonatomic) UILabel *promotion;
@property (strong, nonatomic) UILabel *capacity;
@property (strong, nonatomic) UILabel *distance;
@property (strong, nonatomic) UILabel *surgeMultiplier;
@property (strong, nonatomic) UILabel *estimatePrice;
@property (strong, nonatomic) UILabel *estimateDuration;

@end
