//
//  BBAvatarCell.h
//  Bobo
//
//  Created by Zhouboli on 15/6/22.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBAvatarCell : UITableViewCell

@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UIImage *avatar;
@property (strong, nonatomic) UILabel *nicknameLbl;
@property (strong, nonatomic) UILabel *introductionLbl;

@end
