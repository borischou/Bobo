//
//  AppDelegate.h
//  Bobo
//
//  Created by Zhouboli on 15/6/11.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SWRevealViewController.h"
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) SWRevealViewController *revealViewController;
@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) NSString *wbToken;
@property (copy, nonatomic) NSString *wbCurrentUserID;
@property (strong, nonatomic) User *user;
@property BOOL isLoggedIn;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end