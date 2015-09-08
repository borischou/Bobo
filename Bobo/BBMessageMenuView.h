//
//  BBMessageMenuView.h
//  Bobo
//
//  Created by Zhouboli on 15/9/8.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBMessageMenuViewDelegate <NSObject>

-(void)didClickMenuButtonAtIndex:(NSInteger)index;

@end

@interface BBMessageMenuView : UIView

@property (weak, nonatomic) id <BBMessageMenuViewDelegate> delegate;

-(void)moveLineAccordingToFlag:(NSInteger)flag; //0-收到的评论; 1-发出的评论; 2-@我的评论; 3-所有的评论

@end
