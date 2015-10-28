//
//  BBListTableViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/10/8.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBListTableViewController.h"
#import "BBListTableViewCell.h"
#import "BBProfileTableViewController.h"
#import <MJRefresh.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"
#import "Utils.h"

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
    User *user = _users[indexPath.row];
    NSDictionary *params = @{@"uid": user.idstr};
    [Utils genericWeiboRequestWithAccount:[[AppDelegate delegate] defaultAccount]
                                      URL:@"statuses/user_timeline.json"
                      SLRequestHTTPMethod:SLRequestMethodGET
                               parameters:params
               completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSMutableArray *statuses = [Utils statusesWith:responseObject];
         Status *status = statuses.firstObject;
         User *user = status.user;
         
         BBProfileTableViewController *profiletvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
         [Utils setupNavigationController:self.navigationController withUIViewController:profiletvc];
         profiletvc.uid = user.idstr;
         profiletvc.statuses = statuses;
         profiletvc.user = user;
         profiletvc.shouldNavBtnShown = NO;
         profiletvc.title = @"Profile";
         profiletvc.hidesBottomBarWhenPushed = YES;
         [self.navigationController pushViewController:profiletvc animated:YES];
     }
               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error %@", error);
         dispatch_async(dispatch_get_main_queue(), ^{
             [Utils presentNotificationWithText:@"访问失败"];
         });
     }];
}

#pragma mark - BBListTableViewCellDelegate

-(void)tableViewCell:(BBListTableViewCell *)cell didTapRelationshipView:(UITapGestureRecognizer *)tap
{
    UIImageView *imageView = (UIImageView *)tap.view;
    AppDelegate *delegate = [AppDelegate delegate];
    ACAccount *account = [delegate defaultAccount];
    
    if ([imageView.image isEqual:[NSNull null]] || imageView.image == nil) {
        //do nothing
    }
    
    if ([imageView.image isEqual:[UIImage imageNamed:@"settings_icon"]])
    {
        NSLog(@"settings");
        //个人设置
    }
    if ([imageView.image isEqual:[UIImage imageNamed:@"following_icon"]]
        || [imageView.image isEqual:[UIImage imageNamed:@"friend_icon"]])
    {
        if ([delegate.user.idstr isEqualToString:cell.user.idstr]) {
            return;
        }
        NSLog(@"following");
        //取关
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"取消关注" message:@"您是否确定取消关注此用户？" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消关注" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSDictionary *params = @{@"uid": _user.idstr};
            [Utils weiboPostRequestWithAccount:account URL:@"friendships/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (!error) {
                    NSLog(@"success");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell.user setFollowing:NO];
                        [Utils presentNotificationWithText:@"成功取关"];
                        [cell setNeedsLayout];
                    });
                } else {
                    NSLog(@"error: %@", error);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Utils presentNotificationWithText:@"取关失败"];
                    });
                }
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"继续关注" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alertController addAction:action];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:^{}];
    }
    if ([imageView.image isEqual:[UIImage imageNamed:@"follow_icon"]])
    {
        if ([delegate.user.idstr isEqualToString:cell.user.idstr]) {
            return;
        }
        NSLog(@"follow");
        //关注
        NSDictionary *params = @{@"uid": _user.idstr};
        [Utils weiboPostRequestWithAccount:account URL:@"friendships/create.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSLog(@"success");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.user setFollowing:YES];
                    [Utils presentNotificationWithText:@"关注成功"];
                    [cell setNeedsLayout];
                });
            } else {
                NSLog(@"error: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utils presentNotificationWithText:@"关注失败"];
                });
            }
        }];
    }
}

@end
