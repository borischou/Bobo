//
//  BBUpdateBackgroundViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/8/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBUpdateBackgroundViewController.h"
#import "AppDelegate.h"
#import "CStatus.h"
#import "Status.h"

@implementation BBUpdateBackgroundViewController

-(void)viewDidLoad
{
    self.view.backgroundColor = [UIColor clearColor];
    self.view.alpha = 0.0;
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *context = appDelegate.managedObjectContext;
//    for (int i = 0; i < 10; i ++) {
//        CStatus *status = [NSEntityDescription insertNewObjectForEntityForName:@"CStatus" inManagedObjectContext:context];
//        status.idstr = @"testID";
//    }
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CStatus"];
//    NSError *error = nil;
//    NSArray *statuses = [context executeFetchRequest:request error:&error];
//    Status *fetchedStatus = [statuses firstObject];
//    NSLog(@"STATUS: %ld %@", statuses.count, fetchedStatus.idstr);
}

@end
