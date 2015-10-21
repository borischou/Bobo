//
//  BBStatusDetailViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/8/20.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBStatusDetailViewController.h"

#import <MJRefresh/MJRefresh.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <SafariServices/SafariServices.h>
#import "BBProfileTableViewController.h"
#import "BBUpdateStatusView.h"
#import "BBStatusTableViewCell.h"
#import "BBCommentTableViewCell.h"
#import "BBImageBrowserView.h"
#import "NSString+Convert.h"
#import "AppDelegate.h"
#import "Comment.h"
#import "Utils.h"
#import "BBReplyCommentView.h"
#import "BBCommentBarView.h"
#import "BBNotificationView.h"

#define bBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define dComntBarViewHeight 60

#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define uSmallGap 5

#define bWeiboDomain @"https://api.weibo.com/2/"

static NSString *reuseWBCell = @"reuseWBCell";
static NSString *reuseCMCell = @"reuseCMCell";

@interface BBStatusDetailViewController () <UITableViewDataSource, UITableViewDelegate, BBStatusTableViewCellDelegate, BBCommentTableViewCellDelegate, BBReplyCommentViewDelegate, TTTAttributedLabelDelegate, BBUpdateStatusViewDelegate>
{
    int _page;
}

@property (strong, nonatomic) ACAccount *weiboAccount;
@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) BBCommentBarView *barView;

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

#pragma mark - Helpers

-(void)initCommentBarView
{
    if (!_barView) {
        _barView = [[BBCommentBarView alloc] initWithFrame:CGRectMake(0, bHeight, bWidth, dComntBarViewHeight) status:_status];
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
    if (indexPath.section == 1) {
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
         [Utils presentNotificationWithText:@"访问失败"];
     }];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapCommentIcon:(UIImageView *)commentIcon
{
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:1]; //写评论
    //updateStatusView.idStr = cell.status.idstr;
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
                });            }
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
    //updateStatusView.idStr = cell.status.idstr;
    updateStatusView.status = cell.status;
    updateStatusView.nameLabel.text = @"转发";
    if (_status.retweeted_status.text.length > 0) {
        updateStatusView.statusTextView.text = [NSString stringWithFormat:@"//@%@:%@", _status.user.screen_name, _status.text];
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
        [largeUrls addObject:[NSString middlePictureUrlConvertedFromThumbUrl:str]];
    }
    [self setImageBrowserWithImageUrls:largeUrls andTappedViewTag:tap.view.tag];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetPicture:(UITapGestureRecognizer *)tap
{
    NSMutableArray *largeUrls = @[].mutableCopy;
    for (NSString *str in cell.status.retweeted_status.pic_urls) {
        [largeUrls addObject:[NSString middlePictureUrlConvertedFromThumbUrl:str]];
    }
    [self setImageBrowserWithImageUrls:largeUrls andTappedViewTag:tap.view.tag];
}

-(void)setImageBrowserWithImageUrls:(NSMutableArray *)urls andTappedViewTag:(NSInteger)tag
{
    BBImageBrowserView *browserView = [[BBImageBrowserView alloc] initWithFrame:[UIScreen mainScreen].bounds imageUrls:urls imageTag:tag];
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:browserView];
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

-(void)replyView:(BBReplyCommentView *)replyView mask:(UIView *)mask didPressDeleteButton:(UIButton *)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除评论" message:@"是否删除此评论？" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //调用删除接口
        NSDictionary *params = @{@"cid": replyView.comment.idstr};
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
        NSLog(@"encoded url: %@", [hotword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]);
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[hotword stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
        [self.navigationController presentViewController:sfvc animated:YES completion:^{}];
    }
    if ([hotword hasPrefix:@"#"]) {
        //热门话题
    }
}

@end
