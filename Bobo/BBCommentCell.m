//
//  BBCommentCell.m
//  Bobo
//
//  Created by Zhouboli on 15/7/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBCommentCell.h"

#define cAvatarHeight 40
#define cAvatarWidth cAvatarHeight
#define cLabelHeight 20
#define cLabelWidth [UIScreen mainScreen].bounds.size.width * 0.7
#define cBigGap 10
#define cSmallGap 5

@implementation BBCommentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

-(void)initCellLayout
{
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(cBigGap, cBigGap, cAvatarWidth, cAvatarHeight)];
    _avatarView.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:_avatarView];
    
    
}

@end
