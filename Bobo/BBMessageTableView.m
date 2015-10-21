//
//  BBMessageTableView.m
//  Bobo
//
//  Created by Zhouboli on 15/9/2.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBMessageTableView.h"
#import <SafariServices/SafariServices.h>
#import "BBMessageTableViewCell.h"
#import "BBStatusDetailViewController.h"
#import "BBProfileTableViewController.h"
#import "BBMessageViewController.h"
#import "BBReplyCommentView.h"
#import "AppDelegate.h"
#import "Utils.h"

#define bBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

static NSString *messageCell = @"messageCell";

@interface BBMessageTableView () <UITableViewDataSource, UITableViewDelegate, BBMessageTableViewCellDelegate, TTTAttributedLabelDelegate, BBReplyCommentViewDelegate>

@end

@implementation BBMessageTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = bBGColor;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        _comments = @[].mutableCopy;
        self.dataSource = self;
        self.delegate = self;
        [self registerClass:[BBMessageTableViewCell class] forCellReuseIdentifier:messageCell];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _comments.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [_comments objectAtIndex:indexPath.row];
    return comment.heightForMessageCell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCell forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_comments.count > 0) {
        Comment *comment = [_comments objectAtIndex:indexPath.row];
        cell.comment = comment;
        cell.delegate = self;
        cell.tweetTextLabel.delegate = self;
        cell.retweetTextLabel.delegate = self;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [_comments objectAtIndex:indexPath.row];
    BBReplyCommentView *replyView = [[BBReplyCommentView alloc] initWithFrame:CGRectMake(0, bHeight, bWidth, 50*5)];
    replyView.comment = comment;
    replyView.delegate = self;
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:replyView];
    replyView.shouldShowViewStatusOption = YES;
    CGRect replyRect;
    if ([comment.status.user.idstr isEqualToString:delegate.user.idstr]) //评论的微博是自己发的
    {
        replyView.shouldShowDeleteOption = YES;
        replyRect = CGRectMake(0, bHeight-50*5, bWidth, 50*5);
    }
    else if ([comment.user.idstr isEqualToString:delegate.user.idstr]) //评论是自己发的
    {
        replyView.shouldShowDeleteOption = YES;
        replyRect = CGRectMake(0, bHeight-50*5, bWidth, 50*5);
    }
    else
    {
        replyView.shouldShowDeleteOption = NO;
        replyRect = CGRectMake(0, bHeight-50*4, bWidth, 50*4);
    }
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [replyView setFrame:replyRect];
    } completion:^(BOOL finished) {}];
}

#pragma mark - BBMessageTableViewCellDelegate

-(void)tableViewCell:(BBMessageTableViewCell *)cell didTapAvatarView:(UIImageView *)avatarView
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
         UITabBarController *uitbc = (UITabBarController *)self.window.rootViewController;
         UINavigationController *uinvc = uitbc.selectedViewController;
         BBMessageViewController *mvc = uinvc.viewControllers.firstObject;
         
         BBProfileTableViewController *profiletvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
         profiletvc.uid = user.idstr;
         profiletvc.statuses = statuses;
         profiletvc.user = user;
         profiletvc.shouldNavBtnShown = NO;
         profiletvc.title = @"Profile";
         profiletvc.hidesBottomBarWhenPushed = YES;
         [Utils setupNavigationController:mvc.navigationController withUIViewController:profiletvc];
         [mvc.navigationController pushViewController:profiletvc animated:YES];
     }
               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error %@", error);
         dispatch_async(dispatch_get_main_queue(), ^{
             [Utils presentNotificationWithText:@"访问失败"];
         });
     }];
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
    UITabBarController *uitbc = (UITabBarController *)self.window.rootViewController;
    
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
             UITabBarController *uitbc = (UITabBarController *)self.window.rootViewController;
             UINavigationController *uinvc = uitbc.selectedViewController;
             BBMessageViewController *mvc = uinvc.viewControllers.firstObject;
             
             BBProfileTableViewController *profiletvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
             [Utils setupNavigationController:mvc.navigationController withUIViewController:profiletvc];
             profiletvc.uid = user.idstr;
             profiletvc.statuses = statuses;
             profiletvc.user = user;
             profiletvc.shouldNavBtnShown = NO;
             profiletvc.title = @"Profile";
             profiletvc.hidesBottomBarWhenPushed = YES;
             [mvc.navigationController pushViewController:profiletvc animated:YES];
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
        [uitbc.selectedViewController.navigationController presentViewController:sfvc animated:YES completion:^{}];
    }
    if ([hotword hasPrefix:@"#"]) {
        //热门话题
    }
}

#pragma mark - BBReplyCommentViewDelegate & support

-(void)deleteRowForComment:(Comment *)comment
{
    NSInteger index = [_comments indexOfObject:comment];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
    [_comments removeObject:comment];
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self reloadData];
}

-(void)replyView:(BBReplyCommentView *)replyView mask:(UIView *)mask didDeleteComment:(Comment *)comment
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除评论" message:@"是否删除此评论？" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //不论成败，先本地删除
        [self deleteRowForComment:comment];
        
        //调用删除接口
        NSDictionary *params = @{@"cid": comment.idstr};
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
    
    UITabBarController *uitbc = (UITabBarController *)self.window.rootViewController;
    [uitbc.selectedViewController presentViewController:alertController animated:YES completion:^{}];
}

@end
