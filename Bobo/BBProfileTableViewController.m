//
//  BBProfileTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/22.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBProfileTableViewController.h"

static NSString *reuseCountsCell = @"countsCell";

typedef NS_ENUM(NSInteger, FetchResultType) {
    FetchResultTypeRefresh,
    FetchResultTypeHistory,
    FetchResultTypeCounts
};

@interface BBProfileTableViewController () <BBStatusTableViewCellDelegate, BBCountTableViewCellDelegate, TTTAttributedLabelDelegate, BBProfileMenuHeaderViewDelegate, BBAlbumCollectionViewControllerDelegate, UITabBarControllerDelegate>

@end

@implementation BBProfileTableViewController

#pragma mark - Life cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _originalTurnedOn = NO;
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
    if (_shouldNavBtnShown)
    {
        [self setNavBarBtn];
    }
    if (_user)
    {
        self.tableView.tableHeaderView = [self getAvatarView];
    }
    _currentLastStatusId = [self lastIdFromStatuses:_statuses];
    [self setMJRefresh];
    
    if (!_statuses || _statuses.count <= 0)
    {
        [self.tableView.header beginRefreshing];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeSomething) name:@"bobo" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.tabBarController.delegate = nil;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"让圣光净化一切！");
    [Utils clearImageCache];
    [Utils clearDiskImages];
}

#pragma mark - UIButtons

-(void)postBarbuttonPressed
{
    AppDelegate *delegate = [AppDelegate delegate];
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:updateStatusTypePost]; //0: 发微博
    updateStatusView.nameLabel.text = delegate.user.screen_name;
    [delegate.window addSubview:updateStatusView];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        updateStatusView.frame = CGRectMake(uSmallGap, statusBarHeight+uSmallGap, bWidth-2*uSmallGap, bHeight/2-5);
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {}];
}

-(void)loginBtnPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bobo" object:self];
    //获取系统账号数据库中的新浪微博账号数据
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *type = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierSinaWeibo];
    NSArray *accounts = [store accountsWithAccountType:type];
    _weiboAccount = accounts.firstObject;
    _uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    
    //若未授权则向用户申请授权
    if (_weiboAccount.accountType.accessGranted == NO)
    {
        [store requestAccessToAccountsWithType:type options:nil completion:^(BOOL granted, NSError *error)
        {
            if (granted == YES)
            { //授权成功
                NSLog(@"授权成功。");
                
                //本地尚未保存授权账号uid
                if (!_uid)
                {
                    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"account/get_uid.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        //获取本账号uid并保存在本地
                        NSError *error = nil;
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
                        NSString *uid = [NSString stringWithFormat:@"%@", dict[@"uid"]];
                        [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"uid"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"error: %@", error);
                    }];
                }
            }
            else
            {
                NSLog(@"授权失败, 错误: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utils presentNotificationWithText:@"授权失败"];
                });
            }
        }];
    }
    //用户已授权
    else
    {
        if (!_uid)
        {
            [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"account/get_uid.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
            {
                //获取本账号uid并保存在本地
                NSError *error = nil;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
                NSString *uid = [NSString stringWithFormat:@"%@", dict[@"uid"]];
                [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"uid"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
                       completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                NSLog(@"error: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utils presentNotificationWithText:@"更新失败"];
                });
            }];
        }
        else
        {
            UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"已登录" message:@"您已授权并登录微博" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
            {
                NSLog(@"OK action triggered.");
            }];
            [alertcontroller addAction:action];
            [self presentViewController:alertcontroller animated:YES completion:^{}];
        }
    }
}

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (!_weiboAccount)
        {
            _weiboAccount = [[AppDelegate delegate] validWeiboAccount];
            if (_weiboAccount)
            {
                [self fetchUserProfile];
                [self fetchUserLatestStatuses];
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
            [self fetchUserProfile];
            [self fetchUserLatestStatuses];
        }
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchUserHistoryStatuses)];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
}

-(UIView *)getAvatarView
{
    BBProfileHeaderView *avatarView = [[BBProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight/3.5)];
    avatarView.user = _user;
    [avatarView setNeedsLayout];
    return avatarView;
}

-(void)observeSomething
{
    NSLog(@"Notification Center usage: Profile view controller which registered 'bobo' to be the notification sender's name just observed that the button 'login' registered as 'bobo' in WeiboList view controller was pressed once.");
}

#pragma mark - Fetch requests

//https://api.weibo.com/2/users/show.json?uid=id_string
-(void)fetchUserProfile
{
    if (!_uid || _uid.length < 1)
    {
        AppDelegate *delegate = [AppDelegate delegate];
        if (delegate.uid || delegate.user.idstr)
        {
            [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"users/show.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:@{@"uid": delegate.uid? delegate.uid: delegate.user.idstr} completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                NSError *error = nil;
                [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] fetchResultType:FetchResultTypeCounts];
            }
                       completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                NSLog(@"error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utils presentNotificationWithText:@"更新失败"];
                    [self.tableView.header endRefreshing];
                });
                
            }];
        }
        else
        {
            [self.tableView.header endRefreshing];
            [Utils presentNotificationWithText:@"没有有效的uid"];
            [[AppDelegate delegate] fetchUserProfile];
        }
    }
    else
    {
        [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"users/show.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:@{@"uid": _uid} completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
            NSError *error = nil;
            [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] fetchResultType:FetchResultTypeCounts];
        }
                   completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            NSLog(@"error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [Utils presentNotificationWithText:@"更新失败"];
                [self.tableView.header endRefreshing];
            });
        }];
    }
}

//https://api.weibo.com/2/statuses/user_timeline.json?uid=id_string
-(void)fetchUserLatestStatuses
{
    if (!_uid)
    {
        AppDelegate *delegate = [AppDelegate delegate];
        _uid = delegate.uid? delegate.uid: delegate.user.idstr;
        if (!_uid || _uid.length == 0)
        {
            return;
        }
    }
    NSDictionary *params = @{@"uid": _uid};
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"statuses/user_timeline.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:params completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] fetchResultType:FetchResultTypeRefresh];
    }
               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        [Utils presentNotificationWithText:@"更新失败"];
        [self.tableView.header endRefreshing];
    }];
}

//https://api.weibo.com/2/statuses/user_timeline.json?count=count_num&max_id=id_string
-(void)fetchUserHistoryStatuses
{
    if (!_uid)
    {
        return;
    }
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"statuses/user_timeline.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:@{@"uid": _uid, @"count": @"20", @"max_id": _currentLastStatusId} completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] fetchResultType:FetchResultTypeHistory];
    }
               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"profile footer error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils presentNotificationWithText:@"更新失败"];
            [self.tableView.footer endRefreshing];
        });
        
    }];
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

-(void)setNavBarBtn
{
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(0, 0, 23, 23);
    [loginBtn setImage:[UIImage imageNamed:@"iconfont-denglu"] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *loginbarbtn = [[UIBarButtonItem alloc] initWithCustomView:loginBtn];
    self.navigationItem.leftBarButtonItem = loginbarbtn;
    
    UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    postBtn.frame = CGRectMake(0, 0, 23, 23);
    [postBtn setImage:[UIImage imageNamed:@"barbutton_icon_post"] forState:UIControlStateNormal];
    [postBtn addTarget:self action:@selector(postBarbuttonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *postBarBtn = [[UIBarButtonItem alloc] initWithCustomView:postBtn];
    self.navigationItem.rightBarButtonItem = postBarBtn;
}

-(void)handleWeiboResult:(id)result fetchResultType:(NSInteger)type
{
    if (type == FetchResultTypeCounts)
    {
        [self.tableView.header endRefreshing];
        _user = [[User alloc] initWithDictionary:result];
        self.tableView.tableHeaderView = [self getAvatarView];
    }
    
    NSMutableArray *downloadedStatuses = [result objectForKey:@"statuses"];
    if (!_statuses)
    {
        _statuses = @[].mutableCopy;
    }
    if (type == FetchResultTypeRefresh)
    {
        if (downloadedStatuses.count > 0)
        {
            _statuses = nil;
            _statuses = @[].mutableCopy;
            for (int i = 0; i < downloadedStatuses.count; i ++)
            {
                Status *status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
                if (!_originalTurnedOn)
                {
                    [_statuses addObject:status];
                }
                else
                {
                    if (!status.retweeted_status)
                    {
                        [_statuses addObject:status];
                    }
                }
            }
        }
    }
    if (type == FetchResultTypeHistory)
    {
        for (int i = 1; i < downloadedStatuses.count; i ++)
        {
            Status *status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
            if (!_originalTurnedOn)
            {
                [_statuses addObject:status];
            }
            else
            {
                if (!status.retweeted_status)
                {
                    [_statuses addObject:status];
                }
            }
        }
    }
    if ([self lastIdFromStatuses:_statuses])
    {
        _currentLastStatusId = [self lastIdFromStatuses:_statuses];
    }
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    [self.tableView reloadData];
}

-(User *)getUserProfile
{
    AppDelegate *delegate = [AppDelegate delegate];
    return delegate.user;
}

-(NSString *)lastIdFromStatuses:(NSMutableArray *)statuses
{
    Status *lastOne = statuses.lastObject;
    return lastOne.idstr;
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

#pragma mark - UITableView delegate & data source & Helpers

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [tableView registerClass:[BBCountTableViewCell class] forCellReuseIdentifier:reuseCountsCell];
        BBCountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCountsCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.user = _user;
        cell.delegate = self;
        return cell;
    }
    else
    {
        [tableView registerClass:[BBStatusTableViewCell class] forCellReuseIdentifier:@"home"];
        BBStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"home" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([_statuses count])
        {
            if ([_statuses count])
            {
                Status *status = [self.statuses objectAtIndex:indexPath.section-1];
                cell.status = status;
                cell.delegate = self;
                cell.tweetTextLabel.delegate = self;
                cell.retweetTextLabel.delegate = self;
            }
        }
        return cell;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        BBProfileMenuHeaderView *headerView = nil;
        if (_originalTurnedOn)
        {
            headerView = [[BBProfileMenuHeaderView alloc] initWithFrame:CGRectMake(0, 0, bWidth, 35) flag:menuButtonIndexOriginals];
        }
        else
        {
            headerView = [[BBProfileMenuHeaderView alloc] initWithFrame:CGRectMake(0, 0, bWidth, 35)];
        }
        headerView.delegate = self;
        return headerView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return bHeight/10;
    }
    else
    {
        Status *status = [_statuses objectAtIndex:indexPath.section-1];
        return status.height;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= 1)
    {
        BBStatusDetailViewController *dtvc = [[BBStatusDetailViewController alloc] init];
        dtvc.title = @"Detail";
        dtvc.hidesBottomBarWhenPushed = YES;
        dtvc.status = [_statuses objectAtIndex:indexPath.section-1];
        [self.navigationController pushViewController:dtvc animated:YES];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_statuses count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 35;
    }
    return 2;
}

-(void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

#pragma mark - UIScrollViewDelegate

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self setNavBarAlphaByYcord:scrollView.contentOffset.y];
//}
//
//-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
//{
//    NSLog(@"scrollViewDidScrollToTop: %f", scrollView.contentOffset.y);
//    [self.navigationController.navigationBar setAlpha:1.0];
//}

#pragma mark - BBProfileMenuHeaderViewDelegate & support

-(void)didClickMenuButtonAtIndex:(NSInteger)index
{
    //读取相册，所有微博或原创微博
    if (index == menuButtonIndexAll)
    {
        _currentIndex = menuButtonIndexAll;
        _originalTurnedOn = NO;
        [_statuses removeAllObjects];
        [self.tableView reloadData];
        [self.tableView.header beginRefreshing];
    }
    if (index == menuButtonIndexOriginals)
    {
        _currentIndex = menuButtonIndexOriginals;
        _originalTurnedOn = YES;
        [_statuses removeAllObjects];
        [self.tableView reloadData];
        [self.tableView.header beginRefreshing];
    }
    if (index == menuButtonIndexAlbum)
    {
        //此处不保存index，因为会压入新viewcontroller
        BBAlbumCollectionViewController *acvc = [[BBAlbumCollectionViewController alloc] initWithCollectionViewLayout:[self flowLayout]];
        acvc.user = _user;
        acvc.hidesBottomBarWhenPushed = YES;
        acvc.delegate = self;
        [self.navigationController pushViewController:acvc animated:YES];
    }
}

-(UICollectionViewFlowLayout *)flowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((bWidth-3)/4, (bWidth-3)/4);
    layout.minimumInteritemSpacing = 1.0;
    layout.minimumLineSpacing = 1.0;
    return layout;
}

#pragma mark - BBAlbumCollectionViewControllerDelegate

-(void)collectionViewControllerDidPushBack:(BBAlbumCollectionViewController *)collectionViewController
{
    BBProfileMenuHeaderView *menuView = (BBProfileMenuHeaderView *)[self.tableView footerViewForSection:0];
    [menuView moveLineAccordingToFlag:_currentIndex];
}

#pragma mark - TTTAttributedLabelDelegate & support

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result
{
    NSLog(@"pressed: %@", [label.text substringWithRange:result.range]);
    [self presentDetailViewWithHotword:[label.text substringWithRange:result.range]];
}

-(void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    NSLog(@"long pressed: %@", [label.text substringWithRange:result.range]);
    [self presentDetailViewWithHotword:[label.text substringWithRange:result.range]];
}

-(void)presentDetailViewWithHotword:(NSString *)hotword
{
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
             dispatch_async(dispatch_get_main_queue(), ^{
                 [Utils presentNotificationWithText:@"访问失败"];
             });
         }];
    }
    if ([hotword hasPrefix:@"http"])
    {
        //打开webview
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[hotword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
        [self.navigationController presentViewController:sfvc animated:YES completion:^{}];
    }
    if ([hotword hasPrefix:@"#"])
    {
        //热门话题
    }
}

@end
