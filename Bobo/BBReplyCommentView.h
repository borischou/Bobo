//
//  BBReplyCommentView.h
//  Bobo
//
//  Created by Boris Chow on 8/18/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface BBReplyCommentView : UIView

@property (strong, nonatomic) UIButton *replyBtn;
@property (strong, nonatomic) UIButton *repostBtn;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *viewStatusBtn;
@property (strong, nonatomic) UIButton *deleteBtn;

@property (nonatomic) BOOL shouldShowViewStatusOption;
@property (nonatomic) BOOL shouldShowDeleteOption;

@property (strong, nonatomic) Comment *comment;

@end
