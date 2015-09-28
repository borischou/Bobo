//
//  BBProfileTableVC.h
//  Bobo
//
//  Created by Zhouboli on 15/6/22.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"

@interface BBProfileTableViewController : UITableViewController

@property (strong, nonatomic) User *user;
@property (copy, nonatomic) NSString *uid;
@property (strong, nonatomic) NSMutableArray *statuses;
@property (nonatomic) BOOL shouldNavBtnShown;

@end
