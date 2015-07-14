//
//  BBWBDetailsTableVC.h
//  Bobo
//
//  Created by Zhouboli on 15/7/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "User.h"

@interface BBWBDetailsTableVC : UITableViewController

@property (strong, nonatomic) Status *status;
@property (strong, nonatomic) User *user;

@end
