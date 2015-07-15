//
//  BBBaiduCustomPaopaoVC.h
//  Bobo
//
//  Created by Zhouboli on 15/7/15.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBPaopaoViewDelegate <NSObject>

@optional
-(void)pushToAddressView;

@end

@interface BBBaiduCustomPaopaoVC : UIViewController

@property (weak, nonatomic) id <BBPaopaoViewDelegate> delegate;

@property (copy, nonatomic) NSString *address;
@property (strong, nonatomic) UILabel *addrLbl;

@end
