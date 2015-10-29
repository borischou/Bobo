//
//  BBStatusDetailViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/8/20.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBStatusDetailViewController.h"
#import "BBDetailMenuHeaderView.h"
#import "Feedback.h"

typedef NS_ENUM(NSInteger, detailFetchResult)
{
    detailFetchResultRepost,
    detailFetchResultComment
};

static NSString *reuseWBCell = @"reuseWBCell";
static NSString *reuseCMCell = @"reuseCMCell";

@interface BBStatusDetailViewController () <UITableViewDataSource, UITableViewDelegate, BBStatusTableViewCellDelegate, BBCommentTableViewCellDelegate, BBReplyCommentViewDelegate, TTTAttributedLabelDelegate, BBCommentBarViewDelegate, BBDetailMenuHeaderViewDelegate>
{
    int _page, _repost_page;
}

@end

@implementation BBStatusDetailViewController

#pragma mark - Lazy boys

-(Status *)status
{
    if (!_status)
    {
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
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
    _commentTurnedOn = YES;
    [self setMJRefresh];
    [self.tableView.header beginRefreshing];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initCommentBarView];
    [self setNavBarAlphaByYcord:self.tableView.contentOffset.y];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setAlpha:1.0];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_barView setFrame:CGRectMake(0, bHeight, bWidth, dComntBarViewHeight)];
    }
                     completion:^(BOOL finished)
    {
        _barView.delegate = nil;
        _barView = nil;
        [_barView removeFromSuperview];
    }];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"净化吧");
    [Utils clearImageCache];
    [Utils clearDiskImages];
}

#pragma mark - Helpers

-(void)setNavBarAlphaByYcord:(CGFloat)y
{
    CGFloat distance = y;
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    [self.navigationController.navigationBar setAlpha:1-distance/navHeight];
}

-(void)initCommentBarView
{
    if (!_barView)
    {
        _barView = [[BBCommentBarView alloc] initWithFrame:CGRectMake(0, bHeight, bWidth, dComntBarViewHeight) status:_status];
        _barView.delegate = self;
        [self.view addSubview:_barView];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_barView setFrame:CGRectMake(0, bHeight-dComntBarViewHeight, bWidth, dComntBarViewHeight)];
        } completion:^(BOOL finished) {}];
    }
}

-(void)setMJRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (_commentTurnedOn)
        {
            _page = 1;
            [self fetchLatestComments];
        }
        else
        {
            _repost_page = 1;
            [self fetchLatestReposts];
        }
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fetchLatestComments)];
    [footer setTitle:@"上拉以获取更早微博" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
}

#pragma mark - Fetch Comments

-(void)fetchLatestReposts
{
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:[NSString stringWithFormat:@"statuses/repost_timeline.json?id=%@&page=%d", _status.idstr, _repost_page] SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] type:detailFetchResultRepost];
    }
               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"detail error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        [Utils presentNotificationWithText:@"更新失败"];
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
    }];
}

-(void)fetchLatestComments
{
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:[NSString stringWithFormat:@"comments/show.json?id=%@&page=%d", _status.idstr, _page] SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] type:detailFetchResultComment];
    }
               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"detail error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        [Utils presentNotificationWithText:@"更新失败"];
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
    }];
}

-(void)handleWeiboResult:(id)result type:(NSInteger)type
{
    if (type == detailFetchResultComment)
    {
        if (!_comments)
        {
            _comments = @[].mutableCopy;
        }
        if (_page == 1)
        {
            _comments = nil;
            _comments = @[].mutableCopy;
            [self.tableView reloadData];
        }
        if (![[result objectForKey:@"comments"] isEqual:[NSNull null]])
        {
            NSArray *commentsArray = [result objectForKey:@"comments"];
            if (commentsArray.count > 0)
            {
                for (NSDictionary *dict in commentsArray)
                {
                    Comment *comment = [[Comment alloc] initWithDictionary:dict];
                    [_comments addObject:comment];
                }
                _page += 1;
            }
        }
    }
    if (type == detailFetchResultRepost)
    {
        if (!_statuses)
        {
            _statuses = @[].mutableCopy;
        }
        if (_repost_page == 1)
        {
            _statuses = nil;
            _statuses = @[].mutableCopy;
            [self.tableView reloadData];
        }
        if (![[result objectForKey:@"reposts"] isEqual:[NSNull null]])
        {
            NSArray *statusArray = [result objectForKey:@"reposts"];
            if (statusArray.count > 0)
            {
                for (NSDictionary *dict in statusArray)
                {
                    Status *status = [[Status alloc] initWithDictionary:dict];
                    [_statuses addObject:status];
                }
                _repost_page += 1;
            }
        }
    }
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        if (_commentTurnedOn)
        {
            if (_comments.count)
            {
                return _comments.count;
            }
            else
            {
                return 0;
            }
        }
        else
        {
            if (_statuses.count)
            {
                return _statuses.count;
            }
            else
            {
                return 0;
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return _status.height;
    }
    else
    {
        if (_commentTurnedOn)
        {
            if (_comments.count > 0)
            {
                Comment *comment = [_comments objectAtIndex:indexPath.row];
                return comment.height;
            }
            else
            {
                return 0;
            }
            
        }
        else
        {
            if (_statuses.count > 0)
            {
                Status *status = [_statuses objectAtIndex:indexPath.row];
                return status.heightForRepost;
            }
            else
            {
                return 0;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [tableView registerClass:[BBStatusTableViewCell class] forCellReuseIdentifier:reuseWBCell];
        BBStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseWBCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.status = _status;
        cell.tweetTextLabel.delegate = self;
        cell.retweetTextLabel.delegate = self;
        cell.delegate = self;
        return cell;
    }
    else
    {
        [tableView registerClass:[BBCommentTableViewCell class] forCellReuseIdentifier:reuseCMCell];
        BBCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCMCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (_commentTurnedOn)
        {
            Comment *comment = [_comments objectAtIndex:indexPath.row];
            cell.comment = comment;
            cell.status = nil;
        }
        else
        {
            Status *status = [_statuses objectAtIndex:indexPath.row];
            cell.status = status;
            cell.comment = nil;
        }
        cell.commentTextLabel.delegate = self;
        cell.delegate = self;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        AppDelegate *delegate = [AppDelegate delegate];

        BBReplyCommentView *replyCommentView = [[BBReplyCommentView alloc] initWithFrame:CGRectMake(0, bHeight, bWidth, 150)];
        Comment *comment = [_comments objectAtIndex:indexPath.row];
        replyCommentView.comment = comment;
        replyCommentView.delegate = self;
        replyCommentView.shouldShowViewStatusOption = NO;
        int param = 0;
        if ([comment.user.idstr isEqualToString:delegate.user.idstr]
            || [comment.status.user.idstr isEqualToString:delegate.user.idstr])
        {
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 35;
    }
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
    }
    else
    {
        BBDetailMenuHeaderView *menuView;
        if (_commentTurnedOn)
        {
            menuView = [[BBDetailMenuHeaderView alloc] initWithFrame:CGRectMake(0, 0, bWidth, 35) flag:detailMenuButtonIndexComment];
        }
        else
        {
            menuView = [[BBDetailMenuHeaderView alloc] initWithFrame:CGRectMake(0, 0, bWidth, 35) flag:detailFetchResultRepost];
        }
        menuView.delegate = self;
        return menuView;
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setNavBarAlphaByYcord:scrollView.contentOffset.y];
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScrollToTop: %f", scrollView.contentOffset.y);
    [self.navigationController.navigationBar setAlpha:1.0];
}

#pragma mark - BBDetailMenuHeaderDelegate

-(void)didClickMenuButtonAtIndex:(NSInteger)index
{
    if (index == detailMenuButtonIndexComment)
    {
        if (_commentTurnedOn)
        {
            return;
        }
        else
        {
            _commentTurnedOn = YES;
            if (_comments.count == 0)
            {
                [self.tableView.header beginRefreshing];
            }
            else
            {
                [self.tableView reloadData];
            }
        }
    }
    if (index == detailMenuButtonIndexRepost)
    {
        _commentTurnedOn = NO;
        if (_statuses.count == 0 || !_statuses)
        {
            [self.tableView.header beginRefreshing];
        }
        else
        {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - BBCommentTableViewCellDelegate

-(void)commentTableViewCell:(BBCommentTableViewCell *)cell didTapAvatarView:(UIImageView *)avatarView
{
    NSDictionary *params = @{@"uid": cell.comment.user.idstr};
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

#pragma mark - BBCommentBarViewDelegate

-(void)commentBarView:(BBCommentBarView *)commentBarView didDisplayComment:(Comment *)comment
{
    [_comments insertObject:comment atIndex:0];
    [self.tableView reloadData];
}

@end
