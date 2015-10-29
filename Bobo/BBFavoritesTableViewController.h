//
//  BBCollectionTableViewController.h
//  Bobo
//
//  Created by Zhouboli on 15/8/7.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBStatusDetailViewController.h"
#import "BBProfileTableViewController.h"
#import "BBStatusTableViewCell.h"
#import "BBButtonbarTableViewCell.h"
#import "BBImageBrowserView.h"
#import "Status.h"
#import "User.h"
#import "NSString+Convert.h"
#import "UIButton+Bobtn.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "BBUpdateStatusView.h"
#import <MJRefresh/MJRefresh.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <SafariServices/SafariServices.h>

@interface BBFavoritesTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *statuses;
@property (strong, nonatomic) ACAccount *weiboAccount;

@end
