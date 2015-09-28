//
//  BBProfileTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/22.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import <UIImageView+WebCache.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <AFNetworking.h>
#import <SafariServices/SafariServices.h>

#import "SWRevealViewController.h"
#import "BBUpdateStatusView.h"
#import "BBProfileTableViewController.h"
#import "BBStatusDetailViewController.h"
#import "BBCountTableViewCell.h"
#import "AppDelegate.h"
#import "BBProfileHeaderView.h"
#import "BBStatusTableViewCell.h"
#import "BBImageBrowserView.h"
#import "BBButtonbarTableViewCell.h"
#import "NSString+Convert.h"
#import "UIButton+Bobtn.h"
#import "Utils.h"

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kAppKey @"916936343"
#define bWeiboDomain @"https://api.weibo.com/2/"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnHeight bHeight/25
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define uSmallGap 5
#define uBigGap 10

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

static NSString *reuseCountsCell = @"countsCell";

@interface BBProfileTableViewController () <BBStatusTableViewCellDelegate, BBCountTableViewCellDelegate>

@property (copy, nonatomic) NSString *currentLastStatusId;
@property (strong, nonatomic) ACAccount *weiboAccount;

@end

@implementation BBProfileTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
    if (_shouldNavBtnShown) {
        [self setNavBarBtn];
    }
    if (_user) {
        self.tableView.tableHeaderView = [self getAvatarView];
    }
    _currentLastStatusId = [self lastIdFromStatuses:_statuses];
    [self setMJRefresh];
    if (!_statuses || _statuses.count <= 0) {
        [self.tableView.header beginRefreshing];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeSomething) name:@"bobo" object:nil];
}

#pragma mark - Helpers

-(void)setNavBarBtn
{
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(0, 0, 23, 23);
    [loginBtn setImage:[UIImage imageNamed:@"iconfont-denglu"] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *loginbarbtn = [[UIBarButtonItem alloc] initWithCustomView:loginBtn];
    self.navigationItem.leftBarButtonItem = loginbarbtn;
    
    UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    postBtn.frame = CGRectMake(0, 0, 23, 23);
    [postBtn setImage:[UIImage imageNamed:@"barbutton_icon_post"] forState:UIControlStateNormal];
    [postBtn addTarget:self action:@selector(postBarbuttonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *postBarBtn = [[UIBarButtonItem alloc] initWithCustomView:postBtn];
    self.navigationItem.rightBarButtonItem = postBarBtn;
}

#pragma mark - UIButtons

-(void)postBarbuttonPressed
{
    AppDelegate *delegate = [AppDelegate delegate];
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:0]; //0: 发微博
    updateStatusView.nameLabel.text = delegate.user.screen_name;
    [delegate.window addSubview:updateStatusView];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        updateStatusView.frame = CGRectMake(uSmallGap, statusBarHeight+uSmallGap, bWidth-2*uSmallGap, bHeight/2-5);
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {}];
}

-(void)loginBtnPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bobo" object:self];
    //获取系统账号数据库中的新浪微博账号数据
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *type = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
    NSArray *accounts = [store accountsWithAccountType:type];
    _weiboAccount = accounts.firstObject;
    _uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    
    //若未授权则向用户申请授权
    if (_weiboAccount.accountType.accessGranted == NO) {
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
                    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"error: %@", error);
                    }];
                }
            } else {
                NSLog(@"授权失败, 错误: %@", error);
                [Utils presentNotificationWithText:@"授权失败"];
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
            } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error: %@", error);
                [Utils presentNotificationWithText:@"更新失败"];
            }];
        } else {
            UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"已登录" message:@"您已授权并登录微博" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"OK action triggered.");
            }];
            [alertcontroller addAction:action];
            [self presentViewController:alertcontroller animated:YES completion:^{}];
        }
    }
}

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchUserProfile];
        [self fetchUserLatestStatuses];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchUserHistoryStatuses)];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
}

-(UIView *)getAvatarView
{
    BBProfileHeaderView *avatarView = [[BBProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight/3.5)];
    avatarView.user = _user;
    
    return avatarView;
}

-(void)observeSomething
{
    NSLog(@"Notification Center usage: Profile view controller which registered 'bobo' to be the notification sender's name just observed that the button 'login' registered as 'bobo' in WeiboList view controller was pressed once.");
}

#pragma mark - Fetch requests

//https://api.weibo.com/2/users/show.json?uid=id_string
-(void)fetchUserProfile
{
    if (!_uid) {
        AppDelegate *delegate = [AppDelegate delegate];
        if (delegate.uid || delegate.user.idstr) {
            [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"users/show.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:@{@"uid": _uid} completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSError *error = nil;
                [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] type:@"show"];
            } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
                [Utils presentNotificationWithText:@"更新失败"];
                [self.tableView.header endRefreshing];
            }];
        } else {
            [self.tableView.header endRefreshing];
            NSLog(@"没有有效的uid。");
        }
    } else {
        [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"users/show.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:@{@"uid": _uid} completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error = nil;
            [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] type:@"show"];
        } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
            [Utils presentNotificationWithText:@"更新失败"];
            [self.tableView.header endRefreshing];
        }];
    }
}

//https://api.weibo.com/2/statuses/user_timeline.json?uid=id_string
-(void)fetchUserLatestStatuses
{
    if (!_uid) {
        return;
    }
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"statuses/user_timeline.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:@{@"uid": _uid} completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] type:@"latest"];
    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        [Utils presentNotificationWithText:@"更新失败"];
        [self.tableView.header endRefreshing];
    }];
}

//https://api.weibo.com/2/statuses/user_timeline.json?count=count_num&max_id=id_string
-(void)fetchUserHistoryStatuses
{
    if (!_uid) {
        return;
    }
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"statuses/user_timeline.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:@{@"uid": _uid, @"count": @"5", @"max_id": _currentLastStatusId} completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] type:@"history"];
    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"profile footer error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        [Utils presentNotificationWithText:@"更新失败"];
        [self.tableView.footer endRefreshing];
    }];
}

#pragma mark - Helpers

-(void)handleWeiboResult:(id)result type:(NSString *)type
{
    if ([type isEqualToString:@"show"]) {
        [self.tableView.header endRefreshing];
        _user = [[User alloc] initWithDictionary:result];
        self.tableView.tableHeaderView = [self getAvatarView];
    }
    
    NSMutableArray *downloadedStatuses = [result objectForKey:@"statuses"];
    if (!_statuses) {
        _statuses = @[].mutableCopy;
    }
    if ([type isEqualToString:@"latest"]) {
        if (downloadedStatuses.count > 0) {
            _statuses = nil;
            _statuses = @[].mutableCopy;
            for (int i = 0; i < downloadedStatuses.count; i ++) {
                Status *status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
                [_statuses addObject:status];
            }
        }
    }
    if ([type isEqualToString:@"history"]) {
        for (int i = 1; i < downloadedStatuses.count; i ++) {
            Status *status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
            [_statuses addObject:status];
        }
    }
    
    _currentLastStatusId = [self lastIdFromStatuses:_statuses];
        
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    [self.tableView reloadData];
}

-(User *)getUserProfile
{
    AppDelegate *delegate = [AppDelegate delegate];
    return delegate.user;
}

-(NSString *)lastIdFromStatuses:(NSMutableArray *)statuses
{
    Status *lastOne = statuses.lastObject;
    return lastOne.idstr;
}

#pragma mark - UITableView delegate & data source & Helpers

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [tableView registerClass:[BBCountTableViewCell class] forCellReuseIdentifier:reuseCountsCell];
        BBCountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCountsCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.user = _user;
        cell.delegate = self;
        return cell;
    }
    else
    {
        [tableView registerClass:[BBStatusTableViewCell class] forCellReuseIdentifier:@"home"];
        BBStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"home" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([_statuses count]) {
            if ([_statuses count]) {
                Status *status = [self.statuses objectAtIndex:indexPath.section-1];
                cell.status = status;
                cell.delegate = self;
            }
        }
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return bHeight/10;
    }
    else
    {
        Status *status = [_statuses objectAtIndex:indexPath.section-1];
        return status.height;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= 1) {
        BBStatusDetailViewController *dtvc = [[BBStatusDetailViewController alloc] init];
        dtvc.title = @"Detail";
        dtvc.hidesBottomBarWhenPushed = YES;
        dtvc.status = [_statuses objectAtIndex:indexPath.section-1];
        [self.navigationController pushViewController:dtvc animated:YES];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_statuses count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}

-(void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

#pragma mark - BBStatusTableViewCellDelegate & support

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapAvatar:(UIImageView *)avatar
{
    NSLog(@"didTapAvatar");
    NSDictionary *params = @{@"uid": cell.status.user.idstr};
    [Utils genericWeiboRequestWithAccount:[[AppDelegate delegate] defaultAccount]
                                      URL:@"statuses/user_timeline.json"
                      SLRequestHTTPMethod:SLRequestMethodGET
                               parameters:params
               completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSMutableArray *statuses = [Utils statusesWith:responseObject];
         Status *status = statuses.firstObject;
         User *user = status.user;
         
         BBProfileTableViewController *profiletvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
         profiletvc.uid = user.idstr;
         profiletvc.statuses = statuses;
         profiletvc.user = user;
         profiletvc.shouldNavBtnShown = NO;
         profiletvc.title = @"Profile";
         profiletvc.hidesBottomBarWhenPushed = YES;
         [Utils setupNavigationController:self.navigationController withUIViewController:profiletvc];
         [self.navigationController pushViewController:profiletvc animated:YES];
     }
               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error %@", error);
         [Utils presentNotificationWithText:@"访问失败"];
     }];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapCommentIcon:(UIImageView *)commentIcon
{
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:1]; //写评论
    updateStatusView.idStr = cell.status.idstr;
    updateStatusView.nameLabel.text = cell.status.user.screen_name;
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:updateStatusView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        updateStatusView.frame = CGRectMake(uSmallGap, statusBarHeight+uSmallGap, bWidth-2*uSmallGap, bHeight/2-5);
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {}];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapFavoriteIcon:(UIImageView *)favoriteIcon
{
    if (cell.status.favorited) {
        [favoriteIcon setImage:[UIImage imageNamed:@"fav_icon_3"]];
        NSDictionary *params = @{@"id": cell.status.idstr};
        [Utils weiboPostRequestWithAccount:[[AppDelegate delegate] defaultAccount] URL:@"favorites/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSLog(@"response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                [cell.status setFavorited:NO];
                [Utils presentNotificationWithText:@"删除成功"];
            }
            else {
                NSLog(@"收藏删除失败: %@", error);
                [Utils presentNotificationWithText:@"删除失败"];
            }
        }];
    }
    else
    {
        [favoriteIcon setImage:[UIImage imageNamed:@"faved_icon"]];
        NSDictionary *params = @{@"id": cell.status.idstr};
        [Utils weiboPostRequestWithAccount:[[AppDelegate delegate] defaultAccount] URL:@"favorites/create.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSLog(@"response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                [cell.status setFavorited:YES];
                [Utils presentNotificationWithText:@"收藏成功"];
            }
            else {
                NSLog(@"收藏失败: %@", error);
                [Utils presentNotificationWithText:@"收藏失败"];
            }
        }];
    }
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetIcon:(UIImageView *)retweetIcon
{
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:2]; //转发
    updateStatusView.idStr = cell.status.idstr;
    updateStatusView.nameLabel.text = @"转发";
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:updateStatusView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        updateStatusView.frame = CGRectMake(uSmallGap, statusBarHeight+uSmallGap, bWidth-2*uSmallGap, bHeight/2-5);
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {}];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetView:(UIView *)retweetView
{
    BBStatusDetailViewController *dtvc = [[BBStatusDetailViewController alloc] init];
    dtvc.title = @"Detail";
    dtvc.hidesBottomBarWhenPushed = YES;
    dtvc.status = cell.status.retweeted_status;
    
    [self.navigationController pushViewController:dtvc animated:YES];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell statusPictureTapped:(UITapGestureRecognizer *)tap
{
    NSMutableArray *largeUrls = @[].mutableCopy;
    for (NSString *str in cell.status.pic_urls) {
        [largeUrls addObject:[NSString middlePictureUrlConvertedFromThumbUrl:str]];
    }
    [self setImageBrowserWithImageUrls:largeUrls andTappedViewTag:tap.view.tag];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell retweetPictureTapped:(UITapGestureRecognizer *)tap
{
    NSMutableArray *largeUrls = @[].mutableCopy;
    for (NSString *str in cell.status.retweeted_status.pic_urls) {
        [largeUrls addObject:[NSString middlePictureUrlConvertedFromThumbUrl:str]];
    }
    [self setImageBrowserWithImageUrls:largeUrls andTappedViewTag:tap.view.tag];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapHotword:(NSString *)hotword
{
    NSLog(@"点击%@", hotword);
    if ([hotword hasPrefix:@"@"]) {
        NSDictionary *params = @{@"screen_name": [hotword substringFromIndex:1]};
        [Utils genericWeiboRequestWithAccount:[[AppDelegate delegate] defaultAccount]
                                          URL:@"statuses/user_timeline.json"
                          SLRequestHTTPMethod:SLRequestMethodGET
                                   parameters:params
                   completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSMutableArray *statuses = [Utils statusesWith:responseObject];
             Status *status = statuses.firstObject;
             User *user = status.user;
             
             BBProfileTableViewController *profiletvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
             [Utils setupNavigationController:self.navigationController withUIViewController:profiletvc];
             profiletvc.uid = user.idstr;
             profiletvc.statuses = statuses;
             profiletvc.user = user;
             profiletvc.shouldNavBtnShown = NO;
             profiletvc.title = @"Profile";
             profiletvc.hidesBottomBarWhenPushed = YES;
             [self.navigationController pushViewController:profiletvc animated:YES];
         }
                   completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"error %@", error);
             [Utils presentNotificationWithText:@"访问失败"];
         }];
    }
    if ([hotword hasPrefix:@"http"]) {
        //打开webview
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:hotword]];
        [self.navigationController presentViewController:sfvc animated:YES completion:^{}];
    }
    if ([hotword hasPrefix:@"#"]) {
        //热门话题
    }
}

-(void)setImageBrowserWithImageUrls:(NSMutableArray *)urls andTappedViewTag:(NSInteger)tag
{
    BBImageBrowserView *browserView = [[BBImageBrowserView alloc] initWithFrame:[UIScreen mainScreen].bounds withImageUrls:urls andImageTag:tag];
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:browserView];
}

#pragma mark - BBCountTableViewCellDelegate

-(void)tableViewCell:(BBCountTableViewCell *)cell didTapTodoImageViewWithTapGesture:(UITapGestureRecognizer *)tap
{
    UIImageView *imageView = (UIImageView *)tap.view;
    AppDelegate *delegate = [AppDelegate delegate];
    ACAccount *account = [delegate defaultAccount];
    
    if ([imageView.image isEqual:[UIImage imageNamed:@"settings_icon"]])
    {
        NSLog(@"settings");
        //个人设置
    }
    if ([imageView.image isEqual:[UIImage imageNamed:@"following_icon"]]
        || [imageView.image isEqual:[UIImage imageNamed:@"friend_icon"]])
    {
        NSLog(@"following");
        //取关
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"取消关注" message:@"您是否确定取消关注此用户？" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消关注" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSDictionary *params = @{@"uid": _user.idstr};
            [Utils weiboPostRequestWithAccount:account URL:@"friendships/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (!error) {
                    NSLog(@"success");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_user setFollowing:NO];
                        [cell setNeedsLayout];
                    });
                } else {
                    NSLog(@"error: %@", error);
                    [Utils presentNotificationWithText:@"取关失败"];
                }
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"继续关注" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alertController addAction:action];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:^{}];
    }
    if ([imageView.image isEqual:[UIImage imageNamed:@"follow_icon"]])
    {
        NSLog(@"follow");
        //关注
        NSDictionary *params = @{@"uid": _user.idstr};
        [Utils weiboPostRequestWithAccount:account URL:@"friendships/create.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSLog(@"success");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_user setFollowing:YES];
                    [cell setNeedsLayout];
                });
            } else {
                NSLog(@"error: %@", error);
                [Utils presentNotificationWithText:@"关注失败"];
            }
        }];
    }
}

@end
