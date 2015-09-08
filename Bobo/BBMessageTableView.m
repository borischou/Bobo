//
//  BBMessageTableView.m
//  Bobo
//
//  Created by Zhouboli on 15/9/2.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBMessageTableView.h"
#import "BBMessageTableViewCell.h"

#define bBGColor [UIColor colorWithRed:30.f/255 green:30.f/255 blue:30.f/255 alpha:1.f]

static NSString *messageCell = @"messageCell";

@interface BBMessageTableView () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation BBMessageTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = bBGColor;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        _comments = @[].mutableCopy;
        self.dataSource = self;
        self.delegate = self;
        [self registerClass:[BBMessageTableViewCell class] forCellReuseIdentifier:messageCell];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _comments.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [_comments objectAtIndex:indexPath.row];
    return comment.heightForMessageCell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCell forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_comments.count > 0) {
        Comment *comment = [_comments objectAtIndex:indexPath.row];
        cell.comment = comment;
    }
    return cell;
}

@end
