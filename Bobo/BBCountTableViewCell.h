//
//  BBCountCell.h
//  Bobo
//
//  Created by Zhouboli on 15/6/24.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Counts.h"
#import "User.h"

@class BBCountTableViewCell;
@protocol BBCountTableViewCellDelegate <NSObject>

-(void)tableViewCell:(BBCountTableViewCell *)cell didTapTodoImageViewWithTapGesture:(UITapGestureRecognizer *)tap;

@end

@interface BBCountTableViewCell : UITableViewCell

@property (weak, nonatomic) id <BBCountTableViewCellDelegate> delegate;

@property (strong, nonatomic) User *user;

@end
