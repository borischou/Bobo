//
//  BBWBDetailsTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/7/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBWBDetailsTableVC.h"
#import "BBHomelistTableViewCell.h"
#import "BBNetworkUtils.h"

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

@interface BBWBDetailsTableVC ()

@end

@implementation BBWBDetailsTableVC

static NSString *reuseWBCell = @"reuseWBCell";

#pragma mark - Lazy boys

-(Status *)status
{
    if (!_status) {
        _status = [[Status alloc] init];
    }
    return _status;
}

-(User *)user
{
    if (!_user) {
        _user = [[User alloc] init];
    }
    return _user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = bBGColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _status.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[BBHomelistTableViewCell class] forCellReuseIdentifier:reuseWBCell];
    BBHomelistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseWBCell forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.status = _status;
    //avatar
    if (_status.user.avatar != nil) {
        cell.avatarView.image = _status.user.avatar;
    } else {
        cell.avatarView.image = [UIImage imageNamed:@"timeline_image_loading"];
        [BBNetworkUtils fetchAvatarForStatus:_status withCell:cell];
    }
    
    //status images
    for (int i = 0; i < [cell.status.pic_urls count]; i ++) {
        if (![[_status.images objectAtIndex:i] isEqual:[NSNull null]]) {
            [[cell.statusImgViews objectAtIndex:i] setImage:[_status.images objectAtIndex:i]];
        } else {
            [cell.statusImgViews[i] setImage:[UIImage imageNamed:@"timeline_image_loading"]];
            [BBNetworkUtils fetchImageFromUrl:[_status.pic_urls objectAtIndex:i] atIndex:i forImages:_status.images withViews:cell.statusImgViews];
        }
    }
    
    //retweeted_status images
    for (int i = 0; i < [cell.status.retweeted_status.pic_urls count]; i ++) {
        if (![[_status.retweeted_status.images objectAtIndex:i] isEqual:[NSNull null]]) {
            [[cell.imgViews objectAtIndex:i] setImage:[_status.retweeted_status.images objectAtIndex:i]];
        } else {
            [cell.imgViews[i] setImage:[UIImage imageNamed:@"timeline_image_loading"]];
            [BBNetworkUtils fetchImageFromUrl:[_status.retweeted_status.pic_urls objectAtIndex:i] atIndex:i forImages:_status.retweeted_status.images withViews:cell.imgViews];
        }
    }
    
    return cell;
}

@end
