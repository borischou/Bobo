//
//  BBUpdateStatusView.h
//  Bobo
//
//  Created by Zhouboli on 15/8/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBUpdateStatusViewDelegate <NSObject>

@required
-(void)updateStatusDidFinishInput:(NSString *)text;

@end

@interface BBUpdateStatusView : UIView

@property (weak, nonatomic) id <BBUpdateStatusViewDelegate> delegate;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *sendBtn;
@property (strong, nonatomic) UITextView *statusTextView;

@end
