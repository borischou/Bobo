//
//  BBReplyCommentView.m
//  Bobo
//
//  Created by Boris Chow on 8/18/15.
//  Copyright (c) 2015 Zhouboli. All rights reserved.
//

#import "BBReplyCommentView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@implementation BBReplyCommentView

-(instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, bHeight-60, bWidth, 60)];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        [self setupButtonLayout];
    }
    return self;
}

-(void)setupButtonLayout
{
    _replyBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/3)];
    [_replyBtn setTitle:@"回复" forState:UIControlStateNormal];
    [_replyBtn addTarget:self action:@selector(replyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_replyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_replyBtn];
    
    _repostBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height/3, self.frame.size.width, self.frame.size.height/3)];
    [_repostBtn setTitle:@"转发" forState:UIControlStateNormal];
    [_repostBtn addTarget:self action:@selector(repostButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_repostBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_repostBtn];
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height*2/3, self.frame.size.width, self.frame.size.height/3)];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:_cancelBtn];
}

-(void)replyButtonPressed
{
    NSLog(@"replyButtonPressed");
}

-(void)repostButtonPressed
{
    NSLog(@"repostButtonPressed");
}

-(void)cancelButtonPressed
{
    NSLog(@"cancelButtonPressed");
}

@end
