//
//  BBCountCell.h
//  Bobo
//
//  Created by Zhouboli on 15/6/24.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Counts.h"

@interface BBCountTableViewCell : UITableViewCell

@property (strong, nonatomic) NSMutableArray *views;
@property (strong, nonatomic) UILabel *wbcounts;
@property (strong, nonatomic) UILabel *friendcounts;
@property (strong, nonatomic) UILabel *followercounts;

@end