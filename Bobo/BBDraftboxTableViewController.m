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
#import "BBUpdateStatusView.h"
#import "AppDelegate.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define uSmallGap 5
#define uBigGap 10

static NSString *reuseId = @"draftcell";

static NSString *filename = @"draft";
static NSString *filepath = @"draft.plist";

@interface BBDraftboxTableViewController () <BBDraftboxTableViewCellDelegate>

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

#pragma mark - Table view data source & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _drafts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBDraftboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    Draft *draft = _drafts[indexPath.row];
    cell.draft = draft;
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_drafts.count > 0) {
        Draft *draft = _drafts[indexPath.row];
        return draft.height;
    } else return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBDraftboxTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    AppDelegate *delegate = [AppDelegate delegate];
    BBUpdateStatusView *updateStatusView = [[BBUpdateStatusView alloc] initWithFlag:cell.draft.draftType]; //0: 发微博
    NSDictionary *params = cell.draft.params;
    switch (cell.draft.draftType) {
        case DraftTypeOriginal:
            [updateStatusView.nameLabel setText:@"微博草稿"];
            [updateStatusView.statusTextView setText:cell.draft.text];
            [updateStatusView.todoLabel setHidden:YES];
            if (cell.draft.images.count > 0) {
                updateStatusView.pickedOnes = @[].mutableCopy;
                for (NSData *image in cell.draft.images) {
                    [updateStatusView.pickedOnes addObject:image];
                }
            }
            break;
        case DraftTypeComment:
            [updateStatusView.nameLabel setText:@"评论草稿"];
            [updateStatusView.statusTextView setText:cell.draft.text];
            [updateStatusView.todoLabel setHidden:NO];
            [updateStatusView.todoLabel setTextColor:[params[@"comment_ori"] boolValue]? [UIColor greenColor]: [UIColor lightTextColor]];
            break;
        case DraftTypeRepost:
            [updateStatusView.nameLabel setText:@"转发草稿"];
            [updateStatusView.statusTextView setText:cell.draft.text];
            [updateStatusView.todoLabel setHidden:NO];
            [updateStatusView.todoLabel setTextColor:[params[@"is_comment"] boolValue]? [UIColor greenColor]: [UIColor lightTextColor]];
            break;
        case DraftTypeReply:
            [updateStatusView.nameLabel setText:@"回复草稿"];
            [updateStatusView.statusTextView setText:cell.draft.text];
            [updateStatusView.todoLabel setHidden:NO];
            [updateStatusView.todoLabel setTextColor:[params[@"comment_ori"] boolValue]? [UIColor greenColor]: [UIColor lightTextColor]];
            break;
            
        default:
            break;
    }
    [delegate.window addSubview:updateStatusView];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        updateStatusView.frame = CGRectMake(uSmallGap, statusBarHeight+uSmallGap, bWidth-2*uSmallGap, bHeight/2-5);
        [updateStatusView.statusTextView becomeFirstResponder];
    } completion:^(BOOL finished) {}];
}

#pragma mark - BBDraftboxTableViewCellDelegate

-(void)tableViewCell:(BBDraftboxTableViewCell *)cell didPressResendButton:(UIButton *)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    });
}

@end
