//
//  BBUberCarTableViewCell.m
//  Bobo
//
//  Created by Zhouboli on 15/7/9.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBUberCarTableViewCell.h"

#define bCellBGColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]
#define bImgBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define carImgWidth 100
#define carImgHeight carImgWidth
#define labelHeight 20
#define labelWidth bWidth/2

@implementation BBUberCarTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setCellView];
    }
    return self;
}

-(void)setCellView
{
    self.backgroundColor = bCellBGColor;
    _carImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, carImgWidth, carImgWidth)];
    _carImgView.backgroundColor = bImgBGColor;
    [self.contentView addSubview:_carImgView];
    
    _carType = [[UILabel alloc] initWithFrame:CGRectMake(carImgWidth + 3, 5, labelWidth, labelHeight)];
    _carType.textColor = [UIColor lightTextColor];
    [self.contentView addSubview:_carType];
    
    _estimatePrice = [[UILabel alloc] initWithFrame:CGRectMake(carImgWidth + 3, 5 + labelHeight + 5, labelWidth, labelHeight)];
    _estimatePrice.textColor = [UIColor lightTextColor];
    [self.contentView addSubview:_estimatePrice];
    
    _estimateDuration = [[UILabel alloc] initWithFrame:CGRectMake(carImgWidth + 3, 5 + labelHeight + 5 + labelHeight + 5, labelWidth, labelHeight)];
    _estimateDuration.textColor = [UIColor lightTextColor];
    [self.contentView addSubview:_estimateDuration];
    
    _distance = [[UILabel alloc] initWithFrame:CGRectMake(carImgWidth + 3, 5 * 4 + labelHeight * 3, labelWidth, labelHeight)];
    _distance.textColor = [UIColor lightTextColor];
    [self.contentView addSubview:_distance];
}

@end
