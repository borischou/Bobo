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

#define bWeiboDomain @"https://api.weibo.com/2/"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@interface BBMessageViewController ()

@property (strong, nonatomic) BBMessageTableView *messageTableView;
@property (copy, nonatomic) NSString *max_id;
@property (copy, nonatomic) NSString *since_id;

@end

@implementation BBMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _messageTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:_messageTableView];
    [self setMJRefresh];
    [_messageTableView.header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Weibo support

-(void)setMJRefresh
{
    _messageTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchLatestCommentsToMe];
        [self fetchApiRateLimitStatus];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchHistoryCommentsToMe)];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    _messageTableView.footer = footer;
}

-(void)weiboRequestHandler:(WBHttpRequest *)request withResult:(id)result AndError:(NSError *)error andType:(NSString *)type
{
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"请求异常" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [_messageTableView.header endRefreshing];
        [_messageTableView.footer endRefreshing];
    } else {
        if ([type isEqualToString:@"refresh"]) { //下拉刷新最新消息
            NSArray *downloadedComments = [result objectForKey:@"comments"];
            if (downloadedComments.count > 0) {
                for (int i = 0; i < [downloadedComments count]; i ++) {
                    Comment *tmp_comment = [[Comment alloc] initWithDictionary:downloadedComments[i]];
                    [_messageTableView.comments insertObject:tmp_comment atIndex:i];
                    if ([downloadedComments count] - 1 == i) {
                        _max_id = tmp_comment.idstr;
                    }
                }
                Comment *comment = [[Comment alloc] initWithDictionary:[downloadedComments objectAtIndex:0]];
                _since_id = comment.idstr;
            }
            [_messageTableView.header endRefreshing];
        }
        
        if ([type isEqualToString:@"history"]) { //上拉刷新历史消息
            NSArray *historyMessages = [result objectForKey:@"statuses"];
            if (historyMessages.count > 0) {
                for (int i = 1; i < [historyMessages count]; i ++) {
                    Comment *tmp_comment = [[Comment alloc] initWithDictionary:historyMessages[i]];
                    [_messageTableView.comments addObject:tmp_comment];
                    if ([historyMessages count] - 1 == i) {
                        _max_id = tmp_comment.idstr;
                    }
                }
            }
            [_messageTableView.footer endRefreshing];
        }
        [_messageTableView reloadData];
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

-(void)fetchLatestCommentsToMe
{
    AppDelegate *delegate = [AppDelegate delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [_messageTableView.header endRefreshing];
        [alertView show];
    } else {
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        if (delegate.wbToken) {
            [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
            NSString *url;
            if (!_since_id) {
                url = [bWeiboDomain stringByAppendingString:@"comments/to_me.json"];
            } else {
                url = [bWeiboDomain stringByAppendingFormat:@"comments/to_me.json?since_id=%@", _since_id];
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

-(void)fetchHistoryCommentsToMe
{
    AppDelegate *delegate = [AppDelegate delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [_messageTableView.footer endRefreshing];
        [alertView show];
    } else {
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
        NSString *para = [NSString stringWithFormat:@"max_id=%@&count=20", _max_id];
        NSString *url = [bWeiboDomain stringByAppendingFormat:@"comments/to_me.json?%@", para];
        NSLog(@"The full url for history statuses is: %@", url);
        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"history"];
        }];
    }
}


@end
