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
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapCommentIcon:(UIImageView *)commentIcon
{
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:updateStatusTypeComment]; //写评论
    updateStatusView.status = cell.status;
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:updateStatusView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        updateStatusView.frame = CGRectMake(uSmallGap, statusBarHeight+uSmallGap, bWidth-2*uSmallGap, bHeight/2-5);
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {}];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapFavoriteIcon:(UIImageView *)favoriteIcon
{
    favoriteIcon.userInteractionEnabled = NO;
    
    if (cell.status.favorited)
    {
        [favoriteIcon setImage:[UIImage imageNamed:@"fav_icon_3"]];
        NSDictionary *params = @{@"id": cell.status.idstr};
        [Utils weiboPostRequestWithAccount:[[AppDelegate delegate] defaultAccount] URL:@"favorites/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
        {
            if (!error)
            {
                NSLog(@"response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                [cell.status setFavorited:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    favoriteIcon.userInteractionEnabled = YES;
                    [Utils presentNotificationWithText:@"删除成功"];
                });
            }
            else
            {
                NSLog(@"收藏删除失败: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    favoriteIcon.userInteractionEnabled = YES;
                    [Utils presentNotificationWithText:@"删除失败"];
                });
            }
        }];
    }
    else
    {
        [favoriteIcon setImage:[UIImage imageNamed:@"faved_icon"]];
        NSDictionary *params = @{@"id": cell.status.idstr};
        [Utils weiboPostRequestWithAccount:[[AppDelegate delegate] defaultAccount] URL:@"favorites/create.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
        {
            if (!error)
            {
                NSLog(@"response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                [cell.status setFavorited:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    favoriteIcon.userInteractionEnabled = YES;
                    [Utils presentNotificationWithText:@"收藏成功"];
                });
            }
            else
            {
                NSLog(@"收藏失败: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    favoriteIcon.userInteractionEnabled = YES;
                    [Utils presentNotificationWithText:@"收藏失败"];
                });
            }
        }];
    }
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetIcon:(UIImageView *)retweetIcon
{
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:updateStatusTypeRepost]; //转发
    updateStatusView.status = cell.status;
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
    sender.enabled = NO;
    
    //delete the status
    AppDelegate *delegate = [AppDelegate delegate];
    if ([cell.status.user.idstr isEqualToString:delegate.user.idstr])
    {
        UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"删除微博" message:@"是否删除此微博？" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
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
                        sender.enabled = YES;
                        [Utils presentNotificationWithText:@"删除失败"];
                    });
                }
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
        {
            //取消
            sender.enabled = YES;
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
    [self setImageBrowserWithImageUrls:largeUrls tappedViewTag:tap.view.tag];
}

-(void)tableViewCell:(BBStatusTableViewCell *)cell didTapRetweetPicture:(UITapGestureRecognizer *)tap
{
    NSMutableArray *largeUrls = @[].mutableCopy;
    for (NSString *str in cell.status.retweeted_status.pic_urls)
    {
        [largeUrls addObject:[NSString middlePictureUrlConvertedFromThumbUrl:str]];
    }
    [self setImageBrowserWithImageUrls:largeUrls tappedViewTag:tap.view.tag];
}

-(void)setImageBrowserWithImageUrls:(NSMutableArray *)urls tappedViewTag:(NSInteger)tag
{
    BBImageBrowserView *browserView = [[BBImageBrowserView alloc] initWithFrame:[UIScreen mainScreen].bounds imageUrls:urls imageTag:tag];
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:browserView];
}

#pragma mark - BBCountTableViewCellDelegate

-(void)tableViewCell:(BBCountTableViewCell *)cell didTapTodoImageView:(UITapGestureRecognizer *)tap
{
    UIImageView *imageView = (UIImageView *)tap.view;
    imageView.userInteractionEnabled = NO;
    
    AppDelegate *delegate = [AppDelegate delegate];
    ACAccount *account = [delegate defaultAccount];
    
    if ([imageView.image isEqual:[NSNull null]] || imageView.image == nil)
    {
        //do nothing
    }
    
    if ([imageView.image isEqual:[UIImage imageNamed:@"settings_icon"]])
    {
        NSLog(@"settings");
        imageView.userInteractionEnabled = YES;
        //个人设置
        BBSettingsTableViewController *stvc = [[BBSettingsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [stvc setTitle:@"Settings"];
        stvc.hidesBottomBarWhenPushed = YES;
        [Utils setupNavigationController:nil withUIViewController:stvc];
        [self.navigationController pushViewController:stvc animated:YES];
    }
    
    if ([imageView.image isEqual:[UIImage imageNamed:@"following_icon"]]
        || [imageView.image isEqual:[UIImage imageNamed:@"friend_icon"]])
    {
        if ([delegate.user.idstr isEqualToString:cell.user.idstr])
        {
            return;
        }
        NSLog(@"following");
        //取关
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"取消关注" message:@"您是否确定取消关注此用户？" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消关注" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSDictionary *params = @{@"uid": self.user.idstr};
            [Utils weiboPostRequestWithAccount:account URL:@"friendships/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (!error)
                {
                    NSLog(@"success");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.userInteractionEnabled = YES;
                        [self.user setFollowing:NO];
                        [Utils presentNotificationWithText:@"成功取关"];
                        [cell setNeedsLayout];
                    });
                }
                else
                {
                    NSLog(@"error: %@", error);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.userInteractionEnabled = YES;
                        [Utils presentNotificationWithText:@"取关失败"];
                    });
                }
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"继续关注" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
        {
            imageView.userInteractionEnabled = YES;
        }];
        [alertController addAction:action];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:^{}];
    }
    
    if ([imageView.image isEqual:[UIImage imageNamed:@"follow_icon"]])
    {
        if ([delegate.user.idstr isEqualToString:cell.user.idstr] || [delegate.uid isEqualToString:cell.user.idstr])
        {
            return;
        }
        NSLog(@"follow");
        //关注
        NSDictionary *params = @{@"uid": self.user.idstr? self.user.idstr: @""};
        [Utils weiboPostRequestWithAccount:account URL:@"friendships/create.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
        {
            if (!error)
            {
                NSLog(@"success");
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.userInteractionEnabled = YES;
                    [self.user setFollowing:YES];
                    [Utils presentNotificationWithText:@"关注成功"];
                    [cell setNeedsLayout];
                });
            }
            else
            {
                NSLog(@"error: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.userInteractionEnabled = YES;
                    [Utils presentNotificationWithText:@"关注失败"];
                });
            }
        }];
    }
}

-(void)tableViewCell:(BBCountTableViewCell *)cell didTapFollowerCountLabel:(UITapGestureRecognizer *)tap
{
    //跳转获取粉丝数列表
    BBListTableViewController *ltvc = [[BBListTableViewController alloc] initWithStyle:UITableViewStylePlain listType:listTypeFollower];
    ltvc.hidesBottomBarWhenPushed = YES;
    ltvc.user = self.user;
    [self.navigationController pushViewController:ltvc animated:YES];
}

-(void)tableViewCell:(BBCountTableViewCell *)cell didTapFollowingCountLabel:(UITapGestureRecognizer *)tap
{
    //跳转获取关注列表
    BBListTableViewController *ltvc = [[BBListTableViewController alloc] initWithStyle:UITableViewStylePlain listType:listTypeFollowing];
    ltvc.hidesBottomBarWhenPushed = YES;
    ltvc.user = self.user;
    [self.navigationController pushViewController:ltvc animated:YES];
}

-(void)tableViewCell:(BBCountTableViewCell *)cell didTapWeiboCountLabel:(UITapGestureRecognizer *)tap
{
    //刷新个人微博列表
    [self.tableView.header beginRefreshing];
}

@end
