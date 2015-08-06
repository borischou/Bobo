//
//  BBProfileTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/22.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import <UIImageView+WebCache.h>

#import "BBProfileTableVC.h"
#import "BBCountCell.h"
#import "AppDelegate.h"
#import "WeiboSDK.h"
#import "BBMeHeaderView.h"
#import "Status.h"
#import "BBHomelistTableViewCell.h"
#import "BBNetworkUtils.h"
#import "BBImageBrowserView.h"
#import "BBButtonbarCell.h"
#import "BBWBDetailsTableVC.h"
#import "NSString+Convert.h"
#import "UIButton+Bobtn.h"

#define kRedirectURI @"https://api.weibo.com/oauth2/default.html"
#define kAppKey @"916936343"
#define bWeiboDomain @"https://api.weibo.com/2/"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnHeight bHeight/25

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

static NSString *reuseCountsCell = @"countsCell";

@interface BBProfileTableVC () <BBImageBrowserProtocol>

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray *statuses;

@end

@implementation BBProfileTableVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.view.backgroundColor = bBGColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self fetchMyProfile];
    [self setMJRefresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeSomething) name:@"bobo" object:nil];
}

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.tableView.header beginRefreshing];
        [self fetchMyProfile];
        [self fetchMyWeibo];
    }];
}

-(UIView *)getAvatarView
{
    BBMeHeaderView *avatarView = [[BBMeHeaderView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight/3.5)];
    [avatarView.avatarView sd_setImageWithURL:[NSURL URLWithString:_user.avatar_large] placeholderImage:[UIImage imageNamed:@"bb_holder_profile_image"]];
    avatarView.name.text = _user.screen_name;
    
    return avatarView;
}

-(void)observeSomething
{
    NSLog(@"Notification Center usage: Profile view controller which registered 'bobo' to be the notification sender's name just observed that the button 'login' registered as 'bobo' in WeiboList view controller was pressed once.");
}

#pragma mark - Fetch requests

-(void)fetchMyProfile
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        [[[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else
    {
        NSMutableDictionary *params = @{}.mutableCopy;
        if (delegate.wbToken) {
            [params setObject:delegate.wbToken forKey:@"access_token"];
            [params setObject:delegate.wbCurrentUserID forKey:@"uid"];
            NSString *url = [bWeiboDomain stringByAppendingString:@"users/show.json"];
            [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"show"];
            }];
        }
        else
        {
            [self.tableView.header endRefreshing];
        }
    }
}

-(void)fetchMyWeibo
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        [[[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    else
    {
        NSMutableDictionary *params = @{}.mutableCopy;
        [params setObject:delegate.wbToken forKey:@"access_token"];
        [params setObject:delegate.wbCurrentUserID forKey:@"uid"];
        NSString *url = [bWeiboDomain stringByAppendingString:@"statuses/user_timeline.json"];
        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"me"];
        }];
    }
}

#pragma mark - Helpers

-(void)weiboRequestHandler:(WBHttpRequest *)request withResult:(id)result AndError:(NSError *)error andType:(NSString *)type
{
    if ([type isEqualToString:@"show"]) {
        [self.tableView.header endRefreshing];
        _user = [[User alloc] initWithDictionary:result];
        self.tableView.tableHeaderView = [self getAvatarView];
        [self.tableView reloadData];
    }
    if ([type isEqualToString:@"me"]) {
        _statuses = @[].mutableCopy;
        NSMutableArray *downloadedStatuses = [result objectForKey:@"statuses"];
        for (int i = 0; i < downloadedStatuses.count; i ++) {
            Status *status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
            [_statuses addObject:status];
        }
        [self.tableView.header endRefreshing];
        [self.tableView reloadData];
    }
}

#pragma mark - BBImageBrowserProtocol

-(void)setImageBrowserWithImageUrls:(NSMutableArray *)urls andTappedViewTag:(NSInteger)tag
{
    BBImageBrowserView *browserView = [[BBImageBrowserView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame withImageUrls:urls andImageTag:tag];
    [self.view.window addSubview:browserView];
}

#pragma mark - UITableView delegate & data source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [tableView registerClass:[BBCountCell class] forCellReuseIdentifier:reuseCountsCell];
        BBCountCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCountsCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.wbcounts.text = [NSString stringWithFormat:@"%ld", _user.statuses_count];
        cell.followercounts.text = [NSString stringWithFormat:@"%ld", _user.followers_count];
        cell.friendcounts.text = [NSString stringWithFormat:@"%ld", _user.friends_count];
        return cell;
    }
    else
    {
        if (indexPath.row == 0) {
            [tableView registerClass:[BBHomelistTableViewCell class] forCellReuseIdentifier:@"home"];
            BBHomelistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"home" forIndexPath:indexPath];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([_statuses count]) {
                Status *status = [_statuses objectAtIndex:indexPath.section-1];
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
            return cell;
        }
        else
        {
            [tableView registerClass:[BBButtonbarCell class] forCellReuseIdentifier:@"buttonBar"];
            BBButtonbarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buttonBar" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([_statuses count]) {
                Status *status = [_statuses objectAtIndex:indexPath.section-1];
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
            return cell;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return bHeight/10;
    } else
    {
        if (indexPath.row == 0) {
            Status *status = [_statuses objectAtIndex:indexPath.section-1];
            return status.height;
        } else {
            return bBtnHeight;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBWBDetailsTableVC *dtvc = [[BBWBDetailsTableVC alloc] initWithStyle:UITableViewStyleGrouped];
    dtvc.title = @"Detail";
    dtvc.hidesBottomBarWhenPushed = YES;
    dtvc.status = [self.statuses objectAtIndex:indexPath.section-1];
    dtvc.user = _user;
    [self.navigationController pushViewController:dtvc animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return 2;
    }
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
    return 2;
}

-(void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

@end
