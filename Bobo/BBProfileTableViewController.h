//
//  BBProfileTableVC.h
//  Bobo
//
//  Created by Zhouboli on 15/6/22.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MJRefresh/MJRefresh.h>
#import <AFNetworking.h>
#import <SafariServices/SafariServices.h>

#import "BBUpdateStatusView.h"
#import "BBStatusDetailViewController.h"
#import "BBListTableViewController.h"
#import "BBAlbumCollectionViewController.h"
#import "BBCountTableViewCell.h"
#import "AppDelegate.h"
#import "BBProfileHeaderView.h"
#import "BBStatusTableViewCell.h"
#import "BBImageBrowserView.h"
#import "BBButtonbarTableViewCell.h"
#import "NSString+Convert.h"
#import "UIButton+Bobtn.h"
#import "Utils.h"
#import "Status.h"
#import "BBProfileMenuHeaderView.h"
#import "BBSettingsTableViewController.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnHeight bHeight/25
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define uSmallGap 5
#define uBigGap 10

//#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

@interface BBProfileTableViewController : UITableViewController

@property (strong, nonatomic) User *user;
@property (copy, nonatomic) NSString *uid;
@property (strong, nonatomic) NSMutableArray *statuses;
@property (nonatomic) BOOL shouldNavBtnShown;
@property (copy, nonatomic) NSString *currentLastStatusId;
@property (strong, nonatomic) ACAccount *weiboAccount;
@property (nonatomic) BOOL originalTurnedOn;
@property (nonatomic) NSInteger currentIndex;

@end
