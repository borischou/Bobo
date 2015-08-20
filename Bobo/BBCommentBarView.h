//
//  BBCommentBarView.h
//  Bobo
//
//  Created by Zhouboli on 15/8/20.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"

@interface BBCommentBarView : UIView

@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *sendBtn;
@property (strong, nonatomic) UILabel *holderLabel;
@property (strong, nonatomic) Status *status;

-(instancetype)initWithFrame:(CGRect)frame status:(Status *)status;

@end
