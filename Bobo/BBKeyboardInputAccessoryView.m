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

#define kBtnWidth bWidth/8
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
    [_addPictureBtn setImage:[UIImage imageNamed:@"icon_album"] forState:UIControlStateNormal];
    [_addPictureBtn setImage:[UIImage imageNamed:@"icon_album_selected"] forState:UIControlStateHighlighted];
    [self addSubview:_addPictureBtn];
    
    _callCameraBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [_callCameraBtn setImage:[UIImage imageNamed:@"icon_camera"] forState:UIControlStateNormal];
    [_callCameraBtn setImage:[UIImage imageNamed:@"icon_camera_selected"] forState:UIControlStateHighlighted];
    [self addSubview:_callCameraBtn];
    
    [_addPictureBtn setFrame:CGRectMake(0, 0, kBtnWidth, kBtnHeight)];
    [_callCameraBtn setFrame:CGRectMake(kBtnWidth, 0, kBtnWidth, kBtnHeight)];
}

@end
