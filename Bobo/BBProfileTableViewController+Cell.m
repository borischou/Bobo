//
//  BBProfileTableViewController+Cell.m
//  Bobo
//
//  Created by Zhouboli on 15/10/28.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBProfileTableViewController+Cell.h"

//#define bWidth [UIScreen mainScreen].bounds.size.width
//#define bHeight [UIScreen mainScreen].bounds.size.height
//#define bBtnHeight bHeight/25
//#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
//#define uSmallGap 5
//#define uBigGap 10

@implementation BBProfileTableViewController (Cell)

#pragma mark - BBStatusTableViewCellDelegate & support

//个人页无需重复进入个人页
-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapAvatar:(UIImageView *)avatar
{
    return;
    //    NSLog(@"didTapAvatar");
    //    NSDictionary *params = @{@"uid": cell.status.user.idstr};
    //    [Utils genericWeiboRequestWithAccount:[[AppDelegate delegate] defaultAccount]
    //                                      URL:@"statuses/user_timeline.json"
    //                      SLRequestHTTPMethod:SLRequestMethodGET
    //                               parameters:params
    //               completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    //     {
    //         NSMutableArray *statuses = [Utils statusesWith:responseObject];
    //         Status *status = statuses.firstObject;
    //         User *user = status.user;
    //
    //         BBProfileTableViewController *profiletvc = [[BBProfileTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    //         profiletvc.uid = user.idstr;
    //         profiletvc.statuses = statuses;
    //         profiletvc.user = user;
    //         profiletvc.shouldNavBtnShown = NO;
    //         profiletvc.title = @"Profile";
    //         profiletvc.hidesBottomBarWhenPushed = YES;
    //         [Utils setupNavigationController:self.navigationController withUIViewController:profiletvc];
    //         [self.navigationController pushViewController:profiletvc animated:YES];
    //     }
    //               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
    //     {
    //         NSLog(@"error %@", error);
    //         dispatch_async(dispatch_get_main_queue(), ^{
    //             [Utils presentNotificationWithText:@"访问失败"];
    //         });
    //     }];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapCommentIcon:(UIImageView *)commentIcon
{
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:1]; //写评论
    updateStatusView.status = cell.status;
    //updateStatusView.nameLabel.text = cell.status.user.screen_name;
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:updateStatusView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        updateStatusView.frame = CGRectMake(uSmallGap, statusBarHeight+uSmallGap, bWidth-2*uSmallGap, bHeight/2-5);
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {}];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapFavoriteIcon:(UIImageView *)favoriteIcon
{
    if (cell.status.favorited)
    {
        [favoriteIcon setImage:[UIImage imageNamed:@"fav_icon_3"]];
        NSDictionary *params = @{@"id": cell.status.idstr};
        [Utils weiboPostRequestWithAccount:[[AppDelegate delegate] defaultAccount] URL:@"favorites/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error)
            {
                NSLog(@"response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                [cell.status setFavorited:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utils presentNotificationWithText:@"删除成功"];
                });
            }
            else
            {
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
            if (!error)
            {
                NSLog(@"response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                [cell.status setFavorited:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utils presentNotificationWithText:@"收藏成功"];
                });
            }
            else
            {
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
//    if (cell.status.retweeted_status.text.length > 0)
//    {
//        updateStatusView.statusTextView.text = [NSString stringWithFormat:@"//@%@:%@", cell.status.user.screen_name, cell.status.text];
//    }
    //updateStatusView.statusTextView.selectedRange = NSMakeRange(0, 0); //光标起始位置
    //updateStatusView.nameLabel.text = @"转发";
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
    if ([cell.status.user.idstr isEqualToString:delegate.user.idstr])
    {
        UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"删除微博" message:@"是否删除此微博？" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSDictionary *params = @{@"id": cell.status.idstr};
            [Utils weiboPostRequestWithAccount:self.weiboAccount URL:@"statuses/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (!error) {
                    NSLog(@"response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                        if (self.statuses[indexPath.section-1])
                        {
                            [self.statuses removeObjectAtIndex:indexPath.section-1];
                        }
                        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                        [Utils presentNotificationWithText:@"删除成功"];
                    });
                }
                else
                {
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
    for (NSString *str in cell.status.pic_urls)
    {
        [largeUrls addObject:[NSString middlePictureUrlConvertedFromThumbUrl:str]];
    }
    [self setImageBrowserWithImageUrls:largeUrls andTappedViewTag:tap.view.tag];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetPicture:(UITapGestureRecognizer *)tap
{
    NSMutableArray *largeUrls = @[].mutableCopy;
    for (NSString *str in cell.status.retweeted_status.pic_urls)
    {
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

@end
