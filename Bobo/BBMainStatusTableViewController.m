//
//  BBWeiboListTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import "BBImageBrowserView.h"
#import "BBMainStatusTableViewController.h"
#import "BBHomelistTableViewCell.h"
#import "BBStatusDetailTableViewController.h"
#import "WeiboSDK.h"
#import "AppDelegate.h"
#import "BBButtonbarCell.h"
#import "BBNetworkUtils.h"
#import "UIButton+Bobtn.h"
#import "NSString+Convert.h"
#import "User.h"
#import "Status.h"

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kAppKey @"916936343"
#define bWeiboDomain @"https://api.weibo.com/2/"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnHeight bHeight/25

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

//@synthesize status;
static NSString *reuseIdentifier = @"reuseCell";
static NSString *reuseBarCellId = @"barCell";

@interface BBMainStatusTableViewController () <WBHttpRequestDelegate, BBImageBrowserProtocol>

@property (nonatomic) NSInteger currentLastStatusId;
@property (copy, nonatomic) NSString *currentLastStateIdStr;

@end

@implementation BBMainStatusTableViewController

#pragma mark - Lazy Instantiation

-(NSMutableArray *)statuses
{
    if (!_statuses) {
        _statuses = @[].mutableCopy;
    }
    return _statuses;
}

-(NSMutableArray *)users
{
    if (!_users) {
        _users = @[].mutableCopy;
    }
    return _users;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setMJRefresh];
    [self.tableView.header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BBImageBrowserProtocol

-(void)setImageBrowserWithImageUrls:(NSMutableArray *)urls andTappedViewTag:(NSInteger)tag
{
    BBImageBrowserView *browserView = [[BBImageBrowserView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame withImageUrls:urls andImageTag:tag];
    [self.view.window addSubview:browserView];
}

#pragma mark - WBHttpRequestDelegate & Helpers

-(void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"WBHttpRequestDelegate" message:[NSString stringWithFormat:@"didFinishLoadingWithResult: %@", result] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"WBHttpRequestDelegate" message:[NSString stringWithFormat:@"didFailWithError: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshStatus];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchHistoryStatus)];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
}

-(void)weiboRequestHandler:(WBHttpRequest *)request withResult:(id)result AndError:(NSError *)error andType:(NSString *)type
{
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请求异常" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        [alertView show];
    } else {
        if ([type isEqualToString:@"refresh"]) { //下拉刷新最新微博
            NSArray *downloadedStatuses = [result objectForKey:@"statuses"];
            for (int i = 0; i < [downloadedStatuses count]; i ++) {
                
                Status *tmp_status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
                [self.statuses insertObject:tmp_status atIndex:i];
                [self.users insertObject:tmp_status.user atIndex:i];
                
                if ([downloadedStatuses count] - 1 == i) {
                    _currentLastStatusId = tmp_status.status_id;
                    _currentLastStateIdStr = tmp_status.idstr;
                }
            }
            NSLog(@"length of the statuses and users: %ld, %ld", [_statuses count], [_users count]);
            [self.tableView.header endRefreshing];
            NSLog(@"Last status after refresh fetch:\n%@", [downloadedStatuses lastObject]);
        }
        
        if ([type isEqualToString:@"history"]) { //上拉刷新历史微博
            NSArray *historyStatuses = [result objectForKey:@"statuses"];
            NSLog(@"History statuses: %@", historyStatuses);
            for (int i = 0; i < [historyStatuses count]; i ++) {
                Status *tmp_status = [[Status alloc] initWithDictionary:historyStatuses[i]];
                [self.statuses addObject:tmp_status];
                if ([historyStatuses count] - 1 == i) {
                    _currentLastStateIdStr = tmp_status.idstr;
                    _currentLastStatusId = tmp_status.status_id;
                }
            }
            [self.tableView.footer endRefreshing];
            NSLog(@"Last status after history fetch:\n%@", [historyStatuses lastObject]);
        }
        NSLog(@"The currentLastStatusId is: %ld", _currentLastStatusId);
        [self.tableView reloadData];
    }
}

-(void)refreshStatus
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.tableView.header endRefreshing];
        [alertView show];
    } else {
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        if (delegate.wbToken) {
            [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
            NSString *url = [bWeiboDomain stringByAppendingString:@"statuses/home_timeline.json"];
            [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"refresh"];
            }];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"出错了" message:@"您未登录微博授权，请先登录。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}

-(void)fetchHistoryStatus
{
    [self.tableView.footer beginRefreshing];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.tableView.footer endRefreshing];
        [alertView show];
    } else {
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
        NSString *para = [NSString stringWithFormat:@"?max_id=%@", _currentLastStateIdStr];
        NSString *url = [bWeiboDomain stringByAppendingFormat:@"statuses/home_timeline%@", para];
        NSLog(@"The full url is: %@", url);
        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"history"];
        }];
    }
}

#pragma mark - Table view data source & delegate & Helpers

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if ([self.statuses count]) {
        return [self.statuses count];
    } else return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.row) {
        [tableView registerClass:[BBHomelistTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
        BBHomelistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setStatusDataForCell:cell IndexPath:indexPath];
        return cell;
    }
    else {
        [tableView registerClass:[BBButtonbarCell class] forCellReuseIdentifier:reuseBarCellId];
        BBButtonbarCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseBarCellId forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setStatusButtonBarDataForCell:cell IndexPath:indexPath];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        if ([self.statuses count]) {
            Status *status = [self.statuses objectAtIndex:indexPath.section];
            return status.height;
        }
        else return 80;
    } else return bBtnHeight;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBStatusDetailTableViewController *dtvc = [[BBStatusDetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    dtvc.title = @"Detail";
    dtvc.hidesBottomBarWhenPushed = YES;
    dtvc.status = [self.statuses objectAtIndex:indexPath.section];
    dtvc.user = [self.users objectAtIndex:indexPath.section];
    [self.navigationController pushViewController:dtvc animated:YES];
}

-(void)setStatusDataForCell:(BBHomelistTableViewCell *)cell IndexPath:(NSIndexPath *)indexPath
{
    if ([self.statuses count]) {
        Status *status = [self.statuses objectAtIndex:indexPath.section];
        cell.status = status;
        //avatar
        if (status.user.avatar != nil) {
            cell.avatarView.image = status.user.avatar;
        } else {
            cell.avatarView.image = [UIImage imageNamed:@"timeline_image_loading"];
            [BBNetworkUtils fetchAvatarForStatus:status withCell:cell];
        }
        
        //status images
        for (int i = 0; i < [cell.status.pic_urls count]; i ++) {
            if (![[status.images objectAtIndex:i] isEqual:[NSNull null]]) {
                [[cell.statusImgViews objectAtIndex:i] setImage:[status.images objectAtIndex:i]];
            } else {
                [cell.statusImgViews[i] setImage:[UIImage imageNamed:@"timeline_image_loading"]];
                [BBNetworkUtils fetchImageFromUrl:[status.pic_urls objectAtIndex:i] atIndex:i forImages:status.images withViews:cell.statusImgViews];
            }
        }
        
        //retweeted_status images
        for (int i = 0; i < [cell.status.retweeted_status.pic_urls count]; i ++) {
            if (![[status.retweeted_status.images objectAtIndex:i] isEqual:[NSNull null]]) {
                [[cell.imgViews objectAtIndex:i] setImage:[status.retweeted_status.images objectAtIndex:i]];
            } else {
                [cell.imgViews[i] setImage:[UIImage imageNamed:@"timeline_image_loading"]];
                [BBNetworkUtils fetchImageFromUrl:[status.retweeted_status.pic_urls objectAtIndex:i] atIndex:i forImages:status.retweeted_status.images withViews:cell.imgViews];
            }
        }
    }
}

-(void)setStatusButtonBarDataForCell:(BBButtonbarCell *)cell IndexPath:(NSIndexPath *)indexPath
{
    if ([_statuses count]) {
        Status *status = [self.statuses objectAtIndex:indexPath.section];
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

@end
