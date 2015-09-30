//
//  BBMessageTableViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/9/2.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBMessageViewController.h"
#import "BBMessageTableView.h"
#import <MJRefresh/MJRefresh.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Utils.h"
#import "AppDelegate.h"
#import "Comment.h"
#import "BBMessageMenuView.h"

#define bWeiboDomain @"https://api.weibo.com/2/"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define mMenuHeight 35
#define mTableViewHeight bHeight-mMenuHeight-49-44-[UIApplication sharedApplication].statusBarFrame.size.height

@interface BBMessageViewController () <UIScrollViewDelegate, BBMessageMenuViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) BBMessageMenuView *menuView;
@property (strong, nonatomic) BBMessageTableView *messageTableView;
@property (strong, nonatomic) BBMessageTableView *byMeTableView;
@property (strong, nonatomic) BBMessageTableView *mentionTableView;
@property (strong, nonatomic) BBMessageTableView *allTableView;
@property (strong, nonatomic) BBMessageTableView *atMeTableView;

@property (copy, nonatomic) NSMutableArray *maxids;
@property (copy, nonatomic) NSMutableArray *sinceids;
@property (copy, nonatomic) NSString *uri;

@property (strong, nonatomic) ACAccount *weiboAccount;

@end

@implementation BBMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
    
    _uri = @"to_me";
    _maxids = @[[NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]].mutableCopy;
    _sinceids = @[[NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null]].mutableCopy;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, mMenuHeight, bWidth, mTableViewHeight)];
    _scrollView.contentSize = CGSizeMake(bWidth*5, mTableViewHeight);
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    _messageTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(0, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
    [_scrollView addSubview:_messageTableView];
    
    _menuView = [[BBMessageMenuView alloc] init];
    _menuView.delegate = self;
    [self.view addSubview:_menuView];
    
    [self setMJRefreshWithTableView:_messageTableView flag:0];
    [_messageTableView.header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BBMessageMenuViewDelegate

-(void)didClickMenuButtonAtIndex:(NSInteger)index
{
    [_scrollView setContentOffset:CGPointMake(index*bWidth, 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate & support

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self loadTableViewInScrollView:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadTableViewInScrollView:scrollView];
}

-(void)loadTableViewInScrollView:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0) { //to_me
        [_menuView moveLineAccordingToFlag:0];
        _uri = @"to_me";
        if (!_messageTableView) {
            _messageTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(0, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_messageTableView];
            [self setMJRefreshWithTableView:_messageTableView flag:0];
            [_messageTableView.header beginRefreshing];
        }
    }
    if (scrollView.contentOffset.x == bWidth) { //by_me
        [_menuView moveLineAccordingToFlag:1];
        _uri = @"by_me";
        if (!_byMeTableView) {
            _byMeTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(bWidth, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_byMeTableView];
            [self setMJRefreshWithTableView:_byMeTableView flag:1];
            [_byMeTableView.header beginRefreshing];
        }
    }
    if (scrollView.contentOffset.x == bWidth*2) { //mentions
        [_menuView moveLineAccordingToFlag:2];
        _uri = @"mentions";
        if (!_mentionTableView) {
            _mentionTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(bWidth*2, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_mentionTableView];
            [self setMJRefreshWithTableView:_mentionTableView flag:2];
            [_mentionTableView.header beginRefreshing];
        }
    }
    if (scrollView.contentOffset.x == bWidth*3) { //timeline
        [_menuView moveLineAccordingToFlag:3];
        _uri = @"timeline";
        if (!_allTableView) {
            _allTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(bWidth*3, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_allTableView];
            [self setMJRefreshWithTableView:_allTableView flag:3];
            [_allTableView.header beginRefreshing];
        }
    }
    if (scrollView.contentOffset.x == bWidth*4) { //@me
        [_menuView moveLineAccordingToFlag:4];
        if (!_atMeTableView) {
            _atMeTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(bWidth*4, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_atMeTableView];
            [self setMJRefreshWithTableView:_atMeTableView flag:4];
            [_atMeTableView.header beginRefreshing];
        }
    }
}

#pragma mark - Weibo support

-(void)setMJRefreshWithTableView:(BBMessageTableView *)tableView flag:(NSInteger)flag
{
    tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchLatestCommentsWithTableView:tableView flag:flag];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self fetchHistoryCommentsWithTableView:tableView flag:flag];
    }];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    tableView.footer = footer;
}

-(void)handleWeiboResult:(id)result type:(NSString *)type forTableView:(BBMessageTableView *)tableView flag:(NSInteger)flag
{
    NSArray *downloads = nil;
    if ([type isEqualToString:@"refresh"]) { //下拉刷新最新消息
        if (flag != 4) {
            downloads = [result objectForKey:@"comments"];
            if (downloads.count > 0) {
                for (int i = 0; i < [downloads count]; i ++) {
                    Comment *tmp_comment = [[Comment alloc] initWithDictionary:downloads[i]];
                    [tableView.comments insertObject:tmp_comment atIndex:i];
                    if ([downloads count] - 1 == i) {
                        _maxids[flag] = tmp_comment.idstr;
                    }
                }
                Comment *comment = [[Comment alloc] initWithDictionary:[downloads objectAtIndex:0]];
                _sinceids[flag] = comment.idstr;
            }
        }
        if (flag == 4) {
            downloads = [result objectForKey:@"statuses"];
            if (downloads.count > 0) {
                for (int i = 0; i < [downloads count]; i ++) {
                    Status *tmp_status = [[Status alloc] initWithDictionary:downloads[i]];
                    Comment *comment = [[Comment alloc] initWithStatus:tmp_status];
                    [tableView.comments insertObject:comment atIndex:i];
                    if ([downloads count] - 1 == i) {
                        _maxids[flag] = tmp_status.idstr;
                    }
                }
                Status *status = [[Status alloc] initWithDictionary:[downloads objectAtIndex:0]];
                _sinceids[flag] = status.idstr;
            }
        }
        [tableView.header endRefreshing];
    }
    
    if ([type isEqualToString:@"history"]) { //上拉刷新历史消息
        if (flag != 4) {
            downloads = [result objectForKey:@"comments"];
            if (downloads.count > 0) {
                for (int i = 1; i < [downloads count]; i ++) {
                    Comment *tmp_comment = [[Comment alloc] initWithDictionary:downloads[i]];
                    [tableView.comments addObject:tmp_comment];
                    if ([downloads count] - 1 == i) {
                        _maxids[flag] = tmp_comment.idstr;
                    }
                }
            }
        }
        if (flag == 4) {
            downloads = [result objectForKey:@"statuses"];
            if (downloads.count > 0) {
                for (int i = 0; i < [downloads count]; i ++) {
                    Status *tmp_status = [[Status alloc] initWithDictionary:downloads[i]];
                    Comment *comment = [[Comment alloc] initWithStatus:tmp_status];
                    [tableView.comments addObject:comment];
                    if ([downloads count] - 1 == i) {
                        _maxids[flag] = tmp_status.idstr;
                    }
                }
            }
        }
        [tableView.footer endRefreshing];
    }
    [tableView reloadData];
}

-(void)fetchLatestCommentsWithTableView:(BBMessageTableView *)tableView flag:(NSInteger)flag
{
    if (flag != 4) {
        NSString *url = [NSString stringWithFormat:@"comments/%@.json", _uri];
        NSDictionary *params = nil;
        if (![_sinceids[flag] isEqual:[NSNull null]]) {
            params = @{@"since_id": _sinceids[flag]};
        }
        [Utils genericWeiboRequestWithAccount:_weiboAccount URL:url SLRequestHTTPMethod:SLRequestMethodGET parameters:params completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
            if ([_uri isEqualToString:@"to_me"]) {
                [self handleWeiboResult:result type:@"refresh" forTableView:_messageTableView flag:0];
            }
            if ([_uri isEqualToString:@"by_me"]) {
                [self handleWeiboResult:result type:@"refresh" forTableView:_byMeTableView flag:1];
            }
            if ([_uri isEqualToString:@"mentions"]) {
                [self handleWeiboResult:result type:@"refresh" forTableView:_mentionTableView flag:2];
            }
            if ([_uri isEqualToString:@"timeline"]) {
                [self handleWeiboResult:result type:@"refresh" forTableView:_allTableView flag:3];
            }
        } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"message error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [Utils presentNotificationWithText:@"更新失败"];
                [tableView.header endRefreshing];
            });
        }];
    }
    if (flag == 4) {
        NSDictionary *params = nil;
        if (![_sinceids[flag] isEqual:[NSNull null]]) {
            params = @{@"since_id": _sinceids[flag]};
        }
        [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"statuses/mentions.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:params completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
            [self handleWeiboResult:result type:@"refresh" forTableView:_atMeTableView flag:4];
        } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"message error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [Utils presentNotificationWithText:@"更新失败"];
                [tableView.header endRefreshing];
            });
        }];
    }
}

-(void)fetchHistoryCommentsWithTableView:(BBMessageTableView *)tableView flag:(NSInteger)flag
{
    if (flag != 4) {
        NSDictionary *params = nil;
        if (![_maxids[flag] isEqual:[NSNull null]]) {
            params = @{@"max_id": _maxids[flag], @"count": @"20"};
        }

        [Utils genericWeiboRequestWithAccount:_weiboAccount URL:[NSString stringWithFormat:@"comments/%@.json", _uri] SLRequestHTTPMethod:SLRequestMethodGET parameters:params completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
            if ([_uri isEqualToString:@"to_me"]) {
                [self handleWeiboResult:result type:@"history" forTableView:_messageTableView flag:0];
            }
            if ([_uri isEqualToString:@"by_me"]) {
                [self handleWeiboResult:result type:@"history" forTableView:_byMeTableView flag:1];
            }
            if ([_uri isEqualToString:@"mentions"]) {
                [self handleWeiboResult:result type:@"history" forTableView:_mentionTableView flag:2];
            }
            if ([_uri isEqualToString:@"timeline"]) {
                [self handleWeiboResult:result type:@"history" forTableView:_allTableView flag:3];
            }
        } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Utils presentNotificationWithText:@"更新失败"];
                [tableView.footer endRefreshing];
            });
        }];
    }
    if (flag == 4) {
        NSDictionary *param = nil;
        if (![_maxids[flag] isEqual:[NSNull null]]) {
            param = @{@"max_id": _maxids[flag], @"count": @"20"};
        }
        [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"statuses/mentions.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:param completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
            [self handleWeiboResult:result type:@"history" forTableView:_atMeTableView flag:4];
        } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Utils presentNotificationWithText:@"更新失败"];
                [tableView.footer endRefreshing];
            });
        }];
    }
}

@end
