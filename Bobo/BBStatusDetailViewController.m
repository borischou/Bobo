//
//  BBStatusDetailViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/8/20.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBStatusDetailViewController.h"

static NSString *reuseWBCell = @"reuseWBCell";
static NSString *reuseCMCell = @"reuseCMCell";

@interface BBStatusDetailViewController () <UITableViewDataSource, UITableViewDelegate, BBStatusTableViewCellDelegate, BBCommentTableViewCellDelegate, BBReplyCommentViewDelegate, TTTAttributedLabelDelegate, BBCommentBarViewDelegate>
{
    int _page;
}

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
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
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
    } completion:^(BOOL finished) {
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
    if (!_barView) {
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
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:[NSString stringWithFormat:@"comments/show.json?id=%@&page=%d", _status.idstr, _page] SLRequestHTTPMethod:SLRequestMethodGET parameters:nil completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]];
    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"detail error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        [Utils presentNotificationWithText:@"更新失败"];
        [self.tableView.header endRefreshing];
        [self.tableView.footer endRefreshing];
    }];
}

-(void)handleWeiboResult:(id)result
{
    if (!_comments) {
        _comments = @[].mutableCopy;
    }
    if (_page == 1) {
        _comments = nil;
        _comments = @[].mutableCopy;
        [self.tableView reloadData];
    }
    
    if (![[result objectForKey:@"comments"] isEqual:[NSNull null]]) {
        NSArray *commentsArray = [result objectForKey:@"comments"];
        if (commentsArray.count > 0) {
            for (NSDictionary *dict in commentsArray) {
                Comment *comment = [[Comment alloc] initWithDictionary:dict];
                [_comments addObject:comment];
            }
            _page += 1;
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
    if (section == 0) {
        return 1;
    }
    else
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
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return _status.height;
    }
    else
    {
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
        Comment *comment = [_comments objectAtIndex:indexPath.row];
        cell.comment = comment;
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
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
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

#pragma mark - BBReplyCommentViewDelegate & support

-(void)deleteRowForComment:(Comment *)comment
{
    NSInteger index = [_comments indexOfObject:comment];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
    [_comments removeObject:comment];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
}

-(void)replyView:(BBReplyCommentView *)replyView mask:(UIView *)mask didDeleteComment:(Comment *)comment
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除评论" message:@"是否删除此评论？" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //不管成败，先本地删除
        [self deleteRowForComment:comment];
        
        //调用删除接口
        NSDictionary *params = @{@"cid": comment.idstr? comment.idstr: @""};
        [Utils weiboPostRequestWithAccount:[[AppDelegate delegate] defaultAccount] URL:@"comments/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSString *notificationText = nil;
            if (!error) {
                NSLog(@"评论删除成功。");
                notificationText = @"评论删除成功";
            }
            else
            {
                NSLog(@"评论删除失败：%@", error);
                notificationText = [NSString stringWithFormat:@"评论删除失败: %@", error];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    mask.alpha = 0;
                    [replyView setFrame:CGRectMake(0, bHeight, bWidth, replyView.viewHeight)];
                } completion:^(BOOL finished) {
                    if (finished) {
                        [Utils presentNotificationWithText:notificationText];
                        [mask removeFromSuperview];
                        [replyView removeFromSuperview];
                    }
                }];
            });
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [mask removeFromSuperview];
        [replyView removeFromSuperview];
    }];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [replyView setAlpha:0];
        [mask setAlpha:0];
    } completion:^(BOOL finished) {}];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(void)replyView:(BBReplyCommentView *)replyView mask:(UIView *)mask didDisplayComment:(Comment *)comment
{
    [_comments insertObject:comment atIndex:0];
    [self.tableView reloadData];
    [replyView removeFromSuperview];
}

#pragma mark - BBCommentBarViewDelegate

-(void)commentBarView:(BBCommentBarView *)commentBarView didDisplayComment:(Comment *)comment
{
    [_comments insertObject:comment atIndex:0];
    [self.tableView reloadData];
}

@end
