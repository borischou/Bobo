//
//  BBProfileMenuHeaderView.h
//  Bobo
//
//  Created by Boris Chow on 10/2/15.
//  Copyright © 2015 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

#define buttonWidth self.frame.size.width/3
#define buttonHeight self.frame.size.height

#define menuColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

typedef NS_ENUM(NSInteger, menuButtonIndex)
{
    menuButtonIndexAll,
    menuButtonIndexOriginals,
    menuButtonIndexAlbum
};

@protocol BBProfileMenuHeaderViewDelegate <NSObject>

-(void)didClickMenuButtonAtIndex:(NSInteger)index;

@end

//此处继承UITableViewHeaderFooterView则可以通过发送footerViewForSection:/headerViewForSection:来获取对应对象
@interface BBProfileMenuHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) id <BBProfileMenuHeaderViewDelegate> delegate;

-(void)moveLineAccordingToFlag:(NSInteger)flag; //0-All; 1-Origin; 2-Album
-(instancetype)initWithFrame:(CGRect)frame flag:(NSInteger)flag;

@end
