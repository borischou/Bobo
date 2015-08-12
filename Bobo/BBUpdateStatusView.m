//
//  BBUpdateStatusView.m
//  Bobo
//
//  Created by Zhouboli on 15/8/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBUpdateStatusView.h"
#import "UIButton+Bobtn.h"

#define uSmallGap 5
#define uBigGap 10
#define uBtnHeight 20
#define uBtnWidth 50

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]

@interface BBUpdateStatusView ()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *sendBtn;
@property (strong, nonatomic) UITextView *statusTextView;

@end

@implementation BBUpdateStatusView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViewLayout];
    }
    return self;
}

-(void)setupViewLayout
{
    self.backgroundColor = bBGColor;
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(uBigGap, uBigGap, uBtnWidth, uBtnHeight) andTitle:@"取消" withBackgroundColor:nil andTintColor:nil];
    [self addSubview:_cancelBtn];
    
    _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-uBigGap-uBtnWidth, uBigGap, uBtnWidth, uBtnHeight) andTitle:@"发送" withBackgroundColor:nil andTintColor:nil];
    [self addSubview:_sendBtn];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/2, uBtnHeight)];
    _nameLabel.center = CGPointMake(self.frame.size.width/2, uSmallGap+uBtnHeight/2);
    [self addSubview:_nameLabel];
    
    _statusTextView = [[UITextView alloc] initWithFrame:CGRectMake(uBigGap, uBigGap+uBtnHeight+uBigGap, self.frame.size.width-2*uBigGap, self.frame.size.height-uBigGap*3-uBtnHeight)];
    [self addSubview:_statusTextView];
}

@end




































