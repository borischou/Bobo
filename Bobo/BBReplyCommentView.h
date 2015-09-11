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
@property (strong, nonatomic) UIButton *viewStatusBtn;
@property (strong, nonatomic) UIButton *deleteBtn;

@property (copy, nonatomic) NSString *idStr;
@property (copy, nonatomic) NSString *cidStr;

@property (nonatomic) BOOL shouldShowViewStatusOption;
@property (nonatomic) BOOL shouldShowDeleteOption;

@end
