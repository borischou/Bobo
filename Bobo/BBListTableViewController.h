//
//  BBListTableViewController.h
//  Bobo
//
//  Created by Zhouboli on 15/10/8.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

typedef NS_ENUM(NSInteger, listType) {
    listTypeFollower,
    listTypeFollowing
};

@interface BBListTableViewController : UITableViewController

@property (strong, nonatomic) User *user;
-(instancetype)initWithStyle:(UITableViewStyle)style listType:(NSInteger)type;

@end
