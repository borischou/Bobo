//
//  BBNotificationView.m
//  Bobo
//
//  Created by Boris Chow on 8/31/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import "BBNotificationView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

@interface BBNotificationView ()

@end

@implementation BBNotificationView

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, -statusBarHeight*2, bWidth, statusBarHeight*2)];
        [self setupNotificationView];
    }
    return self;
}

-(instancetype)initWithNotification:(NSString *)text
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, -statusBarHeight*2, bWidth, statusBarHeight*2)];
        [self setupNotificationViewWithText:text];
    }
    return self;
}

-(void)setupNotificationView
{
    self.backgroundColor = [UIColor blueColor];
    
    _notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, statusBarHeight, bWidth, statusBarHeight)];
    _notificationLabel.textAlignment = NSTextAlignmentCenter;
    _notificationLabel.numberOfLines = 1;
    _notificationLabel.font = [UIFont systemFontOfSize:12.0];
    _notificationLabel.textColor = [UIColor whiteColor];
    [self addSubview:_notificationLabel];
}

-(void)setupNotificationViewWithText:(NSString *)text
{
    [self setupNotificationView];
    _notificationLabel.text = text;
}

@end
