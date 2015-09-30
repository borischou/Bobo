//
//  BBFriendsGroupTableViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/8/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBFriendsGroupTableViewController.h"
#import "BBMainStatusTableViewController.h"
#import "Utils.h"

typedef NS_ENUM(NSInteger, GroupType) {
    GroupTypeHomeTimeline, //所有关注人微博
    GroupTypeBilateralTimeline, //朋友圈微博
};

@interface BBFriendsGroupTableViewController ()

@property (nonatomic) NSInteger presentedRow;

@end

@implementation BBFriendsGroupTableViewController

#pragma mark - Controller life cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Helpers

#pragma mark - UITableViewDelegate & datasource & helpers

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            [cell.textLabel setText:@"所有微博"];
            break;
        case 1:
            [cell.textLabel setText:@"朋友微博"];
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWRevealViewController *revealController = self.revealViewController;
    BBMainStatusTableViewController *mstvc = [[BBMainStatusTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    if (indexPath.row == _presentedRow) {
        [revealController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        return;
    }
    if (indexPath.row == 0) {
        mstvc.groupNumber = GroupTypeBilateralTimeline;
    }
    if (indexPath.row == 1) {
        mstvc.groupNumber = GroupTypeBilateralTimeline;
    }
    UINavigationController *uinvc = [[UINavigationController alloc] initWithRootViewController:mstvc];
    [Utils setupNavigationController:uinvc withUIViewController:mstvc];
    [revealController pushFrontViewController:uinvc animated:YES];
    
    _presentedRow = indexPath.row;
}

@end
