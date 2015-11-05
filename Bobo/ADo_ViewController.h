//
//  ADo_ViewController.h
//  ADo_GuideView
//
//  Created by dwx on 15/5/1.
//  Copyright (c) 2015年 Nododo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ADo_ViewController;
@protocol ADoViewControllerDelegate <NSObject>

@optional
-(void)guideViewController:(ADo_ViewController *)adoViewController didTransitionToMainApp:(UIButton *)sender;

@end

@class LPFRoundScroll;

@interface ADo_ViewController : UIViewController

@property (nonatomic, assign) id<ADoViewControllerDelegate> delegate; // 设置代理

@end
