//
//  AppDelegate.m
//  Bobo
//
//  Created by Zhouboli on 15/6/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "AppDelegate.h"

#import "WeiboSDK.h"

#import "BBProfileTableViewController.h"
#import "BBMainStatusTableViewController.h"
#import "BBFavoritesTableViewController.h"

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kAppKey @"916936343"
#define bWeiboDomain @"https://api.weibo.com/2/"

#define kBarColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]
#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@interface AppDelegate () <WeiboSDKDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self initControllers];
    [self.window makeKeyAndVisible];
    [self checkLoginStatus];
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

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"handleOpenURL: the url is: %@", [NSString stringWithFormat:@"%@", url]);
    return [WeiboSDK handleOpenURL:url delegate:self];
}

#pragma mark - Helpers

-(void)saveTokenAndUserID
{
    self.isLoggedIn = YES;
    [[NSUserDefaults standardUserDefaults] setValue:@(self.isLoggedIn) forKey:@"loginstatus"];
    [[NSUserDefaults standardUserDefaults] setObject:self.wbToken forKey:@"wbtoken"];
    [[NSUserDefaults standardUserDefaults] setObject:self.wbCurrentUserID forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)checkLoginStatus
{
    self.isLoggedIn = [[NSUserDefaults standardUserDefaults] valueForKey:@"loginstatus"];
    self.wbToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"wbtoken"];
    self.wbCurrentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSLog(@"self.wbCurrentUserID: %@\nself.wbToken: %@", self.wbCurrentUserID, self.wbToken);
    if (!self.isLoggedIn || !self.wbToken || !self.wbCurrentUserID) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Auto login failed" message:@"Please login later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)initControllers
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //微博主页
    BBMainStatusTableViewController *weiboListTvc = [[BBMainStatusTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    weiboListTvc.title = @"Bobo";
    weiboListTvc.tabBarItem.image = [UIImage imageNamed:@"chunvzuo"];
    UINavigationController *weiboListNvc = [[UINavigationController alloc] initWithRootViewController:weiboListTvc];
    [self setupNavigationController:weiboListNvc withUITableViewController:weiboListTvc];
    
    //个人中心
    BBProfileTableViewController *profileTvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    profileTvc.title = @"Me";
    profileTvc.tabBarItem.image = [UIImage imageNamed:@"iconfont-gerenshiwu"];
    UINavigationController *profileNvc = [[UINavigationController alloc] initWithRootViewController:profileTvc];
    [self setupNavigationController:profileNvc withUITableViewController:profileTvc];
    
    //收藏微博
    BBFavoritesTableViewController *collectionTvc = [[BBFavoritesTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    collectionTvc.title = @"Favorites";
    collectionTvc.tabBarItem.image = [UIImage imageNamed:@"bb_collect_icon"];
    UINavigationController *collectionNvc = [[UINavigationController alloc] initWithRootViewController:collectionTvc];
    [self setupNavigationController:collectionNvc withUITableViewController:collectionTvc];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:@[profileNvc, weiboListNvc, collectionNvc] animated:YES];
    tabBarController.tabBar.barTintColor = kBarColor;
    self.window.rootViewController = tabBarController;
}

-(void)setupNavigationController:(UINavigationController *)uinvc withUITableViewController:(UITableViewController *)uitvc
{
    uinvc.navigationBar.barTintColor = kBarColor;
    uinvc.navigationBar.tintColor = [UIColor whiteColor];
    
    uitvc.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    uitvc.view.backgroundColor = bBGColor;
    uitvc.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - WeiboSDKDelegate

-(void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    NSLog(@"收到didReceiveWeiboRequest回应: %@", request);
}

-(void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"WeiboSDKDelegate" message:[NSString stringWithFormat:@"didReceiveWeiboResponse:\n%@\n 响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@", [response class], (int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        WBSendMessageToWeiboResponse *sendMsgToWBResponse = (WBSendMessageToWeiboResponse *)response;
        NSString* accessToken = [sendMsgToWBResponse.authResponse accessToken];
        if (accessToken)
        {
            self.wbToken = accessToken;
            NSLog(@"self.wbToken: %@", self.wbToken);
        }
        NSString* userID = [sendMsgToWBResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
            NSLog(@"self.wbCurrentUserID: %@", self.wbCurrentUserID);
        }
        [alertView show];
    }
    
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"WeiboSDKDelegate" message:[NSString stringWithFormat:@"didReceiveWeiboResponse:\n%@\n 响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求数据: %@", [response class], (int)response.statusCode, [(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        self.wbToken = [(WBAuthorizeResponse *)response accessToken];
        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
        NSLog(@"self.wbToken: %@", self.wbToken);
        NSLog(@"self.wbCurrentUserID: %@", self.wbCurrentUserID);
        
        [self saveTokenAndUserID];
        [alertView show];
    }
}

@end
