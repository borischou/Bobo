//
//  BBDraftboxTableViewCell.h
//  Bobo
//
//  Created by Zhouboli on 15/10/12.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Draft.h"

@class BBDraftboxTableViewCell;
@protocol BBDraftboxTableViewCellDelegate <NSObject>

-(void)tableViewCell:(BBDraftboxTableViewCell *)cell didPressResendButton:(UIButton *)sender;

@end

@interface BBDraftboxTableViewCell : UITableViewCell

@property (weak, nonatomic) id <BBDraftboxTableViewCellDelegate> delegate;

@property (strong, nonatomic) Draft *draft;

@end
