//
//  BBListTableViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/10/8.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBListTableViewController.h"
#import "BBListTableViewCell.h"
#import <MJRefresh.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"
#import "Utils.h"

typedef NS_ENUM(NSInteger, fetchResultType) {
    fetchResultTypeRefresh,
    fetchResultTypeHistory
};

@interface BBListTableViewController ()

@property (nonatomic) NSInteger listType;
@property (copy, nonatomic) NSString *cursor;
@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) ACAccount *weiboAccount;

@end

@implementation BBListTableViewController

-(instancetype)initWithStyle:(UITableViewStyle)style listType:(NSInteger)type
{
    self = [super initWithStyle:style];
    if (self) {
        _listType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
    [self setMJRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Weibo support

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchListData];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchListData)];
    [footer setTitle:@"上拉以获取更多" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
}

-(void)fetchListData
{
    NSDictionary *params = nil;
    if (_listType == listTypeFollower)
    {
        params = @{@"uid": _user.idstr, @"cursor": _cursor? _cursor: @""};
        [Utils genericWeiboRequestWithAccount:_weiboAccount
                                          URL:@"friendships/followers.json"
                          SLRequestHTTPMethod:SLRequestMethodGET
                                   parameters:params
                   completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSError *error = nil;
            [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] fetchResultType:fetchResultTypeRefresh];
        }
                   completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            NSLog(@"main error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [Utils presentNotificationWithText:@"更新失败"];
                [self.tableView.header endRefreshing];
            });
        }];
    }
    if (_listType == listTypeFollowing)
    {
        params = @{@"uid": _user.idstr, @"cursor": _cursor? _cursor: @""};
        [Utils genericWeiboRequestWithAccount:_weiboAccount
                                          URL:@"friendships/friends.json"
                          SLRequestHTTPMethod:SLRequestMethodGET
                                   parameters:params
                   completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSError *error = nil;
             [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] fetchResultType:fetchResultTypeRefresh];
         }
                   completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"main error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
             dispatch_async(dispatch_get_main_queue(), ^{
                 [Utils presentNotificationWithText:@"更新失败"];
                 [self.tableView.header endRefreshing];
             });
         }];
    }
}

-(void)handleWeiboResult:(id)result fetchResultType:(NSInteger)type
{
    switch (type) {
        case fetchResultTypeRefresh:
            //重新刷新列表数据
            break;
        case fetchResultTypeHistory:
            //载入更多列表数据
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source & delegate & support

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[BBListTableViewCell class] forCellReuseIdentifier:@"reuse"];
    BBListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse" forIndexPath:indexPath];
    if (_users.count > 0) {
        cell.user = _users[indexPath.row];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
