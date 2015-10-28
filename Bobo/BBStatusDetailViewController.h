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
#import <MJRefresh/MJRefresh.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <SafariServices/SafariServices.h>
#import "BBProfileTableViewController.h"
#import "BBUpdateStatusView.h"
#import "BBStatusTableViewCell.h"
#import "BBCommentTableViewCell.h"
#import "BBImageBrowserView.h"
#import "NSString+Convert.h"
#import "AppDelegate.h"
#import "Comment.h"
#import "Utils.h"
#import "BBReplyCommentView.h"
#import "BBCommentBarView.h"
#import "BBNotificationView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define dComntBarViewHeight 60

#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define uSmallGap 5

#define bWeiboDomain @"https://api.weibo.com/2/"

@interface BBStatusDetailViewController : UIViewController

@property (strong, nonatomic) Status *status;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ACAccount *weiboAccount;
@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) BBCommentBarView *barView;

@end
