//
//  BBWaterfallStatusViewController.m
//  Bobo
//
//  Created by Boris Chow on 8/25/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import "CHTCollectionViewWaterfallLayout.h"
#import "BBWaterfallStatusViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Utils.h"
#import "WeiboSDK.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "BBWaterfallCollectionView.h"
#import "BBUpdateStatusView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define uSmallGap 5
#define uBigGap 10

#define bWeiboDomain @"https://api.weibo.com/2/"

@interface BBWaterfallStatusViewController () <WBHttpRequestDelegate, UICollectionViewDelegate>

@property (strong, nonatomic) BBWaterfallCollectionView *waterfallView;
@property (copy, nonatomic) NSString *max_id;
@property (copy, nonatomic) NSString *since_id;
@property (strong, nonatomic) ACAccount *weiboAccount;

@end

@implementation BBWaterfallStatusViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _weiboAccount = [Utils systemAccounts].firstObject;
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.minimumColumnSpacing = 4.0;
    layout.minimumInteritemSpacing = 4.0;
    layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst;
    _waterfallView = [[BBWaterfallCollectionView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight) collectionViewLayout:layout];
    self.view = _waterfallView;
    [self setNavBarBtn];
    [self setMJRefresh];
    [_waterfallView.header beginRefreshing];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [_waterfallView.statuses removeAllObjects];
    [_waterfallView.header beginRefreshing];
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
//    [_waterfallView.statuses removeAllObjects];
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

#pragma mark - Weibo support

-(void)setMJRefresh
{
    _waterfallView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchLatestStatuses];
        //[self fetchApiRateLimitStatus];
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
        [[[UIAlertView alloc] initWithTitle:@"请求异常" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [_waterfallView.header endRefreshing];
        [_waterfallView.footer endRefreshing];
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
        [_waterfallView.header endRefreshing];
    }];
//    AppDelegate *delegate = [AppDelegate delegate];
//    if (!delegate.isLoggedIn) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [_waterfallView.header endRefreshing];
//        [alertView show];
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
        [_waterfallView.footer endRefreshing];
    }];
//    AppDelegate *delegate = [AppDelegate delegate];
//    if (!delegate.isLoggedIn) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [_waterfallView.footer endRefreshing];
//        [alertView show];
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

@end
