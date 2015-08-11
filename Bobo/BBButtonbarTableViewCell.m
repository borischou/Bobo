//
//  BBButtonbarCell.m
//  Bobo
//
//  Created by Zhouboli on 15/6/18.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBButtonbarTableViewCell.h"
#import "UIButton+Bobtn.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bBtnBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]
#define bCellBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bBtnHeight bHeight/25
#define bBtnWidth (bWidth-2)/3

@implementation BBButtonbarTableViewCell

@synthesize repostBtn;
@synthesize commentBtn;
@synthesize likeBtn;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initCellLayout];
    }
    return self;
}

-(void)initCellLayout
{
    self.contentView.backgroundColor = bCellBGColor;
    repostBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, bBtnWidth, bBtnHeight) andTitle:@"Repost" withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
    [self.contentView addSubview:repostBtn];
    
    commentBtn = [[UIButton alloc] initWithFrame:CGRectMake(bBtnWidth+1, 0, bBtnWidth, bBtnHeight) andTitle:@"Comment" withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
    [self.contentView addSubview:commentBtn];
    
    likeBtn = [[UIButton alloc] initWithFrame:CGRectMake(bBtnWidth*2+2, 0, bBtnWidth, bBtnHeight) andTitle:@"Like" withBackgroundColor:bBtnBGColor andTintColor:[UIColor lightTextColor]];
    [self.contentView addSubview:likeBtn];
}

@end
