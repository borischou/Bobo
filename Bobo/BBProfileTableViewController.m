//
//  BBProfileTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/22.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import <UIImageView+WebCache.h>
#import "SWRevealViewController.h"

#import "BBProfileTableViewController.h"
#import "BBCountTableViewCell.h"
#import "AppDelegate.h"
#import "WeiboSDK.h"
#import "BBMeHeaderView.h"
#import "BBStatusTableViewCell.h"
#import "BBNetworkUtils.h"
#import "BBImageBrowserView.h"
#import "BBButtonbarTableViewCell.h"
#import "BBStatusDetailTableViewController.h"
#import "NSString+Convert.h"
#import "UIButton+Bobtn.h"

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kAppKey @"916936343"
#define bWeiboDomain @"https://api.weibo.com/2/"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnHeight bHeight/25

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

static NSString *reuseCountsCell = @"countsCell";

@interface BBProfileTableViewController () <WBHttpRequestDelegate, BBImageBrowserProtocol, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *statuses;
@property (copy, nonatomic) NSString *currentLastStatusId;
@property (strong, nonatomic) UIAlertView *logoutAlertView;

@end

@implementation BBProfileTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavBarBtn];
    [self setMJRefresh];
    [self.tableView.header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeSomething) name:@"bobo" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addSWRevealViewControllerGestureRecognizer];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeSWRevealControllerGestureRecognizer];
}

#pragma mark - Helpers

-(void)addSWRevealViewControllerGestureRecognizer
{
    [self.view addGestureRecognizer:[self.revealViewController panGestureRecognizer]];
    [self.view addGestureRecognizer:[self.revealViewController tapGestureRecognizer]];
}

-(void)removeSWRevealControllerGestureRecognizer
{
    [self.view removeGestureRecognizer:[self.revealViewController panGestureRecognizer]];
    [self.view removeGestureRecognizer:[self.revealViewController tapGestureRecognizer]];
}

-(void)setNavBarBtn
{
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(0, 0, 23, 23);
    [button1 setImage:[UIImage imageNamed:@"iconfont-denglu"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(loginBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *loginBtn = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.leftBarButtonItem = loginBtn;
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(0, 0, 23, 23);
    [button2 setImage:[UIImage imageNamed:@"iconfont-logout"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(logoutBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *logoutBtn = [[UIBarButtonItem alloc] initWithCustomView:button2];
    self.navigationItem.rightBarButtonItem = logoutBtn;
}

-(void)loginBtnPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bobo" object:self];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"isLoggedIn: %d\ndelegate.wbCurrentUserID: %@\ndelegate.wbToken: %@", delegate.isLoggedIn, delegate.wbCurrentUserID, delegate.wbToken);
    if (!delegate.isLoggedIn || !delegate.wbCurrentUserID || !delegate.wbToken) {
        [WeiboSDK enableDebugMode:YES];
        [WeiboSDK registerApp:kAppKey];
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = kRedirectURI;
        request.scope = @"all";
        [WeiboSDK sendRequest:request];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Logged in" message:@"You are logged in already." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)logoutBtnPressed
{
    self.logoutAlertView = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to log it out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
    [self.logoutAlertView show];
}

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (!_user) {
            [self fetchUserProfile];
        }
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
    BBMeHeaderView *avatarView = [[BBMeHeaderView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight/3.5)];
    [avatarView.avatarView sd_setImageWithURL:[NSURL URLWithString:_user.avatar_large] placeholderImage:[UIImage imageNamed:@"bb_holder_profile_image"]];
    avatarView.name.text = _user.screen_name;
    
    return avatarView;
}

-(void)observeSomething
{
    NSLog(@"Notification Center usage: Profile view controller which registered 'bobo' to be the notification sender's name just observed that the button 'login' registered as 'bobo' in WeiboList view controller was pressed once.");
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.logoutAlertView]) {
        if (1 == buttonIndex) {
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [WeiboSDK logOutWithToken:delegate.wbToken delegate:self withTag:@"user1"];
            delegate.isLoggedIn = NO;
            [[NSUserDefaults standardUserDefaults] setValue:@(delegate.isLoggedIn) forKey:@"loginstatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark - Fetch requests

//https://api.weibo.com/2/users/show.json?uid=id_string
-(void)fetchUserProfile
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        [[[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else
    {
        NSMutableDictionary *params = @{}.mutableCopy;
        if (delegate.wbToken) {
            [params setObject:delegate.wbToken forKey:@"access_token"];
            [params setObject:delegate.wbCurrentUserID forKey:@"uid"];
            NSString *url = [bWeiboDomain stringByAppendingString:@"users/show.json"];
            [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"show"];
            }];
        }
        else
        {
            [self.tableView.header endRefreshing];
        }
    }
}

//https://api.weibo.com/2/statuses/user_timeline.json?uid=id_string
-(void)fetchUserLatestStatuses
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        [[[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else
    {
        NSMutableDictionary *params = @{}.mutableCopy;
        [params setObject:delegate.wbToken forKey:@"access_token"];
        [params setObject:delegate.wbCurrentUserID forKey:@"uid"];
        NSString *url = [bWeiboDomain stringByAppendingString:@"statuses/user_timeline.json"];
        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"me"];
        }];
    }
}

//https://api.weibo.com/2/statuses/user_timeline.json?count=count_num&max_id=id_string
-(void)fetchUserHistoryStatuses
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        [[[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else
    {
        NSMutableDictionary *params = @{}.mutableCopy;
        [params setObject:delegate.wbToken forKey:@"access_token"];
        NSString *para = [NSString stringWithFormat:@"count=5&max_id=%@", _currentLastStatusId];
        NSString *url = [bWeiboDomain stringByAppendingFormat:@"statuses/user_timeline.json?%@", para];
        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"history"];
        }];
    }
}

#pragma mark - Helpers

-(void)weiboRequestHandler:(WBHttpRequest *)request withResult:(id)result AndError:(NSError *)error andType:(NSString *)type
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
    if ([type isEqualToString:@"me"]) {
        for (int i = 0; i < downloadedStatuses.count; i ++) {
            Status *status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
            [_statuses insertObject:status atIndex:i];
        }
    }
    if ([type isEqualToString:@"history"]) {
        for (int i = 1; i < downloadedStatuses.count; i ++) {
            Status *status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
            [_statuses addObject:status];
        }
    }
    
    Status *lastOne = _statuses.lastObject;
    if (lastOne.idstr) {
        _currentLastStatusId = lastOne.idstr;
    }
    
    NSLog(@"CURRENT LAST STATUS ID: %@", _currentLastStatusId);
    
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    [self.tableView reloadData];
}

-(User *)getUserProfile
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.user;
}

#pragma mark - BBImageBrowserProtocol

-(void)setImageBrowserWithImageUrls:(NSMutableArray *)urls andTappedViewTag:(NSInteger)tag
{
    BBImageBrowserView *browserView = [[BBImageBrowserView alloc] initWithFrame:[UIScreen mainScreen].bounds withImageUrls:urls andImageTag:tag];
    [self.view.window addSubview:browserView];
}

#pragma mark - UITableView delegate & data source & Helpers

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [tableView registerClass:[BBCountTableViewCell class] forCellReuseIdentifier:reuseCountsCell];
        BBCountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCountsCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.wbcounts.text = [NSString stringWithFormat:@"%ld", _user.statuses_count];
        cell.followercounts.text = [NSString stringWithFormat:@"%ld", _user.followers_count];
        cell.friendcounts.text = [NSString stringWithFormat:@"%ld", _user.friends_count];
        return cell;
    }
    else
    {
        if (indexPath.row == 0) {
            [tableView registerClass:[BBStatusTableViewCell class] forCellReuseIdentifier:@"home"];
            BBStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"home" forIndexPath:indexPath];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([_statuses count]) {
                Status *status = [self.statuses objectAtIndex:indexPath.section-1];
                cell.status = status;
            }
            return cell;
        }
        else
        {
            [tableView registerClass:[BBButtonbarTableViewCell class] forCellReuseIdentifier:@"buttonBar"];
            BBButtonbarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buttonBar" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self setStatusButtonBarDataForCell:cell IndexPath:indexPath];
            return cell;
        }
    }
}

-(void)setStatusButtonBarDataForCell:(BBButtonbarTableViewCell *)cell IndexPath:(NSIndexPath *)indexPath
{
    if ([_statuses count]) {
        Status *status = [_statuses objectAtIndex:indexPath.section-1];
        if (status.reposts_count > 0) {
            [cell.repostBtn setTitle:[NSString stringWithFormat:@"%@re", [NSString getNumStrFrom:status.reposts_count]] withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
        } else {
            [cell.repostBtn setTitle:@"Repost" withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
        }
        if (status.comments_count > 0) {
            [cell.commentBtn setTitle:[NSString stringWithFormat:@"%@ comts", [NSString getNumStrFrom:status.comments_count]] withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
        } else {
            [cell.commentBtn setTitle:@"Comment" withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];            }
        if (status.attitudes_count > 0) {
            [cell.likeBtn setTitle:[NSString stringWithFormat:@"%@ likes", [NSString getNumStrFrom:status.attitudes_count]] withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
        } else {
            [cell.likeBtn setTitle:@"Like" withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return bHeight/10;
    } else
    {
        if (indexPath.row == 0) {
            Status *status = [_statuses objectAtIndex:indexPath.section-1];
            return status.height;
        } else {
            return bBtnHeight;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBStatusDetailTableViewController *dtvc = [[BBStatusDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    dtvc.title = @"Detail";
    dtvc.hidesBottomBarWhenPushed = YES;
    dtvc.status = [_statuses objectAtIndex:indexPath.section-1];
    [self.navigationController pushViewController:dtvc animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return 2;
    }
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

@end
