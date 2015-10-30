//
//  BBDraftboxTableViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/10/12.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBDraftboxTableViewController.h"
#import "BBDraftboxTableViewCell.h"
#import "Draft.h"
#import "Utils.h"
#import "BBUpdateStatusView.h"
#import "AppDelegate.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define uSmallGap 5
#define uBigGap 10

static NSString *reuseId = @"draftcell";
static NSString *filepath = @"draft.plist";

@interface BBDraftboxTableViewController () <BBDraftboxTableViewCellDelegate, BBUpdateStatusViewDelegate>

@property (strong, nonatomic) NSMutableArray *drafts;

@end

@implementation BBDraftboxTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[BBDraftboxTableViewCell class] forCellReuseIdentifier:reuseId];
    _drafts = [self readDraftsFromPlist];
    if (_drafts && _drafts.count > 0)
    {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
    NSLog(@"让圣光净化一切！");
    [Utils clearImageCache];
    [Utils clearDiskImages];
}

#pragma mark - Helpers

-(NSMutableArray *)readDraftsFromPlist
{
    NSString *plistPath = [Utils plistPathForFilename:filepath];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:plistPath])
    {
        return nil;
    }
    NSDictionary *draftDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableArray *drafts = @[].mutableCopy;
    NSArray *draftArray = draftDict[@"draft"];
    for (NSDictionary *tmp_draft in draftArray)
    {
        [drafts addObject:[[Draft alloc] initWithDictionary:tmp_draft]];
    }
    return drafts;
}

#pragma mark - Table view data source & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _drafts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBDraftboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    Draft *draft = _drafts[indexPath.row];
    cell.draft = draft;
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_drafts.count > 0)
    {
        Draft *draft = _drafts[indexPath.row];
        return draft.height;
    } else return 0;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //向左侧滑后点击删除按钮即触发此回调方法
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *plistPath = [Utils plistPathForFilename:filepath];
        
        //取出原数据
        NSMutableDictionary *drafts = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        NSMutableArray *array = drafts[@"draft"];
        
        //删除对应子数据
        Draft *draft = _drafts[indexPath.row];
        [array removeObject:[draft convertToDictionary]];
        
        //将新数据重新覆盖写入文件
        BOOL flag = [drafts writeToFile:plistPath atomically:YES];
        NSLog(@"写入结果：%@", flag? @"成功": @"失败");
        if (flag)
        {
            [_drafts removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBDraftboxTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    AppDelegate *delegate = [AppDelegate delegate];
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:cell.draft.draftType]; //0: 发微博
    updateStatusView.delegate = self;
    updateStatusView.draft = cell.draft;
    [delegate.window addSubview:updateStatusView];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        updateStatusView.frame = CGRectMake(uSmallGap, statusBarHeight+uSmallGap, bWidth-2*uSmallGap, bHeight/2-5);
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {}];
}

#pragma mark - BBDraftboxTableViewCellDelegate & support

-(void)tableViewCell:(BBDraftboxTableViewCell *)cell didPressResendButton:(UIButton *)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ACAccount *weiboAccount = [[AppDelegate delegate] defaultAccount];
        NSDictionary *cellParams = cell.draft.params;
        NSDictionary *params = nil;
        switch (cell.draft.draftType)
        {
            case 0: //发微博
            {
                if (cell.draft.images.count == 1)
                { //有一张配图
                    NSData *imgData = cell.draft.images.firstObject;
                    params = @{@"status": cell.draft.text};
                    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.weibo.com/2/statuses/upload.json"] parameters:params];
                    [request setAccount:weiboAccount];
                    
                    //必须指定一个filename的字符串，可以是任意字符串，但必须有，原因未知。
                    [request addMultipartData:imgData withName:@"pic" type:@"multipart/form-data" filename:@"pic"];
                    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        NSString *notificationText = nil;
                        if (!error)
                        {
                            notificationText = @"微博发布成功";
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                                [self tableViewCell:cell shouldDeleteDraftAtIndexPath:indexPath];
                            });
                        }
                        else
                        {
                            NSLog(@"发布失败：%@", error);
                            notificationText = [NSString stringWithFormat:@"微博发布失败: %@", error];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [Utils presentNotificationWithText:notificationText];
                        });
                    }];
                }
                else if (cell.draft.images.count > 1)
                {
                    //有多张配图
                }
                else
                { //无配图
                    params = @{@"status": cell.draft.text};
                    [Utils weiboPostRequestWithAccount:weiboAccount URL:@"statuses/update.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        NSString *notificationText = nil;
                        if (!error)
                        {
                            if (urlResponse.statusCode < 300 && urlResponse.statusCode > 0)
                            {
                                notificationText = @"微博发布成功";
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                                    [self tableViewCell:cell shouldDeleteDraftAtIndexPath:indexPath];
                                });
                            }
                            else
                            {
                                notificationText = @"微博发布失败";
                            }
                        }
                        else
                        {
                            NSLog(@"发布失败：%@", error);
                            notificationText = [NSString stringWithFormat:@"微博发布失败: %@", error];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [Utils presentNotificationWithText:notificationText];
                        });
                    }];
                }
            }
                break;
            case 1: //写评论
            {
                params = @{@"comment": cell.draft.text,
                           @"id": cellParams[@"id"],
                           @"comment_ori": cellParams[@"comment_ori"]};
                [Utils weiboPostRequestWithAccount:weiboAccount URL:@"comments/create.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *notificationText = nil;
                    if (!error)
                    {
                        NSLog(@"发布成功。");
                        notificationText = @"评论发布成功";
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                            [self tableViewCell:cell shouldDeleteDraftAtIndexPath:indexPath];
                        });
                    }
                    if (error)
                    {
                        NSLog(@"发布失败：%@", error);
                        notificationText = [NSString stringWithFormat:@"评论发布失败: %@", error];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Utils presentNotificationWithText:notificationText];
                    });
                }];
            }
                break;
            case 2: //转发微博
            {
                params = @{@"status": cell.draft.text,
                           @"id": cellParams[@"id"],
                           @"is_comment": cellParams[@"is_comment"]};
                [Utils weiboPostRequestWithAccount:weiboAccount URL:@"statuses/repost.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *notificationText = nil;
                    if (!error)
                    {
                        notificationText = @"转发发布成功";
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                            [self tableViewCell:cell shouldDeleteDraftAtIndexPath:indexPath];
                        });
                    }
                    else
                    {
                        NSLog(@"发布失败：%@", error);
                        notificationText = [NSString stringWithFormat:@"转发发布失败: %@", error];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Utils presentNotificationWithText:notificationText];
                    });
                }];
            }
                break;
            case 3: //回复评论
            {
                params = @{@"comment": cell.draft.text,
                           @"id": cellParams[@"id"],
                           @"cid": cellParams[@"cid"],
                           @"comment_ori": cellParams[@"comment_ori"]};
                [Utils weiboPostRequestWithAccount:weiboAccount URL:@"comments/reply.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *notificationText = nil;
                    if (!error)
                    {
                        notificationText = @"评论发布成功";
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                            [self tableViewCell:cell shouldDeleteDraftAtIndexPath:indexPath];
                        });
                    }
                    else
                    {
                        NSLog(@"发布失败：%@", error);
                        notificationText = [NSString stringWithFormat:@"评论发布失败: %@", error];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Utils presentNotificationWithText:notificationText];
                    });
                }];
            }
                break;
        }
    });
}

-(void)tableViewCell:(BBDraftboxTableViewCell *)cell shouldDeleteDraftAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *plistPath = [Utils plistPathForFilename:filepath];
    
    //取出原数据
    NSMutableDictionary *drafts = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableArray *array = drafts[@"draft"];
    
    //删除对应子数据
    [array removeObject:[cell.draft convertToDictionary]];
    
    //将新数据重新覆盖写入文件
    BOOL flag = [drafts writeToFile:plistPath atomically:YES];
    NSLog(@"写入结果：%@", flag? @"成功": @"失败");
    if (flag)
    {
        [_drafts removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - BBUpdateStatusViewDelegate

-(void)updateStatusView:(BBUpdateStatusView *)updateStatusView shouldDeleteDraftAt:(NSString *)time
{
    NSString *plistPath = [Utils plistPathForFilename:filepath];
    
    //取出原数据
    NSMutableDictionary *drafts = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableArray *array = drafts[@"draft"];
    
    NSInteger index;
    for (int i = 0; i < array.count; i ++)
    {
        NSDictionary *dict = array[i];
        if ([dict[@"time"] isEqualToString:time])
        {
            index = i;
            break;
        }
    }
    Draft *draft = _drafts[index];
    [array removeObject:[draft convertToDictionary]];
    
    //将新数据重新覆盖写入文件
    BOOL flag = [drafts writeToFile:plistPath atomically:YES];
    NSLog(@"写入结果：%@", flag? @"成功": @"失败");
    if (flag)
    {
        [_drafts removeObjectAtIndex:index];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
