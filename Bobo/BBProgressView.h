//
//  BBProgressView.h
//  Bobo
//
//  Created by Zhouboli on 15/10/28.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBProgressView : UIView

@property (strong, nonatomic) UIColor *centerColor;
@property (strong, nonatomic) UIColor *arcBackColor;
@property (strong, nonatomic) UIColor *arcFinishColor;
@property (strong, nonatomic) UIColor *arcUnfinishColor;

@property (assign, nonatomic) float percent;
@property (assign, nonatomic) float width;

-(void)setPercent:(float)percent;

@end
