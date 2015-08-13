//
//  BBKeyboardInputAccessoryView.m
//  Bobo
//
//  Created by Zhouboli on 15/8/13.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBKeyboardInputAccessoryView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define kBtnWidth bWidth/4
#define kBtnHeight self.bounds.size.height

@interface BBKeyboardInputAccessoryView ()

@end

@implementation BBKeyboardInputAccessoryView

-(instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, bWidth, 50)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupAccessoryButtons];
    }
    return self;
}

-(void)setupAccessoryButtons
{
    _addPictureBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    _addPictureBtn.backgroundColor = [UIColor redColor];
    [self addSubview:_addPictureBtn];
    
    _callCameraBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    _callCameraBtn.backgroundColor = [UIColor blueColor];
    [self addSubview:_callCameraBtn];
    
    [_addPictureBtn setFrame:CGRectMake(0, 0, kBtnWidth, kBtnHeight)];
    [_callCameraBtn setFrame:CGRectMake(kBtnWidth, 0, kBtnWidth, kBtnHeight)];
}

@end
