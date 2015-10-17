//
//  BBUpdateStatusView.h
//  Bobo
//
//  Created by Zhouboli on 15/8/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "Comment.h"

@interface BBUpdateStatusView : UIView

@property (strong, nonatomic) UILabel *todoLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *sendBtn;
@property (strong, nonatomic) UITextView *statusTextView;
@property (strong, nonatomic) Status *status;
@property (strong, nonatomic) Comment *comment;
@property (strong, nonatomic) NSMutableArray *pickedOnes;

-(instancetype)initWithFlag:(NSInteger)flag; //0-发微博; 1-写评论; 2-转发; 3-回复评论

@end
