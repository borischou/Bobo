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

@interface BBSettingsTableViewController ()

@end

@implementation BBSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setBackgroundColor:bCellBGColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setTextColor:[UIColor customGray]];
    [cell.textLabel setText:@"草稿箱"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        BBDraftboxTableViewController *dbtvc = [[BBDraftboxTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [dbtvc setTitle:@"Draftbox"];
        [Utils setupNavigationController:nil withUIViewController:dbtvc];
        [self.navigationController pushViewController:dbtvc animated:YES];
    }
}

@end
