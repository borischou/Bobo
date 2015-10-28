//
//  BBWeiboListTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

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
#import "Utils.h"
#import "BBGroupSelectView.h"

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

static NSString *homeTimeline = @"statuses/home_timeline.json";
static NSString *bilateralTimeline = @"statuses/bilateral_timeline.json";

static NSString *filepath = @"wbdata.plist";

typedef NS_ENUM(NSInteger, FetchResultType)
{
    FetchResultTypeRefresh,
    FetchResultTypeHistory
};

@interface BBMainStatusTableViewController () <BBStatusTableViewCellDelegate, TTTAttributedLabelDelegate, BBGroupSelectViewDelegate, UITabBarControllerDelegate>

@end

@implementation BBMainStatusTableViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _max_id = nil;
    _since_id = nil;
    
    //从沙盒获取上一次保存的分组枚举
    _groupNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"group"];
    if (!_groupNumber || _groupNumber == 0)
    { //所有微博
        _url = homeTimeline;
    }
    if (_groupNumber == 1)
    { //朋友微博
        _url = bilateralTimeline;
    }
    
    [self setNavBarBtn];
    
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
    _statuses = [self readStatusesFromPlist];
    
    [self setMJRefresh];
    
    if (_statuses.count > 0)
    {
        _since_id = [self firstIdFromStatuses:_statuses];
        _max_id = [self lastIdFromStatuses:_statuses];
        [self.tableView reloadData];
    }
    else
    {
        [self.tableView.header beginRefreshing];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.delegate = self;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.tabBarController.delegate = nil;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"净化吧");
    [Utils clearImageCache];
    [Utils clearDiskImages];
}

#pragma mark - Helpers

-(void)navigateToSettings
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:@"您尚未在系统设置中登录您的新浪微博账号，请在设置中登录您的新浪微博账号后再打开Friends浏览微博内容。是否跳转到系统设置？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                     {
                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:"]];
                                     }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                   {
                                       //取消
                                   }];
    [ac addAction:settingsAction];
    [ac addAction:cancelAction];
    [self.navigationController presentViewController:ac animated:YES completion:^{}];
}

-(NSString *)lastIdFromStatuses:(NSMutableArray *)statuses
{
    Status *lastOne = statuses.lastObject;
    return lastOne.idstr;
}

-(NSString *)firstIdFromStatuses:(NSMutableArray *)statuses
{
    Status *firstOne = statuses.firstObject;
    return firstOne.idstr;
}

-(NSMutableArray *)readStatusesFromPlist
{
    NSString *plistPath = [Utils plistPathForFilename:filepath];
    NSData *data = [NSData dataWithContentsOfFile:plistPath];
    NSDictionary *dict = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSMutableArray *statuses = @[].mutableCopy;
    if (![dict[@"statuses"] isEqual:[NSNull null]])
    {
        NSArray *results = [dict objectForKey:@"statuses"];
        if (results.count > 0)
        {
            for (NSDictionary *tmp_dict in results)
            {
                [statuses addObject:[[Status alloc] initWithDictionary:tmp_dict]];
            }
        }
    }
    return statuses;
}

//使用NSKeyedArchiver将微博数据模型字典转成NSData然后写入plist文件（由于微博数据字典过大无法直接写入）
-(void)saveStatusesToPlist:(NSArray *)statuses
{
    NSDictionary *dict = @{@"statuses": statuses};
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    
    //获取Library/Caches目录
    //将文件名拼在目录后面形成完整文件路径
    NSString *plistPath = [Utils plistPathForFilename:filepath];
    
    //将字典数据写入文件
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:plistPath])
    {
        BOOL isCreated = [manager createFileAtPath:plistPath contents:nil attributes:nil];
        NSLog(@"创建结果：%@", isCreated? @"成功": @"失败");
    }
    BOOL flag = [data writeToFile:plistPath atomically:YES];
    NSLog(@"写入结果：%@", flag? @"成功": @"失败");
}

-(void)setNavBarBtn
{
    UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    postBtn.frame = CGRectMake(0, 0, 23, 23);
    [postBtn setImage:[UIImage imageNamed:@"barbutton_icon_post"] forState:UIControlStateNormal];
    [postBtn addTarget:self action:@selector(postBarbuttonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *postBarBtn = [[UIBarButtonItem alloc] initWithCustomView:postBtn];
    self.navigationItem.rightBarButtonItem = postBarBtn;
    
    UIButton *groupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [groupBtn setFrame:CGRectMake(0, 0, 23, 23)];
    [groupBtn setImage:[UIImage imageNamed:@"group_tab_icon"] forState:UIControlStateNormal];
    [groupBtn addTarget:self action:@selector(groupBarbuttonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *groupBarBtn = [[UIBarButtonItem alloc] initWithCustomView:groupBtn];
    self.navigationItem.leftBarButtonItem = groupBarBtn;
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
    } completion:nil];
}

-(void)groupBarbuttonPressed
{
    AppDelegate *delegate = [AppDelegate delegate];
    BBGroupSelectView *groupView = [[BBGroupSelectView alloc] initWithGroupNumber:_groupNumber];
    groupView.groups = @[@"所有微博", @"朋友微博"];
    groupView.delegate = self;
    [delegate.window addSubview:groupView];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [groupView setFrame:CGRectMake(50, statusBarHeight, bWidth*0.6, bHeight/2)];
    } completion:nil];
}

#pragma mark - Weibo support

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (!_weiboAccount)
        {
            _weiboAccount = [[AppDelegate delegate] validWeiboAccount];
            if (_weiboAccount)
            {
                [self fetchLatestStatuses];
            }
            else
            {
                [self.tableView.header endRefreshing];
                [self navigateToSettings];
                [Utils presentNotificationWithText:@"更新失败"];
            }
        }
        else
        {
            [self fetchLatestStatuses];
        }
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchHistoryStatuses)];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
}

-(void)handleWeiboResult:(id)result fetchResultType:(NSInteger)type
{
    if (!_statuses)
    {
        _statuses = @[].mutableCopy;
    }
    if (type == FetchResultTypeRefresh)
    { //下拉刷新最新微博
        NSArray *downloadedStatuses = [result objectForKey:@"statuses"];
        if (downloadedStatuses.count > 0)
        {
            for (int i = 0; i < [downloadedStatuses count]; i ++)
            {
                Status *tmp_status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
                [_statuses insertObject:tmp_status atIndex:i];
            }
            NSDictionary *lastone = downloadedStatuses.lastObject;
            _max_id = lastone[@"idstr"];
            NSDictionary *firstone = downloadedStatuses.firstObject;
            _since_id = firstone[@"idstr"];
            [Utils presentNotificationWithText:[NSString stringWithFormat:@"更新了%ld条微博", downloadedStatuses.count]];
            
            [self shouldSaveStatusesToPlist];
        }
        [self.tableView.header endRefreshing];
    }
    
    if (type == FetchResultTypeHistory)
    { //上拉刷新历史微博
        NSArray *historyStatuses = [result objectForKey:@"statuses"];
        if (historyStatuses.count > 0) {
            for (int i = 1; i < [historyStatuses count]; i ++)
            {
                Status *tmp_status = [[Status alloc] initWithDictionary:historyStatuses[i]];
                [_statuses addObject:tmp_status];
            }
            NSDictionary *lastone = historyStatuses.lastObject;
            _max_id = lastone[@"idstr"];
        }
        [self.tableView.footer endRefreshing];
    }
    [self.tableView reloadData];
}

-(void)shouldSaveStatusesToPlist
{
    if (_statuses.count > 0) {
        __weak BBMainStatusTableViewController *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            //只写入最新20条微博数据
            NSMutableArray *plistarray = @[].mutableCopy;
            if (_statuses.count <= 20)
            {
                for (Status *status in _statuses)
                {
                    [plistarray addObject:[status convertToDictionary]];
                }
            }
            else
            {
                for (int i = 0; i < 20; i ++)
                {
                    Status *status = _statuses[i];
                    [plistarray addObject:[status convertToDictionary]];
                }
            }
            
            [weakSelf saveStatusesToPlist:plistarray];
        });
    }
}

-(void)fetchLatestStatuses
{
    NSString *requestUrl = _url;
    NSDictionary *param = nil;
    if (_since_id)
    {
        param = @{@"since_id": _since_id};
    }
    
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:requestUrl SLRequestHTTPMethod:SLRequestMethodGET parameters:param completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] fetchResultType:FetchResultTypeRefresh];
    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"main error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils presentNotificationWithText:@"更新失败"];
            [self.tableView.header endRefreshing];
        });
    }];
}

-(void)fetchHistoryStatuses
{
    NSString *requestUrl = _url;
    NSDictionary *param = @{@"max_id": _max_id, @"count": @"20"};
    
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:requestUrl SLRequestHTTPMethod:SLRequestMethodGET parameters:param completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] fetchResultType:FetchResultTypeHistory];
    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"main footer error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils presentNotificationWithText:@"更新失败"];
            [self.tableView.header endRefreshing];
        });
    }];
}

#pragma mark - UITabBarControllerDelegate

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{    
    AppDelegate *delegate = [AppDelegate delegate];
    if (delegate.currentIndex == tabBarController.selectedIndex)
    {
        [self.tableView.header beginRefreshing];
    }
    delegate.currentIndex = tabBarController.selectedIndex;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (fabs(targetContentOffset->y+bHeight-self.tableView.contentSize.height) <= 250)
    {
        [self fetchHistoryStatuses];
    }
}

#pragma mark - BBGroupSelectViewDelegate & Support

-(void)groupView:(BBGroupSelectView *)groupView didSelectGroupAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger selected = indexPath.row;
    _groupNumber = selected;
    switch (selected)
    {
        case 0:
            if (![_url isEqualToString:homeTimeline])
            {
                [self saveGroupNumber:0];
                _url = homeTimeline;
                [self clearStatuses];
                [self.tableView reloadData];
                [self.tableView.header beginRefreshing];
            }
            break;
        case 1:
            if (![_url isEqualToString:bilateralTimeline])
            {
                [self saveGroupNumber:1];
                _url = bilateralTimeline;
                [self clearStatuses];
                [self.tableView reloadData];
                [self.tableView.header beginRefreshing];
            }
        default:
            break;
    }
    [groupView maskViewTapped];
}

-(void)saveGroupNumber:(NSInteger)num
{
    [[NSUserDefaults standardUserDefaults] setInteger:num forKey:@"group"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)clearStatuses
{
    _since_id = nil;
    [_statuses removeAllObjects];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([_statuses count])
    {
        return [_statuses count];
    }
    else
    {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerClass:[BBStatusTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    BBStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([_statuses count])
    {
        Status *status = [self.statuses objectAtIndex:indexPath.section];
        cell.status = status;
        cell.tweetTextLabel.delegate = self;
        cell.retweetTextLabel.delegate = self;
        cell.delegate = self;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_statuses count])
    {
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

@end
