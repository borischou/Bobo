//
//  AppDelegate.m
//  Bobo
//
//  Created by Zhouboli on 15/6/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "Utils.h"
#import "AppDelegate.h"
#import "BBProfileTableViewController.h"
#import "BBMainStatusTableViewController.h"
#import "BBFavoritesTableViewController.h"
#import "BBFriendsGroupTableViewController.h"
#import "BBUpdateStatusView.h"
#import "BBPhotoSelectionCollectionViewController.h"
#import "BBWaterfallStatusViewController.h"
#import "BBMessageViewController.h"

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kAppKey @"916936343"
#define bWeiboDomain @"https://api.weibo.com/2/"

#define kBarColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define uSmallGap 5
#define uBigGap 10

typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeToMe,
    MessageTypeAtMe
};

@interface AppDelegate ()

@property (strong, nonatomic) UITabBarController *tabBarController;

@end

@implementation AppDelegate

#pragma mark - Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _weiboAccount = [Utils systemAccounts].firstObject;
    [self accessWeiboSystemAccount];
    [self fetchUserProfile];
    [self initControllers];
    [self startMessagingTimer];
    [_window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Helpers

+(id)delegate
{
    return [[UIApplication sharedApplication] delegate];
}

-(ACAccount *)defaultAccount
{
    return _weiboAccount;
}

-(ACAccount *)validWeiboAccount
{
    _weiboAccount = [Utils systemAccounts].firstObject;
    [self accessWeiboSystemAccount];
    return _weiboAccount;
}

//每次启动app检查是否通过用户的系统级授权以及账号uid
-(void)accessWeiboSystemAccount
{
    //获取系统账号数据库中的新浪微博账号数据
    _uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    
    //若未授权则向用户申请授权
    if (_weiboAccount.accountType.accessGranted == NO || !_weiboAccount) {
        ACAccountStore *store = [[ACAccountStore alloc] init];
        ACAccountType *type = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
        [store requestAccessToAccountsWithType:type options:nil completion:^(BOOL granted, NSError *error) {
            if (granted == YES) { //授权成功
                NSLog(@"授权成功。");
                
                //本地尚未保存授权账号uid
                if (!_uid) {
                    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"account/get_uid.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        //获取本账号uid并保存在本地
                        NSError *error = nil;
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
                        NSString *uid = [NSString stringWithFormat:@"%@", dict[@"uid"]];
                        [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"uid"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        NSLog(@"error: %@", error);
                    }];
                }
            } else {
                NSLog(@"授权失败, 错误: %@", error);
                
            }
        }];
    }
    //用户已授权
    else
    {
        if (!_uid) {
            [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"account/get_uid.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                //获取本账号uid并保存在本地
                NSError *error = nil;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
                NSString *uid = [NSString stringWithFormat:@"%@", dict[@"uid"]];
                [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"uid"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
                       completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                NSLog(@"error: %@", error);
            }];
        }
    }
}

-(void)initControllers
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //Tab:微博主页
    BBMainStatusTableViewController *weiboListTvc = [[BBMainStatusTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    weiboListTvc.title = @"Friends";
    weiboListTvc.tabBarItem.image = [UIImage imageNamed:@"bobo_tab_icon"];
    UINavigationController *weiboListNvc = [[UINavigationController alloc] initWithRootViewController:weiboListTvc];
    [Utils setupNavigationController:weiboListNvc withUIViewController:weiboListTvc];
    
    //Tab:个人中心
    BBProfileTableViewController *profileTvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    profileTvc.title = @"Me";
    profileTvc.shouldNavBtnShown = YES;
    profileTvc.uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    profileTvc.tabBarItem.image = [UIImage imageNamed:@"iconfont-gerenshiwu"];
    UINavigationController *profileNvc = [[UINavigationController alloc] initWithRootViewController:profileTvc];
    [Utils setupNavigationController:profileNvc withUIViewController:profileTvc];
    
    //Tab:收藏微博
    BBFavoritesTableViewController *collectionTvc = [[BBFavoritesTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    collectionTvc.title = @"Favorites";
    collectionTvc.tabBarItem.image = [UIImage imageNamed:@"bb_collect_icon"];
    UINavigationController *collectionNvc = [[UINavigationController alloc] initWithRootViewController:collectionTvc];
    [Utils setupNavigationController:collectionNvc withUIViewController:collectionTvc];

    //Tab:图片墙
    BBWaterfallStatusViewController *waterfallvc = [[BBWaterfallStatusViewController alloc] init];
    waterfallvc.title = @"Waterfall";
    waterfallvc.tabBarItem.image = [UIImage imageNamed:@"tab_waterfall"];
    UINavigationController *waterfallnvc = [[UINavigationController alloc] initWithRootViewController:waterfallvc];
    [Utils setupNavigationController:waterfallnvc withUIViewController:waterfallvc];
    
    //Tab:消息
    BBMessageViewController *messagevc = [[BBMessageViewController alloc] init];
    messagevc.title = @"Message";
    messagevc.tabBarItem.image = [UIImage imageNamed:@"tab_icon_message"];
    UINavigationController *messagenvc = [[UINavigationController alloc] initWithRootViewController:messagevc];
    [Utils setupNavigationController:messagenvc withUIViewController:messagevc];

    //Tabbar
    _tabBarController = [[UITabBarController alloc] init];
    _tabBarController.tabBar.layer.shadowOpacity = 0.2;
    _tabBarController.tabBar.layer.shadowColor = [UIColor blackColor].CGColor;
    [_tabBarController setViewControllers:@[weiboListNvc, messagenvc, waterfallnvc, profileNvc, collectionNvc] animated:YES];
    _tabBarController.tabBar.barTintColor = kBarColor;
    
    self.window.rootViewController = _tabBarController;
}

#pragma mark - Messaging support

-(void)startMessagingTimer
{
    //创建分线程在后台进行消息定时读取
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSTimer *timer = [NSTimer timerWithTimeInterval:30.0 target:self selector:@selector(messageTimerStarted:) userInfo:nil repeats:YES];
        
        //在分线程创建一个runloop保证分线程的生命周期并添加定时器在默认模式下定时触发
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
}

-(void)messageTimerStarted:(NSTimer *)timer
{
    //读取微博消息数量
    [self fetchUserMessageCounts];
}

-(void)fetchUserMessageCounts
{
    if (!_weiboAccount) {
        return; //若还未获取到本地系统账号授权则等待下一轮触发
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils genericWeiboRequestWithAccount:[Utils systemAccounts].firstObject URL:@"comments/to_me.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSError *error;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
                [self handleResponseObject:result messageType:MessageTypeToMe];
            } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error: %@", error);
            }];
            [Utils genericWeiboRequestWithAccount:[Utils systemAccounts].firstObject URL:@"comments/mentions.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSError *error;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
                [self handleResponseObject:result messageType:MessageTypeAtMe];
            } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error: %@", error);
            }];
        });
    }
}

-(void)handleResponseObject:(id)responseObject messageType:(NSInteger)type
{
    NSDictionary *result = responseObject;
    NSInteger count = [result[@"total_number"] integerValue];
    switch (type) {
        case MessageTypeToMe:
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"count_to_me"])
            { //首次获取消息
                [[NSUserDefaults standardUserDefaults] setObject:@(count) forKey:@"count_to_me"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                _toMeIncrement = 0;
            }
            else
            {
                NSInteger toMeCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"count_to_me"] integerValue];
                _toMeIncrement = labs(toMeCount-count);
            }
            break;
        case MessageTypeAtMe:
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"count_at_me"])
            {
                [[NSUserDefaults standardUserDefaults] setObject:@(count) forKey:@"count_at_me"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                _atMeIncrement = 0;
            }
            else
            {
                NSInteger atMeCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"count_at_me"] integerValue];
                _atMeIncrement = labs(atMeCount-count);
            }
            break;
        default:
            break;
    }
    UITabBarItem *messageTab = _tabBarController.tabBar.items[1];
    NSInteger totalIncrement = _toMeIncrement + _atMeIncrement;
    messageTab.badgeValue = totalIncrement > 0? [NSString stringWithFormat:@"%ld", totalIncrement]: nil;
}

#pragma mark - Weibo support

//https://api.weibo.com/2/users/show.json?uid=id_string
-(void)fetchUserProfile
{
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    if (!uid) {
        [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"account/get_uid.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //获取本账号uid并保存在本地
            NSError *error = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
            NSString *uid = [NSString stringWithFormat:@"%@", dict[@"uid"]];
            [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"uid"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [Utils genericWeiboRequestWithAccount:[Utils systemAccounts].firstObject URL:@"users/show.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:@{@"uid": uid} completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSError *error = nil;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
                _user = [[User alloc] initWithDictionary:dict];
            } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error: %@", error);
            }];
        }
                   completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            NSLog(@"error: %@", error);
        }];
    }
    else
    {
        [Utils genericWeiboRequestWithAccount:[Utils systemAccounts].firstObject URL:@"users/show.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:@{@"uid": uid} completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error = nil;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
            _user = [[User alloc] initWithDictionary:dict];
        }
                   completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            NSLog(@"error: %@", error);
        }];
    }
}

@end
