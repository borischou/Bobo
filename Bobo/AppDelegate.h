//
//  AppDelegate.h
//  Bobo
//
//  Created by Zhouboli on 15/6/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) SWRevealViewController *revealViewController;
@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) NSString *wbToken;
@property (copy, nonatomic) NSString *wbCurrentUserID;
@property BOOL isLoggedIn;

@end