//
//  BBWeiboListTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import "WeiboSDK.h"
#import "SWRevealViewController.h"

#import "BBMainStatusTableViewController.h"
#import "BBStatusTableViewCell.h"
#import "BBStatusDetailTableViewController.h"
#import "AppDelegate.h"
#import "BBButtonbarTableViewCell.h"
#import "BBNetworkUtils.h"
#import "UIButton+Bobtn.h"
#import "NSString+Convert.h"
#import "User.h"
#import "Status.h"

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kAppKey @"916936343"
#define bWeiboDomain @"https://api.weibo.com/2/"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnHeight bHeight/25

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

static NSString *reuseIdentifier = @"reuseCell";
static NSString *reuseBarCellId = @"barCell";

@interface BBMainStatusTableViewController () <WBHttpRequestDelegate>

@property (copy, nonatomic) NSString *max_id;
@property (copy, nonatomic) NSString *since_id;
@property (copy, nonatomic) NSMutableArray *statuses;

@end

@implementation BBMainStatusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setMJRefresh];
    [self.tableView.header beginRefreshing];
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

#pragma mark - WBHttpRequestDelegate & Helpers

-(void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"WBHttpRequestDelegate" message:[NSString stringWithFormat:@"didFinishLoadingWithResult: %@", result] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"WBHttpRequestDelegate" message:[NSString stringWithFormat:@"didFailWithError: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchLatestStatuses];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchHistoryStatuses)];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
}

-(void)weiboRequestHandler:(WBHttpRequest *)request withResult:(id)result AndError:(NSError *)error andType:(NSString *)type
{
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请求异常" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        [alertView show];
    } else {
        if (!_statuses) {
            _statuses = @[].mutableCopy;
        }
        if ([type isEqualToString:@"refresh"]) { //下拉刷新最新微博
            NSArray *downloadedStatuses = [result objectForKey:@"statuses"];
            if (downloadedStatuses.count > 0) {
                for (int i = 0; i < [downloadedStatuses count]; i ++) {
                    Status *tmp_status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
                    [_statuses insertObject:tmp_status atIndex:i];
                    if ([downloadedStatuses count] - 1 == i) {
                        _max_id = tmp_status.idstr;
                    }
                }
                Status *status = [[Status alloc] initWithDictionary:[downloadedStatuses objectAtIndex:0]];
                _since_id = status.idstr;
            }
            [self.tableView.header endRefreshing];
        }
        
        if ([type isEqualToString:@"history"]) { //上拉刷新历史微博
            NSArray *historyStatuses = [result objectForKey:@"statuses"];
            if (historyStatuses.count > 0) {
                for (int i = 1; i < [historyStatuses count]; i ++) {
                    Status *tmp_status = [[Status alloc] initWithDictionary:historyStatuses[i]];
                    [_statuses addObject:tmp_status];
                    if ([historyStatuses count] - 1 == i) {
                        _max_id = tmp_status.idstr;
                    }
                }
            }
            [self.tableView.footer endRefreshing];
        }
        NSLog(@"The currentLastStatusId is: %@", _max_id);
        [self.tableView reloadData];
    }
}

-(void)fetchLatestStatuses
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.tableView.header endRefreshing];
        [alertView show];
    } else {
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        if (delegate.wbToken) {
            [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
            NSString *url;
            if (!_since_id) {
                url = [bWeiboDomain stringByAppendingString:@"statuses/home_timeline.json"];
            } else {
                url = [bWeiboDomain stringByAppendingFormat:@"statuses/home_timeline.json?since_id=%@", _since_id];
            }
            NSLog(@"The full url for latest statuses is: %@", url);
            [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"refresh"];
            }];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"出错了" message:@"您未登录微博授权，请先登录。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

-(void)fetchHistoryStatuses
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.tableView.footer endRefreshing];
        [alertView show];
    } else {
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
        NSString *para = [NSString stringWithFormat:@"max_id=%@&count=20", _max_id];
        NSString *url = [bWeiboDomain stringByAppendingFormat:@"statuses/home_timeline.json?%@", para];
        NSLog(@"The full url for history statuses is: %@", url);
        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"history"];
        }];
    }
}

#pragma mark - Table view data source & delegate & Helpers

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if ([_statuses count]) {
        return [_statuses count];
    } else return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[BBStatusTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    BBStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([_statuses count]) {
        if (!cell.status) {
            Status *status = [self.statuses objectAtIndex:indexPath.section];
            cell.status = status;
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_statuses count]) {
        Status *status = [_statuses objectAtIndex:indexPath.section];
        return status.height;
    }
    else
    {
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBStatusDetailTableViewController *dtvc = [[BBStatusDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    dtvc.title = @"Detail";
    dtvc.hidesBottomBarWhenPushed = YES;
    Status *status = [_statuses objectAtIndex:indexPath.section];
    dtvc.status = status;
    [self.navigationController pushViewController:dtvc animated:YES];
}

@end
