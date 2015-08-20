//
//  BBReplyCommentView.h
//  Bobo
//
//  Created by Boris Chow on 8/18/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBReplyCommentView : UIView

@property (strong, nonatomic) UIButton *replyBtn;
@property (strong, nonatomic) UIButton *repostBtn;
@property (strong, nonatomic) UIButton *cancelBtn;

@property (copy, nonatomic) NSString *idStr;
@property (copy, nonatomic) NSString *cidStr;

-(instancetype)initWithFrame:(CGRect)frame mask:(UIView *)mask;

@end
