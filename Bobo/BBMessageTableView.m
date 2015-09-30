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

@interface BBMessageTableView () <UITableViewDataSource, UITableViewDelegate, BBMessageTableViewCellDelegate, TTTAttributedLabelDelegate>

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
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:replyView];
    replyView.shouldShowViewStatusOption = YES;
    CGRect replyRect;
    if ([comment.status.user.idstr isEqualToString:delegate.user.idstr]) {
        replyView.shouldShowDeleteOption = YES;
        replyRect = CGRectMake(0, bHeight-50*5, bWidth, 50*5);
    } else {
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
         BBMessageViewController *mvc = (BBMessageViewController *)self.nextResponder.nextResponder.nextResponder;
         
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
    BBMessageViewController *mvc = (BBMessageViewController *)self.nextResponder.nextResponder.nextResponder;
    
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
        [mvc.navigationController presentViewController:sfvc animated:YES completion:^{}];
    }
    if ([hotword hasPrefix:@"#"]) {
        //热门话题
    }
}

@end
