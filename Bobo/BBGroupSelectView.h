//
//  BBGroupSelectView.h
//  Bobo
//
//  Created by Zhouboli on 15/9/30.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBGroupSelectView;
@protocol BBGroupSelectViewDelegate <NSObject>

-(void)groupView:(BBGroupSelectView *)groupView didSelectGroupAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface BBGroupSelectView : UIView

@property (weak, nonatomic) id <BBGroupSelectViewDelegate> delegate;

@property (copy, nonatomic) NSArray *groups;

-(void)maskViewTapped;

@end
