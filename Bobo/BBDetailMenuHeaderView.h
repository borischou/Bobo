//
//  BBDetailMenuHeaderView.h
//  Bobo
//
//  Created by Zhouboli on 15/10/29.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, detailMenuButtonIndex)
{
    detailMenuButtonIndexRepost,
    detailMenuButtonIndexComment
};

@protocol BBDetailMenuHeaderViewDelegate <NSObject>

-(void)didClickMenuButtonAtIndex:(NSInteger)index;

@end

@interface BBDetailMenuHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) id <BBDetailMenuHeaderViewDelegate> delegate;

-(void)moveLineAccordingToFlag:(NSInteger)flag; //0-Repost, 1-Comment
-(instancetype)initWithFrame:(CGRect)frame flag:(NSInteger)flag;

@end
