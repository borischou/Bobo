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

typedef NS_ENUM(NSInteger, FetchResultType)
{
    FetchResultTypeRefresh,
    FetchResultTypeHistory
};

typedef NS_ENUM(NSInteger, messageType)
{
    messageTypeToMe,
    messageTypeByMe,
    messageTypeMentionMe,
    messageTypeAll
};

@interface BBMessageViewController () <UIScrollViewDelegate, UITabBarControllerDelegate, BBMessageMenuViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) BBMessageMenuView *menuView;
@property (strong, nonatomic) BBMessageTableView *messageTableView;
@property (strong, nonatomic) BBMessageTableView *byMeTableView;
@property (strong, nonatomic) BBMessageTableView *mentionTableView;
@property (strong, nonatomic) BBMessageTableView *allTableView;

@property (strong, nonatomic) BBMessageTableView *currentTableView;

@property (strong, nonatomic) NSMutableArray *maxids;
@property (strong, nonatomic) NSMutableArray *sinceids;
@property (copy, nonatomic) NSString *uri;

@property (strong, nonatomic) ACAccount *weiboAccount;

@end

@implementation BBMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    AppDelegate *delegate = [AppDelegate delegate];
    
    _weiboAccount = [delegate defaultAccount];
    
    _uri = @"to_me";
    _maxids = @[[NSNull null], [NSNull null], [NSNull null], [NSNull null]].mutableCopy;
    _sinceids = @[[NSNull null], [NSNull null], [NSNull null], [NSNull null]].mutableCopy;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, mMenuHeight, bWidth, mTableViewHeight)];
    _scrollView.contentSize = CGSizeMake(bWidth*4, mTableViewHeight);
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
    
    [self setMJRefreshWithTableView:_messageTableView flag:messageTypeToMe];
    [_messageTableView.header beginRefreshing];
    _currentTableView = _messageTableView;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"让圣光净化一切！");
    [Utils clearImageCache];
    [Utils clearDiskImages];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.delegate = self;
    AppDelegate *delegate = [AppDelegate delegate];
    [_menuView setBadgeValue:delegate.atMeIncrement];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.tabBarController.delegate = nil;
}

#pragma mark - Helpers

-(void)navigateToSettings
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:@"您尚未在系统设置中登录您的新浪微博账号，请在设置中登录您的新浪微博账号后再打开Friends浏览微博内容。是否跳转到系统设置？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utils preferenceSinaWeiboURL]]];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        //取消
    }];
    [ac addAction:settingsAction];
    [ac addAction:cancelAction];
    [self.navigationController presentViewController:ac animated:YES completion:^{}];
}

#pragma mark - UITabBarControllerDelegate

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    AppDelegate *delegate = [AppDelegate delegate];
    if (delegate.currentIndex == tabBarController.selectedIndex)
    {
        [_currentTableView.header beginRefreshing];
    }
    delegate.currentIndex = tabBarController.selectedIndex;
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
    if (scrollView.contentOffset.x == 0)
    { //to_me
        [_menuView moveLineAccordingToFlag:messageTypeToMe];
        _uri = @"to_me";
        if (!_messageTableView)
        {
            _messageTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(0, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_messageTableView];
            [self setMJRefreshWithTableView:_messageTableView flag:messageTypeToMe];
            [_messageTableView.header beginRefreshing];
            _currentTableView = _messageTableView;
        }
    }
    if (scrollView.contentOffset.x == bWidth)
    { //by_me
        [_menuView moveLineAccordingToFlag:messageTypeByMe];
        _uri = @"by_me";
        if (!_byMeTableView)
        {
            _byMeTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(bWidth, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_byMeTableView];
            [self setMJRefreshWithTableView:_byMeTableView flag:messageTypeByMe];
            [_byMeTableView.header beginRefreshing];
            _currentTableView = _byMeTableView;
        }
    }
    if (scrollView.contentOffset.x == bWidth*2)
    { //mentions
        [_menuView moveLineAccordingToFlag:messageTypeMentionMe];
        _uri = @"mentions";
        if (!_mentionTableView)
        {
            _mentionTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(bWidth*2, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_mentionTableView];
            [self setMJRefreshWithTableView:_mentionTableView flag:messageTypeMentionMe];
            [_mentionTableView.header beginRefreshing];
            _currentTableView = _mentionTableView;
        }
    }
    if (scrollView.contentOffset.x == bWidth*3)
    { //timeline
        [_menuView moveLineAccordingToFlag:messageTypeAll];
        _uri = @"timeline";
        if (!_allTableView)
        {
            _allTableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(bWidth*3, 0, bWidth, mTableViewHeight) style:UITableViewStyleGrouped];
            [scrollView addSubview:_allTableView];
            [self setMJRefreshWithTableView:_allTableView flag:messageTypeAll];
            [_allTableView.header beginRefreshing];
            _currentTableView = _allTableView;
        }
    }
}

#pragma mark - Weibo support

-(void)setMJRefreshWithTableView:(BBMessageTableView *)tableView flag:(NSInteger)flag
{
    tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _weiboAccount = [[AppDelegate delegate] validWeiboAccount];
        if (!_weiboAccount)
        {
            if (_weiboAccount)
            {
                [self fetchLatestCommentsWithTableView:tableView flag:flag];
            }
            else
            {
                [tableView.header endRefreshing];
                [self navigateToSettings];
                [Utils presentNotificationWithText:@"更新失败"];
            }
        }
        else
        {
            [self fetchLatestCommentsWithTableView:tableView flag:flag];
        }
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self fetchHistoryCommentsWithTableView:tableView flag:flag];
    }];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    tableView.footer = footer;
}

-(void)handleWeiboResult:(id)result fetchResultType:(NSInteger)type forTableView:(BBMessageTableView *)tableView flag:(NSInteger)flag
{
    if (type == FetchResultTypeRefresh)
    { //下拉刷新最新消息
        NSArray *downloadedComments = [result objectForKey:@"comments"];
        if (downloadedComments.count > 0)
        {
            for (int i = 0; i < [downloadedComments count]; i ++)
            {
                Comment *tmp_comment = [[Comment alloc] initWithDictionary:downloadedComments[i]];
                [tableView.comments insertObject:tmp_comment atIndex:i];
            }
            NSDictionary *lastone = downloadedComments.lastObject;
            _maxids[flag] = lastone[@"idstr"];
            NSDictionary *firstone = downloadedComments.firstObject;
            _sinceids[flag] = firstone[@"idstr"];
        }
        [tableView.header endRefreshing];
    }
    
    if (type == FetchResultTypeHistory)
    { //上拉刷新历史消息
        NSArray *historyMessages = [result objectForKey:@"statuses"];
        if (historyMessages.count > 0)
        {
            for (int i = 1; i < [historyMessages count]; i ++)
            {
                Comment *tmp_comment = [[Comment alloc] initWithDictionary:historyMessages[i]];
                [tableView.comments addObject:tmp_comment];
            }
            NSDictionary *lastone = historyMessages.lastObject;
            _maxids[flag] = lastone[@"idstr"];
        }
        [tableView.footer endRefreshing];
    }
    [tableView reloadData];
    NSLog(@"The currentLastStatusId is: %@", _maxids[flag]);
}

-(void)fetchLatestCommentsWithTableView:(BBMessageTableView *)tableView flag:(NSInteger)flag
{
    NSString *url;
    if ([_sinceids[flag] isEqual:[NSNull null]])
    {
        url = [NSString stringWithFormat:@"comments/%@.json", _uri];
    }
    else
    {
        url = [NSString stringWithFormat:@"comments/%@.json?since_id=%@", _uri, _sinceids[flag]];
    }
    
    UITabBarItem *messageTab = self.tabBarController.tabBar.items[1];
    
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:url SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSError *error = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if ([_uri isEqualToString:@"to_me"])
        {
            NSInteger toMeCount = [result[@"total_number"] integerValue];
            
            NSInteger oldToMeCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"count_to_me"] integerValue];
            NSInteger increment = labs(toMeCount-oldToMeCount);
            NSInteger badgeValue = messageTab.badgeValue.integerValue-increment;
            
            messageTab.badgeValue = messageTab.badgeValue.integerValue-increment > 0? [NSString stringWithFormat:@"%ld", (long)badgeValue]: nil;
            
            [[NSUserDefaults standardUserDefaults] setObject:@(toMeCount) forKey:@"count_to_me"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self handleWeiboResult:result fetchResultType:FetchResultTypeRefresh forTableView:_messageTableView flag:messageTypeToMe];
        }
        if ([_uri isEqualToString:@"by_me"])
        {
            [self handleWeiboResult:result fetchResultType:FetchResultTypeRefresh forTableView:_byMeTableView flag:messageTypeByMe];
        }
        if ([_uri isEqualToString:@"mentions"])
        {
            NSInteger atMeCount = [result[@"total_number"] integerValue];
            
            NSInteger oldAtMeCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"count_at_me"] integerValue];
            NSInteger increment = labs(atMeCount-oldAtMeCount);
            NSInteger badgeValue = messageTab.badgeValue.integerValue-increment;
            
            messageTab.badgeValue = messageTab.badgeValue.integerValue-increment > 0? [NSString stringWithFormat:@"%ld", (long)badgeValue]: nil;
            
            [[NSUserDefaults standardUserDefaults] setObject:@(atMeCount) forKey:@"count_at_me"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_menuView setBadgeValue:0];
            [self handleWeiboResult:result fetchResultType:FetchResultTypeRefresh forTableView:_mentionTableView flag:messageTypeMentionMe];
        }
        if ([_uri isEqualToString:@"timeline"])
        {
            [self handleWeiboResult:result fetchResultType:FetchResultTypeRefresh forTableView:_allTableView flag:messageTypeAll];
        }
    }
               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"message error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils presentNotificationWithText:@"更新失败"];
            [tableView.header endRefreshing];
        });
        
    }];
}

-(void)fetchHistoryCommentsWithTableView:(BBMessageTableView *)tableView flag:(NSInteger)flag
{
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:[NSString stringWithFormat:@"comments/%@.json?max_id=%@&count=20", _uri, _maxids[flag]] SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if ([_uri isEqualToString:@"to_me"])
        {
            [self handleWeiboResult:result fetchResultType:FetchResultTypeHistory forTableView:_messageTableView flag:messageTypeToMe];
        }
        if ([_uri isEqualToString:@"by_me"])
        {
            [self handleWeiboResult:result fetchResultType:FetchResultTypeHistory forTableView:_byMeTableView flag:messageTypeByMe];
        }
        if ([_uri isEqualToString:@"mentions"])
        {
            [self handleWeiboResult:result fetchResultType:FetchResultTypeHistory forTableView:_mentionTableView flag:messageTypeMentionMe];
        }
        if ([_uri isEqualToString:@"timeline"])
        {
            [self handleWeiboResult:result fetchResultType:FetchResultTypeHistory forTableView:_allTableView flag:messageTypeAll];
        }
    }
               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils presentNotificationWithText:@"更新失败"];
            [tableView.footer endRefreshing];
        });
        
    }];
}

@end
