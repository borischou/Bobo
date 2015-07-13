//
//  BBWeiboListTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBImageBrowserView.h"
#import "BBWeiboListTableVC.h"
#import "WeiboSDK.h"
#import "AppDelegate.h"
#import "BBHomelistTableViewCell.h"
#import "BBButtonbarCell.h"
#import "BBNetworkUtils.h"
#import "UIButton+Bobtn.h"
//#import "UserModel.h"
//#import "StatusModel.h"
#import "User.h"
#import "Status.h"
#import <MJRefresh/MJRefresh.h>

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kAppKey @"916936343"
#define bWeiboDomain @"https://api.weibo.com/2/"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnHeight bHeight/25

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

@interface BBWeiboListTableVC () <WBHttpRequestDelegate, UIAlertViewDelegate, BBImageBrowserProtocol>

@property (nonatomic) NSInteger currentLastStatusId;
@property (strong, nonatomic) NSString *currentLastStateIdStr;
@property (strong, nonatomic) UIAlertView *logoutAlertView;

@end

@implementation BBWeiboListTableVC

//@synthesize status;
static NSString *reuseIdentifier = @"reuseCell";
static NSString *reuseBarCellId = @"barCell";

//lazy boy
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
    self.view.backgroundColor = bBGColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setNavBarBtn];
    [self refreshStatus];
    [self setMJRefresh];
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

#pragma mark - Helpers

-(void)setMJRefresh
{
    __weak __typeof(self) weakSelf = self;
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshStatus];
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
        [alertView show];
    } else {
        if ([type isEqualToString:@"refresh"]) {
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
        
        if ([type isEqualToString:@"history"]) {
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

-(void)setNavBarBtn
{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(loginBtnPressed)];
    self.navigationItem.leftBarButtonItem = leftItem;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutBtnPressed)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)refreshStatus
{
    [self.tableView.header beginRefreshing];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.tableView.header endRefreshing];
        [alertView show];
    } else {
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
        NSString *url = [bWeiboDomain stringByAppendingString:@"statuses/home_timeline.json"];
        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"refresh"];
        }];
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
        NSString *para = [@"?max_id=" stringByAppendingString:[NSString stringWithFormat:@"%@", _currentLastStateIdStr]];
        NSString *url = [bWeiboDomain stringByAppendingFormat:@"statuses/home_timeline%@", para];
        NSLog(@"The full url is: %@", url);
        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"history"];
        }];
    }
}

-(void)loginBtnPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bobo" object:self];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"isLoggedIn: %d\ndelegate.wbCurrentUserID: %@\ndelegate.wbToken: %@", delegate.isLoggedIn, delegate.wbCurrentUserID, delegate.wbToken);
    if (!delegate.isLoggedIn || !delegate.wbCurrentUserID || !delegate.wbToken) {
        [WeiboSDK enableDebugMode:YES];
        [WeiboSDK registerApp:kAppKey];
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = kRedirectURI;
        request.scope = @"all";
        [WeiboSDK sendRequest:request];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Logged in" message:@"You are logged in already." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)logoutBtnPressed
{
    self.logoutAlertView = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to log it out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
    [self.logoutAlertView show];
}

-(NSString *)getNumStrFrom:(NSInteger)num
{
    NSString *numStr;
    if (num > 0 && num < 1000) {
        numStr = [NSString stringWithFormat:@"%ld", num];
    }
    if (num > 999 && num < 10000) {
        numStr = [NSString stringWithFormat:@"%dk", (int)num/1000];
    }
    if (num > 9999 && num < 10000 * 100) {
        numStr = [NSString stringWithFormat:@"%.1fw", (float)num/10000];
    }
    if (num >= 10000 * 100) {
        numStr = [NSString stringWithFormat:@"%dm", (int)num/10000*100];
    }
    return numStr;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.logoutAlertView]) {
        if (1 == buttonIndex) {
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [WeiboSDK logOutWithToken:delegate.wbToken delegate:self withTag:@"user1"];
            delegate.isLoggedIn = NO;
            [[NSUserDefaults standardUserDefaults] setValue:@(delegate.isLoggedIn) forKey:@"loginstatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark - WBHttpRequestDelegate

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

#pragma mark - Table view data source & delegate

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
                if (![[status.pic_urls objectAtIndex:i] isEqual:[NSNull null]]) {
                    [[cell.statusImgViews objectAtIndex:i] setImage:[status.pic_urls objectAtIndex:i]];
                } else {
                    [cell.statusImgViews[i] setImage:[UIImage imageNamed:@"timeline_image_loading"]];
                    [BBNetworkUtils fetchImageFromUrl:[status.pic_urls objectAtIndex:i] atIndex:i forImages:status.pic_urls withViews:cell.statusImgViews];
                }
            }
            
            //retweeted_status images
            for (int i = 0; i < [cell.status.retweeted_status.pic_urls count]; i ++) {
                if (![[status.retweeted_status.pic_urls objectAtIndex:i] isEqual:[NSNull null]]) {
                    [[cell.imgViews objectAtIndex:i] setImage:[status.retweeted_status.pic_urls objectAtIndex:i]];
                } else {
                    [cell.imgViews[i] setImage:[UIImage imageNamed:@"timeline_image_loading"]];
                    [BBNetworkUtils fetchImageFromUrl:[status.retweeted_status.pic_urls objectAtIndex:i] atIndex:i forImages:status.retweeted_status.pic_urls withViews:cell.imgViews];
                }
            }
        }
        return cell;
    }
    else {
        [tableView registerClass:[BBButtonbarCell class] forCellReuseIdentifier:reuseBarCellId];
        BBButtonbarCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseBarCellId forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([_statuses count]) {
            Status *status = [self.statuses objectAtIndex:indexPath.section];
            if (status.reposts_count > 0) {
                [cell.repostBtn setTitle:[NSString stringWithFormat:@"%@re", [self getNumStrFrom:status.reposts_count]] withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
            } else {
                [cell.repostBtn setTitle:@"Repost" withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
            }
            if (status.comments_count > 0) {
                [cell.commentBtn setTitle:[NSString stringWithFormat:@"%@ comts", [self getNumStrFrom:status.comments_count]] withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
            } else {
                [cell.commentBtn setTitle:@"Comment" withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];            }
            if (status.attitudes_count > 0) {
                [cell.likeBtn setTitle:[NSString stringWithFormat:@"%@ likes", [self getNumStrFrom:status.attitudes_count]] withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
            } else {
                [cell.likeBtn setTitle:@"Like" withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
            }
        }
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        if ([self.statuses count]) {
            Status *status = [self.statuses objectAtIndex:indexPath.section];
            NSLog(@"status.height: %f", status.height);
            return status.height;
        }
        else return 80;
    } else return bBtnHeight;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //push to detail
}

#pragma mark - Backups

-(void)fetchCurrentUserId
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        if (delegate.wbToken) {
            [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
            NSString *url = [bWeiboDomain stringByAppendingString:@"account/get_uid.json"];
            [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"uid"];
            }];
        } else NSLog(@"fetchUID failed: token doesn't exist.");
    }
}

@end
