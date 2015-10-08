//
//  BBListTableViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/10/8.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBListTableViewController.h"

@interface BBListTableViewController ()

@end

@implementation BBListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

@end
