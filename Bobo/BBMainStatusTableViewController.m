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

static NSString *filename = @"wbdata";
static NSString *filepath = @"wbdata.plist";

typedef NS_ENUM(NSInteger, FetchResultType) {
    FetchResultTypeRefresh,
    FetchResultTypeHistory
};

@interface BBMainStatusTableViewController () <BBStatusTableViewCellDelegate, TTTAttributedLabelDelegate, BBGroupSelectViewDelegate>

@property (copy, nonatomic) NSString *max_id;
@property (copy, nonatomic) NSString *since_id;
@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) ACAccount *weiboAccount;
@property (strong, nonatomic) NSMutableArray *statuses;

@end

@implementation BBMainStatusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _max_id = nil;
    _since_id = nil;
    if (!_groupNumber || _groupNumber == 0) { //所有微博
        _url = homeTimeline;
    }
    if (_groupNumber == 1) { //朋友微博
        _url = bilateralTimeline;
    }
    [self setNavBarBtn];
    [self setMJRefresh];
    
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
    _statuses = [self readStatusesFromPlist];
    if (_statuses.count > 0)
    {
        _max_id = [self lastIdFromStatuses:_statuses];
        [self.tableView reloadData];
    }
    else
    {
        [self.tableView.header beginRefreshing];
    }
}

#pragma mark - Helpers

-(BOOL)validWeiboAccount
{
    AppDelegate *delegate = [AppDelegate delegate];
    delegate.weiboAccount = [Utils systemAccounts].firstObject;
    [delegate accessWeiboSystemAccount];
    return delegate.weiboAccount.username.length > 0? YES: NO;
}

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

-(NSMutableArray *)readStatusesFromPlist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [cachesDirectory stringByAppendingPathComponent:filepath];
    NSData *data = [NSData dataWithContentsOfFile:plistPath];
    NSDictionary *dict = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    //NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSMutableArray *statuses = @[].mutableCopy;
    if (![dict[@"statuses"] isEqual:[NSNull null]]) {
        NSArray *results = [dict objectForKey:@"statuses"];
        if (results.count > 0) {
            for (NSDictionary *tmp_dict in results) {
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    //将文件名拼在目录后面形成完整文件路径
    NSString *plistPath = [cachesDirectory stringByAppendingPathComponent:filepath];
    NSLog(@"PATH: %@", plistPath);
    
    //将字典数据写入文件
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:plistPath]) {
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
    } completion:^(BOOL finished) {
        if (finished) {
            //what are you gonna do
        }
    }];
}

-(void)groupBarbuttonPressed
{
    AppDelegate *delegate = [AppDelegate delegate];
    BBGroupSelectView *groupView = [[BBGroupSelectView alloc] init];
    groupView.groups = @[@"所有微博", @"朋友微博"];
    groupView.delegate = self;
    [delegate.window addSubview:groupView];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [groupView setFrame:CGRectMake(50, statusBarHeight, bWidth*0.6, bHeight/2)];
    } completion:^(BOOL finished) {}];
}

#pragma mark - Weibo support

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (![self validWeiboAccount])
        {
            [self.tableView.header endRefreshing];
            [self navigateToSettings];
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
    if (!_statuses) {
        _statuses = @[].mutableCopy;
    }
    if (type == FetchResultTypeRefresh) { //下拉刷新最新微博
        NSArray *downloadedStatuses = [result objectForKey:@"statuses"];
        if (downloadedStatuses.count > 0) {
            for (int i = 0; i < [downloadedStatuses count]; i ++) {
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
    
    if (type == FetchResultTypeHistory) { //上拉刷新历史微博
        NSArray *historyStatuses = [result objectForKey:@"statuses"];
        if (historyStatuses.count > 0) {
            for (int i = 1; i < [historyStatuses count]; i ++) {
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
    if (_since_id) {
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

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (fabs(targetContentOffset->y+bHeight-self.tableView.contentSize.height) <= 250) {
        [self fetchHistoryStatuses];
    }
}

#pragma mark - BBGroupSelectViewDelegate & Support

-(void)groupView:(BBGroupSelectView *)groupView didSelectGroupAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger selected = indexPath.row;
    switch (selected) {
        case 0:
            if ([_url isEqualToString:homeTimeline]) {
                return;
            } else {
                _url = homeTimeline;
                [self clearStatuses];
                [self.tableView reloadData];
                [self.tableView.header beginRefreshing];
            }
            [groupView maskViewTapped];
            break;
        case 1:
            if ([_url isEqualToString:bilateralTimeline]) {
                return;
            } else {
                _url = bilateralTimeline;
                [self clearStatuses];
                [self.tableView reloadData];
                [self.tableView.header beginRefreshing];
            }
            [groupView maskViewTapped];
        default:
            break;
    }
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
        cell.tweetTextLabel.delegate = self;
        cell.retweetTextLabel.delegate = self;
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
         dispatch_async(dispatch_get_main_queue(), ^{
             [Utils presentNotificationWithText:@"访问失败"];
         });
     }];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapCommentIcon:(UIImageView *)commentIcon
{
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:1]; //写评论
    updateStatusView.status = cell.status;
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utils presentNotificationWithText:@"删除成功"];
                });
            }
            else {
                NSLog(@"收藏删除失败: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utils presentNotificationWithText:@"删除失败"];
                });
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utils presentNotificationWithText:@"收藏成功"];
                });
            }
            else {
                NSLog(@"收藏失败: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utils presentNotificationWithText:@"收藏失败"];
                });
            }
        }];
    }
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetIcon:(UIImageView *)retweetIcon
{
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:2]; //转发
    updateStatusView.status = cell.status;
    updateStatusView.nameLabel.text = @"转发";
    if (cell.status.retweeted_status.text.length > 0) {
        updateStatusView.statusTextView.text = [NSString stringWithFormat:@"//@%@:%@", cell.status.user.screen_name, cell.status.text];
    }
    updateStatusView.statusTextView.selectedRange = NSMakeRange(0, 0); //光标起始位置
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

-(void)tableViewCell:(BBStatusTableViewCell *)cell didPressDeleteButton:(UIButton *)sender
{
    //delete the status
    AppDelegate *delegate = [AppDelegate delegate];
    if ([cell.status.user.idstr isEqualToString:delegate.user.idstr]) {
        UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"删除微博" message:@"是否删除此微博？" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSDictionary *params = @{@"id": cell.status.idstr};
            [Utils weiboPostRequestWithAccount:_weiboAccount URL:@"statuses/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (!error) {
                    NSLog(@"response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                        if (_statuses[indexPath.section]) {
                            [_statuses removeObjectAtIndex:indexPath.section];
                        }
                        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                        [Utils presentNotificationWithText:@"删除成功"];
                    });
                }
                else {
                    NSLog(@"收藏失败: %@", error);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Utils presentNotificationWithText:@"删除失败"];
                    });
                }
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //取消
        }];
        [alertcontroller addAction:deleteAction];
        [alertcontroller addAction:cancelAction];
        [self.navigationController presentViewController:alertcontroller animated:YES completion:^{}];
    }
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapStatusPicture:(UITapGestureRecognizer *)tap
{
    NSMutableArray *largeUrls = @[].mutableCopy;
    for (NSString *str in cell.status.pic_urls) {
        [largeUrls addObject:[NSString largePictureUrlConvertedFromThumbUrl:str]];
    }
    [self setImageBrowserWithImageUrls:largeUrls andTappedViewTag:tap.view.tag];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetPicture:(UITapGestureRecognizer *)tap
{
    NSMutableArray *largeUrls = @[].mutableCopy;
    for (NSString *str in cell.status.retweeted_status.pic_urls) {
        [largeUrls addObject:[NSString largePictureUrlConvertedFromThumbUrl:str]];
    }
    [self setImageBrowserWithImageUrls:largeUrls andTappedViewTag:tap.view.tag];
}

-(void)setImageBrowserWithImageUrls:(NSMutableArray *)urls andTappedViewTag:(NSInteger)tag
{
    BBImageBrowserView *browserView = [[BBImageBrowserView alloc] initWithFrame:[UIScreen mainScreen].bounds imageUrls:urls imageTag:tag];
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:browserView];
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
    if ([hotword hasPrefix:@"http"]) {
        //打开webview
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[hotword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
        [self.navigationController presentViewController:sfvc animated:YES completion:^{}];
    }
    if ([hotword hasPrefix:@"#"]) {
        //热门话题
    }
}

@end
