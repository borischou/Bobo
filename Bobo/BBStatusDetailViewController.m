//
//  BBStatusDetailViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/8/20.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBStatusDetailViewController.h"

#import <MJRefresh/MJRefresh.h>
#import "WeiboSDK.h"

#import "BBStatusTableViewCell.h"
#import "BBCommentTableViewCell.h"
#import "BBNetworkUtils.h"
#import "AppDelegate.h"
#import "Comment.h"
#import "BBReplyCommentView.h"
#import "BBCommentBarView.h"

#define bBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define dComntBarViewHeight 60

#define bWeiboDomain @"https://api.weibo.com/2/"

static NSString *reuseWBCell = @"reuseWBCell";
static NSString *reuseCMCell = @"reuseCMCell";

@interface BBStatusDetailViewController () <UITableViewDataSource, UITableViewDelegate, WBHttpRequestDelegate> {
    int _page;
}

@property (copy, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) BBCommentBarView *barView;
@property (strong, nonatomic) WBHttpRequest *wbRequest;

@end

@implementation BBStatusDetailViewController

#pragma mark - Lazy boys

-(Status *)status
{
    if (!_status) {
        _status = [[Status alloc] init];
    }
    return _status;
}

-(void)viewDidLoad
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight-dComntBarViewHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = bBGColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    self.view.backgroundColor = bBGColor;

    _wbRequest = [[WBHttpRequest alloc] init];
    _wbRequest.delegate = self;

    [self setMJRefresh];
    [self.tableView.header beginRefreshing];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initCommentBarView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_barView setFrame:CGRectMake(0, bHeight, bWidth, dComntBarViewHeight)];
    } completion:^(BOOL finished) {
        _barView = nil;
        [_barView removeFromSuperview];
    }];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_wbRequest disconnect];
    _wbRequest.delegate = nil;
}

#pragma mark - Helpers

-(void)initCommentBarView
{
    if (!_barView) {
        _barView = [[BBCommentBarView alloc] initWithFrame:CGRectMake(0, bHeight, bWidth, dComntBarViewHeight) status:_status];
        [self.view addSubview:_barView];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_barView setFrame:CGRectMake(0, bHeight-dComntBarViewHeight, bWidth, dComntBarViewHeight)];
        } completion:^(BOOL finished) {
        }];
    }
}

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self fetchLatestComments];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchLatestComments)];
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
    }
    else
    {
        NSString *para = [NSString stringWithFormat:@"id=%@&page=%d", _status.idstr, _page];
        NSString *url = [bWeiboDomain stringByAppendingFormat:@"comments/show.json?%@", para];
        NSLog(@"The full url is: %@", url);
        
        [WBHttpRequest requestWithAccessToken:delegate.wbToken url:url httpMethod:@"GET" params:nil delegate:self withTag:@"comment"];
    }
}

#pragma mark - WBHttpRequestDelegate

-(void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    [[[UIAlertView alloc] initWithTitle:@"请求异常" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"RESPONSE: %@", response);
}

-(void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)result
{
    if ([request.tag isEqualToString:@"comment"]) {
        if (!_comments) {
            _comments = @[].mutableCopy;
        }
        if (_page == 1) {
            _comments = nil;
            _comments = @[].mutableCopy;
        }
        
        NSError *error = nil;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&error];
        
        if (error) {
            NSLog(@"JSON ERROR: %@", error);
        }
        
        if (![[resultDict objectForKey:@"comments"] isEqual:[NSNull null]]) {
            NSArray *commentsArray = [resultDict objectForKey:@"comments"];
            if (commentsArray.count > 0) {
                for (NSDictionary *dict in commentsArray) {
                    Comment *comment = [[Comment alloc] initWithDictionary:dict];
                    [_comments addObject:comment];
                }
                _page += 1;
            }
        }
    }
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else
    {
        if (_comments.count) {
            return _comments.count;
        }
        else
        {
            return 0;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return _status.height;
    } else {
        Comment *comment = [_comments objectAtIndex:indexPath.row];
        return comment.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [tableView registerClass:[BBStatusTableViewCell class] forCellReuseIdentifier:reuseWBCell];
        BBStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseWBCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.status = _status;
        return cell;
    }
    else
    {
        [tableView registerClass:[BBCommentTableViewCell class] forCellReuseIdentifier:reuseCMCell];
        BBCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCMCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        Comment *comment = [_comments objectAtIndex:indexPath.row];
        cell.comment = comment;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        AppDelegate *delegate = [AppDelegate delegate];

        BBReplyCommentView *replyCommentView = [[BBReplyCommentView alloc] initWithFrame:CGRectMake(0, bHeight, bWidth, 150)];
        Comment *comment = [_comments objectAtIndex:indexPath.row];
        replyCommentView.cidStr = comment.idstr;
        replyCommentView.idStr = _status.idstr;
        replyCommentView.shouldShowViewStatusOption = NO;
        int param = 0;
        if ([comment.user.idstr isEqualToString:delegate.user.idstr]) {
            replyCommentView.shouldShowDeleteOption = YES;
            param = 1;
        } else {
            replyCommentView.shouldShowDeleteOption = NO;
            param = 0;
        }
        [delegate.window addSubview:replyCommentView];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [replyCommentView setFrame:CGRectMake(0, bHeight-(3*50+param*50), bWidth, 3*50+param*50)];
        } completion:^(BOOL finished) {}];
    }
}

@end
