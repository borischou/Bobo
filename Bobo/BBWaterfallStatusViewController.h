//
//  BBWaterfallStatusViewController.h
//  Bobo
//
//  Created by Boris Chow on 8/25/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import <MJRefresh/MJRefresh.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Utils.h"
#import "AppDelegate.h"
#import "BBWaterfallCollectionView.h"
#import "BBUpdateStatusView.h"
#import "BBGroupSelectView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define uSmallGap 5
#define uBigGap 10

#define bWeiboDomain @"https://api.weibo.com/2/"

@interface BBWaterfallStatusViewController : UIViewController

@property (nonatomic) NSInteger groupNumber;
@property (strong, nonatomic) BBWaterfallCollectionView *waterfallView;
@property (copy, nonatomic) NSString *max_id;
@property (copy, nonatomic) NSString *since_id;
@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) ACAccount *weiboAccount;

-(void)fetchHistoryStatuses;

@end
