//
//  BBCountCell.m
//  Bobo
//
//  Created by Zhouboli on 15/6/24.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBCountTableViewCell.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define bCountCellHeight bHeight/10
#define bCountSmallCellWidth (bWidth-2)/3
#define bNumPartHeight bCountCellHeight*0.618 //golden ratio
#define bTextPartHeight bCountCellHeight*0.382

#define bAvatarWidth 45
#define bAvatarHeight bAvatarWidth
#define bNicknameWidth [UIScreen mainScreen].bounds.size.width/2
#define bNicknameHeight 20
#define bPostTimeWidth bNicknameWidth
#define bPostTimeHeight 20
#define bTopPadding 10.0
#define bPostImgHeight [UIScreen mainScreen].bounds.size.width/6
#define bPostImgWidth bPostImgHeight
#define bTextFontSize 14.f
#define bSmallGap 5
#define bBigGap 10
#define bRetweetBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bImgBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]
#define bCellBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

@interface BBCountTableViewCell ()

@end

@implementation BBCountTableViewCell

-(NSMutableArray *)views
{
    if (!_views) {
        _views = @[].mutableCopy;
    }
    return _views;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = bCellBGColor;
        [self initCountLayout];
    }
    return self;
}

-(void)initCountLayout
{
    //number part
    self.wbcounts = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bCountSmallCellWidth, bNumPartHeight)];
    self.friendcounts = [[UILabel alloc] initWithFrame:CGRectMake(bCountSmallCellWidth+1, 0, bCountSmallCellWidth, bNumPartHeight)];
    self.followercounts = [[UILabel alloc] initWithFrame:CGRectMake(bCountSmallCellWidth*2+2, 0, bCountSmallCellWidth, bNumPartHeight)];
    [self initCellLabel:self.wbcounts];
    [self initCellLabel:self.friendcounts];
    [self initCellLabel:self.followercounts];
    
    //text part
    UILabel *wbTextLbl = nil;
    [self initCellLabel:wbTextLbl withFrame:CGRectMake(0, bNumPartHeight, bCountSmallCellWidth, bTextPartHeight) andTitle:@"Bobo" withFontSize:13.f];
    UILabel *followTextLbl = nil;
    [self initCellLabel:followTextLbl withFrame:CGRectMake(bCountSmallCellWidth+1, bNumPartHeight, bCountSmallCellWidth, bTextPartHeight) andTitle:@"Follows" withFontSize:13.f];
    
    UILabel *followerTextLbl = nil;
    [self initCellLabel:followerTextLbl withFrame:CGRectMake(bCountSmallCellWidth*2+2, bNumPartHeight, bCountSmallCellWidth, bTextPartHeight) andTitle:@"Followers" withFontSize:13.f];
}

-(void)initCellLabel:(UILabel *)label
{
    label.text = @"0";
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:label];
}

-(void)initCellLabel:(UILabel *)label withFrame:(CGRect)frame andTitle:(NSString *)title withFontSize:(CGFloat)size
{
    label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.attributedText = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:size]}];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:label];
}

@end
