//
//  BBAvatarCell.m
//  Bobo
//
//  Created by Zhouboli on 15/6/22.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBAvatarCell.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bAvatarWidth 50
#define bAvatarHeight bAvatarWidth
#define bSmallGap 5
#define bBigGap 10
#define bRetweetBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bImgBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bCellBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

@implementation BBAvatarCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initLayout];
    }
    return self;
}

-(void)initLayout
{
    self.contentView.backgroundColor = bCellBGColor;

    self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(bSmallGap, bSmallGap, bAvatarWidth, bAvatarHeight)];
    self.avatarView.backgroundColor = bImgBGColor;
    [self.contentView addSubview:self.avatarView];
    
    self.nicknameLbl = [[UILabel alloc] initWithFrame:CGRectMake(bSmallGap + bAvatarWidth + bSmallGap, bSmallGap, bWidth/2, bAvatarHeight/2)];
    self.nicknameLbl.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.nicknameLbl];
    
    self.introductionLbl = [[UILabel alloc] initWithFrame:CGRectMake(bSmallGap + bAvatarWidth + bSmallGap, bSmallGap + bAvatarHeight/2 + bSmallGap, bWidth/2, bAvatarHeight/2)];
    self.introductionLbl.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:self.introductionLbl];
}

@end
