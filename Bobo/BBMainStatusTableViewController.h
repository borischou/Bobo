//
//  BBWeiboListTableVC.h
//  Bobo
//
//  Created by Zhouboli on 15/6/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MJRefresh/MJRefresh.h>

@interface BBMainStatusTableViewController : UITableViewController

@property (nonatomic) NSInteger groupNumber;
@property (copy, nonatomic) NSString *max_id;
@property (copy, nonatomic) NSString *since_id;
@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) ACAccount *weiboAccount;
@property (strong, nonatomic) NSMutableArray *statuses;

@end
