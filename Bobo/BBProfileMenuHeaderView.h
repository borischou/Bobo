//
//  BBProfileMenuHeaderView.h
//  Bobo
//
//  Created by Boris Chow on 10/2/15.
//  Copyright © 2015 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBProfileMenuHeaderViewDelegate <NSObject>

-(void)didClickMenuButtonAtIndex:(NSInteger)index;

@end

@interface BBProfileMenuHeaderView : UIView

@property (weak, nonatomic) id <BBProfileMenuHeaderViewDelegate> delegate;

-(void)moveLineAccordingToFlag:(NSInteger)flag; //0-All; 1-Origin; 2-Album

@end
