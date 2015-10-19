//
//  AppDelegate.h
//  Bobo
//
//  Created by Zhouboli on 15/6/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) User *user;
@property (copy, nonatomic) NSString *uid;
@property (strong, nonatomic) ACAccount *weiboAccount;

-(ACAccount *)defaultAccount;
-(void)accessWeiboSystemAccount;
+(id)delegate;

@end