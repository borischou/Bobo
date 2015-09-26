//
//  BBUpdateStatusView.h
//  Bobo
//
//  Created by Zhouboli on 15/8/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBUpdateStatusView;
@protocol BBUpdateStatusViewDelegate <NSObject>

-(void)updateView:(BBUpdateStatusView *)updateView didTapTodoLabel:(UILabel *)todoLabel;
-(void)updateView:(BBUpdateStatusView *)updateView mask:(UIView *)mask didPressCancelButton:(UIButton *)sender;
-(void)updateView:(BBUpdateStatusView *)updateView didPressSendButton:(UIButton *)sender;
-(void)updateView:(BBUpdateStatusView *)updateView didPressSelectPictureButton:(UIButton *)sender;
-(void)updateView:(BBUpdateStatusView *)updateView didPressTriggerCameraButton:(UIButton *)sender;

@end

@interface BBUpdateStatusView : UIView

@property (weak, nonatomic) id <BBUpdateStatusViewDelegate> delegate;

@property (strong, nonatomic) UILabel *todoLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *sendBtn;
@property (strong, nonatomic) UITextView *statusTextView;
@property (copy, nonatomic) NSString *idStr; //当前微博id
@property (copy, nonatomic) NSString *cidStr; //评论时评论cid
@property (copy, nonatomic) NSMutableArray *pickedOnes;

-(instancetype)initWithFlag:(int)flag;

@end
