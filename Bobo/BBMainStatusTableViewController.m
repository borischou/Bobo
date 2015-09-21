//
//  BBWeiboListTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "WeiboSDK.h"
#import "SWRevealViewController.h"
#import "Utils.h"
#import "BBMainStatusTableViewController.h"
#import "BBStatusDetailViewController.h"
#import "BBButtonbarTableViewCell.h"
#import "BBStatusTableViewCell.h"
#import "BBUpdateStatusView.h"
#import "AppDelegate.h"
#import "BBNetworkUtils.h"
#import "UIButton+Bobtn.h"
#import "NSString+Convert.h"
#import "Status.h"
#import "User.h"

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

static NSString *reuseIdentifier = @"reuseCell";
static NSString *reuseBarCellId = @"barCell";

@interface BBMainStatusTableViewController () <WBHttpRequestDelegate>

@property (copy, nonatomic) NSString *max_id;
@property (copy, nonatomic) NSString *since_id;
@property (copy, nonatomic) NSMutableArray *statuses;
@property (strong, nonatomic) ACAccount *weiboAccount;

@end

@implementation BBMainStatusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
    [self setNavBarBtn];
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

-(void)setNavBarBtn
{
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
    } completion:^(BOOL finished) {
        if (finished) {
            //what are you gonna do
        }
    }];
}

#pragma mark - WBHttpRequestDelegate & Helpers

-(void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    [[[UIAlertView alloc] initWithTitle:@"WBHttpRequestDelegate" message:[NSString stringWithFormat:@"didFinishLoadingWithResult: %@", result] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"WBHttpRequestDelegate" message:[NSString stringWithFormat:@"didFailWithError: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchLatestStatuses];
        //[self fetchApiRateLimitStatus];
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
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        [[[UIAlertView alloc] initWithTitle:@"请求异常" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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

-(void)fetchApiRateLimitStatus
{
    AppDelegate *delegate = [AppDelegate delegate];
    NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
    if (delegate.wbToken) {
        [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
        NSString *url;
        
        url = [bWeiboDomain stringByAppendingString:@"account/rate_limit_status.json"];
        
        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            NSDictionary *resultDic = result;
            NSLog(@"访问情况：%@", resultDic.description);
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"出错了" message:@"您未登录微博授权，请先登录。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

-(void)fetchLatestStatuses
{
    NSString *url;
    if (!_since_id) {
        url = @"statuses/home_timeline.json";
    } else {
        url = [NSString stringWithFormat:@"statuses/home_timeline.json?since_id=%@", _since_id];
    }
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:url SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [self weiboRequestHandler:nil withResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] AndError:nil andType:@"refresh"];
    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableView.header endRefreshing];
    }];
//    AppDelegate *delegate = [AppDelegate delegate];
//    if (!delegate.isLoggedIn) {
//        [self.tableView.header endRefreshing];
//        [[[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    } else {
//        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
//        if (delegate.wbToken) {
//            [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
//            NSString *url;
//            if (!_since_id) {
//                url = [bWeiboDomain stringByAppendingString:@"statuses/home_timeline.json"];
//            } else {
//                url = [bWeiboDomain stringByAppendingFormat:@"statuses/home_timeline.json?since_id=%@", _since_id];
//            }
//            NSLog(@"The full url for latest statuses is: %@", url);
//            [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
//                [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"refresh"];
//            }];
//        } else {
//            [[[UIAlertView alloc] initWithTitle:@"出错了" message:@"您未登录微博授权，请先登录。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        }
//    }
}

-(void)fetchHistoryStatuses
{
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:[NSString stringWithFormat:@"statuses/home_timeline.json?max_id=%@&count=20", _max_id] SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [self weiboRequestHandler:nil withResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] AndError:nil andType:@"history"];
    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableView.footer endRefreshing];
    }];
//    AppDelegate *delegate = [AppDelegate delegate];
//    if (!delegate.isLoggedIn) {
//        [self.tableView.footer endRefreshing];
//        [[[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    } else {
//        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
//        [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
//        NSString *para = [NSString stringWithFormat:@"max_id=%@&count=20", _max_id];
//        NSString *url = [bWeiboDomain stringByAppendingFormat:@"statuses/home_timeline.json?%@", para];
//        NSLog(@"The full url for history statuses is: %@", url);
//        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
//            [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"history"];
//        }];
//    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (fabs(targetContentOffset->y+bHeight-self.tableView.contentSize.height) <= 250) {
        [self fetchHistoryStatuses];
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
        Status *status = [self.statuses objectAtIndex:indexPath.section];
        cell.status = status;
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
    BBStatusDetailViewController *dtvc = [[BBStatusDetailViewController alloc] init];
    dtvc.title = @"Detail";
    dtvc.hidesBottomBarWhenPushed = YES;
    Status *status = [_statuses objectAtIndex:indexPath.section];
    dtvc.status = status;
    [self.navigationController pushViewController:dtvc animated:YES];
}

@end
