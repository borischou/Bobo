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
#import "WeiboSDK.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "Comment.h"
#import "BBMessageMenuView.h"

#define bWeiboDomain @"https://api.weibo.com/2/"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define mMenuHeight 35
#define mTableViewHeight bHeight-mMenuHeight-49-44-[UIApplication sharedApplication].statusBarFrame.size.height

@interface BBMessageViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) BBMessageMenuView *menuView;

@property (strong, nonatomic) BBMessageTableView *messageTableView;
@property (strong, nonatomic) BBMessageTableView *byMeTableView;
@property (strong, nonatomic) BBMessageTableView *mentionTableView;
@property (strong, nonatomic) BBMessageTableView *allTableView;

@property (copy, nonatomic) NSMutableArray *maxids;
@property (copy, nonatomic) NSMutableArray *sinceids;
@property (copy, nonatomic) NSString *uri;

@end

@implementation BBMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _uri = @"to_me";
    _maxids = @[[NSNull null], [NSNull null], [NSNull null], [NSNull null]].mutableCopy;
    _sinceids = @[[NSNull null], [NSNull null], [NSNull null], [NSNull null]].mutableCopy;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, mMenuHeight, bWidth, mTableViewHeight)];
    scrollView.contentSize = CGSizeMake(bWidth*4, mTableViewHeight);
    scrollView.delegate = self;
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    _messageTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(0, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
    [scrollView addSubview:_messageTableView];
    
    _menuView = [[BBMessageMenuView alloc] init];
    [self.view addSubview:_menuView];
    
    [self setMJRefreshWithTableView:_messageTableView flag:0];
    [_messageTableView.header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate & support

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0) { //to_me
        _menuView.flag = 0;
        [_menuView setNeedsLayout];
        _uri = @"to_me";
        if (!_messageTableView) {
            _messageTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(0, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_messageTableView];
            [self setMJRefreshWithTableView:_messageTableView flag:0];
            [_messageTableView.header beginRefreshing];
        }
    }
    if (scrollView.contentOffset.x == bWidth) { //by_me
        _menuView.flag = 1;
        [_menuView setNeedsLayout];
        _uri = @"by_me";
        if (!_byMeTableView) {
            _byMeTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(bWidth, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_byMeTableView];
            [self setMJRefreshWithTableView:_byMeTableView flag:1];
            [_byMeTableView.header beginRefreshing];
        }
    }
    if (scrollView.contentOffset.x == bWidth*2) { //mentions
        _menuView.flag = 2;
        [_menuView setNeedsLayout];
        _uri = @"mentions";
        if (!_mentionTableView) {
            _mentionTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(bWidth*2, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_mentionTableView];
            [self setMJRefreshWithTableView:_mentionTableView flag:2];
            [_mentionTableView.header beginRefreshing];
        }
    }
    if (scrollView.contentOffset.x == bWidth*3) { //timeline
        _menuView.flag = 3;
        [_menuView setNeedsLayout];
        _uri = @"timeline";
        if (!_allTableView) {
            _allTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(bWidth*3, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_allTableView];
            [self setMJRefreshWithTableView:_allTableView flag:3];
            [_allTableView.header beginRefreshing];
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

-(void)weiboRequestHandler:(WBHttpRequest *)request forTableView:(BBMessageTableView *)tableView withResult:(id)result error:(NSError *)error type:(NSString *)type flag:(NSInteger)flag
{
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"请求异常" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [tableView.header endRefreshing];
        [tableView.footer endRefreshing];
    } else {
        if ([type isEqualToString:@"refresh"]) { //下拉刷新最新消息
            NSArray *downloadedComments = [result objectForKey:@"comments"];
            if (downloadedComments.count > 0) {
                for (int i = 0; i < [downloadedComments count]; i ++) {
                    Comment *tmp_comment = [[Comment alloc] initWithDictionary:downloadedComments[i]];
                    [tableView.comments insertObject:tmp_comment atIndex:i];
                    if ([downloadedComments count] - 1 == i) {
                        _maxids[flag] = tmp_comment.idstr;
                    }
                }
                Comment *comment = [[Comment alloc] initWithDictionary:[downloadedComments objectAtIndex:0]];
                _sinceids[flag] = comment.idstr;
            }
            [tableView.header endRefreshing];
        }
        
        if ([type isEqualToString:@"history"]) { //上拉刷新历史消息
            NSArray *historyMessages = [result objectForKey:@"statuses"];
            if (historyMessages.count > 0) {
                for (int i = 1; i < [historyMessages count]; i ++) {
                    Comment *tmp_comment = [[Comment alloc] initWithDictionary:historyMessages[i]];
                    [tableView.comments addObject:tmp_comment];
                    if ([historyMessages count] - 1 == i) {
                        _maxids[flag] = tmp_comment.idstr;
                    }
                }
            }
            [tableView.footer endRefreshing];
        }
        [tableView reloadData];
        NSLog(@"The currentLastStatusId is: %@", _maxids[flag]);
    }
}

-(void)fetchLatestCommentsWithTableView:(BBMessageTableView *)tableView flag:(NSInteger)flag
{
    
    AppDelegate *delegate = [AppDelegate delegate];
    if (!delegate.isLoggedIn) {
        [tableView.header endRefreshing];
        [[[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        if (delegate.wbToken) {
            [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
            NSString *url;
            if ([_sinceids[flag] isEqual:[NSNull null]]) {
                url = [bWeiboDomain stringByAppendingFormat:@"comments/%@.json", _uri];
            } else {
                url = [bWeiboDomain stringByAppendingFormat:@"comments/%@.json?since_id=%@", _uri, _sinceids[flag]];
            }
            NSLog(@"The full url for latest statuses is: %@", url);
            [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                if ([_uri isEqualToString:@"to_me"]) {
                    [self weiboRequestHandler:httpRequest forTableView:_messageTableView withResult:result error:error type:@"refresh" flag:0];
                }
                if ([_uri isEqualToString:@"by_me"]) {
                    [self weiboRequestHandler:httpRequest forTableView:_byMeTableView withResult:result error:error type:@"refresh" flag:1];
                }
                if ([_uri isEqualToString:@"mentions"]) {
                    [self weiboRequestHandler:httpRequest forTableView:_mentionTableView withResult:result error:error type:@"refresh" flag:2];
                }
                if ([_uri isEqualToString:@"timeline"]) {
                    [self weiboRequestHandler:httpRequest forTableView:_allTableView withResult:result error:error type:@"refresh" flag:3];
                }
            }];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"出错了" message:@"您未登录微博授权，请先登录。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

-(void)fetchHistoryCommentsWithTableView:(BBMessageTableView *)tableView flag:(NSInteger)flag
{
    AppDelegate *delegate = [AppDelegate delegate];
    if (!delegate.isLoggedIn) {
        [tableView.footer endRefreshing];
        [[[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
        NSString *para = [NSString stringWithFormat:@"max_id=%@&count=20", _maxids[flag]];
        NSString *url = [bWeiboDomain stringByAppendingFormat:@"comments/%@.json?%@", _uri, para];
        NSLog(@"The full url for history statuses is: %@", url);
        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            if ([_uri isEqualToString:@"to_me"]) {
                [self weiboRequestHandler:httpRequest forTableView:_messageTableView withResult:result error:error type:@"history" flag:0];
            }
            if ([_uri isEqualToString:@"by_me"]) {
                [self weiboRequestHandler:httpRequest forTableView:_byMeTableView withResult:result error:error type:@"history" flag:1];
            }
            if ([_uri isEqualToString:@"mentions"]) {
                [self weiboRequestHandler:httpRequest forTableView:_mentionTableView withResult:result error:error type:@"history" flag:2];
            }
            if ([_uri isEqualToString:@"timeline"]) {
                [self weiboRequestHandler:httpRequest forTableView:_allTableView withResult:result error:error type:@"history" flag:3];
            }
        }];
    }
}

@end
