//
//  BBCommentBarView.h
//  Bobo
//
//  Created by Zhouboli on 15/8/20.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBCommentBarViewDelegate <NSObject>

-(void)didTappedPlaceholderLabel;

@end

@interface BBCommentBarView : UIView

@property (weak, nonatomic) id <BBCommentBarViewDelegate> delegate;

@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *sendBtn;
@property (strong, nonatomic) UILabel *holderLabel;

-(instancetype)initWithFrame:(CGRect)frame shouldLabelShown:(BOOL)isShown;

@end
