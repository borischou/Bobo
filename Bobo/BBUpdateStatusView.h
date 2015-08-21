//
//  BBUpdateStatusView.h
//  Bobo
//
//  Created by Zhouboli on 15/8/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBUpdateStatusView : UIView

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *sendBtn;
@property (strong, nonatomic) UITextView *statusTextView;
@property (copy, nonatomic) NSString *idStr; //当前微博id
@property (copy, nonatomic) NSString *cidStr; //评论时评论cid

@property (nonatomic) int flag; //0: 发微博 1: 评论 2: 转发 3: 回复

-(instancetype)initWithFlag:(int)flag;

@end
