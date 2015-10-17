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

static NSString *filename = @"draft";
static NSString *filepath = @"draft.plist";

@interface BBDraftboxTableViewController ()

@property (strong, nonatomic) NSMutableArray *drafts;

@end

@implementation BBDraftboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[BBDraftboxTableViewCell class] forCellReuseIdentifier:reuseId];
    _drafts = [self readDraftsFromPlist];
    if (_drafts && _drafts.count > 0) {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers

-(NSMutableArray *)readDraftsFromPlist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [cachesDirectory stringByAppendingPathComponent:filepath];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:plistPath]) {
        return nil;
    }
    NSDictionary *draftDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableArray *drafts = @[].mutableCopy;
    NSArray *draftArray = draftDict[@"draft"];
    for (NSDictionary *tmp_draft in draftArray) {
        [drafts addObject:[[Draft alloc] initWithDictionary:tmp_draft]];
    }
    return drafts;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _drafts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBDraftboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    Draft *draft = _drafts[indexPath.row];
    cell.draft = draft;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_drafts.count > 0) {
        Draft *draft = _drafts[indexPath.row];
        return draft.height;
    } else return 0;
}

@end
