//
//  BBNotificationView.h
//  Bobo
//
//  Created by Boris Chow on 8/31/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBNotificationView : UIView

@property (strong, nonatomic) UILabel *notificationLabel;

-(instancetype)initWithNotification:(NSString *)text;

@end
