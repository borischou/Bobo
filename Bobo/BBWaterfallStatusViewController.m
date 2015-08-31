//
//  BBWaterfallStatusViewController.m
//  Bobo
//
//  Created by Boris Chow on 8/25/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import "CHTCollectionViewWaterfallLayout.h"
#import "BBWaterfallStatusViewController.h"
#import "SWRevealViewController.h"

#import <MJRefresh/MJRefresh.h>
#import "WeiboSDK.h"
#import "SWRevealViewController.h"

#import "BBWaterfallCollectionView.h"
#import "AppDelegate.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define bWeiboDomain @"https://api.weibo.com/2/"

@interface BBWaterfallStatusViewController () <WBHttpRequestDelegate, UICollectionViewDelegate>

@property (strong, nonatomic) BBWaterfallCollectionView *waterfallView;
@property (copy, nonatomic) NSString *max_id;
@property (copy, nonatomic) NSString *since_id;

@end

@implementation BBWaterfallStatusViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.minimumColumnSpacing = 4.0;
    layout.minimumInteritemSpacing = 4.0;
    layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst;
    _waterfallView = [[BBWaterfallCollectionView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight) collectionViewLayout:layout];
    self.view = _waterfallView;
    
    [self setMJRefresh];
    [_waterfallView.header beginRefreshing];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [_waterfallView.statuses removeAllObjects];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addSWRevealViewControllerGestureRecognizer];
    if (_waterfallView.statuses.count <= 0) {
        [_waterfallView.header beginRefreshing];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeSWRevealControllerGestureRecognizer];
    [_waterfallView.statuses removeAllObjects];
}

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

#pragma mark - Weibo support

-(void)setMJRefresh
{
    _waterfallView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchLatestStatuses];
        [self fetchApiRateLimitStatus];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchHistoryStatuses)];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    _waterfallView.footer = footer;
}

-(void)weiboRequestHandler:(WBHttpRequest *)request withResult:(id)result AndError:(NSError *)error andType:(NSString *)type
{
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请求异常" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [_waterfallView.header endRefreshing];
        [_waterfallView.footer endRefreshing];
        [alertView show];
    } else {
        if (!_waterfallView.statuses) {
            _waterfallView.statuses = @[].mutableCopy;
        }
        if ([type isEqualToString:@"refresh"]) { //下拉刷新最新微博
            NSArray *downloadedStatuses = [result objectForKey:@"statuses"];
            if (downloadedStatuses.count > 0) {
                for (int i = 0; i < [downloadedStatuses count]; i ++) {
                    Status *tmp_status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
                    [_waterfallView.statuses insertObject:tmp_status atIndex:i];
                    if ([downloadedStatuses count] - 1 == i) {
                        _max_id = tmp_status.idstr;
                    }
                }
                Status *status = [[Status alloc] initWithDictionary:[downloadedStatuses objectAtIndex:0]];
                _since_id = status.idstr;
            }
            if (_waterfallView.statuses.count <= 8) {
                [self fetchHistoryStatuses];
            }
            [_waterfallView.header endRefreshing];
        }
        
        if ([type isEqualToString:@"history"]) { //上拉刷新历史微博
            NSArray *historyStatuses = [result objectForKey:@"statuses"];
            if (historyStatuses.count > 0) {
                for (int i = 1; i < [historyStatuses count]; i ++) {
                    Status *tmp_status = [[Status alloc] initWithDictionary:historyStatuses[i]];
                    [_waterfallView.statuses addObject:tmp_status];
                    if ([historyStatuses count] - 1 == i) {
                        _max_id = tmp_status.idstr;
                    }
                }
            }
            [_waterfallView.footer endRefreshing];
        }
        [_waterfallView reloadData];
        NSLog(@"The currentLastStatusId is: %@", _max_id);
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
    AppDelegate *delegate = [AppDelegate delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [_waterfallView.header endRefreshing];
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
    AppDelegate *delegate = [AppDelegate delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [_waterfallView.footer endRefreshing];
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

@end
