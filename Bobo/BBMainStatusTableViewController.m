//
//  BBWeiboListTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <SafariServices/SafariServices.h>
#import "SWRevealViewController.h"
#import "Utils.h"
#import "BBMainStatusTableViewController.h"
#import "BBProfileTableViewController.h"
#import "BBStatusDetailViewController.h"
#import "BBButtonbarTableViewCell.h"
#import "BBStatusTableViewCell.h"
#import "BBUpdateStatusView.h"
#import "AppDelegate.h"
#import "BBImageBrowserView.h"
#import "UIButton+Bobtn.h"
#import "NSString+Convert.h"
#import "Status.h"
#import "User.h"

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kAppKey @"916936343"
#define bWeiboDomain @"https://api.weibo.com/2/"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnHeight bHeight/25
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define uSmallGap 5
#define uBigGap 10

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

static NSString *reuseIdentifier = @"reuseCell";
static NSString *reuseBarCellId = @"barCell";

@interface BBMainStatusTableViewController () <BBStatusTableViewCellDelegate>

@property (copy, nonatomic) NSString *max_id;
@property (copy, nonatomic) NSString *since_id;
@property (copy, nonatomic) NSMutableArray *statuses;
@property (strong, nonatomic) ACAccount *weiboAccount;

@end

@implementation BBMainStatusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
    [self setNavBarBtn];
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

-(void)setNavBarBtn
{
    UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    postBtn.frame = CGRectMake(0, 0, 23, 23);
    [postBtn setImage:[UIImage imageNamed:@"barbutton_icon_post"] forState:UIControlStateNormal];
    [postBtn addTarget:self action:@selector(postBarbuttonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *postBarBtn = [[UIBarButtonItem alloc] initWithCustomView:postBtn];
    self.navigationItem.rightBarButtonItem = postBarBtn;
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

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchLatestStatuses];
        //[self fetchApiRateLimitStatus];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchHistoryStatuses)];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
}

-(void)handleWeiboResult:(id)result type:(NSString *)type
{
    if (!_statuses) {
        _statuses = @[].mutableCopy;
    }
    if ([type isEqualToString:@"refresh"]) { //下拉刷新最新微博
        NSArray *downloadedStatuses = [result objectForKey:@"statuses"];
        if (downloadedStatuses.count > 0) {
            for (int i = 0; i < [downloadedStatuses count]; i ++) {
                Status *tmp_status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
                [_statuses insertObject:tmp_status atIndex:i];
                if ([downloadedStatuses count] - 1 == i) {
                    _max_id = tmp_status.idstr;
                }
            }
            Status *status = [[Status alloc] initWithDictionary:[downloadedStatuses objectAtIndex:0]];
            _since_id = status.idstr;
            [Utils presentNotificationWithText:[NSString stringWithFormat:@"更新了%ld条微博", downloadedStatuses.count]];
        }
        [self.tableView.header endRefreshing];
    }
    
    if ([type isEqualToString:@"history"]) { //上拉刷新历史微博
        NSArray *historyStatuses = [result objectForKey:@"statuses"];
        if (historyStatuses.count > 0) {
            for (int i = 1; i < [historyStatuses count]; i ++) {
                Status *tmp_status = [[Status alloc] initWithDictionary:historyStatuses[i]];
                [_statuses addObject:tmp_status];
                if ([historyStatuses count] - 1 == i) {
                    _max_id = tmp_status.idstr;
                }
            }
        }
        [self.tableView.footer endRefreshing];
    }
    NSLog(@"The currentLastStatusId is: %@", _max_id);
    [self.tableView reloadData];
}

-(void)fetchLatestStatuses
{
    NSString *url;
    if (!_since_id) {
        url = @"statuses/home_timeline.json";
    } else {
        url = [NSString stringWithFormat:@"statuses/home_timeline.json?since_id=%@", _since_id];
    }
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:url SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] type:@"refresh"];
    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"main error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        [Utils presentNotificationWithText:@"更新失败"];
        [self.tableView.header endRefreshing];
    }];
}

-(void)fetchHistoryStatuses
{
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:[NSString stringWithFormat:@"statuses/home_timeline.json?max_id=%@&count=20", _max_id] SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] type:@"history"];
    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"main footer error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        [Utils presentNotificationWithText:@"更新失败"];
        [self.tableView.footer endRefreshing];
    }];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (fabs(targetContentOffset->y+bHeight-self.tableView.contentSize.height) <= 250) {
        [self fetchHistoryStatuses];
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
    if ([_statuses count]) {
        return [_statuses count];
    } else return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[BBStatusTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    BBStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([_statuses count]) {
        Status *status = [self.statuses objectAtIndex:indexPath.section];
        cell.status = status;
        cell.delegate = self;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_statuses count]) {
        Status *status = [_statuses objectAtIndex:indexPath.section];
        return status.height;
    }
    else
    {
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBStatusDetailViewController *dtvc = [[BBStatusDetailViewController alloc] init];
    dtvc.title = @"Detail";
    dtvc.hidesBottomBarWhenPushed = YES;
    Status *status = [_statuses objectAtIndex:indexPath.section];
    dtvc.status = status;
    [self.navigationController pushViewController:dtvc animated:YES];
}

#pragma mark - BBStatusTableViewCellDelegate & support

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapAvatar:(UIImageView *)avatar
{
    NSLog(@"didTapAvatar");
    NSDictionary *params = @{@"uid": cell.status.user.idstr};
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
         profiletvc.uid = user.idstr;
         profiletvc.statuses = statuses;
         profiletvc.user = user;
         profiletvc.shouldNavBtnShown = NO;
         profiletvc.title = @"Profile";
         profiletvc.hidesBottomBarWhenPushed = YES;
         [Utils setupNavigationController:self.navigationController withUIViewController:profiletvc];
         [self.navigationController pushViewController:profiletvc animated:YES];
     }
               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error %@", error);
     }];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapCommentIcon:(UIImageView *)commentIcon
{
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:1]; //写评论
    updateStatusView.idStr = cell.status.idstr;
    updateStatusView.nameLabel.text = cell.status.user.screen_name;
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:updateStatusView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        updateStatusView.frame = CGRectMake(uSmallGap, statusBarHeight+uSmallGap, bWidth-2*uSmallGap, bHeight/2-5);
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {}];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapFavoriteIcon:(UIImageView *)favoriteIcon
{
    if (cell.status.favorited) {
        [favoriteIcon setImage:[UIImage imageNamed:@"fav_icon_3"]];
        NSDictionary *params = @{@"id": cell.status.idstr};
        [Utils weiboPostRequestWithAccount:[[AppDelegate delegate] defaultAccount] URL:@"favorites/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSLog(@"response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                [cell.status setFavorited:NO];
            }
            else {
                NSLog(@"收藏删除失败: %@", error);
            }
        }];
    }
    else
    {
        [favoriteIcon setImage:[UIImage imageNamed:@"faved_icon"]];
        NSDictionary *params = @{@"id": cell.status.idstr};
        [Utils weiboPostRequestWithAccount:[[AppDelegate delegate] defaultAccount] URL:@"favorites/create.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error) {
                NSLog(@"response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                [cell.status setFavorited:YES];
            }
            else {
                NSLog(@"收藏失败: %@", error);
            }
        }];
    }
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetIcon:(UIImageView *)retweetIcon
{
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:2]; //转发
    updateStatusView.idStr = cell.status.idstr;
    updateStatusView.nameLabel.text = @"转发";
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:updateStatusView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        updateStatusView.frame = CGRectMake(uSmallGap, statusBarHeight+uSmallGap, bWidth-2*uSmallGap, bHeight/2-5);
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {}];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetView:(UIView *)retweetView
{
    BBStatusDetailViewController *dtvc = [[BBStatusDetailViewController alloc] init];
    dtvc.title = @"Detail";
    dtvc.hidesBottomBarWhenPushed = YES;
    dtvc.status = cell.status.retweeted_status;
    
    [self.navigationController pushViewController:dtvc animated:YES];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell statusPictureTapped:(UITapGestureRecognizer *)tap
{
    NSMutableArray *largeUrls = @[].mutableCopy;
    for (NSString *str in cell.status.pic_urls) {
        [largeUrls addObject:[NSString middlePictureUrlConvertedFromThumbUrl:str]];
    }
    [self setImageBrowserWithImageUrls:largeUrls andTappedViewTag:tap.view.tag];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell retweetPictureTapped:(UITapGestureRecognizer *)tap
{
    NSMutableArray *largeUrls = @[].mutableCopy;
    for (NSString *str in cell.status.retweeted_status.pic_urls) {
        [largeUrls addObject:[NSString middlePictureUrlConvertedFromThumbUrl:str]];
    }
    [self setImageBrowserWithImageUrls:largeUrls andTappedViewTag:tap.view.tag];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapHotword:(NSString *)hotword
{
    NSLog(@"点击%@", hotword);
    if ([hotword hasPrefix:@"@"]) {
        NSDictionary *params = @{@"screen_name": [hotword substringFromIndex:1]};
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
         }];
    }
    if ([hotword hasPrefix:@"http"]) {
        //打开webview
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:hotword]];
        [self.navigationController presentViewController:sfvc animated:YES completion:^{}];
    }
    if ([hotword hasPrefix:@"#"]) {
        //热门话题
    }
}

-(void)setImageBrowserWithImageUrls:(NSMutableArray *)urls andTappedViewTag:(NSInteger)tag
{
    BBImageBrowserView *browserView = [[BBImageBrowserView alloc] initWithFrame:[UIScreen mainScreen].bounds withImageUrls:urls andImageTag:tag];
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:browserView];
}

@end
