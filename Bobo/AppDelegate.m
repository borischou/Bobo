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
#import "BBUpdateStatusView.h"
#import "BBPhotoSelectionCollectionViewController.h"
#import "BBWaterfallStatusViewController.h"
#import "BBMessageViewController.h"

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kAppKey @"916936343"
#define bWeiboDomain @"https://api.weibo.com/2/"

#define bBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]
#define kBarColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define uSmallGap 5
#define uBigGap 10

@interface AppDelegate () <WeiboSDKDelegate, SWRevealViewControllerDelegate>

@end

@implementation AppDelegate

#pragma mark - Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self checkLoginStatus];
    [self startUserProfileFetch];
    [self initControllers];
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

+(id)delegate
{
    return [[UIApplication sharedApplication] delegate];
}

-(void)saveTokenAndUserID
{
    _isLoggedIn = YES;
    [[NSUserDefaults standardUserDefaults] setObject:@(_isLoggedIn) forKey:@"loginstatus"];
    [[NSUserDefaults standardUserDefaults] setObject:_wbToken forKey:@"wbtoken"];
    [[NSUserDefaults standardUserDefaults] setObject:_wbCurrentUserID forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)checkLoginStatus
{
    _isLoggedIn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"loginstatus"] boolValue];
    _wbToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"wbtoken"];
    _wbCurrentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSLog(@"self.wbCurrentUserID: %@\nself.wbToken: %@", _wbCurrentUserID, _wbToken);
    if (!_isLoggedIn || !_wbToken || !_wbCurrentUserID) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Auto login failed" message:@"Please login later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    return _isLoggedIn && _wbToken && _wbCurrentUserID;
}

-(void)initControllers
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //Tab:微博主页
    BBMainStatusTableViewController *weiboListTvc = [[BBMainStatusTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    weiboListTvc.title = @"Bobo";
    weiboListTvc.tabBarItem.image = [UIImage imageNamed:@"chunvzuo"];
    UINavigationController *weiboListNvc = [[UINavigationController alloc] initWithRootViewController:weiboListTvc];
    [self setupNavigationController:weiboListNvc withUIViewController:weiboListTvc];
    
    //Tab:个人中心
    BBProfileTableViewController *profileTvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    profileTvc.title = @"Me";
    profileTvc.tabBarItem.image = [UIImage imageNamed:@"iconfont-gerenshiwu"];
    UINavigationController *profileNvc = [[UINavigationController alloc] initWithRootViewController:profileTvc];
    [self setupNavigationController:profileNvc withUIViewController:profileTvc];
    
    //Tab:收藏微博
    BBFavoritesTableViewController *collectionTvc = [[BBFavoritesTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    collectionTvc.title = @"Favorites";
    collectionTvc.tabBarItem.image = [UIImage imageNamed:@"bb_collect_icon"];
    UINavigationController *collectionNvc = [[UINavigationController alloc] initWithRootViewController:collectionTvc];
    [self setupNavigationController:collectionNvc withUIViewController:collectionTvc];

    //Tab:图片墙
    BBWaterfallStatusViewController *waterfallvc = [[BBWaterfallStatusViewController alloc] init];
    waterfallvc.title = @"Waterfall";
    waterfallvc.tabBarItem.image = [UIImage imageNamed:@"tab_waterfall"];
    UINavigationController *waterfallnvc = [[UINavigationController alloc] initWithRootViewController:waterfallvc];
    [self setupNavigationController:waterfallnvc withUIViewController:waterfallvc];
    
    //Tab:消息
    BBMessageViewController *messagevc = [[BBMessageViewController alloc] init];
    messagevc.title = @"Message";
    messagevc.tabBarItem.image = [UIImage imageNamed:@"tab_icon_message"];
    UINavigationController *messagenvc = [[UINavigationController alloc] initWithRootViewController:messagevc];
    [self setupNavigationController:messagenvc withUIViewController:messagevc];

    //Tabbar
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:@[weiboListNvc, messagenvc, waterfallnvc, profileNvc, collectionNvc] animated:YES];
    tabBarController.tabBar.barTintColor = kBarColor;
    
    //Rear:微博分组
    BBFriendsGroupTableViewController *friendsGroupTvc = [[BBFriendsGroupTableViewController alloc] init];
    friendsGroupTvc.title = @"Group";
    friendsGroupTvc.view.backgroundColor = [UIColor whiteColor];
    
    _revealViewController = [[SWRevealViewController alloc] initWithRearViewController:friendsGroupTvc frontViewController:tabBarController];
    _revealViewController.delegate = self;
    
    self.window.rootViewController = _revealViewController;
}

-(void)setupNavigationController:(UINavigationController *)uinvc withUIViewController:(UIViewController *)uivc
{
    uinvc.navigationBar.barTintColor = kBarColor;
    uinvc.navigationBar.tintColor = [UIColor whiteColor];
    
    uivc.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    uivc.view.backgroundColor = bBGColor;
    
    if ([uivc isKindOfClass:[UITableViewController class]]) {
        UITableViewController *uitvc = (UITableViewController *)uivc;
        uitvc.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

#pragma mark - WeiboSDK Helpers

//https://api.weibo.com/2/users/show.json?uid=id_string
-(void)fetchUserProfile
{
    if (!_isLoggedIn) {
        [[[UIAlertView alloc] initWithTitle:@"请求用户信息失败" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else
    {
        NSMutableDictionary *params = @{}.mutableCopy;
        if (_wbToken) {
            [params setObject:_wbToken forKey:@"access_token"];
            [params setObject:_wbCurrentUserID forKey:@"uid"];
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
        _wbToken = [(WBAuthorizeResponse *)response accessToken];
        _wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
        NSLog(@"self.wbToken: %@", _wbToken);
        NSLog(@"self.wbCurrentUserID: %@", _wbCurrentUserID);
        
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

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "bankwel.CoreDataTest" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Bobo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Bobo.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end
