//
//  BBListTableViewCell.h
//  Bobo
//
//  Created by Zhouboli on 15/10/8.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@class BBListTableViewCell;
@protocol BBListTableViewCellDelegate <NSObject>

@optional
-(void)tableViewCell:(BBListTableViewCell *)cell didTapRelationshipView:(UITapGestureRecognizer *)tap;

@end

@interface BBListTableViewCell : UITableViewCell

@property (weak, nonatomic) id <BBListTableViewCellDelegate> delegate;

@property (strong, nonatomic) User *user;

@end
