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

static NSString *reuseId = @"draftcell";

@interface BBDraftboxTableViewController ()

@property (strong, nonatomic) NSMutableArray *drafts;

@end

@implementation BBDraftboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[BBDraftboxTableViewCell class] forCellReuseIdentifier:reuseId];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _drafts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBDraftboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    Draft *draft = _drafts[indexPath.row];
    cell.draft = draft;
    return cell;
}

@end
