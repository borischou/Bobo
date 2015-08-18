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
#import "BBFriendsGroupTableViewController.h"
#import "BBUpdateBackgroundViewController.h"
#import "BBUpdateStatusView.h"
#import "BBPhotoSelectionCollectionViewController.h"

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kAppKey @"916936343"
#define bWeiboDomain @"https://api.weibo.com/2/"

#define kBarColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]
#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define uSmallGap 5
#define uBigGap 10

@interface AppDelegate () <WeiboSDKDelegate, SWRevealViewControllerDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) BBUpdateStatusView *updateStatusView;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self checkLoginStatus];
    [self startUserProfileFetch];
    [self initControllers];
    [self.window makeKeyAndVisible];
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

-(BOOL)checkLoginStatus
{
    self.isLoggedIn = [[NSUserDefaults standardUserDefaults] valueForKey:@"loginstatus"];
    self.wbToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"wbtoken"];
    self.wbCurrentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSLog(@"self.wbCurrentUserID: %@\nself.wbToken: %@", self.wbCurrentUserID, self.wbToken);
    if (!self.isLoggedIn || !self.wbToken || !self.wbCurrentUserID) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Auto login failed" message:@"Please login later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    return self.isLoggedIn && self.wbToken && self.wbCurrentUserID;
}

-(void)initControllers
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //Tab:微博主页
    BBMainStatusTableViewController *weiboListTvc = [[BBMainStatusTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    weiboListTvc.title = @"Bobo";
    weiboListTvc.tabBarItem.image = [UIImage imageNamed:@"chunvzuo"];
    UINavigationController *weiboListNvc = [[UINavigationController alloc] initWithRootViewController:weiboListTvc];
    [self setupNavigationController:weiboListNvc withUITableViewController:weiboListTvc];
    
    //Tab:个人中心
    BBProfileTableViewController *profileTvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    profileTvc.title = @"Me";
    profileTvc.tabBarItem.image = [UIImage imageNamed:@"iconfont-gerenshiwu"];
    UINavigationController *profileNvc = [[UINavigationController alloc] initWithRootViewController:profileTvc];
    [self setupNavigationController:profileNvc withUITableViewController:profileTvc];
    
    //Tab:收藏微博
    BBFavoritesTableViewController *collectionTvc = [[BBFavoritesTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    collectionTvc.title = @"Favorites";
    collectionTvc.tabBarItem.image = [UIImage imageNamed:@"bb_collect_icon"];
    UINavigationController *collectionNvc = [[UINavigationController alloc] initWithRootViewController:collectionTvc];
    [self setupNavigationController:collectionNvc withUITableViewController:collectionTvc];
    
    //Tab:发微博
    BBUpdateBackgroundViewController *updateBackgroundVc = [[BBUpdateBackgroundViewController alloc] init];
    updateBackgroundVc.title = @"Post";
    updateBackgroundVc.tabBarItem.image = [UIImage imageNamed:@"post_tab_icon"];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.delegate = self;
    [tabBarController setViewControllers:@[weiboListNvc, profileNvc, collectionNvc, updateBackgroundVc] animated:YES];
    tabBarController.tabBar.barTintColor = kBarColor;
    
    //Rear:微博分组
    BBFriendsGroupTableViewController *friendsGroupTvc = [[BBFriendsGroupTableViewController alloc] init];
    friendsGroupTvc.title = @"Group";
    friendsGroupTvc.view.backgroundColor = [UIColor whiteColor];
    
    _revealViewController = [[SWRevealViewController alloc] initWithRearViewController:friendsGroupTvc frontViewController:tabBarController];
    _revealViewController.delegate = self;
    
    self.window.rootViewController = _revealViewController;
}

-(void)setupNavigationController:(UINavigationController *)uinvc withUITableViewController:(UITableViewController *)uitvc
{
    uinvc.navigationBar.barTintColor = kBarColor;
    uinvc.navigationBar.tintColor = [UIColor whiteColor];
    
    uitvc.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    uitvc.view.backgroundColor = bBGColor;
    uitvc.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UITabBarControllerDelegate

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([tabBarController.tabBar.selectedItem.title isEqualToString:@"Post"]) {
        //initialize update view here
        if (!_updateStatusView) {
            _updateStatusView = [[BBUpdateStatusView alloc] init];
        }
        _updateStatusView.nameLabel.text = _user.screen_name;
        [self.window.rootViewController.view addSubview:_updateStatusView];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _updateStatusView.frame = CGRectMake(uSmallGap, statusBarHeight+uSmallGap, bWidth-2*uSmallGap, bHeight/2-5);
            [_updateStatusView.statusTextView becomeFirstResponder];
        } completion:^(BOOL finished) {
            if (finished) {
                //what are you gonna do
            }
        }];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - WeiboSDK Helpers

-(void)updateStatusWithString:(NSString *)text
{
    if (!self.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        [WBHttpRequest requestForShareAStatus:text contatinsAPicture:nil orPictureUrl:nil withAccessToken:self.wbToken andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            NSLog(@"result: %@", result);
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _updateStatusView.frame = CGRectMake(uSmallGap, -bHeight/2, bWidth-2*uSmallGap, bHeight/2);
            } completion:^(BOOL finished) {
                if (finished) {
                    [_updateStatusView removeFromSuperview];
                    _updateStatusView = nil;
                }
            }];
        }];
    }
}

//https://api.weibo.com/2/users/show.json?uid=id_string
-(void)fetchUserProfile
{
    if (!self.isLoggedIn) {
        [[[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else
    {
        NSMutableDictionary *params = @{}.mutableCopy;
        if (self.wbToken) {
            [params setObject:self.wbToken forKey:@"access_token"];
            [params setObject:self.wbCurrentUserID forKey:@"uid"];
            NSString *url = [bWeiboDomain stringByAppendingString:@"users/show.json"];
            [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                if (!error) {
                    _user = [[User alloc] initWithDictionary:result];
                    NSLog(@"GOT USER PROFILE");
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"错误" message:@"请求用户信息失败。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"错误" message:@"用户授权令牌过期。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

-(void)startUserProfileFetch
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self fetchUserProfile];
    });
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

#pragma mark - SWRevealViewControllerDelegate

-(void)revealControllerPanGestureEnded:(SWRevealViewController *)revealController
{
    
}

-(void)revealControllerPanGestureBegan:(SWRevealViewController *)revealController
{
    
}

@end
