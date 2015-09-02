//
//  BBMessageTableViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/9/2.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBMessageTableViewController.h"
#import "BBMessageTableView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@interface BBMessageTableViewController ()

@end

@implementation BBMessageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[BBMessageTableView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight) style:UITableViewStyleGrouped];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
