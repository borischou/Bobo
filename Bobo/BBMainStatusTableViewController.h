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

#import "BBProfileTableViewController.h"
#import "BBStatusDetailViewController.h"
#import "BBButtonbarTableViewCell.h"
#import "BBStatusTableViewCell.h"
#import "BBUpdateStatusView.h"
#import "AppDelegate.h"
#import "BBImageBrowserView.h"
#import "UIButton+Bobtn.h"
#import "NSString+Convert.h"
#import "Status.h"
#import "User.h"
#import "Utils.h"
#import "BBGroupSelectView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnHeight bHeight/25
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define uSmallGap 5
#define uBigGap 10

#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

@interface BBMainStatusTableViewController : UITableViewController

@property (nonatomic) NSInteger groupNumber;
@property (copy, nonatomic) NSString *max_id;
@property (copy, nonatomic) NSString *since_id;
@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) ACAccount *weiboAccount;
@property (strong, nonatomic) NSMutableArray *statuses;

@end
