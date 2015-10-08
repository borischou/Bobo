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

#define bBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]

@interface BBListTableViewController () <BBListTableViewCellDelegate>

@property (nonatomic) NSInteger listType;
@property (nonatomic) NSInteger cursor;
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
    self.view.backgroundColor = bBGColor;
    self.tableView.separatorColor = bBGColor;
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
    [self setMJRefresh];
    [self.tableView.header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Weibo support

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self resetCursor];
        [self fetchListData];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchListData)];
    [footer setTitle:@"上拉以获取更多" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
}

-(void)resetCursor
{
    _cursor = 0;
}

-(void)fetchListData
{
    NSDictionary *params = nil;
    NSString *uri = nil;
    if (_listType == listTypeFollower)
    {
        uri = @"friendships/followers.json";
    }
    if (_listType == listTypeFollowing) {
        uri = @"friendships/friends.json";
    }
    params = @{@"uid": _user.idstr, @"cursor": [NSString stringWithFormat:@"%ld", _cursor], @"count": @"200", @"trim_status": @"0"};
    [Utils genericWeiboRequestWithAccount:_weiboAccount
                                      URL:uri
                      SLRequestHTTPMethod:SLRequestMethodGET
                               parameters:params
               completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSError *error = nil;
         [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]];
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

-(void)handleWeiboResult:(id)result
{
    if (!_users || _cursor == 0) {
        _users = @[].mutableCopy;
        [self.tableView reloadData];
    }
    if (![[result objectForKey:@"users"] isEqual:[NSNull null]]) {
        NSArray *fetchedData = [result objectForKey:@"users"];
        if (fetchedData.count > 0) {
            for (NSDictionary *dict in fetchedData) {
                User *tmp_user = [[User alloc] initWithDictionary:dict];
                [_users addObject:tmp_user];
            }
            _cursor = [[result objectForKey:@"next_cursor"] integerValue];
        }
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source & delegate & support

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[BBListTableViewCell class] forCellReuseIdentifier:@"reuse"];
    BBListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse" forIndexPath:indexPath];
    cell.delegate = self;
    if (_users.count > 0) {
        cell.user = _users[indexPath.row];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60+10+10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - BBListTableViewCellDelegate

-(void)tableViewCell:(BBListTableViewCell *)cell didTapRelationshipView:(UITapGestureRecognizer *)tap
{
    
}

@end
