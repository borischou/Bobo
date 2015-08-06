//
//  BBProfileTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/22.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>

#import "BBProfileTableVC.h"
#import "BBCountCell.h"
#import "AppDelegate.h"
#import "WeiboSDK.h"
#import "WeiboCountsModel.h"
#import "BBMeHeaderView.h"

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kAppKey @"916936343"
#define bWeiboDomain @"https://api.weibo.com/2/"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]

@interface BBProfileTableVC ()

@property (strong, nonatomic) WeiboCountsModel *myWbCounts;

@end

@implementation BBProfileTableVC

static NSString *reuseAvatarCell = @"avatarCell";
static NSString *reuseCountsCell = @"countsCell";

-(WeiboCountsModel *)myWbCounts
{
    if (!_myWbCounts) {
        _myWbCounts = [[WeiboCountsModel alloc] init];
    }
    return _myWbCounts;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.view.backgroundColor = bBGColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [self getAvatarView];
    
    [self fetchCountsOfMe];
    [self setMJRefresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeSomething) name:@"bobo" object:nil];
}

-(void)setMJRefresh
{
    __weak __typeof(self) weakSelf = self;
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf fetchCountsOfMe];
    }];
}

-(UIView *)getAvatarView
{
    BBMeHeaderView *avatarView = [[BBMeHeaderView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight/3.5)];
    return avatarView;
}

-(void)observeSomething
{
    NSLog(@"Notification Center usage: Profile view controller which registered 'bobo' to be the notification sender's name just observed that the button 'login' registered as 'bobo' in WeiboList view controller was pressed once.");
}

#pragma mark - Fetch requests

-(void)fetchCountsOfMe
{
    [self.tableView.header beginRefreshing];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        if (delegate.wbToken) {
            [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
            [extraParaDict setObject:[NSString stringWithFormat:@"%@", delegate.wbCurrentUserID] forKey:@"uids"];
            NSString *url = [bWeiboDomain stringByAppendingString:@"users/counts.json"];
            [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"counts"];
            }];
        } else {
            [self.tableView.header endRefreshing];
            NSLog(@"fetch counts failed: token doesn't exist or expired.");
        }
    }
}

#pragma mark - Helpers

-(void)weiboRequestHandler:(WBHttpRequest *)request withResult:(id)result AndError:(NSError *)error andType:(NSString *)type
{
    if ([type isEqualToString:@"counts"]) {
        NSDictionary *myCounts = [result firstObject];
        NSLog(@"counts: %@", myCounts);
        self.myWbCounts = [[WeiboCountsModel alloc] initWithWeiboCounts:myCounts];
        [self.tableView reloadData];
        [self.tableView.header endRefreshing];
    }
}

#pragma mark - UITableView delegate & data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerClass:[BBCountCell class] forCellReuseIdentifier:reuseCountsCell];
    BBCountCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCountsCell forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.wbcounts.text = [NSString stringWithFormat:@"%ld", self.myWbCounts.statuses_count];
    cell.followercounts.text = [NSString stringWithFormat:@"%ld", self.myWbCounts.followers_count];
    cell.friendcounts.text = [NSString stringWithFormat:@"%ld", self.myWbCounts.friends_count];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

@end
