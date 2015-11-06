//
//  BBSettingsTableViewController.m
//  Bobo
//
//  Created by Boris Chow on 10/16/15.
//  Copyright © 2015 Zhouboli. All rights reserved.
//

#import "BBSettingsTableViewController.h"
#import "BBDraftboxTableViewController.h"
#import "UIColor+Custom.h"
#import "Utils.h"

#define bCellBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

static NSString *filepath = @"wbdata.plist";

@interface BBSettingsTableViewController ()

@end

@implementation BBSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source & support

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setBackgroundColor:bCellBGColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setTextColor:[UIColor customGray]];
    if (indexPath.section == 0)
    {
        [cell.textLabel setText:@"草稿箱"];
        [cell.imageView setImage:[UIImage imageNamed:@"draft_icon"]];
    }
    if (indexPath.section == 1)
    {
        [cell.textLabel setText:@"清除缓存"];
        [cell.imageView setImage:[UIImage imageNamed:@"cache_icon"]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        BBDraftboxTableViewController *dbtvc = [[BBDraftboxTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [dbtvc setTitle:@"Draftbox"];
        [Utils setupNavigationController:nil withUIViewController:dbtvc];
        [self.navigationController pushViewController:dbtvc animated:YES];
    }
    if (indexPath.section == 1)
    {
        NSString *plistPath = [Utils plistPathForFilename:filepath];
        //计算缓存大小并询问是否清除
        unsigned long long fileSize = [self fileSizeAtPath:plistPath];
        NSString *message = [NSString stringWithFormat:@"缓存大小为%.1fkb", fileSize/1000.0];
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"缓存" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *clearAction = [UIAlertAction actionWithTitle:@"清除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            //清除动作
            if ([self clearPlistFileAt:plistPath])
            {
                [Utils presentNotificationWithText:@"缓存已清除"];
            }
            else
            {
                [Utils presentNotificationWithText:@"缓存清除失败，请重试"];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //取消
        }];
        [ac addAction:clearAction];
        [ac addAction:cancelAction];
        [self.navigationController presentViewController:ac animated:YES completion:nil];
    }
}

-(BOOL)clearPlistFileAt:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path])
    {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *dict = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (![dict[@"statuses"] isEqual:[NSNull null]])
        {
            NSMutableDictionary *mDict = dict.mutableCopy;
            [mDict setValue:[NSNull null] forKey:@"statuses"];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mDict];
            BOOL flag = [data writeToFile:path atomically:YES];
            if (!flag)
            {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

-(unsigned long long)fileSizeAtPath:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path])
    {
        return [[manager attributesOfItemAtPath:path error:nil] fileSize];
    }
    return 0;
}

@end
