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
#import "AppDelegate.h"
#import "BBWaterfallCollectionView.h"
#import "BBUpdateStatusView.h"
#import "BBGroupSelectView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define uSmallGap 5
#define uBigGap 10

#define bWeiboDomain @"https://api.weibo.com/2/"

static NSString *homeTimeline = @"statuses/home_timeline.json";
static NSString *bilateralTimeline = @"statuses/bilateral_timeline.json";

@interface BBWaterfallStatusViewController () <UICollectionViewDelegate, BBGroupSelectViewDelegate>

@property (strong, nonatomic) BBWaterfallCollectionView *waterfallView;
@property (copy, nonatomic) NSString *max_id;
@property (copy, nonatomic) NSString *since_id;
@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) ACAccount *weiboAccount;

@end

@implementation BBWaterfallStatusViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.minimumColumnSpacing = 4.0;
    layout.minimumInteritemSpacing = 4.0;
    layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst;
    _waterfallView = [[BBWaterfallCollectionView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight) collectionViewLayout:layout];
    self.view = _waterfallView;
    
    if (!_groupNumber || _groupNumber == 0) { //所有微博
        _url = homeTimeline;
    }
    if (_groupNumber == 1) { //朋友微博
        _url = bilateralTimeline;
    }
    
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
    if (_waterfallView.statuses.count <= 0) {
        [_waterfallView.header beginRefreshing];
    }
}

#pragma mark - Helpers

-(void)setNavBarBtn
{
    UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    postBtn.frame = CGRectMake(0, 0, 23, 23);
    [postBtn setImage:[UIImage imageNamed:@"barbutton_icon_post"] forState:UIControlStateNormal];
    [postBtn addTarget:self action:@selector(postBarbuttonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *postBarBtn = [[UIBarButtonItem alloc] initWithCustomView:postBtn];
    self.navigationItem.rightBarButtonItem = postBarBtn;
    
    UIButton *groupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [groupBtn setFrame:CGRectMake(0, 0, 23, 23)];
    [groupBtn setImage:[UIImage imageNamed:@"group_tab_icon"] forState:UIControlStateNormal];
    [groupBtn addTarget:self action:@selector(groupBarbuttonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *groupBarBtn = [[UIBarButtonItem alloc] initWithCustomView:groupBtn];
    self.navigationItem.leftBarButtonItem = groupBarBtn;
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

-(void)groupBarbuttonPressed
{
    AppDelegate *delegate = [AppDelegate delegate];
    BBGroupSelectView *groupView = [[BBGroupSelectView alloc] init];
    groupView.groups = @[@"所有微博", @"朋友微博"];
    groupView.delegate = self;
    [delegate.window addSubview:groupView];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [groupView setFrame:CGRectMake(50, statusBarHeight, bWidth*0.6, bHeight/2)];
    } completion:^(BOOL finished) {}];
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

-(void)handleWeiboResult:(id)result type:(NSString *)type
{
    if (!_waterfallView.statuses) {
        _waterfallView.statuses = @[].mutableCopy;
    }
    if ([type isEqualToString:@"refresh"]) { //下拉刷新最新微博
        NSArray *downloadedStatuses = [result objectForKey:@"statuses"];
        if (downloadedStatuses.count > 0) {
            for (int i = 0; i < [downloadedStatuses count]; i ++) {
                Status *tmp_status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
                [_waterfallView.statuses insertObject:tmp_status atIndex:i];
//                if ([downloadedStatuses count] - 1 == i) {
//                    _max_id = tmp_status.idstr;
//                }
            }
//            Status *status = [[Status alloc] initWithDictionary:[downloadedStatuses objectAtIndex:0]];
//            _since_id = status.idstr;
            NSDictionary *lastone = downloadedStatuses.lastObject;
            _max_id = lastone[@"idstr"];
            NSDictionary *firstone = downloadedStatuses.firstObject;
            _since_id = firstone[@"idstr"];
            [Utils presentNotificationWithText:[NSString stringWithFormat:@"更新了%ld条微博", downloadedStatuses.count]];
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
//                if ([historyStatuses count] - 1 == i) {
//                    _max_id = tmp_status.idstr;
//                }
            }
            NSDictionary *lastone = historyStatuses.lastObject;
            _max_id = lastone[@"idstr"];
        }
        [_waterfallView.footer endRefreshing];
    }
    [_waterfallView reloadData];
    NSLog(@"The currentLastStatusId is: %@", _max_id);
}

-(void)fetchLatestStatuses
{
    NSString *requestUrl = _url;
    NSDictionary *param = nil;
    if (_since_id) {
        param = @{@"since_id": _since_id};
    }
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:requestUrl SLRequestHTTPMethod:SLRequestMethodGET parameters:param completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] type:@"refresh"];
    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils presentNotificationWithText:@"更新失败"];
            [_waterfallView.header endRefreshing];
        });
    }];
}

-(void)fetchHistoryStatuses
{
    NSString *requestUrl = _url;
    NSDictionary *param = @{@"max_id": _max_id, @"count": @"20"};
    
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:requestUrl SLRequestHTTPMethod:SLRequestMethodGET parameters:param completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] type:@"history"];
    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils presentNotificationWithText:@"访问失败"];
            [_waterfallView.footer endRefreshing];
        });
    }];
}

#pragma mark - BBGroupSelectViewDelegate & Support

-(void)groupView:(BBGroupSelectView *)groupView didSelectGroupAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger selected = indexPath.row;
    switch (selected) {
        case 0:
            if ([_url isEqualToString:homeTimeline]) {
                return;
            } else {
                _url = homeTimeline;
                [self clearStatuses];
                [_waterfallView.header beginRefreshing];
            }
            [groupView maskViewTapped];
            break;
        case 1:
            if ([_url isEqualToString:bilateralTimeline]) {
                
                return;
            } else {
                _url = bilateralTimeline;
                [self clearStatuses];
                [_waterfallView.header beginRefreshing];
            }
            [groupView maskViewTapped];
        default:
            break;
    }
}

-(void)clearStatuses
{
    _since_id = nil;
    [_waterfallView.statuses removeAllObjects];
}

@end
