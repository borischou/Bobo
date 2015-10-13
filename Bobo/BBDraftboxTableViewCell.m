//
//  BBDraftboxTableViewCell.m
//  Bobo
//
//  Created by Zhouboli on 15/10/12.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBDraftboxTableViewCell.h"

static CGFloat dSmallGap = 5;
static CGFloat dBigGap = 10;

@interface BBDraftboxTableViewCell ()

@property (strong, nonatomic) UIButton *resendButton; //重新发送按钮
@property (strong, nonatomic) UILabel *type; //草稿类型
@property (strong, nonatomic) UILabel *content; //草稿内容
@property (strong, nonatomic) UILabel *time; //草稿保存时间
@property (strong, nonatomic) UIImageView *preview; //草稿第一张附图预览(如果有)

//转发草稿
@property (strong, nonatomic) UILabel *repostContent; //原微博文本

@end

@implementation BBDraftboxTableViewCell

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
        
    }
    return self;
}

-(void)setupSubviews
{
    
}

@end
