//
//  BBStatusDetailViewController+Reply.m
//  Bobo
//
//  Created by Zhouboli on 15/10/29.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBStatusDetailViewController+Reply.h"

@implementation BBStatusDetailViewController (Reply)

#pragma mark - BBReplyCommentViewDelegate & support

-(void)deleteRowForData:(id)data
{
    NSInteger index;
    NSIndexPath *indexPath;
    if ([data isKindOfClass:[Comment class]])
    {
        index = [self.comments indexOfObject:data];
        indexPath = [NSIndexPath indexPathForRow:index inSection:1];
        [self.comments removeObject:data];
    }
    if ([data isKindOfClass:[Status class]])
    {
        index = [self.statuses indexOfObject:data];
        indexPath = [NSIndexPath indexPathForRow:index inSection:1];
        [self.statuses removeObject:data];
    }
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
}

-(void)replyView:(BBReplyCommentView *)replyView mask:(UIView *)mask didDeleteStatus:(Status *)status
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除微博" message:@"是否删除此微博？" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        [self deleteRowForData:status];
        NSDictionary *params = @{@"id": status.idstr};
        [Utils weiboPostRequestWithAccount:self.weiboAccount URL:@"statuses/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
        {
            if (!error)
            {
                NSLog(@"response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                dispatch_async(dispatch_get_main_queue(), ^{
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
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
    {
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

-(void)replyView:(BBReplyCommentView *)replyView mask:(UIView *)mask didDeleteComment:(Comment *)comment
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除评论" message:@"是否删除此评论？" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        //不管成败，先本地删除
        [self deleteRowForData:comment];
        
        //调用删除接口
        NSDictionary *params = @{@"cid": comment.idstr? comment.idstr: @""};
        [Utils weiboPostRequestWithAccount:[[AppDelegate delegate] defaultAccount] URL:@"comments/destroy.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
        {
            NSString *notificationText = nil;
            if (!error)
            {
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
                }
                                 completion:^(BOOL finished)
                 {
                    if (finished)
                    {
                        [Utils presentNotificationWithText:notificationText];
                        [mask removeFromSuperview];
                        [replyView removeFromSuperview];
                    }
                }];
            });
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
    {
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
    [self.comments insertObject:comment atIndex:0];
    [self.tableView reloadData];
    [replyView removeFromSuperview];
}

@end
