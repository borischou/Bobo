//
//  BBFriendsGroupTableViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/8/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBFriendsGroupTableViewController.h"

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
            [cell.textLabel setText:@"朋友圈"];
            break;
        case 1:
            [cell.textLabel setText:@"所有"];
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
