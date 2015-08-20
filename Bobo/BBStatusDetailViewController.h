//
//  BBStatusDetailViewController.h
//  Bobo
//
//  Created by Zhouboli on 15/8/20.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "User.h"

@interface BBStatusDetailViewController : UIViewController

@property (strong, nonatomic) Status *status;
@property (strong, nonatomic) UITableView *tableView;

@end
