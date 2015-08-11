//
//  BBWBDetailsTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/7/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import "WeiboSDK.h"

#import "BBStatusDetailTableViewController.h"
#import "BBHomelistTableViewCell.h"
#import "BBNetworkUtils.h"
#import "AppDelegate.h"
#import "Comment.h"

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

#define bWeiboDomain @"https://api.weibo.com/2/"

@interface BBStatusDetailTableViewController ()

@property (copy, nonatomic) NSMutableArray *comments;

@end

@implementation BBStatusDetailTableViewController

static NSString *reuseWBCell = @"reuseWBCell";

#pragma mark - Lazy boys

-(Status *)status
{
    if (!_status) {
        _status = [[Status alloc] init];
    }
    return _status;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bBGColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setMJRefresh];
    [self.tableView.header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchLatestComments];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchHistoryComments)];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
}

#pragma mark - Fetch Comments

-(void)fetchLatestComments
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        [alertView show];
    } else {
        static int page = 1;
        NSMutableDictionary *extraParaDict = [NSMutableDictionary dictionary];
        [extraParaDict setObject:delegate.wbToken forKey:@"access_token"];
        NSString *para = [NSString stringWithFormat:@"id=%@&page=%d", _status.idstr, page++];
        NSString *url = [bWeiboDomain stringByAppendingFormat:@"comments/show.json?%@", para];
        NSLog(@"The full url is: %@", url);
        [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:extraParaDict queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
            [self weiboRequestHandler:httpRequest withResult:result AndError:error andType:@"comments"];
        }];
    }
}

-(void)fetchHistoryComments
{

}

-(void)weiboRequestHandler:(WBHttpRequest *)request withResult:(id)result AndError:(NSError *)error andType:(NSString *)type
{
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请求异常" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        [alertView show];
    } else {
        if ([type isEqualToString:@"comments"]) {
            NSDictionary *resultDict = (NSDictionary *)result;
            if (![[resultDict objectForKey:@"comments"] isEqual:[NSNull null]]) {
                NSArray *commentsArray = [resultDict objectForKey:@"comments"];
                for (NSDictionary *dict in commentsArray) {
                    Comment *comment = [[Comment alloc] initWithDictionary:dict];
                    [_comments addObject:comment];
                }
            }
        }
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _status.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[BBHomelistTableViewCell class] forCellReuseIdentifier:reuseWBCell];
    BBHomelistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseWBCell forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.status = _status;
    //avatar
    if (_status.user.avatar != nil) {
        cell.avatarView.image = _status.user.avatar;
    } else {
        cell.avatarView.image = [UIImage imageNamed:@"timeline_image_loading"];
        [BBNetworkUtils fetchAvatarForStatus:_status withCell:cell];
    }
    
    //status images
    for (int i = 0; i < [cell.status.pic_urls count]; i ++) {
        if (![[_status.images objectAtIndex:i] isEqual:[NSNull null]]) {
            [[cell.statusImgViews objectAtIndex:i] setImage:[_status.images objectAtIndex:i]];
        } else {
            [cell.statusImgViews[i] setImage:[UIImage imageNamed:@"timeline_image_loading"]];
            [BBNetworkUtils fetchImageFromUrl:[_status.pic_urls objectAtIndex:i] atIndex:i forImages:_status.images withViews:cell.statusImgViews];
        }
    }
    
    //retweeted_status images
    for (int i = 0; i < [cell.status.retweeted_status.pic_urls count]; i ++) {
        if (![[_status.retweeted_status.images objectAtIndex:i] isEqual:[NSNull null]]) {
            [[cell.imgViews objectAtIndex:i] setImage:[_status.retweeted_status.images objectAtIndex:i]];
        } else {
            [cell.imgViews[i] setImage:[UIImage imageNamed:@"timeline_image_loading"]];
            [BBNetworkUtils fetchImageFromUrl:[_status.retweeted_status.pic_urls objectAtIndex:i] atIndex:i forImages:_status.retweeted_status.images withViews:cell.imgViews];
        }
    }
    
    return cell;
}

@end
