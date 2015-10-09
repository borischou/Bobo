//
//  BBProfileMenuHeaderView.h
//  Bobo
//
//  Created by Boris Chow on 10/2/15.
//  Copyright © 2015 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, menuButtonIndex) {
    menuButtonIndexAll,
    menuButtonIndexOriginals,
    menuButtonIndexAlbum
};

@protocol BBProfileMenuHeaderViewDelegate <NSObject>

-(void)didClickMenuButtonAtIndex:(NSInteger)index;

@end

@interface BBProfileMenuHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) id <BBProfileMenuHeaderViewDelegate> delegate;

-(void)moveLineAccordingToFlag:(NSInteger)flag; //0-All; 1-Origin; 2-Album
-(instancetype)initWithFrame:(CGRect)frame flag:(NSInteger)flag;

@end
