//
//  BBCollectionTableViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/8/7.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "SWRevealViewController.h"
#import "BBFavoritesTableViewController.h"
#import "BBStatusTableViewCell.h"
#import "BBButtonbarTableViewCell.h"
#import "Status.h"
#import "User.h"
#import "NSString+Convert.h"
#import "UIButton+Bobtn.h"
#import "BBNetworkUtils.h"
#import "BBImageBrowserView.h"
#import "BBStatusDetailTableViewController.h"
#import "AppDelegate.h"
#import "WeiboSDK.h"
#import <MJRefresh/MJRefresh.h>

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnHeight bHeight/25

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

#define bWeiboDomain @"https://api.weibo.com/2/"

@interface BBFavoritesTableViewController () <BBImageBrowserProtocol> {
    int page;
}

@property (strong, nonatomic) NSMutableArray *statuses;

@end

@implementation BBFavoritesTableViewController

#pragma mark - View Controller life cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    page = 1;
    [self setMJRefresh];
    [self.tableView.header beginRefreshing];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addSWRevealViewControllerGestureRecognizer];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeSWRevealControllerGestureRecognizer];
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

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchFavoriteStatuses];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchFavoriteStatuses)];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
}

//https://api.weibo.com/2/favorites.json?count=count_num&page=page_num
-(void)fetchFavoriteStatuses
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        [alertView show];
    } else {
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
        NSString *para = [NSString stringWithFormat:@"count=20&page=%d", page];
        NSString *url = [bWeiboDomain stringByAppendingFormat:@"favorites.json?%@", para];
        NSLog(@"The full url is: %@", url);
        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"fav"];
        }];
    }
}

-(void)weiboRequestHandler:(WBHttpRequest *)request withResult:(id)result AndError:(NSError *)error andType:(NSString *)type
{
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请求异常" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        [alertView show];
    } else {
        if ([type isEqualToString:@"fav"]) {
            NSDictionary *resultDict = result;
            if (![[resultDict objectForKey:@"favorites"] isEqual:[NSNull null]]) {
                NSArray *favArray = [resultDict objectForKey:@"favorites"];
                if (favArray.count > 0) {
                    if (!_statuses) {
                        _statuses = @[].mutableCopy;
                    }
                    for (int i = 0; i < favArray.count; i ++) {
                        if (![[favArray[i] objectForKey:@"status"] isEqual:[NSNull null]]) {
                            Status *status = [[Status alloc] initWithDictionary:[favArray[i] objectForKey:@"status"]];
                            [_statuses addObject:status];
                        }
                    }
                    page += 1;
                }
            }
        }
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableView data source & delegate & Helpers

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([_statuses count]) {
        return [_statuses count];
    } else {
        return 0;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_statuses count]) {
        if (indexPath.row == 0) {
            Status *status = [_statuses objectAtIndex:indexPath.section];
            return status.height;
        } else {
            return bBtnHeight;
        }
    } else {
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        [tableView registerClass:[BBStatusTableViewCell class] forCellReuseIdentifier:@"home"];
        BBStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"home" forIndexPath:indexPath];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([_statuses count]) {
            Status *status = [self.statuses objectAtIndex:indexPath.section];
            cell.status = status;
        }
        return cell;
    }
    else
    {
        [tableView registerClass:[BBButtonbarTableViewCell class] forCellReuseIdentifier:@"buttonBar"];
        BBButtonbarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buttonBar" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setStatusButtonBarDataForCell:cell IndexPath:indexPath];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBStatusDetailTableViewController *dtvc = [[BBStatusDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    dtvc.title = @"Detail";
    dtvc.hidesBottomBarWhenPushed = YES;
    Status *status = [_statuses objectAtIndex:indexPath.section];
    dtvc.status = status;
    [self.navigationController pushViewController:dtvc animated:YES];
}

-(void)setStatusButtonBarDataForCell:(BBButtonbarTableViewCell *)cell IndexPath:(NSIndexPath *)indexPath
{
    if ([_statuses count]) {
        Status *status = [_statuses objectAtIndex:indexPath.section];
        if (status.reposts_count > 0) {
            [cell.repostBtn setTitle:[NSString stringWithFormat:@"%@re", [NSString getNumStrFrom:status.reposts_count]] withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
        } else {
            [cell.repostBtn setTitle:@"Repost" withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
        }
        if (status.comments_count > 0) {
            [cell.commentBtn setTitle:[NSString stringWithFormat:@"%@ comts", [NSString getNumStrFrom:status.comments_count]] withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
        } else {
            [cell.commentBtn setTitle:@"Comment" withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];            }
        if (status.attitudes_count > 0) {
            [cell.likeBtn setTitle:[NSString stringWithFormat:@"%@ likes", [NSString getNumStrFrom:status.attitudes_count]] withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
        } else {
            [cell.likeBtn setTitle:@"Like" withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
        }
    }
}

#pragma mark - BBImageBrowserProtocol

-(void)setImageBrowserWithImageUrls:(NSMutableArray *)urls andTappedViewTag:(NSInteger)tag
{
    BBImageBrowserView *browserView = [[BBImageBrowserView alloc] initWithFrame:[UIScreen mainScreen].bounds withImageUrls:urls andImageTag:tag];
    [self.view.window addSubview:browserView];
}

@end